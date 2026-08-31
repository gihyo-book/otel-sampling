#!/usr/bin/env bash
# 『OpenTelemetryではじめるテレメトリーサンプリング』サンプルコード
# 付録B リストb-12（p.400）トレース連動ログサンプリングの診断手順
#
# 書籍からの変更点
#   - トレースIDのゼロ値を16桁から32桁に修正した。トレースIDは16バイト＝32桁の
#     16進数であり、16桁はスパンIDの長さのため、書籍のパターンは決して一致しない。
#   - 検索対象をdebugエクスポーターの実際の出力形式に合わせた。debugエクスポーターは
#     「Trace ID       : <32桁の16進数>」という平文で出力し、"trace_id":"..." という
#     JSONキーでは出力しないため、書籍のコマンドは常に0件を返す。
#
# 前提
#   Collectorのログにテレメトリーの内容を出力するため、debugエクスポーターを
#   verbosity: detailed で有効にしておく。
#
# 動作確認: OpenTelemetry Collector contrib v0.158.0

set -euo pipefail

# ログレコードにtrace_idが含まれているか確認（空のトレースIDの件数）
kubectl logs -l app=otel-collector --tail=100 |
  grep -Ec 'Trace ID[[:space:]]*: 0{32}'

# トレースIDが空のログの割合を確認
kubectl logs -l app=otel-collector --tail=500 |
  grep -E 'Trace ID[[:space:]]*:' |
  sed -E 's/.*Trace ID[[:space:]]*:[[:space:]]*//' |
  awk '{if ($1 ~ /^0{32}$/ || $1 == "") print "empty"; else print "present"}' |
  sort | uniq -c

# filterプロセッサーの条件を確認
kubectl get configmap otel-collector-config -o yaml |
  grep -A 10 "filter"
