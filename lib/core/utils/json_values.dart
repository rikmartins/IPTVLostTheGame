// Conversores tolerantes para o JSON do Xtream Codes, onde o mesmo campo
// pode chegar como int, String, "", null ou bool consoante o painel.

int? asInt(Object? value) => switch (value) {
  final int v => v,
  final double v => v.isFinite ? v.toInt() : null,
  final bool v => v ? 1 : 0,
  final String v =>
    int.tryParse(v.trim()) ?? double.tryParse(v.trim())?.toInt(),
  _ => null,
};

double? asDouble(Object? value) => switch (value) {
  final double v => v.isFinite ? v : null,
  final int v => v.toDouble(),
  final String v => double.tryParse(v.trim().replaceAll(',', '.')),
  _ => null,
};

/// Devolve `null` para strings vazias, para não guardar lixo na base de dados.
String? asString(Object? value) => switch (value) {
  final String v when v.trim().isEmpty => null,
  final String v => v.trim(),
  final num v => v.toString(),
  final bool v => v.toString(),
  _ => null,
};

bool asBool(Object? value) => switch (value) {
  final bool v => v,
  final num v => v != 0,
  final String v => v.trim() == '1' || v.trim().toLowerCase() == 'true',
  _ => false,
};

/// Timestamps Unix em segundos (`exp_date`, `added`, ...). 0 ou inválido → null.
DateTime? asEpochSeconds(Object? value) {
  final seconds = asInt(value);
  if (seconds == null || seconds <= 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
}
