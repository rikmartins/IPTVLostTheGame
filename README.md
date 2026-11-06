<p align="center">
  <img src="assets/branding/logo.webp" alt="SoPro Media" width="460">
</p>

<p align="center">
  <a href="https://github.com/rikmartins/IPTVLostTheGame/releases/latest"><img src="https://img.shields.io/github/v/release/rikmartins/IPTVLostTheGame?label=%C3%BAltima%20vers%C3%A3o&color=21615A" alt="Última versão"></a>
</p>

## Download

Os links descarregam sempre a versão mais recente.

| Dispositivo | Download direto |
|---|---|
| Android (telemóvel e tablet) | [SoProMedia-Android.apk](https://github.com/rikmartins/IPTVLostTheGame/releases/latest/download/SoProMedia-Android.apk) |
| Android TV | [SoProMedia-AndroidTV.apk](https://github.com/rikmartins/IPTVLostTheGame/releases/latest/download/SoProMedia-AndroidTV.apk) |
| Windows (instalador) | [SoProMedia-Setup.exe](https://github.com/rikmartins/IPTVLostTheGame/releases/latest/download/SoProMedia-Setup.exe) |
| Windows (MSI) | [SoProMedia-Windows.msi](https://github.com/rikmartins/IPTVLostTheGame/releases/latest/download/SoProMedia-Windows.msi) |

**Android / Android TV:** ao abrir o APK, o Android pede para autorizar a
instalação de apps desconhecidas para o browser (ou para a app que usaste
para descarregar, como a *Downloader* na TV). A seguir o Google Play Protect
pode pedir para analisar a app (*Analisar app*): acontece com cada versão
nova, porque a app não vem da Play Store e a Google ainda não conhece esse
APK. A análise demora poucos segundos e a instalação continua.

**Windows:** o `.exe` instala só para o teu utilizador e as atualizações não
pedem administrador; o `.msi` instala para todos os utilizadores do PC. Como
o instalador ainda não tem assinatura digital, o SmartScreen pode avisar:
*Mais informações → Executar mesmo assim*.

Depois de instalada, a app procura novas versões em
**Definições → Aplicação**.

---

Cliente IPTV (Xtream Codes) e Jellyfin em Flutter para Android, Android TV
e Windows.

- Catálogo (canais, filmes, séries e guia TV) sincronizado para uma base de
  dados local (Isar) num isolate próprio; a interface lê só daí.
- Vários perfis (por exemplo *IPTV X* e *IPTV Y*), cada um com a sua lista
  guardada no dispositivo: mudar de perfil é imediato. Em
  **Definições → Perfis**, ou no nome do perfil no topo de cada secção.
- Perfis **Jellyfin** (escolhe *Jellyfin* no login): as bibliotecas de
  filmes e séries aparecem como grupos, e a TV em direto do servidor (com
  o guia) na secção TV. Os filmes e episódios tocam o ficheiro original,
  sem conversão, e o progresso fica no servidor: retomas onde ficaste,
  aqui ou noutro aparelho, e os episódios vistos aparecem marcados. Basta
  escrever o IP do servidor; a porta 8096 é experimentada sozinha.
- Grupos visíveis à escolha: o botão ao lado de **Grupos** (TV, filmes e
  séries) abre a lista de todos os grupos para mostrar ou ocultar. Os
  ocultos também saem de "Todos". Fica guardado em cada perfil.
- Pré-visualização na TV em direto: o primeiro toque (ou OK no comando)
  num canal mostra-o num vídeo pequeno com o guia (agora e a seguir); o
  segundo abre o ecrã inteiro, que continua o mesmo stream sem nova
  ligação ao servidor.
- **Favoritos**: clique longo num canal (botão direito no computador, ou a
  estrela na pré-visualização com o comando). Aparecem no grupo
  *Favoritos*, no topo da lista de grupos da TV e do Guia.
- **Guia** em grelha: canais em linhas e o tempo na horizontal, de ontem
  até daqui a três dias. Num programa a dar: ver em direto ou, se o canal
  tiver catch-up, do início; nos que já passaram, a gravação.
- **Pesquisa** (lupa no topo de cada secção): canais, filmes e séries ao
  mesmo tempo, sem acentos nem maiúsculas e com as palavras por qualquer
  ordem.
- **Continuar a ver**: a app guarda onde ficaste em cada filme e
  episódio. Os que ficaram a meio aparecem no grupo *Continuar a ver* de
  Filmes e Séries (retomam logo), com uma barra de progresso nos posters,
  e os episódios vistos aparecem marcados.
- Reprodução com media_kit (libmpv), descodificação na placa gráfica e
  perfis de pré-buffer (Rápido / Normal / Estável). Mudar de canal abre-o
  logo; só carregando várias vezes seguidas é que espera pelo último. No
  Android há ainda a opção *Descodificação direta no ecrã* (sem cópias,
  para TV boxes fracas).
- Logos e posters guardados no dispositivo: não voltam a ser
  descarregados a cada arranque.
- VPN pessoal em **Definições → VPN**, de duas formas:
  - **WireGuard**, com um ficheiro `.conf` (Android e Windows). No Android
    pode passar só o tráfego da app; no Windows pede administrador só na
    primeira ligação.
  - **IKEv2**, com as credenciais VPN da subscrição (na PureVPN, em
    *Subscriptions*; não são o email e a palavra-passe da conta), que não
    expiram como um `.conf`. Usa o IKEv2 do próprio sistema: Windows, e
    Android 11 ou mais recente.

  Se o servidor não responder, a app desliga a VPN sozinha para não ficares
  sem internet.
- Na TV, o login e o `.conf` da VPN podem ser preenchidos no telemóvel:
  lê o código QR no ecrã e preenche a página que abre (mesma rede Wi-Fi;
  os dados não passam pela internet).
- Opção **Memorizar dados** no login.
- Tema escuro (por omissão nas instalações novas) ou claro, sem
  animações entre ecrãs, e atualizações a partir das releases deste
  repositório.

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

No Android há duas variantes (flavors) com o mesmo identificador
(`com.iptvapp.lostthegame`): `mobile` e `tv`. Só o manifest muda
(`android/app/src/tv`: launcher e banner da TV). O identificador vem do
nome antigo da app e nunca muda: com outro, o Android trata-a como uma app
diferente e não atualiza a instalada.

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

   O workflow `Release` publica sempre os quatro ficheiros da tabela de
   download (ou nenhum). Os nomes não levam a versão, para os links acima
   apontarem sempre para a mais recente; a versão da app vem da tag. O
   atualizador da app descarrega sempre a mesma variante que está instalada.

   Tags com hífen (`v0.2.0-beta.1`) saem como pré-release e a app não as
   oferece como atualização.
