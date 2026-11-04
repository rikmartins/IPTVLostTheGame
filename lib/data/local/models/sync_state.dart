import 'package:isar_community/isar.dart';

part 'sync_state.g.dart';

enum SyncKind { live, movies, series, epg }

/// Um registo por [SyncKind]; serve para decidir atualizações automáticas
/// em segundo plano e mostrar "Atualizado há X" nas definições.
@Collection(accessor: 'syncStates')
class SyncState {
  /// Igual a `kind.index`.
  Id id = Isar.autoIncrement;

  @enumerated
  late SyncKind kind;

  DateTime? lastSuccessAt;

  int itemCount = 0;

  /// Erro da última tentativa; null se correu bem.
  String? lastError;
}
