# だしトモ 開発・実装方針

人間向けの方針書。セットアップ手順は [README.md](../README.md)、コーディングエージェント向けの短い制約は [AGENTS.md](../AGENTS.md) を参照。

## 1. プロジェクト構成

- Flutter と Go を同一リポジトリで管理するモノレポ構成
- Flutter アプリは Web、iOS、Android に対応
- 開発初期は Web 版を最優先
- Web 版は正式なメインプロダクトではなく、開発中の動作確認と Pull Request レビューに利用する
- デスクトップアプリは対象外

```text
.
├── apps/
│   ├── app/          # Flutter
│   └── api/          # Go API
├── docs/
│   └── api/          # OpenAPI（API の正）
├── mise.toml
└── package.json
```

## 2. 対象とする開発環境

開発対象環境: macOS、Linux、Windows + WSL2。

### Windows + WSL2 の運用

Windows メンバーは、日常的な Flutter Web 開発と Go 開発を WSL2 上で行う。

| 作業 | 環境 |
| --- | --- |
| Flutter Web 開発 | WSL2 |
| Go 開発 | WSL2 |
| Android Studio、Android SDK、Android Emulator | Windows ネイティブ |
| Android 固有のビルド・動作確認 | Windows ネイティブ |

Android 確認用として、Windows 側には WSL2 側とは別にリポジトリを `git clone` する。

iOS のビルドと Simulator 確認は macOS 環境で行う。

### 改行コードと基本フォーマット

- リポジトリ内のテキストファイルは原則 LF に統一する（[`.gitattributes`](../.gitattributes)、[`.editorconfig`](../.editorconfig)）
- 個人環境の `core.autocrlf` に依存せず、リポジトリの設定を優先する

## 3. ツールとバージョン管理

[mise](https://mise.jdx.dev/) で以下を管理する。

- Flutter
- Go
- Node.js
- pnpm

Dart SDK は Flutter SDK に含まれるものを利用し、単独では管理しない。

- ツールのバージョンは `latest` 指定にせず、`mise.toml` に完全なバージョンを固定する
- FVM は導入せず、Flutter のバージョン管理も原則 mise に統一する

| ツール | バージョン選択方針 |
| --- | --- |
| Flutter | 導入時点の最新安定版 |
| Go | 導入時点の最新安定版 |
| Node.js | Active LTS |
| pnpm | 導入時点の最新安定版 |

依存関係を更新するときは理由を示し、`mise.lock` など対応する lockfile を同じ変更に含める。

### Android 開発環境

- Android Studio、Android SDK、Android Emulator は Android Studio の公式手順に従って導入する
- Android Studio は初期環境構築時点の最新安定版を使用する。各自が無条件に更新するのではなく、チームで動作確認したバージョンを README に記録する
- JDK は原則 Android Studio に同梱されている JDK を使用する。mise では Java を管理しない

初期環境構築時に README へ記録する項目:

- 検証済みの Android Studio バージョン
- `flutter doctor -v` で確認した JDK バージョン
- Android SDK Platform
- Android SDK Build-Tools
- Android Emulator の検証環境

Android Studio、JDK、Gradle、Android Gradle Plugin などを更新する場合は、専用の Pull Request を作成し、Android ビルドが成功することを確認する。CI ではローカルの検証環境と同じ JDK のメジャーバージョンを固定して使用する。

Windows ネイティブ環境では初期構築時に以下を検証する。

- mise 経由で Flutter を導入できること
- `flutter doctor` が正常に完了すること
- Android Emulator を認識できること
- Android のデバッグビルドが成功すること

mise 経由の Flutter が安定して動作しない場合は、Windows ネイティブ環境に限り、Flutter 公式手順による直接インストールを許容する。

## 4. Flutter の技術選定

画面サイズ、縦横比、Safe Areaの差へ対応するUI設計は[`docs/ui/responsive-layout.md`](ui/responsive-layout.md)を正とする。

| 領域 | 選定 |
| --- | --- |
| アーキテクチャ | MVVM に近いレイヤー構成 |
| 状態管理・DI | flutter_riverpod |
| ルーティング | go_router |
| HTTP クライアント | dio（Interceptor、認証トークン、アップロード進捗、リトライ、キャンセルなどが必要なため採用） |
| データモデル | freezed + json_serializable |
| Lint | flutter_lints |

### コード生成

- 初期段階では Riverpod のコード生成は使用しない
- `*.freezed.dart` と `*.g.dart` は Git 管理する
- 生成結果が最新かどうかを CI で確認する

## 5. Go の技術選定

Go 標準ライブラリを中心に構成し、必要になった段階でライブラリを追加する。

| 用途 | 選定 |
| --- | --- |
| HTTP サーバー | net/http |
| JSON | encoding/json |
| ログ | log/slog |
| テスト | testing |
| HTTP テスト | net/http/httptest |
| フォーマット | gofmt |
| 静的解析 | go vet |

Framework や ORM（Gin、Echo、GORM など）は必要性の合意なしに追加しない。

## 6. API 定義の共有

- Flutter と Go の間の API 定義は OpenAPI を正として管理する
- OpenAPI ファイル: [`docs/api/openapi.yaml`](api/openapi.yaml)
- 公開API契約を追加・変更するPull Requestでは、Goの実装に先立って、または同じPull Request内で`openapi.yaml`を更新する。Flutterが利用するAPIの場合はFlutter側も同じPull Requestで更新する

API の仕様には最低限以下を記述する。

- エンドポイント
- HTTP メソッド
- リクエスト
- レスポンス
- ステータスコード
- エラーレスポンス
- 認証の要否

## 7. Git・ブランチ運用

```text
main
└── develop
    ├── feature/*
    ├── fix/*
    ├── refactor/*
    └── chore/*
```

| ブランチ | 役割 |
| --- | --- |
| `main` | 本番・発表可能な安定版。本番デプロイの対象 |
| `develop` | 開発中の機能を統合するブランチ |

基本フロー:

```text
feature/*（など）
    ↓ Pull Request
develop
    ↓ リリース用 Pull Request
main
```

### コミット

[Conventional Commits](https://www.conventionalcommits.org/ja/v1.0.0/) を採用し、要約は日本語で書く。

```text
feat: 食事記録画面を追加
fix: Web で画像選択が失敗する問題を修正
test: だしトモ生成のテストを追加
refactor: API クライアントを Service へ分離
chore: Flutter のバージョンを更新
docs: 開発環境の説明を追加
```

### マージ方式

Merge Commit を利用する。

## 8. GitHub のルール（案）

`main` と `develop` に Branch Protection または Ruleset を設定する想定。

- 直接 push を禁止
- Pull Request 経由の変更を必須
- PR 作成者以外から最低 1 人の Approve を必須
- 必須 CI の成功をマージ条件にする
- 未解決のレビューコメントがある場合はマージ不可
- Force Push を禁止
- ブランチ削除を禁止

ルールの詳細や緊急修正時の例外運用は後日決定する。
