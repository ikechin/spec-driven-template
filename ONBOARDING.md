# ONBOARDING: 既存プロジェクトへの導入ガイド

このキットは **既にコードが少し進んでいる既存プロジェクト** に後付けで SPEC 駆動開発 + Agent Teams 運用を導入するためのものです。新規プロジェクトでも同じ手順で使えます。

---

## 1. 前提

- 既存プロジェクトのルートディレクトリが存在する
- Claude Code がインストール済み
- プロジェクトに README / package.json / ソースコードなど、現状を把握できる情報がある

---

## 2. コピー手順

このテンプレートの以下をプロジェクトルートへコピーしてください:

```bash
TEMPLATE=/path/to/spec-driven-template
PROJECT=/path/to/your-project

cp    $TEMPLATE/CLAUDE.md              $PROJECT/CLAUDE.md
cp -r $TEMPLATE/docs                   $PROJECT/docs
cp -r $TEMPLATE/.steering              $PROJECT/.steering
cp -r $TEMPLATE/.claude                $PROJECT/.claude
cp -r $TEMPLATE/contracts              $PROJECT/contracts
cp    $TEMPLATE/services/README.md     $PROJECT/services/README.md   # 既存 services/ がある場合のみ
```

既存ファイルを上書きする前には必ず diff を取り、失われる情報がないか確認してください。

---

## 3. Claude に現状分析と TODO 埋めを依頼する

キットをコピーしたら、新しい Claude Code セッションを開き以下のプロンプトを渡してください:

> このプロジェクトの README, package.json, ディレクトリ構造, 既存ドキュメントを読んで、
> `CLAUDE.md` および `docs/` 配下の `<!-- TODO(claude): ... -->` コメントを埋めてください。
> 特に以下を現状のコードに合わせて具体化してください:
> - サービス名 (`service-a/b/c` → 実際のサービス名)
> - ドメイン用語 (`docs/glossary.md`)
> - ポート番号・環境変数 (`docs/ENVIRONMENT.md`)
> - プロダクト要求 (`docs/product-requirements.md`)
> - システムアーキテクチャ (`docs/system-architecture.md`)
> 不明点は質問してください。勝手に仮定で埋めないでください。

Claude は TODO を順に処理し、確信が持てない箇所では質問してきます。1 ファイルずつレビュー・承認しながら進めることを推奨します。

---

## 4. 初回ステアリングの作成

ドキュメントが揃ったら、最初のステアリングを作成します:

```bash
mkdir -p .steering/$(date +%Y%m%d)-initial-adoption
cp .steering/_template/*.md .steering/$(date +%Y%m%d)-initial-adoption/
```

または `/plan-task` スキルを使って対話的に生成してください。初回ステアリングは「既存コードの現状整理 + 次に着手するタスク」として書くのがおすすめです。

---

## 5. 以降の開発フロー

以降は [`docs/development-workflow.md`](docs/development-workflow.md) に沿って 6 Phase のサイクルを回してください。

1. `/plan-task` → ステアリング作成
2. `/review-steering` → ステアリング品質チェック
3. `/start-implementation` → Agent Teams 並行実装
4. `/review-implementation` → 実装レビュー
5. `/prepare-pr` → PR 作成
6. `/retrospective` → 振り返り

---

## 6. TIPS: サブモジュール構成でない既存プロジェクトへの適用

このキットはデフォルトで `services/service-a`, `service-b`, `service-c` を Git サブモジュールとして扱う前提ですが、**モノレポ構成** や **単一パッケージ構成** でも利用できます。

### モノレポの場合

- `services/service-a/` などのパスを、実際のサービスディレクトリ (例: `packages/web`, `apps/api`) に読み替える
- `CLAUDE.md` の「サブモジュール初期化」セクションは削除 / 該当しない旨を追記
- Agent Teams の Agent 分担は **ディレクトリ単位** で行う（同じリポジトリ内でもパスで分ければ並行編集可能）

### 単一パッケージの場合

- Agent Teams は原則不要。`CLAUDE.md` のパターン 3（単一 Agent）を使う
- ステアリング + `/plan-task` / `/review-implementation` / `/retrospective` のサイクルだけでも十分に価値がある

---

## 7. 次のアクション

- [ ] このキットをプロジェクトにコピー
- [ ] Claude に TODO 埋めを依頼
- [ ] 生成されたドキュメントをレビュー・承認
- [ ] 初回ステアリングを作成
- [ ] `docs/development-workflow.md` を読んでワークフローを把握
- [ ] `docs/lessons-learned.md` を読んで過去の失敗パターンを学ぶ
