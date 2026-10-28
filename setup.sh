#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================================"
echo " 🎙️ Antigravity 全自動・文字起こし＆カレンダー連携パック"
echo "    初期セットアップスクリプト"
echo "========================================================"
echo ""

# 1. 必要なフォルダの作成
mkdir -p \
  "音声データ/未文字起こし" \
  "音声データ/文字起こし済み/通話音声" \
  "音声データ/文字起こし済み/録音データ" \
  "_brain/録音全文" \
  "_brain/通話要約" \
  "_brain/運用/外部ソース台帳"

touch "_brain/通話_除外リスト.txt"

# 2. 話者名の設定
read -r -p "✏️ 文字起こし時のあなたの話者名（例：山田）を入力してください [既定: 山田]: " USER_NAME
USER_NAME="${USER_NAME:-山田}"

if [ -f "_brain/運用/夜間文字起こし運用ルール.md" ]; then
  python3 - "$USER_NAME" <<'PY'
import sys, pathlib
name = sys.argv[1]
p = pathlib.Path("_brain/運用/夜間文字起こし運用ルール.md")
text = p.read_text(encoding="utf-8")
text = text.replace("話者分離: 山田 / 相手名", f"話者分離: {name} / 相手名")
p.write_text(text, encoding="utf-8")
PY
  echo "✅ 運用ルール内の話者名を「${USER_NAME}」に設定しました。"
fi

# 3. グローバルプラグインとしてのインストール確認
echo ""
read -r -p "🔌 Antigravityのグローバルプラグイン（全ワークスペース共通）としても登録しますか？ [Y/n]: " INSTALL_GLOBAL
INSTALL_GLOBAL="${INSTALL_GLOBAL:-Y}"

if [[ "$INSTALL_GLOBAL" =~ ^[Yy]$ ]]; then
  PLUGIN_DIR="$HOME/.gemini/config/plugins/voice-calendar-pack"
  mkdir -p "$PLUGIN_DIR"
  cp -R "$SCRIPT_DIR/plugin.json" "$SCRIPT_DIR/README.md" "$SCRIPT_DIR/rules" "$SCRIPT_DIR/skills" "$SCRIPT_DIR/assets" "$PLUGIN_DIR/"
  echo "✅ グローバルプラグインを $PLUGIN_DIR にインストールしました！"
  echo "   （※Antigravityを再起動するとプラグイン一覧に反映されます）"
fi

echo ""
echo "🎉 セットアップが完了しました！"
echo "--------------------------------------------------------"
echo "【次のステップ】"
echo "1. Google Antigravityでこのフォルダを開きます"
echo "2. Google Calendar（gcalendar）プラグインをONにします"
echo "3. チャット欄で「毎夜01:00の自動実行スケジュールを登録して」と伝えます"
echo "4. あとは「音声データ/未文字起こし/」に録音ファイルを入れるだけです！"
echo "--------------------------------------------------------"
