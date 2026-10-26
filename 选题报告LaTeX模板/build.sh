#!/bin/sh
set -eu
cd "$(dirname "$0")"
# 优先使用正常安装的 Biber；兼容部分 macOS 通用二进制解包失败的问题。
if ! biber --version >/dev/null 2>&1; then
  if [ "$(uname -s)" = Darwin ]; then
    report_tmp=$(mktemp -d /tmp/cumt-report-biber.XXXXXX)
    trap 'rm -rf "$report_tmp"' EXIT HUP INT TERM
    report_lipo=$(xcrun --find lipo)
    "$report_lipo" "$(command -v biber)" -thin "$(uname -m)" -output "$report_tmp/biber"
    chmod +x "$report_tmp/biber"
    PATH="$report_tmp:$PATH"
    export PATH
    biber --version
  else
    echo 'Biber 不可用，请安装与 biblatex 匹配的 Biber。' >&2
    exit 1
  fi
fi
latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex
