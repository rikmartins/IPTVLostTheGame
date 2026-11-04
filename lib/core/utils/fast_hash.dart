/// FNV-1a de 64 bits (a variante recomendada pela documentação do Isar).
///
/// Converte chaves textuais em [int] estáveis entre execuções, para usar como
/// `Id` ou como chave indexável: o Isar não permite Strings fora da última
/// posição de um índice composto.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
