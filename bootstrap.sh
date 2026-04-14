#!/usr/bin/env bash
#
# bootstrap.sh — spec-driven-template を既存プロジェクトにコピーする
#
# Usage:
#   ./bootstrap.sh /path/to/target-project
#
# 動作:
#   - 必須ファイル/ディレクトリを TARGET にコピー
#   - 既存ファイルがある場合は上書き前に確認 (y / N / a=skip-all / o=overwrite-all)
#   - bootstrap.sh / README.md / .git / .gitignore はコピー対象外
#

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 /path/to/target-project" >&2
    exit 1
fi

TARGET="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- バリデーション ----
if [ ! -d "$TARGET" ]; then
    echo "Error: target directory does not exist: $TARGET" >&2
    exit 1
fi

if [ ! -d "$TARGET/.git" ]; then
    echo "Warning: $TARGET is not a git repository. Continuing anyway." >&2
fi

# ---- コピー対象 ----
# 注意: bootstrap.sh / README.md / .git / .gitignore は含めない
ITEMS=(
    "CLAUDE.md"
    "ONBOARDING.md"
    "docs"
    ".steering"
    ".claude"
    "templates"
    "contracts"
    "services/README.md"
    "e2e/README.md"
)

# ---- 上書きモード ----
SKIP_ALL=0
OVERWRITE_ALL=0

confirm_overwrite() {
    local path="$1"
    if [ "$OVERWRITE_ALL" -eq 1 ]; then return 0; fi
    if [ "$SKIP_ALL" -eq 1 ]; then return 1; fi
    printf "Overwrite '%s'? [y/N/o=overwrite-all/a=skip-all] " "$path" >&2
    read -r ans </dev/tty || ans="N"
    case "$ans" in
        y|Y) return 0 ;;
        o|O) OVERWRITE_ALL=1; return 0 ;;
        a|A) SKIP_ALL=1; return 1 ;;
        *) return 1 ;;
    esac
}

copy_file() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ]; then
        if ! confirm_overwrite "$dst"; then
            echo "  skip: $dst"
            return
        fi
    fi
    cp "$src" "$dst"
    echo "  copy: $dst"
}

copy_dir() {
    local src="$1"
    local dst="$2"
    mkdir -p "$dst"
    # rsync が使えれば理想だが、POSIX 互換で find を使う
    (cd "$src" && find . -type f) | while IFS= read -r rel; do
        rel="${rel#./}"
        copy_file "$src/$rel" "$dst/$rel"
    done
}

# ---- 実行 ----
echo "Bootstrapping spec-driven-template into: $TARGET"
echo ""

for item in "${ITEMS[@]}"; do
    src="$SCRIPT_DIR/$item"
    dst="$TARGET/$item"
    if [ ! -e "$src" ]; then
        echo "  skip (not found in template): $item"
        continue
    fi
    if [ -d "$src" ]; then
        copy_dir "$src" "$dst"
    else
        copy_file "$src" "$dst"
    fi
done

# ---- 完了メッセージ ----
cat <<EOF

Done. Next steps:

  cd "$TARGET"
  claude

  # Claude セッション内で:
  /analyze-existing-project   # 現状分析
  /fill-root-docs             # ルート docs/ の TODO を埋める
  # サブモジュール追加後:
  /generate-submodule-docs <service-name>

詳細は ONBOARDING.md を参照してください。
EOF
