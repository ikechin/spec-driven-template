---
name: generate-submodule-docs
description: Phase 2 - templates/submodule/ を指定サービスに展開し TODO を埋める
---

# Generate Submodule Docs - サブモジュール用ドキュメント生成

このスキルは `templates/submodule/` 配下の 4 ファイル雛形を `services/<name>/` にコピーし、サブモジュール内のソースコードを読んで TODO を埋めます。

## 引数

サービス名（例: `service-a`, `frontend`, `payment-api`）。
引数が無い場合はユーザーに尋ねる。

## 前提

- `templates/submodule/` 配下に CLAUDE.md / docs/functional-design.md / docs/repository-structure.md / docs/development-guidelines.md が存在すること
- 対象サービスのソースコードがローカルに存在すること（サブモジュール init 済み or モノレポのディレクトリが存在）

## 実行手順

### 1. 引数取得

ユーザーから `<service-name>` を取得。なければ尋ねる。

### 2. サブモジュール状態判定

以下の 3 ケースで分岐:

#### ケース A: `.gitmodules` に登録済み

- 通常モードで進める
- `services/<name>/` 配下に既存ファイルがあるかを確認

#### ケース B: `.gitmodules` 未登録だが `services/<name>/` ディレクトリは存在

- モノレポ構成と判断し通常モードで進める
- ユーザーに以下の warning を出力:
  > `services/<name>/` はサブモジュール未登録です。モノレポ構成として処理を続行します。

#### ケース C: `services/<name>/` ディレクトリ自体が存在しない

- `services/<name>/` を作成
- 雛形をコピーして TODO を埋める（ソースが無いので埋められる箇所は限定的）
- 完了後、ユーザーに以下を促す:
  > サブモジュールを追加してください:
  > `git submodule add <repository-url> services/<name>`
  > 追加後にこのスキルを再実行すると、ソースコードを元に TODO を再生成できます。

### 3. ファイルコピー

`templates/submodule/` 配下の 4 ファイルを `services/<name>/` 配下にコピー:

| コピー元 | コピー先 |
|---|---|
| `templates/submodule/CLAUDE.md` | `services/<name>/CLAUDE.md` |
| `templates/submodule/docs/functional-design.md` | `services/<name>/docs/functional-design.md` |
| `templates/submodule/docs/repository-structure.md` | `services/<name>/docs/repository-structure.md` |
| `templates/submodule/docs/development-guidelines.md` | `services/<name>/docs/development-guidelines.md` |

**既存ファイルがある場合は上書き前にユーザー確認 (y/N)。**

### 4. TODO の埋め込み

コピー先の各ファイルで `<!-- TODO(claude): ... -->` コメントを処理する。
サブモジュール内の以下を読んで具体内容を生成:

- `package.json` / `go.mod` / `requirements.txt` 等 → 技術スタック・ビルドコマンド
- 既存 `README.md` → サービス概要
- ソースディレクトリ (`src/`, `cmd/`, `pages/`, `app/` 等) → コンポーネント設計・レイヤ構成
- ルーティング定義ファイル → API 一覧
- `tree -L 2` 相当 → ディレクトリ構成
- lint/format 設定ファイル (`.eslintrc`, `.golangci.yml`, `prettier.config.*`) → コーディング規約
- テスト関連ファイル → テスト規約

埋められない箇所は `TODO(human): 要確認` に置換する。
処理後は TODO(claude) コメント自体を削除する。

### 5. 完了案内（重要）

ユーザーに**必ず**以下を案内する:

```
✅ services/<name>/ にドキュメントを生成しました。

⚠️ 重要: これらのファイルはサブモジュールリポジトリ側にコミットしてください。

  cd services/<name>
  git add CLAUDE.md docs/
  git commit -m "Add service documentation from spec-driven-template"
  git push origin <branch>

その後、親リポジトリ側で submodule reference を更新してください:

  cd <親リポルート>
  git add services/<name>
  git commit -m "Update <name> submodule reference"
```

ケース B（モノレポ）の場合はサブモジュールではないため、親リポで通常通り `git add services/<name>` のみで OK と案内する。

## 注意事項

- サブモジュール内のファイルは**サブモジュール側にコミット**する必要がある（親リポではない）
- 親リポでは submodule reference の更新のみコミット
- 既存ファイルの上書きは必ずユーザー確認
- 不明な箇所は `TODO(human): 要確認` で残す
