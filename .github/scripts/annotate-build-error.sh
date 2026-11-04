#!/usr/bin/env bash
# Publica o erro de um build como anotação da execução.
#
# Os logs do GitHub Actions só se veem com sessão iniciada (também pela API),
# mas as anotações são públicas: aparecem no resumo da execução e em
# GET /repos/{dono}/{repo}/check-runs/{id}/annotations.
#
# Uso: annotate-build-error.sh <ficheiro de log> <título>
set -euo pipefail

log="$1"
title="$2"

# O bloco "What went wrong" do Gradle tem a causa; senão, o fim do log.
message="$(grep -E -A 25 'What went wrong' "$log" | head -n 40 || true)"
if [ -z "$message" ]; then
  message="$(grep -E -B 2 -A 10 '(^|[^a-z])(error|Error|ERROR)[: ]' "$log" | head -n 40 || true)"
fi
if [ -z "$message" ]; then
  message="$(tail -n 40 "$log")"
fi

# Codificação das workflow commands para mensagens com várias linhas.
message="${message//'%'/'%25'}"
message="${message//$'\r'/'%0D'}"
message="${message//$'\n'/'%0A'}"
echo "::error title=${title}::${message}"
