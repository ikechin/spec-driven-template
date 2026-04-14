# services/

このディレクトリには **Git サブモジュール** として各サービスを配置します。

## サブモジュール構成（デフォルト）

| ディレクトリ | 役割 | リポジトリ |
|---|---|---|
| `service-a/` | <!-- TODO(claude): 役割 --> | <!-- TODO(claude): サブモジュール URL --> |
| `service-b/` | <!-- TODO --> | <!-- TODO --> |
| `service-c/` | <!-- TODO --> | <!-- TODO --> |

`service-a/b/c` はプレースホルダー名です。実際のサービス名（`frontend`, `bff`, `backend`, `api-gateway` 等）にリネームして利用してください。役割（frontend / backend / worker など）はプロジェクト依存です。

## サブモジュールの追加方法

```bash
git submodule add <repo-url> services/<service-name>
git submodule update --init --recursive
```

サブモジュール追加後は、Claude セッションで `/generate-submodule-docs <service-name>` スキルを実行することで、`templates/submodule/` 配下の雛形を `services/<name>/` に展開し、サブモジュール内のソースを読んで CLAUDE.md / docs/ の TODO を自動で埋められます。生成ファイルは**サブモジュール側のリポジトリにコミット**してください（親リポではなく）。

## モノレポ構成で使う場合

このテンプレートはサブモジュール前提ですが、モノレポでも利用可能です。`services/` を以下のように読み替えてください:

- `services/service-a` → `packages/web` / `apps/api` など実際のパッケージディレクトリ
- Agent Teams の Agent 分担はディレクトリ単位で行う

詳細は `../ONBOARDING.md` の「TIPS: サブモジュール構成でない既存プロジェクトへの対処」を参照。

## 各サービス内のドキュメント構造

各サブモジュール内には以下を配置することを推奨します:

```
services/<name>/
├── CLAUDE.md                        # サービス固有のルール（ルート CLAUDE.md を継承）
└── docs/
    ├── functional-design.md         # サービス固有の機能設計
    ├── repository-structure.md      # フォルダ構成
    └── development-guidelines.md    # コーディング規約・テスト規約
```
