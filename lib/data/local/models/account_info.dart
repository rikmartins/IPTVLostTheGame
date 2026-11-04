import 'package:isar_community/isar.dart';

part 'account_info.g.dart';

/// `user_info` + `server_info` do Xtream. A password nunca é guardada aqui
/// (vai para o armazenamento seguro do sistema, ver `AuthRepository`).
@Collection(accessor: 'accounts')
class AccountInfo {
  /// Conta única.
  Id id = 0;

  late String username;

  /// "Active", "Expired", "Banned", "Disabled", ...
  late String status;

  /// null = sem data de expiração.
  DateTime? expiresAt;

  DateTime? createdAt;

  bool isTrial = false;

  int activeConnections = 0;

  int maxConnections = 1;

  /// Ex.: ["m3u8", "ts", "rtmp"].
  List<String> allowedOutputFormats = [];

  /// Fuso do servidor (necessário para os URLs de catch-up).
  String? serverTimezone;

  late DateTime lastLoginAt;
}

extension AccountInfoFormats on AccountInfo {
  /// MPEG-TS tem menos latência de arranque no zapping que HLS; usa-se HLS
  /// só quando o fornecedor não permite TS.
  String get preferredLiveExtension {
    if (allowedOutputFormats.isEmpty || allowedOutputFormats.contains('ts')) {
      return 'ts';
    }
    return allowedOutputFormats.contains('m3u8') ? 'm3u8' : 'ts';
  }
}
