import 'dart:convert';

import 'package:xml/xml_events.dart';

class XmltvProgramme {
  const XmltvProgramme({
    required this.channelId,
    required this.start,
    required this.stop,
    required this.title,
    this.description,
  });

  /// Atributo `channel`, normalizado (trim + minúsculas).
  final String channelId;
  final DateTime start;
  final DateTime stop;
  final String title;
  final String? description;
}

enum _Field { none, title, desc }

/// Parser XMLTV orientado a eventos (SAX), em streaming.
///
/// Um `xmltv.php` pode ter centenas de MB; aqui nunca se constrói a árvore
/// DOM — só se guarda o `<programme>` atual até ao fecho da tag.
Stream<XmltvProgramme> parseXmltv(Stream<List<int>> bytes) async* {
  String? channel;
  DateTime? start;
  DateTime? stop;
  String? title;
  String? description;
  var inProgramme = false;
  var field = _Field.none;
  final text = StringBuffer();

  // `bind` e não `bytes.transform(...)`: o stream do Dio é Stream<Uint8List>
  // e o `transform` com um Utf8Decoder rebenta em runtime (variância de
  // genéricos).
  //
  // `normalizeEvents` junta o texto partido entre chunks de rede *antes* de
  // descodificar as entidades; sem isso um `&amp;` cortado em `&am`|`p;`
  // chegava literal ao título.
  final events = const Utf8Decoder(
    allowMalformed: true,
  ).bind(bytes).toXmlEvents().normalizeEvents();

  await for (final batch in events) {
    for (final event in batch) {
      switch (event) {
        case final XmlStartElementEvent e when e.name == 'programme':
          channel = _attribute(e, 'channel')?.trim().toLowerCase();
          start = parseXmltvDate(_attribute(e, 'start'));
          stop = parseXmltvDate(_attribute(e, 'stop'));
          title = null;
          description = null;
          inProgramme = !e.isSelfClosing;

        // Há fornecedores que repetem <title>/<desc> em várias línguas:
        // fica a primeira.
        case XmlStartElementEvent(name: 'title', isSelfClosing: false)
            when inProgramme && title == null:
          field = _Field.title;
          text.clear();

        case XmlStartElementEvent(name: 'desc', isSelfClosing: false)
            when inProgramme && description == null:
          field = _Field.desc;
          text.clear();

        case XmlTextEvent(:final value) when field != _Field.none:
          text.write(value);

        case XmlCDATAEvent(:final value) when field != _Field.none:
          text.write(value);

        case XmlEndElementEvent(name: 'title' || 'desc')
            when field != _Field.none:
          final value = text.toString().trim();
          if (value.isNotEmpty) {
            if (field == _Field.title) {
              title = value;
            } else {
              description = value;
            }
          }
          field = _Field.none;

        case XmlEndElementEvent(name: 'programme'):
          inProgramme = false;
          field = _Field.none;
          if (channel != null &&
              channel.isNotEmpty &&
              start != null &&
              stop != null &&
              title != null &&
              stop.isAfter(start)) {
            yield XmltvProgramme(
              channelId: channel,
              start: start,
              stop: stop,
              title: title,
              description: description,
            );
          }

        default:
          break;
      }
    }
  }
}

/// O `XmlStartElementEvent.getAttribute` só existe depois do xml 7.1.0.
/// Ciclo simples em vez de `where().firstOrNull`: corre 3 vezes por
/// programa, centenas de milhares de vezes por sincronização.
String? _attribute(XmlStartElementEvent event, String name) {
  for (final attribute in event.attributes) {
    if (attribute.localName == name) return attribute.value;
  }
  return null;
}

/// Datas XMLTV: `YYYYMMDDhhmmss ±hhmm`. Segundos, espaço e offset são
/// opcionais; sem offset assume-se UTC. Devolve sempre UTC.
///
/// Feito à mão (sem RegExp nem DateTime.parse) porque corre centenas de
/// milhares de vezes por sincronização.
DateTime? parseXmltvDate(String? value) {
  if (value == null) return null;
  final s = value.trim();
  if (s.length < 12) return null;

  final year = _digits(s, 0, 4);
  final month = _digits(s, 4, 2);
  final day = _digits(s, 6, 2);
  final hour = _digits(s, 8, 2);
  final minute = _digits(s, 10, 2);
  if (year < 0 || month < 0 || day < 0 || hour < 0 || minute < 0) return null;

  var i = 12;
  var second = 0;
  if (s.length >= 14 && _isDigit(s.codeUnitAt(12))) {
    second = _digits(s, 12, 2);
    if (second < 0) return null;
    i = 14;
  }

  var utc = DateTime.utc(year, month, day, hour, minute, second);

  while (i < s.length && s.codeUnitAt(i) == 0x20) {
    i++;
  }
  if (i < s.length) {
    final sign = s.codeUnitAt(i);
    if (sign == 0x2B || sign == 0x2D) {
      // +hhmm / -hhmm / +hh:mm
      final offsetHours = _digits(s, i + 1, 2);
      var minuteStart = i + 3;
      if (minuteStart < s.length && s.codeUnitAt(minuteStart) == 0x3A) {
        minuteStart++;
      }
      final offsetMinutes = _digits(s, minuteStart, 2);
      if (offsetHours >= 0 && offsetMinutes >= 0) {
        final offset = Duration(hours: offsetHours, minutes: offsetMinutes);
        // Hora local = UTC + offset, logo UTC = hora local - offset.
        utc = sign == 0x2B ? utc.subtract(offset) : utc.add(offset);
      }
    }
  }
  return utc;
}

bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

/// Inteiro em `s[start, start + length)`, ou -1 se não forem só dígitos.
int _digits(String s, int start, int length) {
  if (start + length > s.length) return -1;
  var result = 0;
  for (var i = start; i < start + length; i++) {
    final c = s.codeUnitAt(i);
    if (!_isDigit(c)) return -1;
    result = result * 10 + (c - 0x30);
  }
  return result;
}
