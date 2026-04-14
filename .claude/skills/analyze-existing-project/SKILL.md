---
name: analyze-existing-project
description: Phase 0 - 採用先プロジェクトの現状を分析し .adoption/analysis.md にレポートする
---

# Analyze Existing Project - 既存プロジェクト分析

このスキルは spec-driven-template を採用したプロジェクトで最初に実行します。
cwd の現状を読み取り、その後の `/fill-root-docs` / `/generate-submodule-docs` で使う基礎情報を `.adoption/analysis.md` に保存します。

## 前提

- cwd が採用先プロジェクトのルートであること
- `templates/` 配下は分析対象外（雛形のため）

## 実行手順

### 1. cwd の確認

`pwd` で現在のディレクトリを確認し、これを採用先プロジェクトとして扱う旨をユーザーに告げる。

### 2. 現状の読み取り

以下を順に読む（存在するもののみ）:

- `README.md`
- `package.json` / `go.mod` / `requirements.txt` / `pyproject.toml` / `Cargo.toml` / `Gemfile` 等
- ディレクトリ構造 (`tree -L 2 -I 'node_modules|dist|.next|vendor|target'` 相当)
- 既存 `docs/` 配下の Markdown
- 既存 `CLAUDE.md` (もしあれば)
- `.gitmodules` (サブモジュール構成かを判定)
- `services/` `apps/` `packages/` などのサービスらしきディレクトリ

### 3. サブモジュール構成判定

- `.gitmodules` あり → サブモジュール構成
- `services/<name>/` または `packages/<name>/` 等が複数あり → モノレポ構成
- 単一パッケージ → スタンドアロン

判定結果は分析レポートに明記する。

### 4. 抽出する情報

- **プロダクト概要**: README から読み取れる目的・対象ユーザー
- **技術スタック**: 言語 / フレームワーク / DB / インフラ
- **サービス構成**: サブモジュール / モノレポ / スタンドアロン と、各サービス名・推定ロール
- **推定ドメイン用語**: モデル名・テーブル名・主要 URL パス等から推測される業務用語の候補
- **既存ドキュメント状況**: docs/ にあるファイルとそのカバー範囲
- **ギャップ**: spec-driven-template が前提とするドキュメント (architecture / glossary / jsox / security 等) の不足

### 5. `.adoption/` ディレクトリ作成

```bash
mkdir -p .adoption
```

### 6. `.adoption/analysis.md` 作成

以下の構成で書く:

```markdown
# プロジェクト分析レポート

生成日: YYYY-MM-DD
生成元: /analyze-existing-project

## プロダクト概要
...

## 技術スタック
- 言語:
- フレームワーク:
- DB / ストレージ:
- ビルドツール:

## サービス構成
- 構成タイプ: サブモジュール / モノレポ / スタンドアロン
- サービス一覧:
  - <name>: <推定ロール>
  - ...

## 推定ドメイン用語（候補）
| 日本語 | 英語 | 由来 |
|---|---|---|
| ... | ... | (例: src/models/Merchant.ts) |

## 既存ドキュメント状況
- docs/<file>: <要約 / カバー範囲>
- ...

## ギャップ（不足ドキュメント）
- [ ] system-architecture.md
- [ ] glossary.md
- ...

## 次ステップ推奨
1. `/fill-root-docs` でルート docs/ の TODO を埋める
2. `docs/product-requirements.md` は壁打ちで作成（Claude に直接依頼）
3. サブモジュール / サービスごとに `/generate-submodule-docs <name>` を実行
```

### 7. `.adoption/README.md` 作成

```markdown
# .adoption/

このディレクトリは spec-driven-template の採用作業用です。
`/analyze-existing-project` の出力を保存し、後続の `/fill-root-docs` /
`/generate-submodule-docs` がここを参照します。

採用作業が完了したら、このディレクトリは削除して構いません。
```

### 8. ユーザーへの提示

レポートの要約 (5-10 行) を会話に出力し、次に `/fill-root-docs` を実行するよう案内する。

## 注意事項

- `templates/` 配下は読まない・分析しない（雛形のため、採用先プロジェクトの実態と無関係）
- 不明点があれば仮定で埋めず「要確認」とマークする
- 既存 `.adoption/analysis.md` がある場合は上書き前に確認する
