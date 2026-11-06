import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/favorite_channel.dart';
import '../../data/local/models/live_channel.dart';
import '../../data/local/models/media_category.dart';
import '../catalog/category_providers.dart';

/// IDs dos canais favoritos do perfil ativo.
class FavoriteChannels extends Notifier<Set<int>> {
  @override
  Set<int> build() => ref
      .watch(isarProvider)
      .favoriteChannels
      .where()
      .idProperty()
      .findAllSync()
      .toSet();

  /// Devolve se ficou favorito.
  bool toggle(int channelId) {
    final isar = ref.read(isarProvider);
    final add = !state.contains(channelId);
    isar.writeTxnSync(() {
      if (add) {
        isar.favoriteChannels.putSync(
          FavoriteChannel()
            ..id = channelId
            ..addedAt = DateTime.now(),
        );
      } else {
        isar.favoriteChannels.deleteSync(channelId);
      }
    });
    state = add ? {...state, channelId} : ({...state}..remove(channelId));

    // O grupo dos favoritos desaparece quando fica vazio.
    final selected = selectedCategoryProvider(CategoryType.live);
    if (state.isEmpty && ref.read(selected) == kFavoritesGroup) {
      ref.read(selected.notifier).select(null);
    }
    return add;
  }
}

final favoriteChannelsProvider = NotifierProvider<FavoriteChannels, Set<int>>(
  FavoriteChannels.new,
);

/// Junta ou tira dos favoritos e diz o que fez.
void toggleFavorite(BuildContext context, WidgetRef ref, LiveChannel channel) {
  final added = ref.read(favoriteChannelsProvider.notifier).toggle(channel.id);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '«${channel.name}» nos favoritos'
              : '«${channel.name}» saiu dos favoritos',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}
