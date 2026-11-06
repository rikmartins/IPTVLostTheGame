import 'package:isar_community/isar.dart';

part 'favorite_channel.g.dart';

/// Canal favorito do perfil.
///
/// Coleção à parte e não um campo de `LiveChannel`, pela mesma razão dos
/// grupos ocultos: a sincronização reescreve os canais e apagava a escolha.
@Collection(accessor: 'favoriteChannels')
class FavoriteChannel {
  /// O mesmo que `LiveChannel.id`.
  Id id = Isar.autoIncrement;

  late DateTime addedAt;
}
