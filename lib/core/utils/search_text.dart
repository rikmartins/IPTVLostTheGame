/// Letras acentuadas (minúsculas) e a letra sem acento.
const _plain = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ç': 'c', 'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
};

/// Minúsculas e sem acentos: "Família" e "familia" são a mesma pesquisa.
///
/// Corre para cada item gravado na sincronização (186k filmes): o caminho
/// habitual (só ASCII) não passa pelo mapa.
String foldForSearch(String text) {
  final lower = text.toLowerCase();
  var ascii = true;
  for (final unit in lower.codeUnits) {
    if (unit > 127) {
      ascii = false;
      break;
    }
  }
  if (ascii) return lower;

  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_plain[char] ?? char);
  }
  return buffer.toString();
}

/// As palavras de uma pesquisa, já sem acentos.
List<String> searchTermsOf(String query) =>
    foldForSearch(query)
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
