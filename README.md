# IPTV

Cliente IPTV (Xtream Codes) em Flutter para Android, Android TV, Windows,
macOS e iOS.

- Catálogo (canais, filmes, séries e guia TV) sincronizado para uma base de
  dados local (Isar) num isolate próprio; a interface lê só daí.
- Reprodução com media_kit (libmpv) e perfis de pré-buffer
  (Rápido / Normal / Estável).
- Atualizações a partir das releases deste repositório.

## Desenvolvimento

```bash
flutter pub get
dart run build_runner build   # depois de mudar modelos em lib/data/local/models
flutter analyze
flutter test
flutter run -d windows
```

## Publicar uma versão

1. **Uma única vez:** criar a chave de assinatura Android e os secrets do
   GitHub:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tool\setup_android_signing.ps1
   ```

   Guarda `android/upload-keystore.p12` e a palavra-passe num gestor de
   palavras-passe: sem eles não há mais atualizações para quem já instalou.

2. Criar e enviar a tag:

   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```

   O workflow `Release` compila os APKs (um por arquitetura) e o instalador
   Windows, e publica a release. A versão da app vem da tag.

   Tags com hífen (`v0.2.0-beta.1`) saem como pré-release e a app não as
   oferece como atualização.
