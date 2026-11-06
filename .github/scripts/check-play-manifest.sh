#!/usr/bin/env bash
# Confirma que a versão da Play Store (flavor "play") não declara o que as
# regras da loja recusam: o atualizador próprio (instalar APKs) e a VPN.
# Os plugins juntam isto ao manifest sozinhos; src/play/AndroidManifest.xml
# tira-o, e este script apanha um plugin novo ou atualizado que o traga de
# volta.
#
# Corre depois de `flutter build apk|appbundle --flavor play` e lê o
# manifest final que o Gradle deixa em build/app/intermediates. Escreve as
# permissões que ficaram, para se verem no log.
set -euo pipefail

mapfile -t manifests < <(
  find build/app/intermediates -name AndroidManifest.xml \
    -path '*merged_manifest*' -path '*playRelease*'
)
if [ "${#manifests[@]}" -eq 0 ]; then
  echo "::error title=Manifest da Play Store::Não encontrei o manifest final da variante play (o Gradle mudou de pasta?)."
  exit 1
fi

status=0
for forbidden in \
  android.permission.REQUEST_INSTALL_PACKAGES \
  android.permission.BIND_VPN_SERVICE \
  android.net.VpnService \
  android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE \
  VpnForegroundService; do
  if grep -q -F "$forbidden" "${manifests[@]}"; then
    echo "::error title=Manifest da Play Store::A versão da Play Store declara $forbidden; tira-o em android/app/src/play/AndroidManifest.xml."
    status=1
  fi
done

# O applicationId aparece no package e nas authorities dos providers.
if ! grep -q -F 'com.sopromedia.app' "${manifests[@]}"; then
  echo "::error title=Manifest da Play Store::O applicationId da versão da Play Store não é com.sopromedia.app."
  status=1
fi

echo "Permissões da versão da Play Store:"
grep -h -o -E 'uses-permission[^>]*android:name="[^"]+"' "${manifests[@]}" |
  grep -o -E 'android:name="[^"]+"' | sort -u
exit "$status"
