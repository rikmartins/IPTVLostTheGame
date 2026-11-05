/// "21:05", na hora local.
String hhmm(DateTime time) {
  final local = time.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}

/// Posição num vídeo: "42:10", ou "1:02:13" com horas.
String formatPosition(Duration position) {
  String two(int v) => v.toString().padLeft(2, '0');
  final minutes = position.inMinutes % 60;
  final seconds = position.inSeconds % 60;
  return position.inHours > 0
      ? '${position.inHours}:${two(minutes)}:${two(seconds)}'
      : '$minutes:${two(seconds)}';
}
