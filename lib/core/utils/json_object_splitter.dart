import 'dart:typed_data';

const _quote = 0x22; // "
const _backslash = 0x5C; // \
const _openBrace = 0x7B; // {
const _closeBrace = 0x7D; // }
const _openBracket = 0x5B; // [
const _closeBracket = 0x5D; // ]

/// Parte um stream de bytes JSON nos objetos que estão no primeiro nível do
/// documento, sem nunca o materializar inteiro em memória.
///
/// Funciona tanto para arrays (`[{...},{...}]`, o caso normal do Xtream)
/// como para objetos indexados (`{"1":{...},"2":{...}}`, que alguns painéis
/// devolvem). Valores que não são objetos são ignorados.
///
/// Com a resposta do `get_vod_streams` (que pode passar os 100 MB) o pico de
/// memória fica limitado a um chunk de rede mais um objeto, em vez do
/// documento inteiro mais a árvore de `Map`s resultante.
///
/// É seguro trabalhar byte a byte sobre UTF-8: os delimitadores estruturais
/// são ASCII e nenhum byte de um carácter multibyte cai nesse intervalo.
///
/// Cada [Uint8List] emitido pode ser uma *view* sobre o chunk original, por
/// isso deve ser consumido (decodificado) antes de pedir o seguinte.
Stream<Uint8List> splitJsonObjects(Stream<List<int>> source) async* {
  var depth = 0;
  var inString = false;
  var escaped = false;
  // Objeto que começou num chunk anterior e ainda não fechou.
  BytesBuilder? pending;

  await for (final chunk in source) {
    final bytes = chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
    var start = pending != null ? 0 : -1;

    for (var i = 0; i < bytes.length; i++) {
      final byte = bytes[i];

      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (byte == _backslash) {
          escaped = true;
        } else if (byte == _quote) {
          inString = false;
        }
        continue;
      }

      switch (byte) {
        case _quote:
          inString = true;
        case _openBrace:
          if (depth == 1) start = i;
          depth++;
        case _openBracket:
          depth++;
        case _closeBrace:
          depth--;
          if (depth == 1 && start >= 0) {
            final tail = Uint8List.sublistView(bytes, start, i + 1);
            if (pending != null) {
              pending.add(tail);
              yield pending.takeBytes();
              pending = null;
            } else {
              yield tail;
            }
            start = -1;
          }
        case _closeBracket:
          depth--;
      }
    }

    if (start >= 0) {
      (pending ??= BytesBuilder()).add(Uint8List.sublistView(bytes, start));
    }
  }
}
