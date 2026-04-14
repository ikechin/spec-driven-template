---
name: fill-root-docs
description: Phase 1 - .adoption/analysis.md を元にルート docs/ の TODO プレースホルダを埋める
---

# Fill Root Docs - ルートドキュメントの TODO 埋め

このスキルは `/analyze-existing-project` の後に実行します。
`.adoption/analysis.md` の分析結果を使って、ルート `docs/` 配下と `CLAUDE.md` の `<!-- TODO(claude): ... -->` プレースホルダを具体化します。

## 前提

- `/analyze-existing-project` 実行済みであること
- `.adoption/analysis.md` が存在すること

## 対象ファイル

### 埋め込み対象（TODO を具体内容で置換）

- `docs/system-architecture.md`
- `docs/glossary.md`
- `docs/ENVIRONMENT.md`
- ルート `CLAUDE.md`（ドメイン用語 / サブモジュール URL / サービス名プレースホルダ部分のみ）

### 対象外（触らない）

- `docs/product-requirements.md`
  - ユーザーが**壁打ちで別途作成する**ため、このスキルでは触らない
  - 既存ファイルがあり内容が不足している場合は「Claude に壁打ちで作成を依頼することを推奨。既存内容が薄ければ削除も検討」と案内するに留める
- `docs/jsox-compliance.md` / `docs/security-guidelines.md` / `docs/service-contracts.md`
  - これらは横断的要件の定型ドキュメントで、内容は維持する
  - 冒頭に `<!-- TODO(claude): ... -->` 形式の説明バナーがあれば**削除のみ**実施する
- `templates/` 配下すべて
  - サブモジュール用雛形なので、ここでは触らない（`/generate-submodule-docs` が扱う）

## 実行手順

### 1. 前提チェック

`.adoption/analysis.md` の存在を確認。なければ:

> `/analyze-existing-project` を先に実行してください。

と案内して終了。

### 2. `.adoption/analysis.md` を読む

分析結果（プロダクト概要・技術スタック・サービス構成・ドメイン用語候補）を読み込み、置換に使う情報として頭に入れる。

### 3. 各ファイルの処理

対象ファイルそれぞれについて以下を実施:

1. ファイルを読む
2. 既存ファイルがある場合は **置換差分をユーザーにプレビュー** し、上書き許可 (y/N) を取る
3. `<!-- TODO(claude): ... -->` コメントを分析結果から得た具体的な内容で置換
4. 置換後は TODO コメント自体を削除（残骸を残さない）
5. 置換に必要な情報が分析レポートに無い場合は、その箇所を「TODO(human): 要確認」に変換し、ユーザーに後で埋めてもらう

### 4. 対象外ファイルの処理

- `docs/jsox-compliance.md` / `docs/security-guidelines.md` / `docs/service-contracts.md`
  - 冒頭の TODO バナーがあれば削除
  - 本文は変更しない
- `docs/product-requirements.md`
  - 既存ファイルが薄い場合は警告のみ。削除や上書きはしない
- `templates/` 配下
  - 完全に無視

### 5. サマリ提示

最後に変更ファイル一覧と次ステップを提示:

```
変更ファイル:
- docs/system-architecture.md (TODO 5 件埋め込み)
- docs/glossary.md (用語 8 件追加)
- docs/ENVIRONMENT.md (ポート / 環境変数を更新)
- CLAUDE.md (サービス名プレースホルダを置換)

次ステップ:
1. docs/product-requirements.md は Claude に壁打ちで作成を依頼してください
   ("product-requirements.md を壁打ちで作成したい" と伝える)
2. サブモジュールを追加 (`git submodule add ...`)
3. 各サービスに対して `/generate-submodule-docs <service-name>` を実行
```

## 注意事項

- 既存ファイルの上書きは必ずユーザー確認を取る（差分プレビュー → y/N）
- 仮定で埋めない。情報がない場合は `TODO(human)` で残す
- `templates/` には絶対に触らない
