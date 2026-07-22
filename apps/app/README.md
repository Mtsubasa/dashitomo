# だしトモ Flutterアプリ（apps/app）

食事記録アプリ「だしトモ」のFlutterアプリです。対象プラットフォームはAndroidとiOSで、Flutter Webは開発時の動作確認用です。

セットアップやツール導入の詳細はリポジトリルートの[README.md](../../README.md)を、実装方針は[AGENTS.md](AGENTS.md)を参照してください。

## 前提

- ルートで`mise install`が完了していること（Flutter SDKが導入されます）
- 依存の取得: リポジトリルートで`mise run setup:app`（`flutter pub get`）

## 動作確認（Web）

現時点ではWebでの動作確認を推奨します。

### 起動

リポジトリルートで以下を実行します。

```shell
mise run dev:app
```

これは次のコマンドを実行します（`apps/app`ディレクトリ内）。

```shell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000 --dart-define=APP_ENV=local --dart-define=API_BASE_URL=http://localhost:8080
```

起動後、ブラウザで <http://localhost:3000> を開くとアプリが表示されます。初期画面はホーム画面（`/home`）です。

### 確認できる画面

- ホーム画面（`/home`）: 背景・ネームプレート・ペット・下部タブを表示します
  - 左上のメニュー（3本線）ボタンは押せるのみ（動作は未実装）
  - 下部タブ（図鑑 / 日記 / カメラ / 会話 / ガチャ）は押せるのみ（画面遷移は未実装）
- ヘルスチェック画面（`/`）: Go APIとの疎通確認用の初期画面です

## その他のコマンド

すべてリポジトリルートで実行します。一覧は`mise tasks`で確認できます。

| コマンド | 内容 |
| --- | --- |
| `mise run test:app` | Flutterアプリのテスト |
| `mise run lint:app` | 静的解析（`flutter analyze`） |
| `mise run format:app` | Dartのフォーマット |
| `mise run generate` | コード生成（`build_runner`） |
| `mise run build:web` | Web向けリリースビルド |
| `mise run check` | 生成・フォーマット・解析・テスト・Webビルドを一括実行 |

## ディレクトリ構成

```text
apps/app/lib/
├── main.dart
├── app/                    # MaterialApp、go_router
├── core/                   # 機能横断（config、network、theme）
└── features/
    ├── home/               # ホーム画面
    │   └── presentation/   # View（Screen）、ViewModel
    └── health/             # ヘルスチェック（API疎通確認）
```

詳細なレイヤ分割と依存方向は[AGENTS.md](AGENTS.md)を参照してください。
