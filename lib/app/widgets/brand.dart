import 'package:flutter/material.dart';

/// Logo completo ("Lost the Game · IPTV Service"), desenhado sobre papel.
///
/// No tema claro o papel é a própria cor de fundo e o logo assenta sem
/// moldura; no escuro fica como um cartão.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 360});

  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/branding/logo.webp',
        width: width,
        // Logo 1024x572: descodifica só ao tamanho mostrado.
        cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Lost the Game, IPTV Service',
      ),
    );
  }
}

/// Ícone da app (a TV do logo), para a navegação.
class BrandIcon extends StatelessWidget {
  const BrandIcon({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset(
        'assets/branding/icon.png',
        width: size,
        height: size,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}
