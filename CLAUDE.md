# CLAUDE.md (プロジェクトメモリ)

## 🚀 新しいセッション・新しい開発者へ

**コンテキストがクリーンな状態でこのプロジェクトを開始する場合は、まず [`docs/QUICKSTART.md`](docs/QUICKSTART.md) を読んでください。**

また、Agent Teams 運用上の過去の失敗と学びは [`docs/lessons-learned.md`](docs/lessons-learned.md) に集約されています。CLAUDE.md 内の各セクションから参照されます。

---

## 概要
開発を進めるうえで遵守すべき標準ルールを定義します。

このプロジェクトは**マイクロサービスアーキテクチャ**を採用しており、複数のサービスが協調して動作します。
各サービスは独立したドキュメント構造を持ちつつ、このルート CLAUDE.md の規則を継承します。

<!-- TODO(claude): モノレポ等、サブモジュール構成でない場合は、このセクションをプロジェクトの実構成に合わせて書き換えてください -->

### 重要なドキュメントリンク
- **[`docs/QUICKSTART.md`](docs/QUICKSTART.md)** - 新セッション開始時はここから（最優先）
- **[`docs/lessons-learned.md`](docs/lessons-learned.md)** - 過去プロジェクトの失敗と学び（Agent Teams 運用ノウハウ）
- **[`docs/development-workflow.md`](docs/development-workflow.md)** - 開発ワークフロー全体像（SPEC 駆動型開発の手順ガイド）
- **[`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md)** - ポート番号・環境変数のチートシート

## マイクロサービス構成

### ⚠️ 重要: サブモジュール構成

このプロジェクトは **Git サブモジュール**構成を想定しています（モノレポの場合は読み替えてください）。
各サービスは独立した Git リポジトリとして管理することで、実環境のマイクロサービス開発に近い構成を取ります。

**サブモジュールリポジトリ:**
- **services/service-a/**: <!-- TODO(claude): サブモジュールURL -->
- **services/service-b/**: <!-- TODO(claude): サブモジュールURL -->
- **services/service-c/**: <!-- TODO(claude): サブモジュールURL -->

**サブモジュールの初期化（新しいクローン時）:**
```bash
git clone <this-repo>
cd <this-repo>
git submodule update --init --recursive
```

### サービス一覧

<!-- TODO(claude): 実際のサービス構成・役割（frontend / BFF / backend 等）に置き換えてください。
     役割（Frontend / BFF / Backend）はプロジェクト依存です。単に "service-a が <何>を担当" のように書き直してください -->

- **service-a**: <!-- TODO(claude): このサービスの責務 -->
- **service-b**: <!-- TODO(claude): このサービスの責務 -->
- **service-c**: <!-- TODO(claude): このサービスの責務 -->

### Agent 分担（Agent Teams 運用時）
- **Orchestrator Agent**: 全体調整、ルートの `docs/` と `.steering/` を管理
- **Service-A Agent**: `services/service-a/` を担当
- **Service-B Agent**: `services/service-b/` を担当
- **Service-C Agent**: `services/service-c/` を担当
- **E2E Test Agent**: `e2e/` を担当、全サービス統合テストを実装
- **QA/Security Agent**: 横断的な品質・セキュリティチェック

> **補足:** Agent の役割（frontend / BFF / backend / worker など）はプロジェクト依存です。上記は汎用名なので、実プロジェクトに合わせて読み替えるか CLAUDE.md を書き換えてください。

### Agent 間の協調ルール
1. **契約ファーストアプローチ**: API 契約は `contracts/` で一元管理し、各 Agent が参照
2. **用語統一**: `docs/glossary.md` の用語を全 Agent が遵守
3. **横断的要件**: コンプライアンス・セキュリティ要件は `docs/` で定義し、各サービスで実装
4. **変更影響分析**: 1 つのサービス変更が他サービスに影響する場合、ルートの `.steering/` で調整
5. **並行開発**: 各 Agent は独立して作業可能だが、定期的に統合確認

### Agent Teams 運用方針

#### 使用フェーズ
**Agent Teams は実装フェーズでのみ使用します（コスト最適化のため）**

- ❌ **ドキュメント作成フェーズ**: 通常の Claude Code（単一 Agent）で順次作成
- ✅ **実装フェーズ**: Claude Code Agent Teams 機能で並行実装

#### Orchestrator の運用ルール（必須）

**Agent Teams を使用する際は、以下のルールを必ず遵守すること：**

1. **Orchestrator（リーダー Agent）は常にユーザー応答可能な状態を維持する**
   - `TeamCreate` でチーム context を作成し、`Agent` ツールに `team_name` を指定して各メンバーを spawn する
   - 子 Agent からのメッセージ・idle 通知は新しい会話ターンとして**自動配信**されるため、Orchestrator は他の作業をしながらメンバーの完了を待てる
   - ユーザーの質問にいつでも応答できる状態を維持する

2. **ユーザーへの進捗報告**
   - ユーザーから進捗を聞かれた場合、各 Agent の状態（実行中/完了/失敗）を報告する
   - 開発途中でもユーザーの質問に回答する（Agent の完了を待たない）

3. **Orchestrator の事前作業**
   - **`TeamCreate` でチーム context を作成** (専用 TaskList が同時に作られる)
   - API 契約（Proto/OpenAPI）の確定
   - 各サブモジュールで feature ブランチの作成
   - **横断的制約リスト**を収集 (rate limit / セッション / middleware / seed データ / 構造化エラー規約 等) — 各 Agent 起動プロンプトに埋め込む
   - `TaskCreate` でチーム共有タスクリストに各 Agent 担当タスクを作成
   - `Agent` ツールに **`team_name` 必須指定**で各メンバーを spawn
   - `TaskUpdate(owner=...)` でタスクをメンバーに割り当て

#### Agent Teams の正しい使い方（`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`）

**重要な前提:**
真の Agent Teams は `TeamCreate` でチーム context を作成し、その中に `Agent` ツールで `team_name` を指定してメンバーを spawn することで成立する。
**`TeamCreate` を呼ばず、`team_name` も指定しない場合、ただの並列バックグラウンド subagent でしかなく、子 Agent 同士の `SendMessage` 直接通信は成立しない。**
（詳細と過去の失敗事例: [`docs/lessons-learned.md#phase-2-で何が間違っていたか`](docs/lessons-learned.md#phase-2-で何が間違っていたか)）

##### 起動フロー（必須順序）

```
1. TeamCreate(team_name="<task-name>", description="...")
   → ~/.claude/teams/<task-name>/config.json と
     ~/.claude/tasks/<task-name>/ が同時作成される
   → Team = TaskList の 1:1 対応

2. TaskCreate(...) でチーム共有タスクを作成
   → 自動的に当該チームの TaskList に登録される

3. Agent(
     subagent_type="general-purpose",
     name="service-a-agent",
     team_name="<task-name>",   ← 必須
     prompt="...",
   )
   各メンバーを同様に spawn
   → 子 Agent は team config の members 配列に登録され、
     互いを name で参照できるようになる

4. TaskUpdate(taskId="X", owner="service-a-agent")

5. メンバーが作業 → TaskUpdate で完了マーク → 自動的に idle 通知

6. 全タスク完了 → **実装レビュー → レビュー指摘の修正まで同一 Team で実行**

7. レビュー修正まで完了後に shutdown:
   SendMessage({to: "*", message: {type: "shutdown_request"}})

8. TeamDelete でチーム context とタスクディレクトリをクリーンアップ
```

##### 長寿命 Team パターン（実装 → レビュー → 修正まで Team を維持）

タスク完了即 shutdown ではなく、**レビュー + 修正完了まで Team を維持する**。コンテキスト再ロードコストをゼロにでき、複数指摘を並列 DM で短時間に解消できる。

詳細: [`docs/lessons-learned.md#長寿命-team-パターン`](docs/lessons-learned.md#長寿命-team-パターン)

##### 重要な仕様

**メッセージは自動配信される:**
- 子 Agent からのメッセージは新しい会話ターンとして Orchestrator に自動的に届く
- inbox を確認する必要はない
- ファイルシステム (`git status`) で間接的に進捗を覗き見る必要もない

**Peer DM の可視性:**
- 子 Agent 同士の DM は、送信側の idle 通知に「サマリ」が含まれて Orchestrator にも見える
- 詳細本文は見えないので、重要決定は Orchestrator にも CC するのが望ましい

**Idle は正常状態:**
- Agent は 1 ターンごとに idle になる — これは「終了」ではなく「次の入力待ち」
- Idle 通知が来ても **「Agent が終わった」と誤解しない**
- Idle Agent に SendMessage すると wake up して次のターンを実行する

**broadcast (`to: "*"`) は高コスト:**
- メンバー数に線形で課金される
- 全員に本当に必要な情報のみに限定する

##### 通信ルール

1. **Orchestrator 経由が必須のケース（方針・最終決定）**
   - 設計方針の変更・新規方針の決定（例: エラーコード体系の変更、新しい認証方式）
   - API 契約の変更（Proto/OpenAPI を物理ファイルとして修正する場合）
   - 複数 Agent にまたがる横断的課題で方向性を決めかねるとき
   - スコープ外の追加要求

2. **Agent 間 DM が必須のケース — 実装の暗黙前提共有（フルメッシュ）**
   各 Agent は以下を発見・決定した時点で、関係する Agent（および Orchestrator に CC）へ **SendMessage で即座に発信する義務** を負う:
   - **クエリ・条件式のハードコード**（例: `WHERE status='PENDING'`）
   - **レスポンス形状の選択**（フィールド命名、optional/required、null 表現）
   - **エラー区分の追加・変更**（新しいエラーコード、HTTP ステータス、構造化エラー Reason）
   - **バリデーションの境界値**（min/max、形式、空文字の扱い）
   - **権限・認可の判定基準**
   - **横断的制約の発見**（rate limit、セッション、middleware の挙動）

3. **Agent 間 DM が推奨のケース（事実確認）**
   - 実装済みのメソッド名・型名・フィールド名の確認
   - 既存コードのパターン確認
   - テストデータの確認

4. **発信のお作法**
   - **設計判断ログ**: 1〜3 行の簡潔な要約をコミット前に関係 Agent に DM する
   - **plain text で送る** — 構造化 JSON ステータスは禁止
   - **TaskUpdate で進捗管理** — 完了は SendMessage ではなく `TaskUpdate(status="completed")` で
   - **設計変更が必要と判明したら**勝手に決めず Orchestrator に上げる
   - **broadcast (`to: "*"`) は最終手段**

##### Orchestrator が各 Agent 起動時に伝える指示の例

```
あなたは <name> Agent (<役割>) です。

【Agent 間通信 - フルメッシュ型 Agent Teams】
- チーム名: <team-name>
- チーム config: ~/.claude/teams/<team-name>/config.json (members を Read で確認可能)
- 他のメンバーには SendMessage({to: "<name>", message: "...", summary: "..."}) で
  直接 DM 可能。積極的に活用すること
- 自分宛のメッセージは自動配信される (inbox 確認不要)
- TaskList を定期的に確認し、自分に割り当てられたタスクを TaskUpdate で進める
- 完了は TaskUpdate(status="completed") でマーク

【発信義務 - 以下を発見・決定した時点で関係 Agent に即 DM する】
* クエリ・条件式のハードコード
* レスポンス形状の選択
* エラー区分の追加・変更
* バリデーション境界値、権限判定基準、横断的制約の発見

【横断的制約 (事前共有事項)】
<Orchestrator が事前に収集したもの>
```

##### 依存関係のある Agent 間のハンドオフ

**子 Agent は他 Agent の `TaskUpdate(completed)` を自律的に検知しません**。下流 Agent は上流 Agent の完了を自動検出しないため、**Orchestrator が明示的な wake-up DM を送る** 必要があります。

詳細と過去の失敗事例: [`docs/lessons-learned.md#ハンドオフの必須ルール`](docs/lessons-learned.md#ハンドオフの必須ルール)

#### 依存関係に応じたフェーズ分け実行

**全 Agent を常に同時起動するのではなく、依存関係に応じて段階的に起動する。**

**パターン 1: API 契約が確定済み → 全 Agent 並行起動**
**パターン 2: 特定サービス実装に依存する場合 → 段階的起動**
**パターン 3: 単一サービス内の変更 → 単一 Agent**

**判断基準:**
- API 契約が事前確定できる → パターン 1（並行）
- 新しい gRPC/REST の設計が必要 → パターン 2（段階的）
- 影響が 1 サービス内 → パターン 3（単一 Agent）

パターン 3 を選ぶべきケースの詳細判定基準: [`docs/lessons-learned.md#パターン-3-単一-agent-を選ぶべきケース`](docs/lessons-learned.md#パターン-3-単一-agent-を選ぶべきケース)

#### 設計段階の実測検証ルール

**design.md で「〜できない」「〜が必要」と断定する箇所は、実装前に実測 1 回で検証すること。** 5 分以内に検証できる断定は検証する。検証できない断定は「仮説」と明示する。

詳細と実例: [`docs/lessons-learned.md#設計段階の実測検証ルール`](docs/lessons-learned.md#設計段階の実測検証ルール)

#### レビュー・修正フェーズの Agent 活用

**実装完了後のレビュー・修正も Agent に委任できる。**

1. **レビュー**: 各サービスのレビュー Agent を並行起動し、差分ベースでチェック
2. **修正**: レビュー指摘をサービス別の修正 Agent に並行で委任
3. **E2E テスト**: 統合動作確認後に E2E Agent 起動

**注意:** レビュー・修正 Agent は実装 Agent とは別に起動する（コンテキストが汚染されないため）。ただし「長寿命 Team パターン」を使う場合は同一 Team 内で続行する（上記参照）。

#### 実装フェーズでの Agent Teams 活用

**前提条件：**
- すべてのドキュメントが完成していること
- `.steering/[YYYYMMDD]-[開発タイトル]/tasklist.md` で Agent 別タスクが定義されていること
- API 契約（`contracts/`）の方針が確定していること

**実行方法：**
```
1. settings.json に CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 を設定
2. TeamCreate でチーム context を作成
3. TaskCreate でチーム共有タスクを作成
4. Agent ツールに team_name 必須指定で各メンバーを spawn
5. TaskUpdate でタスクを各メンバーに割り当て
6. メンバー作業完了 → 自動 idle 通知
7. 実装レビュー → 指摘修正も同一 Team で実行
8. SendMessage({to: "*", message: {type: "shutdown_request"}}) で全員停止
9. TeamDelete でクリーンアップ
```

#### Agent 別の責務

<!-- TODO(claude): 実プロジェクトの Agent 構成に合わせてこのセクションを書き直してください -->

**Service-A Agent:**
- `services/service-a/` 配下の実装
- `services/service-a/CLAUDE.md` と `services/service-a/docs/` に従う
- `contracts/` の API 仕様を参照

**Service-B Agent / Service-C Agent:** 同様

**E2E Test Agent:**
- `e2e/` 配下の実装
- Docker Compose 等で全サービスを起動してテスト実行
- Frontend/BFF/Backend 全体のユーザーフローテスト

## プロジェクト構造

### ドキュメントの分類

#### 1. ルート永続的ドキュメント（`docs/`）

**マイクロサービス全体**の「**何を作るか**」「**どう作るか**」を定義する恒久的なドキュメント。

- **product-requirements.md** - システム全体のプロダクト要求定義書
- **system-architecture.md** - システムアーキテクチャ設計書
- **glossary.md** - ユビキタス言語定義（全サービス共通）
- **jsox-compliance.md** - コンプライアンス対応設計書（該当する場合）
- **security-guidelines.md** - セキュリティガイドライン
- **service-contracts.md** - サービス間 API 契約方針
- **lessons-learned.md** - 過去プロジェクトの失敗と学び

#### 2. サービス別永続的ドキュメント（`services/{service}/docs/`）

各サービス固有の設計を定義。

- **functional-design.md** - サービス固有の機能設計
- **repository-structure.md** - サービス内のリポジトリ構造
- **development-guidelines.md** - サービス固有の開発ガイドライン

#### 3. 作業単位のドキュメント（`.steering/[YYYYMMDD]-[開発タイトル]/`）

特定の開発作業における「**今回何をするか**」を定義する一時的なステアリングファイル。

- **requirements.md** - 今回の作業の要求内容
- **design.md** - 変更内容の設計
- **tasklist.md** - タスクリスト（Agent 別に分担）

テンプレート: [`.steering/_template/`](.steering/_template/)

### ステアリングディレクトリの命名規則

```
.steering/[YYYYMMDD]-[開発タイトル]/
```

## 開発プロセス

詳細は [`docs/development-workflow.md`](docs/development-workflow.md) を参照してください。

### 開発フェーズの区分

#### フェーズ 1: ドキュメント作成（Agent Teams 不使用）
単一 Agent が順次作成。各ドキュメント作成後、承認を得てから次へ進む。

#### フェーズ 2: 実装（Agent Teams 使用）
複数 Agent が並行作業。Orchestrator が全体調整。

## ドキュメント管理の原則

### ルート永続的ドキュメント（`docs/`）
- **マイクロサービス全体**の基本設計を記述
- 全 Agent・全サービスが参照する「北極星」
- 頻繁に更新されない、大きなアーキテクチャ変更時のみ更新

### サービス別永続的ドキュメント（`services/{service}/docs/`）
- 各サービス固有の設計を記述
- 担当 Agent が主に参照・更新

### 作業単位のドキュメント（`.steering/`）
- 作業ごとに新しいディレクトリを作成
- Agent 別のタスク分担を明記
- 作業完了後は履歴として保持

### Agent 間のドキュメント共有ルール
1. **用語**: `docs/glossary.md` を全 Agent が遵守
2. **API 契約**: `contracts/` に配置し、全 Agent が参照
3. **横断的要件**: `docs/` 配下の要件ドキュメントを全 Agent が実装
4. **変更通知**: あるAgent の変更が他 Agent に影響する場合、ルートの `.steering/` で調整

## 図表・ダイアグラムの記載ルール

設計図やダイアグラムは、関連する永続的ドキュメント内に直接記載します。独立した diagrams フォルダは作成しません。

**推奨形式:**
1. **Mermaid 記法**（推奨）
2. **ASCII アート**（シンプルな図表）
3. **画像ファイル**（複雑なワイヤフレームのみ、`docs/images/`）

## 注意事項

- ドキュメントの作成・更新は段階的に行い、各段階で承認を得る
- `.steering/` のディレクトリ名は日付と開発タイトルで明確に識別できるようにする
- 永続的ドキュメントと作業単位のドキュメントを混同しない
- コード変更後は必ずリント・型チェックを実施する
- セキュリティを考慮したコーディング（XSS 対策、入力バリデーションなど）
- 図表は必要最小限に留め、メンテナンスコストを抑える
