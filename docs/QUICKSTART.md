# 🚀 Quick Start Guide

**新しいセッション・新しい開発者はここから始めてください**

---

## このプロジェクトは何か

<!-- TODO(claude): プロジェクトの 3 行要約を README と既存コードから生成してください。
     - 何のシステムか
     - どんなアーキテクチャか
     - Claude Code Agent Teams を使用しているか -->

---

## 📚 振り返り・学び（最初に一度読むことを強く推奨）

Agent Teams を正しく運用するための過去プロジェクト由来のノウハウは [`lessons-learned.md`](lessons-learned.md) にまとまっています:

- **長寿命 Team パターン** — 実装 → レビュー → 修正まで同一 Team を維持する理由と手順
- **Phase 2 で何が間違っていたか** — `TeamCreate` / `team_name` を省略したときの失敗
- **パターン 3 (単一 Agent) を選ぶべきケース** — Agent Teams を使わない判断基準
- **設計段階の実測検証ルール** — design.md での断定は 5 分実測で検証する
- **ハンドオフの必須ルール** — 上流 Agent 完了から下流 Agent への wake-up DM

---

## ⚠️ 重要: サブモジュール構成

<!-- TODO(claude): このプロジェクトがサブモジュール構成なのか、モノレポなのかを確認し、
     該当しない場合はこのセクションを書き換えてください -->

このプロジェクトは **Git サブモジュール**を使用しています。各サービスは独立した Git リポジトリです。

**新しくクローンした場合、または services/ が空の場合:**

```bash
git submodule update --init --recursive
```

**サブモジュールの確認:**
```bash
git submodule status
```

**各サービスのリポジトリ:**
<!-- TODO(claude): サブモジュール URL を埋めてください -->

---

## 📊 現在の開発状況

<!-- TODO(claude): 現在の実装進捗を .steering/ ディレクトリの中身から把握して記述してください -->

---

## 🏃 Agent Teams 実装の開始方法（推奨: スキル使用）

### 🎯 最速の方法: スキルを使用

**新セッション開始時に以下のコマンドを実行してください:**

```
/start-implementation <steering-directory-name>
```

**引数:** ステアリングディレクトリ名（例: `20250407-initial-adoption`）

**利用可能なステアリングディレクトリを確認:**
```bash
ls -1 .steering/
```

このスキルは自動的に以下を実行します:
1. 指定されたステアリングディレクトリの存在確認
2. 必要なドキュメントを読み込み
3. タスクスコープを要約して確認
4. Agent Teams プロンプトを生成・実行

---

## 📖 手動で開始する場合

### ステップ 1: 重要なドキュメントを確認

新セッション開始時は、以下のドキュメントを順番に確認してください:

1. **このファイル（QUICKSTART.md）** ← 今ここ
2. **[lessons-learned.md](lessons-learned.md)** - 過去の失敗と学び（一度は読む）
3. **`.steering/[YYYYMMDD]-[タスク名]/requirements.md`** - 今回実装する機能の要求定義
4. **`.steering/[YYYYMMDD]-[タスク名]/tasklist.md`** - Agent 別の具体的なタスク一覧
5. **[ENVIRONMENT.md](ENVIRONMENT.md)** - ポート番号・環境変数のチートシート

### ステップ 2: Agent Teams 起動

**前提条件:**
- `.claude/settings.json` に `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` が設定済み
- Claude Code が再起動済み

**Orchestrator プロンプトテンプレート:**

```
Agent Teams を使用して、以下のタスクを並行実装してください。

タスク定義: .steering/[YYYYMMDD]-[タスク名]/tasklist.md

必須確認ドキュメント:
1. .steering/[YYYYMMDD]-[タスク名]/requirements.md - 要求定義
2. .steering/[YYYYMMDD]-[タスク名]/design.md - 設計
3. .steering/[YYYYMMDD]-[タスク名]/tasklist.md - タスクリスト
4. docs/ENVIRONMENT.md - 環境設定
5. contracts/openapi/ または contracts/proto/ - API 仕様

Agent 構成は tasklist.md の「Agent 別タスク分担」セクションを参照してください。
実装順序と依存関係は tasklist.md の「Agent 間の依存関係」セクションを参照してください。
```

---

## 📚 重要なドキュメントへのリンク集

| 優先度 | ファイル | 内容 |
|--------|---------|------|
| 🔴 必須 | [QUICKSTART.md](QUICKSTART.md) | このファイル |
| 🔴 必須 | [lessons-learned.md](lessons-learned.md) | 過去の失敗と学び |
| 🔴 必須 | `.steering/[YYYYMMDD]-[タスク名]/requirements.md` | 要求定義 |
| 🔴 必須 | `.steering/[YYYYMMDD]-[タスク名]/tasklist.md` | タスク一覧 |
| 🔴 必須 | [ENVIRONMENT.md](ENVIRONMENT.md) | 環境設定チートシート |
| 🟡 推奨 | [development-workflow.md](development-workflow.md) | 6 Phase ワークフロー |
| 🟢 参考 | [../CLAUDE.md](../CLAUDE.md) | プロジェクト全体のルール |
| 🟢 参考 | [glossary.md](glossary.md) | 用語集 |

---

## ⚠️ よくある質問

### Q: コンテキストが途切れた場合はどうすればいいですか？
**A:** 新しいセッションを開始し、この QUICKSTART.md を最初に読んでください。

### Q: Agent Teams が起動しない場合は？
**A:** `.claude/settings.json` の設定を確認し、Claude Code を再起動してください。それでも解決しない場合は、手動で順次実装することも可能です。

### Q: 環境変数やポート番号はどこで確認できますか？
**A:** [ENVIRONMENT.md](ENVIRONMENT.md) にまとまっています（TODO コメントを埋めたあと）。
