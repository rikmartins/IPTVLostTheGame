#ifndef RUNNER_VPN_HELPER_H_
#define RUNNER_VPN_HELPER_H_

namespace vpn_helper {

// Modo auxiliar da VPN: a app relança-se a si própria como administrador com
// `--vpn-install <ficheiro .conf>` (ver lib/data/vpn/windows_vpn_backend.dart).
// Se for o caso, faz a instalação, põe o código de saída em |exit_code| e
// devolve true; a app deve então sair sem abrir janela.
bool TryRun(int* exit_code);

}  // namespace vpn_helper

#endif  // RUNNER_VPN_HELPER_H_
