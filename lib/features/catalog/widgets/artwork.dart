import 'package:flutter/material.dart';

// Imagens do catálogo (logos de canais e posters de VOD).
//
// Em todas se usa `cacheWidth`: o Flutter descodifica a imagem já no
// tamanho em que é desenhada. Logos e posters IPTV são muitas vezes ficheiros
// de 1000px+; sem isto, uma grelha no ecrã ocupava centenas de MB de memória
// de imagem.

class ChannelLogo extends StatelessWidget {
  const ChannelLogo({super.key, required this.url, required this.name});

  static const size = 44.0;

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final fallback = _Monogram(
      name: name,
      width: size,
      height: size,
      radius: 8,
    );
    final url = this.url;
    if (url == null) return fallback;

    return SizedBox.square(
      dimension: size,
      child: Image.network(
        url,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

/// Poster 2:3 que ocupa a largura disponível.
class Poster extends StatelessWidget {
  const Poster({super.key, required this.url, required this.title});

  final String? url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final fallback = _Monogram(
          name: title,
          width: width,
          height: height,
          radius: 10,
        );
        final url = this.url;
        if (url == null || !width.isFinite) return fallback;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: width,
            height: height,
            cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                .round(),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => fallback,
          ),
        );
      },
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({
    required this.name,
    required this.width,
    required this.height,
    required this.radius,
  });

  final String name;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final letters = name.trim().isEmpty
        ? '?'
        : String.fromCharCodes(name.trim().runes.take(2)).toUpperCase();

    return Container(
      width: width.isFinite ? width : null,
      height: height.isFinite ? height : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        letters,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
