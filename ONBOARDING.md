# ONBOARDING: 既存プロジェクトへの導入ガイド

このキットは **既にコードが少し進んでいる既存プロジェクト** に後付けで SPEC 駆動開発 + Agent Teams 運用を導入するためのものです。新規プロジェクトでも同じ手順で使えます。

---

## 1. 前提

- 既存プロジェクトのルートディレクトリが存在する
- Claude Code がインストール済み
- プロジェクトに README / package.json / ソースコードなど、現状を把握できる情報がある

---

## 2. 導入フロー（推奨）

### Step 1: テンプレリポを clone

```bash
git clone <this-template-repo-url> /tmp/spec-driven-template
```

### Step 2: bootstrap.sh で採用先プロジェクトにコピー

```bash
cd /tmp/spec-driven-template
./bootstrap.sh /path/to/your-project
```

`bootstrap.sh` は以下をコピーします:

- `CLAUDE.md`, `ONBOARDING.md`
- `docs/`, `.steering/`, `.claude/`, `templates/`, `contracts/`
- `services/README.md`, `e2e/README.md`

既存ファイルがある場合は上書き前に `[y/N/o=overwrite-all/a=skip-all]` で確認します。
`bootstrap.sh` 自身、テンプレリポの `README.md`、`.git`、`.gitignore` はコピーされません。

**コピー後のディレクトリ構造（例）:**

```
your-project/
├── CLAUDE.md
├── ONBOARDING.md
├── docs/                   # ルート永続的ドキュメント
├── .steering/              # ステアリング履歴 + _template/
├── .claude/skills/         # 採用スキル + 開発スキル
├── templates/submodule/    # サブモジュール用雛形（generate-submodule-docs が使う）
├── contracts/              # API 契約 (openapi/proto/types)
├── services/
│   └── README.md           # 空のディレクトリ。サブモジュール追加で埋める (Step 6)
└── e2e/README.md
```

> **既存 CLAUDE.md / docs がある場合**
> bootstrap.sh の上書き確認で `N` または `a=skip-all` を選んで温存してください。
> 採用完了後に手動マージするのが安全です。差分確認の例:
> ```bash
> cp CLAUDE.md .adoption/CLAUDE.md.backup  # 事前バックアップ
> ./bootstrap.sh .                         # 上書きを y で承認
> diff .adoption/CLAUDE.md.backup CLAUDE.md
> # 既存内容のうち残したい部分を手動で template に統合
> ```

### Step 3: 採用先プロジェクトに移動して claude 起動

```bash
cd /path/to/your-project
claude
```

### Step 3.5: `.claude/settings.json` を確認（テンプレ同梱済み）

bootstrap.sh によって `.claude/settings.json` が既に配置されています。内容:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": ["Bash(*)", "Write(*)", "Edit(*)"]
  },
  "statusLine": {
    "type": "command",
    "command": ".claude/shells/statusline.sh"
  }
}
```

含まれるもの:
- **`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`** — Agent Teams 機能を有効化（必須）
- **`permissions.allow`** — Agent Teams が自律実行するために必要な権限。デフォルトは Bash/Write/Edit のフル許可
- **`statusLine`** — `.claude/shells/statusline.sh` によるステータスライン表示（モデル / コンテキスト使用率 / サービス / ブランチ / 最新ステアリング）

⚠️ **セキュリティに関する注意**:
`Bash(*)` はフル許可で強力です。組織のセキュリティポリシーに応じて、以下のように絞ることを検討してください:

```json
"allow": [
  "Bash(git:*)", "Bash(npm:*)", "Bash(yarn:*)", "Bash(pnpm:*)",
  "Bash(go:*)", "Bash(make:*)", "Bash(docker:*)", "Bash(jq:*)",
  "Write(*)", "Edit(*)"
]
```

設定変更後は **Claude Code を再起動** してください（`claude` を再実行 or VS Code を再読込）。
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` がないと `TeamCreate` / `team_name` 指定の Agent spawn が機能せず、ただの並列バックグラウンド subagent になります（詳細は `docs/lessons-learned.md` の "Phase 2 で何が間違っていたか"）。

### Step 4: `/analyze-existing-project` で現状分析

Claude セッション内で実行。
README / package.json / ディレクトリ構造 / 既存 docs を読み取り、`.adoption/analysis.md` に分析レポートを保存します。

### Step 5: `/fill-root-docs` でルート docs/ の TODO 埋め

`.adoption/analysis.md` を元に、以下を埋めます:

- `docs/system-architecture.md`
- `docs/glossary.md`
- `docs/ENVIRONMENT.md`
- ルート `CLAUDE.md` のサービス名 / サブモジュール URL プレースホルダ

既存ファイルがある場合は差分プレビュー → 上書き確認があります。

**触らないファイル:**
- `docs/product-requirements.md` — 壁打ちで作成（Step 10 参照）
- `docs/jsox-compliance.md` / `security-guidelines.md` / `service-contracts.md` — 内容維持、TODO バナーのみ削除
- `templates/` 配下 — サブモジュール用雛形なので別フェーズ

### Step 6: サブモジュールを追加（サブモジュール構成の場合）

```bash
git submodule add <repo-url> services/<service-name>
git submodule update --init --recursive
```

### Step 7: `/generate-submodule-docs <service-name>` を各サービスに実行

各サブモジュール / サービスディレクトリに対して実行:

```
/generate-submodule-docs frontend
/generate-submodule-docs bff
/generate-submodule-docs backend
```

`templates/submodule/` 配下の 4 ファイル (CLAUDE.md, docs/functional-design.md, docs/repository-structure.md, docs/development-guidelines.md) を `services/<name>/` にコピーし、サブモジュール内のソースを読んで TODO を埋めます。

### Step 8: サブモジュール側でコミット

**重要**: 生成されたファイルはサブモジュールリポジトリ側にコミットする必要があります。

```bash
cd services/<name>
git add CLAUDE.md docs/
git commit -m "Add service documentation from spec-driven-template"
git push origin <branch>
```

### Step 9: 親リポで submodule reference を更新

```bash
cd <親リポルート>
git add services/<name>
git commit -m "Update <name> submodule reference"
```

### Step 10: `docs/product-requirements.md` を壁打ちで作成

サブモジュール docs 生成 (Step 7) を経て各サービスの `functional-design.md` が埋まった状態で要求定義を行うことで、現状実装と将来要求のギャップを意識した質の高い壁打ちができます。

これはスキル経由ではなく、Claude に直接依頼します:

> docs/product-requirements.md を壁打ちで作成したい。各サブモジュールの functional-design.md を参照しながら、順番に質問してください。

既存ファイルがあり内容が薄ければ、削除してゼロから作り直すことを検討してください。

### Step 11: 通常の SPEC 駆動開発フローへ

以降は [`docs/development-workflow.md`](docs/development-workflow.md) に沿って 6 Phase のサイクルを回します:

1. `/plan-task` → ステアリング作成
2. `/review-steering` → ステアリング品質チェック
3. `/start-implementation` → Agent Teams 並行実装
4. `/review-implementation` → 実装レビュー
5. `/prepare-pr` → PR 作成
6. `/retrospective` → 振り返り

---

## 3. サブモジュール構成でないプロジェクトの対処

このキットはデフォルトで `services/service-a`, `service-b`, `service-c` を Git サブモジュールとして扱う前提ですが、**モノレポ構成** や **単一パッケージ構成** でも利用できます。

### モノレポの場合

- `bootstrap.sh` は問題なく動作します
- `/generate-submodule-docs <name>` は **モノレポ内のサービスディレクトリにも動作**します。`.gitmodules` に未登録でも `services/<name>/` (または `packages/<name>/`, `apps/<name>/` など読み替え) が存在すれば warning を出した上で雛形を展開します
- `services/service-a` などのパスを実際のディレクトリ名 (例: `packages/web`, `apps/api`) に読み替えてください
- ルート `CLAUDE.md` の「サブモジュール初期化」セクションは削除 / 該当しない旨を追記
- Agent Teams の Agent 分担は **ディレクトリ単位** で行う（同じリポジトリ内でもパスで分ければ並行編集可能）
- 生成ファイルのコミットは親リポで `git add` するだけで OK（サブモジュール側コミットは不要）

### 単一パッケージの場合

- Agent Teams は原則不要。`CLAUDE.md` のパターン 3（単一 Agent）を使う
- ステアリング + `/plan-task` / `/review-implementation` / `/retrospective` のサイクルだけでも十分に価値がある
- `/generate-submodule-docs` はスキップしてよい

---

## 4. 次のアクション チェックリスト

- [ ] テンプレリポを clone
- [ ] `./bootstrap.sh /path/to/your-project` を実行
- [ ] 既存 CLAUDE.md / docs があればバックアップ・マージ方針を決定
- [ ] `.claude/settings.json` に `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` を追加
- [ ] 採用先で `claude` 起動（再起動）
- [ ] `/analyze-existing-project`
- [ ] `/fill-root-docs`
- [ ] サブモジュール追加 (該当する場合)
- [ ] `/generate-submodule-docs <name>` を各サービスに実行
- [ ] 各サブモジュールで生成ファイルをコミット
- [ ] 親リポで submodule reference をコミット
- [ ] `docs/product-requirements.md` を壁打ちで作成（サブモジュール docs を参照しながら）
- [ ] `docs/development-workflow.md` を読んでワークフローを把握
- [ ] `docs/lessons-learned.md` を読んで過去の失敗パターンを学ぶ
