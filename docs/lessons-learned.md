# Lessons Learned: Agent Teams 運用の失敗と学び

このドキュメントは Agent Teams 運用の過去の失敗と学びを集約したものです。`CLAUDE.md` の各セクションから詳細リンクとして参照される、深堀り用のリファレンスです。

運用ルールの「なぜ」を理解したいとき、または新しいプロジェクトで同じ失敗を繰り返さないために参照してください。

---

## 長寿命 Team パターン

### 背景

過去プロジェクトでは、タスク完了時点で Team を即 shutdown し、その後レビューを別セッションで行っていた。結果として:

- 実装 Agent のコンテキストが失われ、レビュー指摘の修正時にコードベースを再把握する必要があった
- 複数の Medium/Low 指摘を並列で解消できず、修正フェーズが不必要に長引いた
- Agent 間の設計判断ログが失われ、修正時に同じ議論を再度する羽目になった

### ルール

**Team を「実装 → レビュー → 修正完了」まで維持する。** タスク #N completed → 即 shutdown ではなく、レビュー指摘を該当メンバーに DM で再割当してから shutdown する。

1. 各メンバーは完了後 **idle 待機**する（shutdown しない）
2. Orchestrator が `/review-implementation` でレビュー
3. 指摘を該当メンバーに DM で再割当
4. Medium/Low 指摘を複数 Agent に **並列 DM** することで短時間に解消
5. すべての指摘が解消されてから `SendMessage({to: "*", message: {type: "shutdown_request"}})`
6. `TeamDelete` でクリーンアップ

### 適用例

過去プロジェクトではこのパターンで 4 件のレビュー指摘を 5 分以内に並列解消できた。Agent の背景知識がコンテキストに残っているため、指摘内容 → 該当コード → 修正の流れにコンテキスト再ロードコストがゼロで済んだ。

---

## Phase 2 で何が間違っていたか

### 背景（過去プロジェクトの失敗事例）

過去プロジェクトの Phase 2 実装では、Agent Teams を **正しく使っていなかった**。具体的には:

- `TeamCreate` を呼ばず、チーム context を作成していなかった
- `Agent` ツール起動時に `team_name` を指定していなかった
- 結果: 子 Agent はただの並列バックグラウンド subagent でしかなく、**互いを認識できない状態**だった

このため、Backend Agent が `WHERE status='PENDING'` で却下済みレコードをフィルタアウトするクエリをハードコードしたとき、その事実が他 Agent（BFF / Frontend）に伝わる経路が存在しなかった。

結果として「却下理由が永久に画面に表示されない」という仕様バグを生み、リリース後に発見された。

### ルール

1. **必ず `TeamCreate` でチーム context を作成する**
2. **`Agent` 起動時に `team_name` を必須指定する**
3. これを怠った場合、子 Agent 同士の `SendMessage` 直接通信は **成立しない** ことを理解する
4. 真の Agent Teams と「ただの並列 subagent」を混同しない

### 適用例

正しい Agent Teams では、Backend がクエリ条件式をハードコードした時点で BFF / Frontend に DM を送る義務がある（CLAUDE.md の「発信義務」参照）。これにより仕様の暗黙前提が可視化され、実装中に検知できる。

---

## パターン 3 (単一 Agent) を選ぶべきケース

### 背景

Agent Teams は並行実装で時間短縮する手段だが、**オーバーヘッド**（TeamCreate / DM / ハンドオフ / TeamDelete）がある。並行度がないタスクに Agent Teams を使うと、単一 Agent で順次実装するより **遅くなる**。

### ルール

以下の **いずれか** を満たす場合は Agent Teams を使わず単一 Agent で順次実装する:

- 変更が **単一サブモジュール内** または **親リポ単体** で完結する
- 実装フェーズが **依存関係により直列にしか進まない**（並行度ゼロ）
- 合計工数が **半日以下** の見積もり
- 新しい gRPC/REST/DB スキーマの追加がない

### 適用例

過去プロジェクトの E2E テストリファクタタスクは、親リポ `e2e/` のみの refactor で依存が直列（setup → spec 移行 → 検証）だったため、単一 Agent で 30 分で完了した。Agent Teams では同等の実装に 1 時間以上かかっていた可能性がある。

**逆に Agent Teams を選ぶべき**のは、2 つ以上の Agent が独立に並行作業できる合意事項（contract fix 等）が存在するとき。

---

## 設計段階の実測検証ルール

### 背景

`design.md` で「〜できない」「〜が必要」と根拠なしに断定すると、実装時に覆されて大幅な手戻りが発生する。

過去プロジェクトでは「BFF origin で取得した session Cookie は browser context に転用不可」と design で断定したが、実測（`cat e2e/.auth/*.json`）で Cookie の `domain=localhost` を確認すれば即座に覆せた事例があった。review-steering で指摘されたにもかかわらず検証せず実装に進み、実装中に前提が崩れて設計ごと見直しになった。

### ルール

**design.md で断定する箇所は、実装前に実測 1 回で検証すること。** 5 分以内に検証できる断定は、review-steering で指摘されたら必ず検証する。検証できない断定は「仮説」と明示し、実装時の発見により修正される可能性を design.md に明記する。

### 適用例（実測すべき断定の例）

- 「API X の Cookie は Y で使えない」→ `cat storageState` / `curl -I` で確認
- 「ライブラリ Z は機能 W をサポートしない」→ docs / example を 1 件 grep
- 「データベース D は制約 C を持つ」→ `\d table` / `SHOW CREATE TABLE`
- 「既存 API の N+1 を避けるため join が必要」→ 既存クエリを `EXPLAIN`

---

## ハンドオフの必須ルール

### 背景

Agent Teams の運用で最も見落とされやすいポイント:
**子 Agent は他 Agent の `TaskUpdate(completed)` を自律的に検知しません**。`TaskList` を能動的にポーリングする設計ではなく、次のメッセージが届くまで idle のまま待機します。

つまり「Backend が終わったら Frontend が自動で動き出す」ということは **起きません**。

過去プロジェクトでは Frontend Agent が BFF 完了後も idle のまま動かず、Orchestrator の明示的 wake-up DM でようやく実装開始した事例があった。これを放置すると下流 Agent は永久に待機してタスクが停止する。

### ルール（Orchestrator 主導）

1. **上流 Agent の完了通知を Orchestrator が受け取る** — 子 Agent からの `TaskUpdate(completed)` または「完了しました」DM が会話ターンとして届く
2. **Orchestrator が下流 Agent に明示的な wake-up DM を送る** — 下流が「次に何をすべきか」を理解できる具体的な内容で:
   - 何が完了したか（例: "service-a-agent 完了、proto が main に merge 済み"）
   - 次にやるべきこと（例: "`cd ../.. && git pull` で親リポ同期 → 型再生成 → 実装"）
   - 合意済み仕様の再掲
   - 完了条件と TaskUpdate 完了マークの指示
3. **下流 Agent は wake-up DM を受け取って起動** — `TaskList` を再確認して自分のタスクを in_progress にし、実装開始

### 代替案の比較

| 方式 | メリット | デメリット | 推奨 |
|---|---|---|---|
| **Orchestrator 主導** | 方針判断責任と一貫、進捗可視性あり | Orchestrator の手動介入が必要 | ✅ デフォルト |
| 上流 Agent が下流に完了 DM | Orchestrator の手数が減る | 上流 Agent が下流の事情を知る必要あり | 特殊ケースのみ |
| ポーリング自律起動 | 完全自律 | TaskList ポーリングは現仕様で不可 | ❌ 不可能 |

### 補足: TaskCreate 時の依存関係明示

`TaskCreate` の description に依存関係を明記し、`TaskUpdate` の `addBlockedBy` / `addBlocks` パラメータで blocker を設定する:

```
TaskCreate(
  subject="Frontend: サイドバーバッジ実装",
  description="依存: Task #2 (BFF /pending-count 完了) の OpenAPI 更新後に型再生成 → 実装"
)
TaskUpdate(taskId="3", addBlockedBy=["2"])
```

これにより下流 Agent が起動時に「自分のタスクは blocked」と認識でき、誤って blocker 未完了のまま実装開始する事故を防げる。**ただし blocker 解消を自律検知する仕組みはない**ため、Orchestrator の明示的 wake-up DM は引き続き必要です。
