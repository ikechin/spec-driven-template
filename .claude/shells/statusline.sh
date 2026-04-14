#!/bin/bash
# spec-driven-template ステータスラインスクリプト
# コンテキスト使用率 + プロジェクト情報 (サービス / ブランチ / 最新ステアリング) を表示
#
# サービス検出は services/<name>/ のディレクトリ名から動的に抽出します。
# モノレポで services/ 以外のパス (packages/ / apps/ 等) を使う場合は
# 下部の SERVICE 検出ブロックを編集してください。

input=$(cat)

# コンテキスト使用率の取得
MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# プログレスバー生成
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '▓')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '░')"

# プロジェクト情報の取得
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

# 現在の作業ディレクトリからサービスを検出
# services/<name>/... のパスから <name> を抽出
CURRENT_DIR=$(pwd)
if [[ "$CURRENT_DIR" == *"/services/"* ]]; then
    SERVICE=$(echo "$CURRENT_DIR" | sed -E 's|.*/services/([^/]+).*|\1|')
elif [[ "$CURRENT_DIR" == *"/e2e"* ]]; then
    SERVICE="E2E"
else
    SERVICE="Root"
fi

# 現在のステアリングタスク（最新）
# サブモジュール対応: 親リポジトリの .steering を探す
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -n "$GIT_ROOT" ]; then
    if [ -d "$GIT_ROOT/.steering" ]; then
        STEERING_DIR="$GIT_ROOT/.steering"
    elif [ -d "$GIT_ROOT/../../.steering" ]; then
        STEERING_DIR="$GIT_ROOT/../../.steering"
    else
        STEERING_DIR=""
    fi

    if [ -n "$STEERING_DIR" ]; then
        # _template ディレクトリは除外して最新を取得
        LATEST_STEERING=$(ls -1t "$STEERING_DIR" 2>/dev/null | grep -v '^_template$' | head -1)
        if [ -n "$LATEST_STEERING" ]; then
            TASK="📋 $LATEST_STEERING"
        else
            TASK=""
        fi
    else
        TASK=""
    fi
else
    TASK=""
fi

# ステータスライン出力
# 形式: [Model] プログレスバー PCT% | サービス | ブランチ | タスク
if [ -n "$TASK" ]; then
    echo "[$MODEL] $BAR $PCT% | $SERVICE | 🌿 $BRANCH | $TASK"
else
    echo "[$MODEL] $BAR $PCT% | $SERVICE | 🌿 $BRANCH"
fi
