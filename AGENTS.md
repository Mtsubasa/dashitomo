# AGENTS.md

だしトモリポジトリで作業するコーディングエージェント向けの指示。セットアップや起動の手順は[README.md](README.md)を参照。環境・Git・技術選定の全体方針は[docs/development-policy.md](docs/development-policy.md)を参照。

## 前提

- だしトモは食事記録アプリであり、健康管理アプリではない。栄養評価や健康指標の機能を明示された要件なしに追加しない
- 対象プラットフォームはAndroidとiOS。Flutter Webは開発時の動作確認用。Desktopは生成しない
- APIに関しては[`docs/api/openapi.yaml`](docs/api/openapi.yaml)を正とする。公開契約の変更ではOpenAPIとGoのhandler・テストを揃え、Flutterが利用するAPIならFlutterのModel・Service・テストも同じPull Requestで揃える
- 未確定の値（識別子、デプロイ先、認証方式など）を推測して埋めない。不明ならユーザーに確認する

## コマンド

開発コマンドにはmise taskを使う。一覧は`mise tasks`で確認できる。

- 作業後は`mise run check`を実行する。コード生成とフォーマットがファイルを書き換えるため、実行後の差分も確認する
- Goの脆弱性検査は`go tool govulncheck ./...`を使う。別インストールや`@latest`へ置き換えない

## コードコメント

- コードを読めば分かる処理の言い換えや、実装作業の実況コメントを書かない
- コメントには、制約の理由、単位・座標系、不変条件、外部仕様、非自明な責務など、コードだけでは判断できない情報を書く
- 「現状は」「将来的に」「一旦」などの決定経緯や推測をコードコメントへ残さない。必要な設計判断は`docs/`、未実装作業はIssueなどで管理する
- 実装変更で意味が古くなったコメントは、コードと同じ変更で更新または削除する
- 公開APIや複雑なprivate処理には必要なdoc commentを付けるが、自明なfieldやWidgetへ説明を重複させない

## Flutter（apps/app）

詳細な配置・依存方向・テスト境界は[`apps/app/AGENTS.md`](apps/app/AGENTS.md)とリポジトリスキルを参照する。

- View、Riverpod Provider、Repository、Serviceの責務分離を守る。WidgetからDioを直接呼ばない。`BuildContext`をRepositoryやServiceへ渡さない
- HTTPクライアントはDioを使用する。チーム合意なしに`http`など別のクライアントを追加しない
- `*.freezed.dart`と`*.g.dart`は生成物。手編集せず、元のDartファイルを変更して`mise run generate`で更新する
- Domain Layerや抽象インターフェースを先回りで増やさない。Riverpodのコード生成は使わない
- `--dart-define`の値はビルド成果物に埋め込まれる。秘密情報を渡さない

## Go（apps/api）

詳細なレイヤ導入条件・依存方向・エラー変換は[`apps/api/AGENTS.md`](apps/api/AGENTS.md)とリポジトリスキルを参照する。

- 標準ライブラリを優先する。FrameworkやORM（Gin、Echo、GORMなど）を必要性の合意なしに追加しない
- 内部エラーをHTTP responseへ漏らさない
- handlerの変更時は`httptest`によるテストを更新する

## Git

- 作業前にブランチと`git status`を確認する。既存の未コミット変更を勝手に削除、上書き、ステージ解除しない
- `main`へ直接pushしない。push、Pull Request作成、リポジトリ設定の変更は明示依頼があるときだけ行う
- ツールや依存関係を無断で更新したり`latest`へ変更したりしない。依存関係を変更するときは理由を示し、対応するlockfile（`mise.lock`、`pubspec.lock`、`go.sum`、`pnpm-lock.yaml`）も同じ変更に含める。lockfileを削除しない
- 検査やテストを弱めて`check`を通さない
- コミットはConventional Commitsに沿い、日本語で要約する
