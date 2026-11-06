import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../core/utils/search_text.dart';
import '../../data/local/models/live_channel.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/local/models/tv_series.dart';
import '../../data/local/models/vod_movie.dart';
import '../catalog/category_providers.dart';

/// Pesquisas mais curtas do que isto apanham metade do catálogo.
const minSearchLength = 2;

/// Resultados mostrados por tipo.
const _limit = 60;

/// Candidatos lidos por tipo, antes de ordenar por relevância.
const _scan = 600;

@immutable
class SearchResults {
  const SearchResults({
    this.channels = const [],
    this.movies = const [],
    this.series = const [],
  });

  final List<int> channels;
  final List<int> movies;
  final List<int> series;

  bool get isEmpty => channels.isEmpty && movies.isEmpty && series.isEmpty;
}

/// Canais, filmes e séries cujo nome contém todas as palavras escritas,
/// por qualquer ordem ("fam add" encontra "A Família Addams"), sem acentos
/// nem maiúsculas, e fora os grupos ocultos.
///
/// As consultas são assíncronas: o Isar procura numa thread sua (~30 ms em
/// 186k filmes no PC, umas centenas de ms numa TV box) e a interface não
/// para enquanto se escreve.
final searchResultsProvider = FutureProvider.autoDispose
    .family<SearchResults, String>((ref, query) async {
      final terms = searchTermsOf(query);
      if (query.trim().length < minSearchLength || terms.isEmpty) {
        return const SearchResults();
      }
      for (final kind in [SyncKind.live, SyncKind.movies, SyncKind.series]) {
        ref.watch(catalogVersionProvider(kind));
      }
      final isar = ref.watch(isarProvider);
      final hiddenLive = ref.watch(hiddenCategoriesProvider(CategoryType.live));
      final hiddenMovies = ref.watch(
        hiddenCategoriesProvider(CategoryType.movie),
      );
      final hiddenSeries = ref.watch(
        hiddenCategoriesProvider(CategoryType.series),
      );
      final phrase = foldForSearch(query.trim());

      final (channels, movies, series) = await (
        _pick<LiveChannel>(
          starting: isar.liveChannels
              .filter()
              .searchNameStartsWith(phrase)
              .limit(_limit)
              .findAll(),
          containing: isar.liveChannels
              .filter()
              .allOf(terms, (q, term) => q.searchNameContains(term))
              .limit(_scan)
              .findAll(),
          id: (c) => c.id,
          name: (c) => c.searchName ?? '',
          category: (c) => c.categoryId,
          hidden: hiddenLive,
          terms: terms,
        ),
        _pick<VodMovie>(
          starting: isar.movies
              .filter()
              .searchNameStartsWith(phrase)
              .limit(_limit)
              .findAll(),
          containing: isar.movies
              .filter()
              .allOf(terms, (q, term) => q.searchNameContains(term))
              .limit(_scan)
              .findAll(),
          id: (m) => m.id,
          name: (m) => m.searchName ?? '',
          category: (m) => m.categoryId,
          hidden: hiddenMovies,
          terms: terms,
        ),
        _pick<TvSeries>(
          starting: isar.series
              .filter()
              .searchNameStartsWith(phrase)
              .limit(_limit)
              .findAll(),
          containing: isar.series
              .filter()
              .allOf(terms, (q, term) => q.searchNameContains(term))
              .limit(_scan)
              .findAll(),
          id: (s) => s.id,
          name: (s) => s.searchName ?? '',
          category: (s) => s.categoryId,
          hidden: hiddenSeries,
          terms: terms,
        ),
      ).wait;
      return SearchResults(channels: channels, movies: movies, series: series);
    });

/// Junta os que começam pelo que se escreveu (pedidos à parte, para não se
/// perderem entre centenas de outros) aos que o contêm, e ordena: primeiro
/// os que começam pela pesquisa, depois os que têm uma palavra a começar
/// pela primeira palavra escrita, e em cada grupo os nomes mais curtos.
Future<List<int>> _pick<T>({
  required Future<List<T>> starting,
  required Future<List<T>> containing,
  required int Function(T item) id,
  required String Function(T item) name,
  required int Function(T item) category,
  required Set<int> hidden,
  required List<String> terms,
}) async {
  final (first, rest) = await (starting, containing).wait;
  final seen = <int>{};
  final ranked = <(int, int)>[];
  for (final (index, item) in [...first, ...rest].indexed) {
    if (!seen.add(id(item)) || hidden.contains(category(item))) continue;
    final folded = name(item);
    final rank = index < first.length
        ? 0
        : ' $folded'.contains(' ${terms.first}')
        ? 1
        : 2;
    ranked.add((id(item), rank * 1000 + folded.length.clamp(0, 999)));
  }
  ranked.sort((a, b) => a.$2.compareTo(b.$2));
  return [for (final (itemId, _) in ranked.take(_limit)) itemId];
}
