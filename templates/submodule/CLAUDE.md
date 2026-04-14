# CLAUDE.md (サービスメモリ)

<!-- TODO(claude): このファイルは `templates/submodule/` から生成されたサービスメモリ雛形です。
     `/generate-submodule-docs <service-name>` 実行時に Claude が以下の TODO を埋めます。
     親リポジトリの `CLAUDE.md` のルールを継承し、サービス固有の事項のみをここに記述してください。 -->

<!-- 役割決定時のガイダンス:
     親プロジェクトの `CLAUDE.md` および `docs/system-architecture.md` を確認して、
     このサービスのロール (frontend / BFF / backend / api-gateway / worker など) を特定し、
     以下の項目を埋めてください:
       - サービス概要 (このファイル)
       - Agent Teams 参加時の関連 Agent リスト
       - 技術スタック (実コードから抽出)
     汎用名 service-a/b/c を実名 (例: web / api / order-service) に置き換える場合、
     親リポの該当箇所も同期して更新する必要があります。 -->

## サービス概要

<!-- TODO(claude): サービスの責務を 1-2 文で記述。
     例: "加盟店管理ドメインのビジネスロジックとデータ永続化を担当する Backend サービス。"
     既存の README.md / package.json description / go.mod の module 名から推定すること。 -->

## 親プロジェクトのルール継承

このサービスは親リポジトリのルールを継承します。実装前に必ず以下を参照してください:

- [親 CLAUDE.md](../../CLAUDE.md) — Agent Teams 運用ルール、ドキュメント管理原則
- [docs/glossary.md](../../docs/glossary.md) — ユビキタス言語（命名はこれに従う）
- [docs/jsox-compliance.md](../../docs/jsox-compliance.md) — J-SOX 対応要件
- [docs/security-guidelines.md](../../docs/security-guidelines.md) — セキュリティ要件
- [docs/service-contracts.md](../../docs/service-contracts.md) — API 契約方針

## 技術スタック

<!-- TODO(claude): 以下を実調査して埋めること。
     - 言語 / ランタイム (package.json engines, go.mod の go version, requirements.txt 等)
     - 主要フレームワーク (Next.js, NestJS, Gin, FastAPI, etc.)
     - 主要ライブラリ (ORM, HTTP クライアント, バリデーション)
     - テストフレームワーク
     - ビルド/パッケージマネージャ (npm/pnpm/yarn/go mod/poetry)
     箇条書きでよい。 -->

## サービス固有ルール

<!-- TODO(claude): このサービスでのみ適用されるコーディング規約・運用ルール。
     例:
     - DI コンテナの使い方
     - エラーハンドリング規約
     - ログ出力規約
     - DB トランザクション境界
     既存ソースの src/ 配下を読んで実態に合わせること。判断できない場合は省略可。 -->

## Agent Teams 参加時の注意

このサービスを担当する Agent (例: `<service-name>-agent`) は、以下の発信義務を負います:

- クエリ・条件式のハードコード（例: `WHERE status='PENDING'`）→ 関係 Agent に即 DM
- レスポンス形状の選択（フィールド命名、null 表現）→ BFF / Frontend Agent に DM
- エラー区分の追加・変更 → 全関係 Agent に DM
- バリデーション境界値、権限判定基準 → 関係 Agent に DM

詳細は親 [CLAUDE.md](../../CLAUDE.md) の「Agent 間 DM が必須のケース」を参照。
