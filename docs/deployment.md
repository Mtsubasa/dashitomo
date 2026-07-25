# デプロイ手順（Vercel）

Flutter Web（`apps/app`）と Go API（`apps/api`）を Vercel にデプロイするためのノウハウ。
セットアップ・起動は [README.md](../README.md)、実装方針は [development-policy.md](development-policy.md) を参照。

## 全体構成

Vercel の 1 プロジェクトは Root Directory を 1 つしか持てず、Go Functions は Root 直下の
`api/` を探す。`apps/app` と `apps/api` はディレクトリも Go モジュール境界（`internal`）も
別なので、**同一リポジトリから 2 プロジェクトを作り、Root Directory を分ける**のが正解。

```text
GitHub: dashitomo（1 リポジトリ）
 ├─ Vercel Project A  Root=apps/app  → Flutter Web（静的ホスティング）
 └─ Vercel Project B  Root=apps/api  → Go API（Serverless Functions）
```

| 対象 | プロジェクト例 | URL 例 |
| --- | --- | --- |
| Go API | dashitomo-backend | https://dashitomo-backend.vercel.app |
| Flutter Web | dashitomo (theta) | https://dashitomo-theta.vercel.app |

## Go API プロジェクト（Root=apps/api）

### 必要なファイル（リポジトリに追加済み）

- `apps/api/api/index.go` — Vercel Go Runtime のエントリポイント。常駐サーバ（`cmd/api`）とは別に、
  リクエストごとに呼ばれる `Handler(w, r)` として既存の `httpapi.NewHandler` を再利用する
  （`sync.Once` で初期化、panic は recover してログ＋500）。`cmd/api/main.go` はローカル
  開発（`mise run dev:api`）用に残置。
- `apps/api/vercel.json` — 全パスを関数へ流す rewrite。ルーティングは既存 Go ルーターに委譲。

  ```json
  { "rewrites": [{ "source": "/(.*)", "destination": "/api/index" }] }
  ```

  rewrite 経由でも関数内の `r.URL.Path` は元のパス（例 `/healthz`）で届くため、
  プレフィックス除去は不要（実機確認済み）。

### Vercel ダッシュボード設定

| 項目 | 値 |
| --- | --- |
| Root Directory | `apps/api` |
| Framework Preset | Other |
| Build / Output | 触らない（Go Runtime が自動検出） |

### 環境変数

| Key | 値 | 備考 |
| --- | --- | --- |
| `CORS_ALLOWED_ORIGINS` | `https://<Flutter Web の URL>` | `scheme://host` のみ。`*` 不可。複数はカンマ区切り |
| `LOG_LEVEL` | `info`（任意） | 未設定なら既定 `debug` |

`PORT` は Functions では不要（設定しない）。

## Flutter Web プロジェクト（Root=apps/app）

Vercel のビルド環境に Flutter SDK は入っていないので、Install で取得する。
バージョンは `mise.toml` に合わせて固定する（例では 3.44.1）。

| 項目 | 値 |
| --- | --- |
| Root Directory | `apps/app` |
| Framework Preset | Other |
| Install Command | `git clone https://github.com/flutter/flutter.git --depth 1 -b 3.44.1 _flutter && _flutter/bin/flutter config --enable-web && _flutter/bin/flutter pub get` |
| Build Command | `_flutter/bin/flutter build web --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=$API_BASE_URL` |
| Output Directory | `build/web` |

### 環境変数

| Key | 値 | 備考 |
| --- | --- | --- |
| `API_BASE_URL` | `https://<Go API の URL>` | 末尾スラッシュなし。ビルド時に `--dart-define` で焼き込む |

`API_BASE_URL` は本番で localhost 不可・絶対 HTTP(S) URL 必須（`app_config.dart` が検証）。
生成物（`*.freezed.dart` / `*.g.dart`）はコミット済みのため、Vercel 側で `build_runner` を回す
必要はない（新規の freezed モデルを足したときはローカルで再生成してコミットする）。

## デプロイ順序（相互参照があるため順番が大事）

1. **Go API を先にデプロイ** → 発行 URL を控える
2. **Flutter Web を作成**し、`API_BASE_URL` にその URL を設定してデプロイ → Web の URL を控える
3. **Go API の `CORS_ALLOWED_ORIGINS`** に Web の URL を設定して Redeploy（2 周目で相互接続が確定）

## 動作確認

```sh
# API 単体
curl -i https://<API>/healthz          # 期待: 200 {"status":"ok"}

# CORS プリフライト（Web オリジンから）
curl -i -X OPTIONS https://<API>/healthz \
  -H "Origin: https://<Web>" -H "Access-Control-Request-Method: GET"
# 期待: 204 かつ access-control-allow-origin: https://<Web>
```

## ハマりどころ

- **環境変数の値に不可視文字/改行を入れない。** コピペで URL の末尾に改行や `/#/home` などの
  パスが混入すると、Vercel が env をプロセスへ注入する起動段階で失敗し、関数コードに到達する前に
  `FUNCTION_INVOCATION_FAILED`（500）になる。この場合、アプリ側の graceful なエラー本文は出ず
  Vercel の汎用エラーページが返るのが目印。**該当 env を削除 → Redeploy で 200 に戻るか**で切り分け、
  戻ったら **手入力で** `scheme://host` のみを再設定する。
- **env 変更後は Redeploy が必要。** 既存デプロイには反映されない。
- **CORS は許可リスト完全一致。** 実装は許可 Origin のみ `Access-Control-Allow-Origin` を返す
  （`apps/api/internal/httpapi/cors.go`）。値は `scheme://host`、末尾スラッシュ・パス・クエリ不可、
  `*` 不可。
- **Preview デプロイの URL は毎回変わる。** PR ごとの Preview から API を叩くなら、Preview 環境にも
  `CORS_ALLOWED_ORIGINS` を用意するか、独自ドメインを割り当てると安定する。
- **ブランチ運用。** `main` が Production。開発は feature ブランチ → PR で、各 Preview URL を確認する。
