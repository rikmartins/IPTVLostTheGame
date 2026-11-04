import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';

import 'vpn_backend.dart';
import 'wireguard_config.dart';

// Tem de coincidir com windows/runner/vpn_helper.cpp.
const _serviceName = 'LostTheGameVPN';

/// O WireGuard tira o nome do túnel (e do adaptador de rede) do nome do
/// ficheiro.
const _configFileName = 'LostTheGame.conf';

/// Windows: o túnel corre num serviço do sistema (o wireguard_svc.exe que
/// vem com o wireguard_flutter_plus), gerido daqui diretamente pelo Service
/// Control Manager.
///
/// O plugin, tal como está, exige a app inteira a correr como
/// administrador. Aqui só a instalação do serviço precisa disso: é feita
/// uma vez por um processo auxiliar elevado (a própria app com
/// `--vpn-install`, ver windows/runner/vpn_helper.cpp), que dá aos
/// utilizadores com sessão iniciada permissão para ligar e desligar o
/// serviço. Daí em diante não há UAC.
class WindowsVpnBackend implements VpnBackend {
  @override
  bool get isSupported => true;

  @override
  bool get supportsAppOnly => false;

  @override
  Future<VpnStatus> status() async => _queryStatus();

  @override
  Stream<VpnStatus> watch() async* {
    // O SCM não avisa mudanças sem uma thread à espera: chega consultar a
    // cada 2 s, é uma chamada local.
    VpnStatus? last;
    while (true) {
      final current = _queryStatus();
      if (current != last) yield last = current;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Future<void> connect(
    WireGuardConfig config, {
    required bool wholeDevice,
  }) async {
    final file = await _configFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(config.text, flush: true);

    if (!_serviceUsesConfig(file.path)) {
      final executable = Platform.resolvedExecutable;
      final configPath = file.path;
      // O ShellExecuteEx bloqueia até o utilizador responder ao UAC:
      // corre noutro isolate para não congelar a interface.
      final exitCode = await Isolate.run(
        () => _runElevatedInstall(executable, configPath),
      );
      if (exitCode == _cancelled) {
        throw const VpnException(
          'É preciso aceitar o pedido de administrador do Windows '
          '(só da primeira vez)',
        );
      }
      if (exitCode != 0) {
        throw VpnException(
          'Não foi possível instalar o serviço da VPN (código $exitCode)',
        );
      }
    }

    // A configuração pode ter mudado: reinicia se já estiver ligado.
    if (_queryStatus() != VpnStatus.disconnected) {
      _control(stop: true);
      await _waitFor(VpnStatus.disconnected);
    }
    _control(stop: false);
    final result = await _waitFor(VpnStatus.connected);
    if (result != VpnStatus.connected) {
      throw const VpnException(
        'A VPN não arrancou. Confirma o ficheiro .conf (chaves e endpoint).',
      );
    }
  }

  @override
  Future<void> disconnect() async {
    if (_queryStatus() == VpnStatus.disconnected) return;
    _control(stop: true);
    await _waitFor(VpnStatus.disconnected);
  }

  Future<File> _configFile() async {
    final support = await getApplicationSupportDirectory();
    final sep = Platform.pathSeparator;
    return File('${support.path}${sep}wireguard$sep$_configFileName');
  }

  /// Espera até [target] ou até o serviço parar (falha ao arrancar).
  Future<VpnStatus> _waitFor(VpnStatus target) async {
    var current = _queryStatus();
    for (var i = 0; i < 60 && current != target; i++) {
      if (target == VpnStatus.connected && i > 2 &&
          current == VpnStatus.disconnected) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
      current = _queryStatus();
    }
    return current;
  }
}

// --- Service Control Manager (advapi32) --------------------------------------

const _scManagerConnect = 0x0001;
const _serviceQueryConfig = 0x0001;
const _serviceQueryStatus = 0x0004;
const _serviceStart = 0x0010;
const _serviceStop = 0x0020;
const _serviceControlStop = 0x00000001;

const _stateStopped = 1;
const _stateStartPending = 2;
const _stateStopPending = 3;
const _stateRunning = 4;

final class _ServiceStatus extends Struct {
  @Uint32()
  external int serviceType;
  @Uint32()
  external int currentState;
  @Uint32()
  external int controlsAccepted;
  @Uint32()
  external int win32ExitCode;
  @Uint32()
  external int serviceSpecificExitCode;
  @Uint32()
  external int checkPoint;
  @Uint32()
  external int waitHint;
}

final class _QueryServiceConfig extends Struct {
  @Uint32()
  external int serviceType;
  @Uint32()
  external int startType;
  @Uint32()
  external int errorControl;
  external Pointer<Utf16> binaryPathName;
  external Pointer<Utf16> loadOrderGroup;
  @Uint32()
  external int tagId;
  external Pointer<Utf16> dependencies;
  external Pointer<Utf16> serviceStartName;
  external Pointer<Utf16> displayName;
}

final _advapi32 = DynamicLibrary.open('advapi32.dll');

final _openScManager = _advapi32
    .lookupFunction<
      Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Uint32),
      Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, int)
    >('OpenSCManagerW');

final _openService = _advapi32
    .lookupFunction<
      Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>, Uint32),
      Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>, int)
    >('OpenServiceW');

final _closeServiceHandle = _advapi32
    .lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>(
      'CloseServiceHandle',
    );

final _queryServiceStatus = _advapi32
    .lookupFunction<
      Int32 Function(Pointer<Void>, Pointer<_ServiceStatus>),
      int Function(Pointer<Void>, Pointer<_ServiceStatus>)
    >('QueryServiceStatus');

final _queryServiceConfig = _advapi32
    .lookupFunction<
      Int32 Function(Pointer<Void>, Pointer<Uint8>, Uint32, Pointer<Uint32>),
      int Function(Pointer<Void>, Pointer<Uint8>, int, Pointer<Uint32>)
    >('QueryServiceConfigW');

final _startService = _advapi32
    .lookupFunction<
      Int32 Function(Pointer<Void>, Uint32, Pointer<Pointer<Utf16>>),
      int Function(Pointer<Void>, int, Pointer<Pointer<Utf16>>)
    >('StartServiceW');

final _controlService = _advapi32
    .lookupFunction<
      Int32 Function(Pointer<Void>, Uint32, Pointer<_ServiceStatus>),
      int Function(Pointer<Void>, int, Pointer<_ServiceStatus>)
    >('ControlService');

/// Abre o serviço com [access] e passa-o a [body]. `null` se o serviço não
/// existir (ou não houver permissão).
T? _withService<T>(int access, T Function(Pointer<Void> service) body) {
  final manager = _openScManager(nullptr, nullptr, _scManagerConnect);
  if (manager == nullptr) return null;
  final name = _serviceName.toNativeUtf16();
  try {
    final service = _openService(manager, name, access);
    if (service == nullptr) return null;
    try {
      return body(service);
    } finally {
      _closeServiceHandle(service);
    }
  } finally {
    calloc.free(name);
    _closeServiceHandle(manager);
  }
}

VpnStatus _queryStatus() {
  final state = _withService(_serviceQueryStatus, (service) {
    final status = calloc<_ServiceStatus>();
    try {
      return _queryServiceStatus(service, status) != 0
          ? status.ref.currentState
          : null;
    } finally {
      calloc.free(status);
    }
  });
  return switch (state) {
    _stateRunning => VpnStatus.connected,
    _stateStartPending => VpnStatus.connecting,
    _stateStopPending => VpnStatus.disconnecting,
    _stateStopped || _ => VpnStatus.disconnected,
  };
}

/// O serviço existe e arranca o wireguard_svc com este ficheiro?
bool _serviceUsesConfig(String configPath) {
  final uses = _withService(_serviceQueryConfig, (service) {
    const size = 8192;
    final buffer = calloc<Uint8>(size);
    final needed = calloc<Uint32>();
    try {
      if (_queryServiceConfig(service, buffer, size, needed) == 0) {
        return false;
      }
      final config = buffer.cast<_QueryServiceConfig>().ref;
      final command = config.binaryPathName.toDartString().toLowerCase();
      return command.contains(configPath.toLowerCase());
    } finally {
      calloc.free(buffer);
      calloc.free(needed);
    }
  });
  return uses ?? false;
}

void _control({required bool stop}) {
  final ok = _withService(_serviceStart | _serviceStop | _serviceQueryStatus, (
    service,
  ) {
    if (!stop) return _startService(service, 0, nullptr) != 0;
    final status = calloc<_ServiceStatus>();
    try {
      return _controlService(service, _serviceControlStop, status) != 0;
    } finally {
      calloc.free(status);
    }
  });
  if (ok == null) {
    throw const VpnException('O serviço da VPN não está instalado');
  }
}

// --- Processo auxiliar elevado (shell32 / kernel32) --------------------------

/// O utilizador recusou o UAC (ou o ShellExecuteEx falhou).
const _cancelled = -1;

const _seeMaskNoCloseProcess = 0x00000040;
const _seeMaskNoAsync = 0x00000100;
const _swHide = 0;
const _infinite = 0xFFFFFFFF;

final class _ShellExecuteInfo extends Struct {
  @Uint32()
  external int cbSize;
  @Uint32()
  external int fMask;
  external Pointer<Void> hwnd;
  external Pointer<Utf16> lpVerb;
  external Pointer<Utf16> lpFile;
  external Pointer<Utf16> lpParameters;
  external Pointer<Utf16> lpDirectory;
  @Int32()
  external int nShow;
  external Pointer<Void> hInstApp;
  external Pointer<Void> lpIDList;
  external Pointer<Utf16> lpClass;
  external Pointer<Void> hkeyClass;
  @Uint32()
  external int dwHotKey;
  external Pointer<Void> hIconOrMonitor;
  external Pointer<Void> hProcess;
}

/// Corre num isolate próprio (bloqueia até o UAC e a instalação acabarem).
int _runElevatedInstall(String executable, String configPath) {
  final shell32 = DynamicLibrary.open('shell32.dll');
  final kernel32 = DynamicLibrary.open('kernel32.dll');
  final shellExecuteEx = shell32
      .lookupFunction<
        Int32 Function(Pointer<_ShellExecuteInfo>),
        int Function(Pointer<_ShellExecuteInfo>)
      >('ShellExecuteExW');
  final waitForSingleObject = kernel32
      .lookupFunction<
        Uint32 Function(Pointer<Void>, Uint32),
        int Function(Pointer<Void>, int)
      >('WaitForSingleObject');
  final getExitCodeProcess = kernel32
      .lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Uint32>),
        int Function(Pointer<Void>, Pointer<Uint32>)
      >('GetExitCodeProcess');
  final closeHandle = kernel32
      .lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>(
        'CloseHandle',
      );

  final info = calloc<_ShellExecuteInfo>();
  // "runas" é o que faz o Windows mostrar o UAC (com o nome da app).
  final verb = 'runas'.toNativeUtf16();
  final file = executable.toNativeUtf16();
  final parameters = '--vpn-install "$configPath"'.toNativeUtf16();
  final exitCode = calloc<Uint32>();
  try {
    info.ref
      ..cbSize = sizeOf<_ShellExecuteInfo>()
      ..fMask = _seeMaskNoCloseProcess | _seeMaskNoAsync
      ..lpVerb = verb
      ..lpFile = file
      ..lpParameters = parameters
      ..nShow = _swHide;
    if (shellExecuteEx(info) == 0 || info.ref.hProcess == nullptr) {
      return _cancelled;
    }
    waitForSingleObject(info.ref.hProcess, _infinite);
    final ok = getExitCodeProcess(info.ref.hProcess, exitCode) != 0;
    closeHandle(info.ref.hProcess);
    return ok ? exitCode.value : _cancelled;
  } finally {
    calloc
      ..free(info)
      ..free(verb)
      ..free(file)
      ..free(parameters)
      ..free(exitCode);
  }
}
