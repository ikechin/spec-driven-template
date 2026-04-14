# e2e/

全サービスを統合した End-to-End テストを配置します。

## 概要

- このディレクトリは **親リポジトリ直下** に置き、サブモジュールにはしません（全サービス横断のため）
- Docker Compose で全サービスを起動した状態でテストを実行する想定
- Playwright / Cypress など任意の E2E フレームワークを利用

<!-- TODO(claude): 実際に採用する E2E フレームワーク、起動方法、ディレクトリ構造を記述してください -->

## 典型的なディレクトリ構造

```
e2e/
├── package.json / go.mod ...
├── playwright.config.ts       # または同等の設定
├── tests/
│   ├── auth/
│   └── <feature>/
└── README.md
```

## Agent Teams での位置付け

CLAUDE.md の「Agent 分担」で **E2E Test Agent** が担当します。Phase 4（統合確認・テスト）のフェーズで、他サービスの実装完了後に起動されます。

Orchestrator から E2E Test Agent への wake-up DM には以下を含めます:

- 各サービスの起動コマンド
- テスト対象のユーザーフロー
- テストデータ（seed）の有無
- 認証情報（テストユーザー）

詳細なハンドオフルール: [`../docs/lessons-learned.md#ハンドオフの必須ルール`](../docs/lessons-learned.md#ハンドオフの必須ルール)

## 実行方法

<!-- TODO(claude): 実プロジェクトの実行コマンドを記述 -->

```bash
# 例
docker compose up -d
cd e2e && npm install && npx playwright test
```
