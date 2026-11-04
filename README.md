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
flutter run --flavor mobile   # Android (telemóvel/tablet)
flutter run --flavor tv       # Android TV
```

No Android há duas variantes (flavors) com o mesmo identificador: `mobile` e
`tv`. Só o manifest muda (`android/app/src/tv`: launcher e banner da TV).

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

   O workflow `Release` publica sempre quatro ficheiros (ou nenhum):

   | Ficheiro | Para |
   |---|---|
   | `IPTV-X.Y.Z-android.apk` | telemóveis e tablets Android |
   | `IPTV-X.Y.Z-android-tv.apk` | Android TV |
   | `IPTV-Setup-X.Y.Z.exe` | Windows, só para o utilizador atual (atualiza sem UAC) |
   | `IPTV-X.Y.Z-windows.msi` | Windows, para todos os utilizadores (Program Files) |

   A versão da app vem da tag. O atualizador da app descarrega sempre a
   mesma variante que está instalada.

   Tags com hífen (`v0.2.0-beta.1`) saem como pré-release e a app não as
   oferece como atualização.
