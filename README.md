# だしトモ

> 一緒に食べて、いつか見送る、世界に一体だけの相棒

だしトモは、育てたキャラクターを「食べて見送る」体験を中心にした食事記録アプリです。

## 対象プラットフォーム

- Android
- iOS

Flutter Webは開発時の動作確認用として使用します。デスクトップアプリは対象外です。

開発環境はmacOS、Linux、Windows + WSL2を想定しています。WindowsではFlutter WebとGoをWSL2上で、Android Studio・SDK・エミュレータとAndroidビルドはWindowsネイティブで行い、Android確認用にWSL2とは別パスへcloneします。iOSはmacOSでビルド・Simulator確認します。

実装方針の詳細は[docs/development-policy.md](docs/development-policy.md)を参照してください。Claude Codeは[CLAUDE.md](CLAUDE.md)、スキルは[`.claude/skills/dashitomo-policy`](.claude/skills/dashitomo-policy/SKILL.md)と[`.codex/skills/dashitomo-policy`](.codex/skills/dashitomo-policy/SKILL.md)にあります。

## リポジトリ構成

```text
.
├── apps/
│   ├── app/          # Flutterアプリ
│   └── api/          # Go API
├── docs/
│   ├── api/          # OpenAPI定義
│   └── database/     # DB設計
├── supabase/         # PostgreSQL migrationとDBテスト
├── mise.toml         # ツールと共通タスク
└── package.json      # OpenAPI・Supabase CLI
```

## セットアップ

### 1. リポジトリのclone

```shell
git clone https://github.com/Mtsubasa/dashitomo.git
cd dashitomo
```

WindowsとWSL2の両方で作業する場合は、それぞれのファイルシステムへ別々にcloneします。

### 2. miseの導入

mise 2026.7.6以上が必要です。

[mise公式のインストールガイド](https://mise.jdx.dev/installing-mise.html)を参照してください。

### 3. ツールの導入

リポジトリのルートで実行します。

```shell
mise install
```

初回はFlutter SDKなどのダウンロードに数分かかります。

以下のバージョンが`mise.toml`と`mise.lock`から導入されます。

- Flutter 3.44.1（Dart 3.12.1を同梱）
- Go 1.25.12
- Node.js 24.18.0
- pnpm 11.10.0

Dart SDKはFlutterに同梱のものを使い、FVMは使いません。バージョンは`latest`指定せず`mise.toml`で固定します。

### 4. 依存関係の取得

```shell
mise run setup
```

初回は依存関係のダウンロードに数分かかります。

失敗した場合は、`setup:app`（Flutter）、`setup:api`（Go）、`setup:tooling`（ツール）を個別に実行して原因を切り分けてください。

### 5. 開発環境の確認

```shell
mise run doctor
```

`flutter doctor -v`は、対象外のプラットフォームや未導入のSDKを問題として表示する場合があります。開発するプラットフォームに必要な項目を確認してください。

DBを扱う場合は、別途Docker互換runtimeが必要です。Docker本体はmiseで管理しません。各OSに合ったDocker環境を導入して起動した後、次のコマンドで確認します。

```shell
mise run doctor:db
```

## 開発サーバーの起動

Go APIとFlutter Webは別のターミナルで起動します。

ターミナル1：

```shell
mise run dev:api
```

ターミナル2：

```shell
mise run dev:app
```

起動後、次のURLを開きます。

- Flutter Web：<http://localhost:3000>
- Health API：<http://localhost:8080/healthz>

画面にアプリ名、実行環境、API URL、Go APIの接続状態が表示されます。
画面に『Go API接続成功: ok』が表示されれば環境構築は完了です

## ローカルDB

ローカル開発にはSupabase CLIで起動するPostgreSQLを使います。Supabase CLIは`package.json`と`pnpm-lock.yaml`で固定され、`mise run setup`で導入されます。

Dockerを起動した状態で、ローカルPostgreSQLとSupabase Authを開始します。アプリで使わないStorage、Realtime、Analyticsなどのserviceは起動しません。

```shell
mise run db:start
```

初回はDocker imageの取得に時間がかかります。

local stackは開発用の共通credentialを使うため、外部ネットワークへ公開しないでください。

migrationからDBを作り直し、lintとpgTAPテストまで実行する場合は次のコマンドを使います。

```shell
mise run check:db
```

local stackを停止するときは次を実行します。

```shell
mise run db:stop
```

アプリケーションデータは`app` schemaに置き、Flutterから直接アクセスしません。設計と未確定事項は[`docs/database/schema.md`](docs/database/schema.md)を参照してください。

## よく使うタスク

```shell
mise run generate   # Flutterのコード生成
mise run format     # DartとGoのフォーマット
mise run lint       # Flutter、Go、OpenAPIの静的検査
mise run test       # FlutterとGoのテスト
mise run build:web  # Flutter Webのリリースビルド
mise run check      # 上記をまとめて実行
mise run check:db   # ローカルDBの再構築、lint、テスト
```

`mise run check`は、コード生成、フォーマット、静的検査とテスト、Webビルドの順で進みます。Webビルドを含むため数分かかることがあります。

`mise run check:db`はDockerを必要とするため、通常の`mise run check`には含めていません。

コード生成とフォーマットはファイルを書き換えます。実行後の差分を確認し、必要な変更をコミットしてください。

個別タスクの一覧は`mise tasks`で確認します。

### OpenAPI

OpenAPIだけを検査する場合は次を実行します。

```shell
mise run lint:openapi
```

## 環境設定

ローカル開発では追加の設定なしで動きます。ポートや接続先を変えたい場合は、以下の値を上書きしてください。

### Flutter

ビルド時に`--dart-define`で埋め込みます。`mise run dev:app`にはローカル用の値が設定済みです。

- `APP_ENV`：実行環境の表示名。初期値は`local`
- `API_BASE_URL`：接続先Go APIのURL。初期値は`http://localhost:8080`

埋め込んだ値はビルド成果物から取り出せるため、秘密情報を渡さないように注意してください。

### Go API

起動時のプロセス環境変数を読みます。

- `PORT`：待受ポート。初期値は`8080`
- `LOG_LEVEL`：`debug`、`info`、`warn`、`error`のいずれか。初期値は`debug`
- `CORS_ALLOWED_ORIGINS`：許可するオリジン。カンマ区切りで複数指定でき、`*`は不可。初期値は`http://localhost:3000`

## ビルド

### Web

```shell
mise run build:web
```

成果物は`apps/app/build/web`に生成されます。

`build:web`は、ローカルAPIへ接続する動作確認用のリリース構成ビルドです。本番用のビルドタスクは、デプロイ先のAPI URLが確定した時点で追加します。

### Android

TODO

### iOS

TODO

## 開発フロー

`main`は本番・発表可能な安定版、`develop`は通常開発の統合先です。機能ブランチは`develop`へPull Requestし、リリース時は`develop`から`main`へPull Requestします。マージ方式はMerge Commitです。

通常の作業ブランチは最新の`develop`から作成します。

```shell
git switch develop
git pull --ff-only
git switch -c [branch-name]
```

ブランチ名には`feature/`、`fix/`、`refactor/`、`chore/`、`docs/`、`test/`、`ci/`などを使います。

コミットは[Conventional Commits](https://www.conventionalcommits.org/ja/v1.0.0/)に沿い、日本語で要約してください。

```text
feat: 食事記録画面の追加
fix: API接続失敗時の再試行を修正
docs: 開発手順の更新
```

公開API契約を変更するときは、OpenAPIとGo Handler・テストを同じPull Requestで揃えます。Flutterが利用するAPIの場合は、Flutter Model・Service・テストも同じPull Requestで更新します。
APIに関しては[`docs/api/openapi.yaml`](docs/api/openapi.yaml)を正とします。

コーディングエージェント向けの制約は[`AGENTS.md`](AGENTS.md)にまとめています。

`main`と`develop`では、直接pushの禁止・Pull Request必須・レビューApprove・CI成功・Force Push禁止などのBranch Protection（またはRuleset）を設定する想定です。詳細は[docs/development-policy.md](docs/development-policy.md)を参照してください。
