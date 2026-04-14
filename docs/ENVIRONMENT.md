# 🔧 環境設定チートシート

**すべてのポート番号・環境変数・Docker コマンドをこの 1 ページにまとめてください**

<!-- TODO(claude): このファイルはすべてプロジェクト固有の設定で埋めてください。
     既存プロジェクトの以下を参照して生成してください:
     - docker-compose.yml
     - .env.example / .env.local.example
     - 各サービスの README.md
     - package.json の scripts
-->

---

## 📡 ポート番号一覧

<!-- TODO(claude): 実ポートに置き換え -->

| サービス | ポート | URL | 説明 |
|---------|--------|-----|------|
| service-a | <!-- TODO --> | http://localhost:<!-- TODO --> | <!-- TODO --> |
| service-b | <!-- TODO --> | http://localhost:<!-- TODO --> | <!-- TODO --> |
| service-c | <!-- TODO --> | http://localhost:<!-- TODO --> | <!-- TODO --> |

---

## 🔑 環境変数

### service-a

<!-- TODO(claude): 実際の環境変数一覧と作成方法を記述 -->

```bash
# TODO
```

### service-b / service-c / e2e

<!-- TODO(claude): 同様に埋める -->

---

## 🐳 Docker Compose コマンド

<!-- TODO(claude): 実プロジェクトの docker compose 運用を記述 -->

**起動:**
```bash
docker compose up -d
```

**停止:**
```bash
docker compose down
```

**ログ確認:**
```bash
docker compose logs -f <service-name>
```

---

## 🗄️ データベース接続情報

<!-- TODO(claude): 該当する場合、接続情報を記述 -->

---

## 🧪 テストユーザー情報

<!-- TODO(claude): シードデータ由来のテストユーザーがあれば記述 -->

---

## 🚨 トラブルシューティング

### ポートが既に使用されている

```bash
lsof -i :<port>
kill -9 <PID>
# または docker compose down
```

### データベース接続エラー

```bash
docker compose down
docker compose up -d
docker compose logs <db-service-name>
```

---

## 📋 環境設定チェックリスト

### 全体
- [ ] `.claude/settings.json` に `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` が設定済み
- [ ] Claude Code を再起動済み

<!-- TODO(claude): サービスごとのセットアップチェック項目を追加 -->
