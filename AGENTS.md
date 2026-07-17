# AGENTS.md

だしトモリポジトリで作業するコーディングエージェント向けの指示。セットアップや起動の手順は[README.md](README.md)を参照。

## 前提

- だしトモは食事記録アプリであり、健康管理アプリではない。栄養評価や健康指標の機能を明示された要件なしに追加しない
- 対象プラットフォームはAndroidとiOS。Flutter Webは開発時の動作確認用。Desktopは生成しない
- APIに関しては[`docs/api/openapi.yaml`](docs/api/openapi.yaml)を正とする。API変更では、OpenAPI、Goのhandlerとテスト、FlutterのModel・Service・テストを同じPull Requestで揃える
- 未確定の値（識別子、デプロイ先、認証方式など）を推測して埋めない。不明ならユーザーに確認する

## コマンド

開発コマンドにはmise taskを使う。一覧は`mise tasks`で確認できる。

- 作業後は`mise run check`を実行する。コード生成とフォーマットがファイルを書き換えるため、実行後の差分も確認する
- Goの脆弱性検査は`go tool govulncheck ./...`を使う。別インストールや`@latest`へ置き換えない

## Flutter（apps/app）

- View、Riverpod Provider、Repository、Serviceの責務分離を守る。WidgetからDioを直接呼ばない。`BuildContext`をRepositoryやServiceへ渡さない
- HTTPクライアントはDioを使用する。チーム合意なしに`http`など別のクライアントを追加しない
- `*.freezed.dart`と`*.g.dart`は生成物。手編集せず、元のDartファイルを変更して`mise run generate`で更新する
- Domain Layerや抽象インターフェースを先回りで増やさない。Riverpodのコード生成は使わない
- `--dart-define`の値はビルド成果物に埋め込まれる。秘密情報を渡さない

## Go（apps/api）

- 標準ライブラリを優先する。FrameworkやORM（Gin、Echo、GORMなど）を必要性の合意なしに追加しない
- 内部エラーをHTTP responseへ漏らさない
- handlerの変更時は`httptest`によるテストを更新する

## Git

- 作業前にブランチと`git status`を確認する。既存の未コミット変更を勝手に削除、上書き、ステージ解除しない
- `main`へ直接pushしない。push、Pull Request作成、リポジトリ設定の変更は明示依頼があるときだけ行う
- ツールや依存関係を無断で更新したり`latest`へ変更したりしない。依存関係を変更するときは理由を示し、対応するlockfile（`mise.lock`、`pubspec.lock`、`go.sum`、`pnpm-lock.yaml`）も同じ変更に含める。lockfileを削除しない
- 検査やテストを弱めて`check`を通さない
- コミットはConventional Commitsに沿い、日本語で要約する
