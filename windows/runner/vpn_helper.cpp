#include "vpn_helper.h"

#include <windows.h>
#include <sddl.h>
#include <shellapi.h>
#include <shlobj.h>

#include <string>

namespace vpn_helper {
namespace {

// Tem de coincidir com lib/data/vpn/windows_vpn_backend.dart.
constexpr wchar_t kServiceName[] = L"LostTheGameVPN";
constexpr wchar_t kDisplayName[] = L"Lost the Game VPN";

// O que o wireguard_flutter_plus junta ao build (ver o CMake dele).
constexpr const wchar_t* kBinaries[] = {L"wireguard_svc.exe", L"tunnel.dll",
                                        L"wireguard.dll"};

// Dependências do serviço (lista terminada em dois nulos).
constexpr wchar_t kDependencies[] = L"Nsi\0TcpIp\0";

// SYSTEM e administradores com controlo total; utilizadores com sessão
// iniciada (IU) podem consultar, ligar (RP) e parar (WP) o serviço. É isto que
// faz só a primeira ligação pedir UAC.
constexpr wchar_t kServiceSddl[] =
    L"D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)"
    L"(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)"
    L"(A;;CCLCSWRPWPLOCRRC;;;IU)";

// Códigos de saída lidos pelo lado Dart.
enum ExitCode : int {
  kOk = 0,
  kBadArguments = 2,
  kNoProgramFiles = 3,
  kCopyFailed = 4,
  kManagerFailed = 5,
  kServiceFailed = 6,
  kSecurityFailed = 7,
};

std::wstring ExecutableDirectory() {
  wchar_t path[MAX_PATH];
  const DWORD length = ::GetModuleFileNameW(nullptr, path, MAX_PATH);
  std::wstring result(path, length);
  return result.substr(0, result.find_last_of(L"\\/"));
}

std::wstring ProgramFilesDirectory() {
  PWSTR raw = nullptr;
  std::wstring result;
  if (SUCCEEDED(::SHGetKnownFolderPath(FOLDERID_ProgramFiles, 0, nullptr,
                                       &raw))) {
    result = raw;
  }
  ::CoTaskMemFree(raw);
  return result;
}

// Os binários de um serviço a correr estão bloqueados: para antes de copiar.
void StopAndWait(SC_HANDLE service) {
  SERVICE_STATUS status{};
  if (!::QueryServiceStatus(service, &status) ||
      status.dwCurrentState == SERVICE_STOPPED) {
    return;
  }
  ::ControlService(service, SERVICE_CONTROL_STOP, &status);
  for (int i = 0; i < 60 && status.dwCurrentState != SERVICE_STOPPED; ++i) {
    ::Sleep(250);
    if (!::QueryServiceStatus(service, &status)) return;
  }
}

int Install(const std::wstring& config_path) {
  const std::wstring program_files = ProgramFilesDirectory();
  if (program_files.empty()) return kNoProgramFiles;

  // O serviço corre como SYSTEM: os binários vão para uma pasta que só o
  // administrador pode alterar. A pasta da app não serve, porque na
  // instalação por utilizador qualquer programa do utilizador lhe escreve.
  const std::wstring target = program_files + L"\\Lost the Game VPN";
  ::CreateDirectoryW(target.c_str(), nullptr);

  SC_HANDLE manager = ::OpenSCManagerW(nullptr, nullptr, SC_MANAGER_ALL_ACCESS);
  if (!manager) return kManagerFailed;

  SC_HANDLE service = ::OpenServiceW(manager, kServiceName, SERVICE_ALL_ACCESS);
  if (service) StopAndWait(service);

  const std::wstring source = ExecutableDirectory();
  for (const wchar_t* file : kBinaries) {
    const std::wstring from = source + L"\\" + file;
    const std::wstring to = target + L"\\" + file;
    if (!::CopyFileW(from.c_str(), to.c_str(), FALSE)) {
      if (service) ::CloseServiceHandle(service);
      ::CloseServiceHandle(manager);
      return kCopyFailed;
    }
  }

  const std::wstring command = L"\"" + target +
                               L"\\wireguard_svc.exe\" -service "
                               L"-config-file=\"" +
                               config_path + L"\"";
  if (service) {
    if (!::ChangeServiceConfigW(service, SERVICE_WIN32_OWN_PROCESS,
                                SERVICE_DEMAND_START, SERVICE_ERROR_NORMAL,
                                command.c_str(), nullptr, nullptr,
                                kDependencies, nullptr, nullptr,
                                kDisplayName)) {
      ::CloseServiceHandle(service);
      ::CloseServiceHandle(manager);
      return kServiceFailed;
    }
  } else {
    service = ::CreateServiceW(manager, kServiceName, kDisplayName,
                               SERVICE_ALL_ACCESS, SERVICE_WIN32_OWN_PROCESS,
                               SERVICE_DEMAND_START, SERVICE_ERROR_NORMAL,
                               command.c_str(), nullptr, nullptr,
                               kDependencies, nullptr, nullptr);
    if (!service) {
      ::CloseServiceHandle(manager);
      return kServiceFailed;
    }
  }

  // Como o próprio plugin faz: o túnel precisa de SID de serviço.
  SERVICE_SID_INFO sid_info{SERVICE_SID_TYPE_UNRESTRICTED};
  ::ChangeServiceConfig2W(service, SERVICE_CONFIG_SERVICE_SID_INFO,
                          &sid_info);
  wchar_t description[] = L"Tunel WireGuard da app Lost the Game.";
  SERVICE_DESCRIPTIONW service_description{description};
  ::ChangeServiceConfig2W(service, SERVICE_CONFIG_DESCRIPTION,
                          &service_description);

  PSECURITY_DESCRIPTOR descriptor = nullptr;
  const bool secured =
      ::ConvertStringSecurityDescriptorToSecurityDescriptorW(
          kServiceSddl, SDDL_REVISION_1, &descriptor, nullptr) &&
      ::SetServiceObjectSecurity(service, DACL_SECURITY_INFORMATION,
                                 descriptor);
  if (descriptor) ::LocalFree(descriptor);

  ::CloseServiceHandle(service);
  ::CloseServiceHandle(manager);
  return secured ? kOk : kSecurityFailed;
}

}  // namespace

bool TryRun(int* exit_code) {
  int argc = 0;
  LPWSTR* argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (!argv) return false;

  bool handled = false;
  if (argc >= 2 && std::wstring(argv[1]) == L"--vpn-install") {
    handled = true;
    *exit_code = argc == 3 ? Install(argv[2]) : kBadArguments;
  }
  ::LocalFree(argv);
  return handled;
}

}  // namespace vpn_helper
