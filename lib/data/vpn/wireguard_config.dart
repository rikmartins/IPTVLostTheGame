import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Diretivas do wg-quick que correm comandos do sistema. Num .conf vindo de
/// fora são um risco (no Windows o serviço corre como SYSTEM) e a app não
/// precisa delas: são removidas na importação.
const _scriptKeys = {'preup', 'postup', 'predown', 'postdown'};

/// Configuração WireGuard (.conf no formato wg-quick), validada.
@immutable
class WireGuardConfig {
  const WireGuardConfig._({
    required this.text,
    required this.addresses,
    required this.endpoint,
    required this.dns,
    required this.routesAllTraffic,
    required this.removedScripts,
  });

  /// Lança [FormatException] com uma mensagem pronta a mostrar.
  factory WireGuardConfig.parse(String raw) {
    final lines = const LineSplitter().convert(
      raw.replaceFirst('﻿', ''),
    );

    String? section;
    var interfaces = 0;
    var peers = 0;
    String? privateKey;
    final addresses = <String>[];
    final dns = <String>[];
    String? endpoint;
    String? publicKey;
    final allowedIps = <String>[];
    var removedScripts = false;
    final kept = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      final content = trimmed.split('#').first.trim();

      if (content.startsWith('[') && content.endsWith(']')) {
        section = content.substring(1, content.length - 1).trim().toLowerCase();
        if (section == 'interface') interfaces++;
        if (section == 'peer') peers++;
        kept.add(content);
        continue;
      }

      final separator = content.indexOf('=');
      if (content.isEmpty || separator <= 0) {
        if (trimmed.isEmpty || trimmed.startsWith('#')) kept.add(trimmed);
        continue;
      }

      final key = content.substring(0, separator).trim().toLowerCase();
      final value = content.substring(separator + 1).trim();

      if (_scriptKeys.contains(key)) {
        removedScripts = true;
        continue;
      }
      kept.add(content);

      List<String> list() => [
        for (final part in value.split(','))
          if (part.trim().isNotEmpty) part.trim(),
      ];

      switch ((section, key)) {
        case ('interface', 'privatekey'):
          privateKey = value;
        case ('interface', 'address'):
          addresses.addAll(list());
        case ('interface', 'dns'):
          dns.addAll(list());
        case ('peer', 'publickey'):
          publicKey ??= value;
        case ('peer', 'endpoint'):
          endpoint ??= value;
        case ('peer', 'allowedips'):
          allowedIps.addAll(list());
      }
    }

    if (interfaces != 1) {
      throw const FormatException(
        'Não é um ficheiro WireGuard válido: falta a secção [Interface].',
      );
    }
    if (peers == 0) {
      throw const FormatException('Falta a secção [Peer] com o servidor.');
    }
    if (!_isKey(privateKey)) {
      throw const FormatException('PrivateKey em falta ou inválida.');
    }
    if (addresses.isEmpty) {
      throw const FormatException('Address em falta na secção [Interface].');
    }
    if (!_isKey(publicKey)) {
      throw const FormatException('PublicKey do servidor em falta ou inválida.');
    }
    if (endpoint == null || !_isEndpoint(endpoint)) {
      throw const FormatException(
        'Endpoint do servidor em falta ou inválido (esperado anfitrião:porta).',
      );
    }
    if (allowedIps.isEmpty) {
      throw const FormatException('AllowedIPs em falta na secção [Peer].');
    }

    return WireGuardConfig._(
      text: '${kept.join('\n').trim()}\n',
      addresses: addresses,
      endpoint: endpoint,
      dns: dns,
      routesAllTraffic:
          allowedIps.contains('0.0.0.0/0') || allowedIps.contains('::/0'),
      removedScripts: removedScripts,
    );
  }

  /// O .conf já limpo (sem scripts, fins de linha `\n`): é isto que se
  /// guarda e se entrega ao WireGuard.
  final String text;

  final List<String> addresses;

  /// `anfitrião:porta` do servidor.
  final String endpoint;
  final List<String> dns;

  /// AllowedIPs inclui 0.0.0.0/0 ou ::/0 (todo o tráfego pelo túnel).
  final bool routesAllTraffic;

  /// Havia PreUp/PostUp/PreDown/PostDown, que foram removidos.
  final bool removedScripts;

  /// Chave WireGuard: base64 de 32 bytes.
  static bool _isKey(String? value) {
    if (value == null || value.length != 44) return false;
    try {
      return base64.decode(value).length == 32;
    } on FormatException {
      return false;
    }
  }

  /// `host:porta` ou `[ipv6]:porta`.
  static bool _isEndpoint(String value) {
    final colon = value.lastIndexOf(':');
    if (colon <= 0 || colon == value.length - 1) return false;
    final port = int.tryParse(value.substring(colon + 1));
    return port != null && port > 0 && port < 65536;
  }
}
