import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'ikev2_backend.dart';
import 'ikev2_config.dart';
import 'vpn_backend.dart';

/// IKEv2 do próprio Windows: uma ligação VPN do utilizador ("Lost the Game
/// IKEv2", aparece também no ícone de rede), sem administrador e sem nada
/// instalado.
///
/// O `rasdial` sozinho não consegue dar utilizador e palavra-passe a uma
/// ligação EAP (erro 703), por isso as credenciais vão primeiro para a
/// ligação com a API do EapHost (`EapHostPeerCredentialsXml2Blob` +
/// `RasSetEapUserData`) e só depois se marca.
class WindowsIkev2Backend implements Ikev2Backend {
  static const entryName = 'Lost the Game IKEv2';

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<VpnStatus> status() async {
    try {
      final result = await Process.run('rasdial.exe', const []);
      return parseRasdialStatus('${result.stdout}');
    } catch (_) {
      return VpnStatus.disconnected;
    }
  }

  @override
  Stream<VpnStatus> watch() =>
      pollVpnStatus(status, interval: const Duration(seconds: 3));

  @override
  Future<void> connect(Ikev2Config config) async {
    final script = await _scriptFile();
    final Process process;
    try {
      process = await Process.start('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        script.path,
      ]);
    } on ProcessException catch (e) {
      throw VpnException('Não foi possível abrir o PowerShell (${e.message}).');
    }

    // Pelo stdin e em base64: a palavra-passe nunca vai na linha de
    // comandos, que outros processos conseguem ler.
    final output = process.stdout.transform(utf8.decoder).join();
    final errors = process.stderr.transform(utf8.decoder).join();
    for (final value in [config.server, config.username, config.password]) {
      process.stdin.writeln(base64.encode(utf8.encode(value)));
    }
    await process.stdin.close();

    final exitCode = await process.exitCode.timeout(
      const Duration(seconds: 90),
      onTimeout: () {
        process.kill();
        return -1;
      },
    );
    final text = await output;
    await errors;
    if (exitCode == -1) {
      throw const VpnException('O Windows demorou demasiado a ligar a VPN.');
    }

    final result = parseConnectOutput(text);
    if (result.error != null) {
      throw VpnException('Não foi possível ligar: ${result.error}');
    }
    final code = result.code;
    if (code == null) {
      throw const VpnException('O Windows não respondeu ao pedido de ligação.');
    }
    if (code != 0) throw VpnException(ikev2ErrorMessage(code));
  }

  @override
  Future<void> disconnect() async {
    try {
      await Process.run('rasdial.exe', const [entryName, '/disconnect']);
    } catch (_) {
      // Já desligada ou sem a ligação: nada a fazer.
    }
  }

  @override
  Future<void> forget() async {
    await disconnect();
    try {
      await Process.run('powershell.exe', const [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        "Remove-VpnConnection -Name '$entryName' -Force "
            '-ErrorAction SilentlyContinue',
      ]);
    } catch (_) {
      // Fica a ligação no Windows; a próxima configuração substitui-a.
    }
  }

  static Future<File> _scriptFile() async {
    final support = await getApplicationSupportDirectory();
    final file = File('${support.path}${Platform.pathSeparator}vpn'
        '${Platform.pathSeparator}ikev2_connect.ps1');
    await file.parent.create(recursive: true);
    // Com BOM: o PowerShell 5.1 lê ficheiros sem BOM no código de páginas
    // ANSI.
    await file.writeAsString('﻿$_connectScript', flush: true);
    return file;
  }
}

/// O `rasdial` sem argumentos lista as ligações ativas, uma por linha (o
/// resto do texto vem na língua do Windows).
@visibleForTesting
VpnStatus parseRasdialStatus(String output) {
  final connected = const LineSplitter()
      .convert(output)
      .any((line) => line.trim() == WindowsIkev2Backend.entryName);
  return connected ? VpnStatus.connected : VpnStatus.disconnected;
}

@visibleForTesting
({int? code, String? error}) parseConnectOutput(String output) {
  int? code;
  String? error;
  for (final line in const LineSplitter().convert(output)) {
    final trimmed = line.trim();
    if (trimmed.startsWith('RESULT=')) code = int.tryParse(trimmed.substring(7));
    if (trimmed.startsWith('ERROR=')) error = trimmed.substring(6);
  }
  return (code: code, error: error);
}

/// Códigos do RAS (`rasdial` devolve-os como código de saída).
@visibleForTesting
String ikev2ErrorMessage(int code) => switch (code) {
  691 =>
    'Utilizador ou palavra-passe VPN errados. Usa as credenciais VPN da '
        'subscrição (na PureVPN, em Subscriptions), não o email e a '
        'palavra-passe da conta.',
  13801 || 13806 =>
    'O servidor apresentou um certificado que o Windows não aceita. '
        'Confirma o endereço do servidor.',
  809 || 800 =>
    'O servidor não respondeu. A rede pode estar a bloquear o IKEv2 '
        '(UDP 500 e 4500), ou o endereço está errado.',
  868 => 'Não foi possível encontrar o servidor. Confirma o endereço.',
  13868 => 'O servidor recusou as definições de segurança do IKEv2.',
  _ => 'Não foi possível ligar (erro $code do Windows).',
};

/// Lê do stdin (base64, uma linha cada) servidor, utilizador e palavra-passe;
/// escreve `RESULT=<código do rasdial>` ou `ERROR=<mensagem>`.
const _connectScript = r'''
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
function Read-Value { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String([Console]::In.ReadLine())) }
$server = Read-Value
$user = Read-Value
$pass = Read-Value
$name = 'Lost the Game IKEv2'
$pbk = Join-Path $env:APPDATA 'Microsoft\Network\Connections\Pbk\rasphone.pbk'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class LostTheGameEap {
  [StructLayout(LayoutKind.Sequential)]
  public struct EAP_TYPE { public byte type; public uint dwVendorId; public uint dwVendorType; }
  [StructLayout(LayoutKind.Sequential)]
  public struct EAP_METHOD_TYPE { public EAP_TYPE eapType; public uint dwAuthorId; }

  [DllImport("eappcfg.dll")]
  static extern uint EapHostPeerConfigXml2Blob(uint flags, IntPtr configDoc,
    out uint size, out IntPtr blob, out EAP_METHOD_TYPE type, out IntPtr eapError);
  [DllImport("eappcfg.dll")]
  static extern uint EapHostPeerCredentialsXml2Blob(uint flags, IntPtr credentialsDoc,
    uint sizeConfigIn, IntPtr configIn, out uint size, out IntPtr blob,
    out EAP_METHOD_TYPE type, out IntPtr eapError);
  [DllImport("eappcfg.dll")]
  static extern void EapHostPeerFreeMemory(IntPtr data);
  [DllImport("eappcfg.dll")]
  static extern void EapHostPeerFreeErrorMemory(IntPtr error);
  [DllImport("rasapi32.dll", CharSet = CharSet.Unicode)]
  static extern uint RasSetEapUserData(IntPtr token, string phonebook, string entry, IntPtr data, uint size);

  static IntPtr Node(string xml) {
    Type t = Type.GetTypeFromProgID("Msxml2.DOMDocument.6.0");
    object doc = Activator.CreateInstance(t);
    t.InvokeMember("async", System.Reflection.BindingFlags.SetProperty, null, doc, new object[] { false });
    object ok = t.InvokeMember("loadXML", System.Reflection.BindingFlags.InvokeMethod, null, doc, new object[] { xml });
    if (!(bool)ok) throw new Exception("XML inválido");
    IntPtr unk = Marshal.GetIUnknownForObject(doc);
    Guid iid = new Guid("2933BF80-7B36-11d2-B20E-00C04F983E60"); // IXMLDOMNode
    IntPtr node;
    int hr = Marshal.QueryInterface(unk, ref iid, out node);
    Marshal.Release(unk);
    if (hr != 0) throw new Exception("IXMLDOMNode " + hr);
    return node;
  }

  public static string Set(string phonebook, string entry, string configXml, string user, string pass) {
    string credsXml =
      "<EapHostUserCredentials xmlns=\"http://www.microsoft.com/provisioning/EapHostUserCredentials\" " +
      "xmlns:eapCommon=\"http://www.microsoft.com/provisioning/EapCommon\" " +
      "xmlns:baseEap=\"http://www.microsoft.com/provisioning/BaseEapMethodUserCredentials\">" +
      "<EapMethod><eapCommon:Type>26</eapCommon:Type><eapCommon:AuthorId>0</eapCommon:AuthorId></EapMethod>" +
      "<Credentials xmlns:eapUser=\"http://www.microsoft.com/provisioning/EapUserPropertiesV1\" " +
      "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
      "xmlns:baseEap=\"http://www.microsoft.com/provisioning/BaseEapUserPropertiesV1\" " +
      "xmlns:MsChapV2=\"http://www.microsoft.com/provisioning/MsChapV2UserPropertiesV1\">" +
      "<baseEap:Eap><baseEap:Type>26</baseEap:Type><MsChapV2:EapType>" +
      "<MsChapV2:Username>" + System.Security.SecurityElement.Escape(user) + "</MsChapV2:Username>" +
      "<MsChapV2:Password>" + System.Security.SecurityElement.Escape(pass) + "</MsChapV2:Password>" +
      "<MsChapV2:LogonDomain></MsChapV2:LogonDomain>" +
      "</MsChapV2:EapType></baseEap:Eap></Credentials></EapHostUserCredentials>";

    uint cfgSize; IntPtr cfg; IntPtr err; EAP_METHOD_TYPE type;
    IntPtr cfgNode = Node(configXml);
    uint r = EapHostPeerConfigXml2Blob(0, cfgNode, out cfgSize, out cfg, out type, out err);
    Marshal.Release(cfgNode);
    if (r != 0) { if (err != IntPtr.Zero) EapHostPeerFreeErrorMemory(err); return "configuração EAP (" + r + ")"; }

    uint size; IntPtr blob;
    IntPtr credNode = Node(credsXml);
    r = EapHostPeerCredentialsXml2Blob(0, credNode, cfgSize, cfg, out size, out blob, out type, out err);
    Marshal.Release(credNode);
    EapHostPeerFreeMemory(cfg);
    if (r != 0) { if (err != IntPtr.Zero) EapHostPeerFreeErrorMemory(err); return "credenciais EAP (" + r + ")"; }

    uint s = RasSetEapUserData(IntPtr.Zero, phonebook, entry, blob, size);
    EapHostPeerFreeMemory(blob);
    return s == 0 ? "ok" : "guardar credenciais (" + s + ")";
  }
}
'@

try {
  $existing = Get-VpnConnection -Name $name -ErrorAction SilentlyContinue
  if ($existing) {
    & rasdial.exe $name /disconnect | Out-Null
    Remove-VpnConnection -Name $name -Force
  }
  Add-VpnConnection -Name $name -ServerAddress $server -TunnelType Ikev2 `
    -EncryptionLevel Required -AuthenticationMethod Eap -SplitTunneling:$false -Force
  $config = (Get-VpnConnection -Name $name).EapConfigXmlStream.OuterXml
  $set = [LostTheGameEap]::Set($pbk, $name, $config, $user, $pass)
  if ($set -ne 'ok') { "ERROR=$set"; exit 0 }
  & rasdial.exe $name | Out-Null
  "RESULT=$LASTEXITCODE"
} catch {
  "ERROR=$($_.Exception.Message)"
}
''';
