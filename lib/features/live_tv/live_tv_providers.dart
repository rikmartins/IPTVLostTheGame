import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/live_channel.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';
import '../catalog/category_providers.dart';
import 'favorites.dart';

// Tudo aqui lê exclusivamente do Isar; a UI nunca toca na rede.
//
// As leituras são síncronas de propósito: o Isar é memory-mapped e estas
// queries custam microssegundos a poucos milissegundos, por isso mudar de
// grupo nunca passa por um frame vazio ou um estado de loading.

/// Só os IDs, já na ordem do fornecedor (`null` = todos, menos os dos
/// grupos ocultos). Com 50k canais são ~400 KB; os objetos completos só são
/// lidos para as linhas visíveis ([liveChannelProvider]) e libertados
/// quando saem do ecrã.
final liveChannelIdsProvider = Provider.autoDispose.family<List<int>, int?>((
  ref,
  categoryId,
) {
  ref.watch(catalogVersionProvider(SyncKind.live));
  final channels = ref.watch(isarProvider).liveChannels;
  if (categoryId == kFavoritesGroup) {
    // Pela ordem dos canais (a do comando), e só os que ainda existem.
    final favorites = ref.watch(favoriteChannelsProvider);
    final found = channels.getAllSync(favorites.toList()).nonNulls.toList()
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return [for (final channel in found) channel.id];
  }
  if (categoryId != null) {
    return channels
        .where()
        .categoryIdEqualToAnySortIndex(categoryId)
        .idProperty()
        .findAllSync();
  }

  final hidden = ref.watch(hiddenCategoriesProvider(CategoryType.live));
  if (hidden.isEmpty) {
    return channels.where().sortBySortIndex().idProperty().findAllSync();
  }
  return channels
      .where()
      .filter()
      .not()
      .anyOf(hidden, (q, id) => q.categoryIdEqualTo(id))
      .sortBySortIndex()
      .idProperty()
      .findAllSync();
});

final liveChannelProvider = Provider.autoDispose.family<LiveChannel?, int>((
  ref,
  id,
) {
  ref.watch(catalogVersionProvider(SyncKind.live));
  return ref.watch(isarProvider).liveChannels.getSync(id);
});
