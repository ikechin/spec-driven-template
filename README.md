# SPEC-driven Development + Agent Teams Template

SPEC駆動開発 と Claude Code Agent Teams 運用の知見をまとめた、既存プロジェクトへコピーして使う雛形キットです。

## 目的

- **SPEC駆動開発** の手順（requirements → design → tasklist → 実装 → レビュー → 振り返り）をチーム共通のワークフローとして導入する
- **Claude Code Agent Teams** を正しく運用するためのルール・スキル・ドキュメントテンプレを提供する
- 過去プロジェクトの失敗と学び（`docs/lessons-learned.md`）を流用し、同じ失敗を繰り返さない

## 対象

- マイクロサービス構成（Git サブモジュール前提）の新規/既存プロジェクト
- モノレポ構成でも `services/` を読み替えて利用可能（ONBOARDING.md 参照）

## 含まれるもの

| パス | 内容 |
|---|---|
| `CLAUDE.md` | プロジェクトメモリ雛形。Agent Teams 運用ルール込み |
| `docs/` | 永続ドキュメント雛形（要求/アーキ/用語/J-SOX/セキュリティ/契約方針）|
| `docs/lessons-learned.md` | 過去プロジェクト由来の運用ノウハウ（Agent Teams 失敗学）|
| `docs/QUICKSTART.md` | 新セッション開始時の最短導線 |
| `docs/development-workflow.md` | 6 Phase 開発ワークフローの全体像 |
| `.steering/_template/` | ステアリングファイル雛形 (requirements/design/tasklist) |
| `.claude/skills/` | `/plan-task`, `/start-implementation` など 13 個のスキル |
| `contracts/` | OpenAPI / Proto / 共通型の配置場所 |
| `templates/submodule/` | サブモジュール展開用の CLAUDE.md / docs 雛形。`/generate-submodule-docs` がここを使う |
| `bootstrap.sh` | キットを採用先プロジェクトにコピーするスクリプト |

## 使い方

[`ONBOARDING.md`](ONBOARDING.md) を参照してください。基本フロー:

```bash
git clone <this-template-repo> /tmp/spec-driven-template
/tmp/spec-driven-template/bootstrap.sh /path/to/your-project
cd /path/to/your-project && claude
# Claude セッション内で:
#   /analyze-existing-project → /fill-root-docs → /generate-submodule-docs <name>
```

`bootstrap.sh` がキットをコピーし、3 つの adoption スキル (`/analyze-existing-project`, `/fill-root-docs`, `/generate-submodule-docs`) が既存コードを読んで TODO(claude) プレースホルダを埋めます。
