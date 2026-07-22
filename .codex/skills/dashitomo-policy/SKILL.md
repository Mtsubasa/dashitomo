---
name: dashitomo-policy
description: >-
  Applies だしトモ repository development policy and architecture (Flutter MVVM,
  Go clean architecture, monorepo, mise, OpenAPI-first API, Git flow). Use when
  implementing features, designing layers, changing API, updating tooling, or
  when the user asks about project conventions or folder structure.
---

# だしトモ 実装方針

## 参照

- 詳細: [docs/development-policy.md](../../../docs/development-policy.md)
- エージェント制約: [AGENTS.md](../../../AGENTS.md)
- セットアップ: [README.md](../../../README.md)
- レスポンシブUI: [docs/ui/responsive-layout.md](../../../docs/ui/responsive-layout.md)

## 必ず守ること

1. **プロダクト**: 食事記録アプリ。健康管理・栄養評価は明示要件なしに追加しない
2. **プラットフォーム**: Android / iOS が本番対象。Web は開発・PR 確認用。Desktop は生成しない
3. **API**: `docs/api/openapi.yaml` が正。公開契約を変更する場合は OpenAPI と Go（handler + httptest）を揃え、Flutter が利用する API なら Flutter（Model / Service + テスト）も同じ PR で揃える
4. **コマンド**: `mise run` を使う。終了時は `mise run check`。生成・format 後の差分を確認する
5. **依存**: `latest` 禁止。`mise.toml` / lockfile を理由付きで同時更新。FVM は使わない
6. **Flutter**: Riverpod（コード生成なし）、go_router、Dio、freezed + json_serializable。Widget から Dio を直接呼ばない
7. **Go**: 標準ライブラリ中心。内部エラーを HTTP に漏らさない
8. **Git**: `develop` から作業ブランチ。`main` 直接 push 禁止（明示依頼時のみ push/PR）。Conventional Commits・日本語要約。マージは Merge Commit
9. **未確定値**: デプロイ先・認証方式など推測で埋めない。不明ならユーザーに確認
10. **コメント**: 処理の実況や決定ログではなく、理由・制約・単位・座標系・不変条件などコードだけでは分からない情報を書く。実装とずれたコメントは同時に更新または削除する

## Flutter アーキテクチャ（MVVM）

方針は **機能単位の feature フォルダ + MVVM**。Domain Layer や抽象インターフェースは先回りで増やさない。

### ディレクトリ

```text
apps/app/lib/
├── main.dart
├── app/                    # MaterialApp、go_router
├── core/                   # 機能横断（config、network/api_client、theme）
└── features/
    └── <feature>/
        ├── presentation/   # View（Screen/Widget）、ViewModel
        └── data/           # Repository、Service、Model（freezed）
```

### レイヤと責務

| MVVM | 配置 | 責務 |
| --- | --- | --- |
| **View** | `presentation/*_screen.dart` など | UI の組み立て。`ref.watch(viewModelProvider)` で状態表示。ユーザー操作は ViewModel へ委譲 |
| **ViewModel** | `presentation/*_view_model.dart` | 画面の状態とユースケース呼び出し。`AsyncNotifier` / `Notifier` + `*Provider`。Repository 経由でデータ取得・更新 |
| **Model** | `data/*_response.dart` など | API / ローカル用 DTO。`freezed` + `json_serializable` |

**data 内の分割**（MVVM の Model 取得経路）:

| 種類 | 責務 |
| --- | --- |
| **Service** | Dio（`core/network/api_client.dart` 経由）での HTTP。OpenAPI に沿ったパス・ボディ |
| **Repository** | Service を組み合わせ、ViewModel が使う単位の API を提供。キャッシュ方針があればここ |

- API の JSON・HTTP ステータス・Dio の詳細は Service に閉じ込める
- Repository はデータ取得元の選択、複数 Service の組み合わせ、キャッシュなどがある場合に責務を持つ。単なる転送でも ViewModel と Service の境界として配置する
- ViewModel は画面単位の状態、入力、処理中・成功・失敗を管理し、表示文言や `BuildContext` を Repository / Service に持ち込まない

### 依存の向き

```text
View → ViewModel → Repository → Service → ApiClient（core）
```

- Widget から **Dio / Service / Repository を直接呼ばない**
- **`BuildContext` を Repository / Service に渡さない**
- Riverpod の Provider で依存を注入（Riverpod コード生成は使わない）
- 新機能は `features/<名前>/` を追加し、上記 2 層（presentation / data）から始める
- View は原則として機能の ViewModel Provider を watch / read する。テーマ、設定、router など `core` / `app` の表示用 Provider は View から直接参照してよい
- 初回取得は `AsyncNotifier.build`、再取得は invalidate、ユーザー操作による更新は ViewModel のメソッドに置く。非同期更新中は二重送信を防ぎ、失敗を View が表示できる状態にする
- Dio 例外を View へそのまま表示しない。Service / Repository でアプリが扱う失敗へ変換し、ユーザー向け文言の決定は presentation 側で行う
- UIは端末種別で分岐せず、`SafeArea`と`LayoutBuilder`の制約を基準にする。アセットへの重ね要素は同じ親Widget内で割合配置する

### 追加時チェック

- [ ] Screen は機能処理を ViewModel に委譲し、許可された `core` / `app` Provider 以外の data 層を参照していない
- [ ] ViewModel は Repository のみ利用（HTTP 詳細を知らない）
- [ ] API 型は `data/` の freezed モデル。生成物は `mise run generate`
- [ ] ViewModel は Provider override 可能な依存を使い、成功・失敗・再試行または更新処理をテストする
- [ ] Screen は主要な loading / data / error とユーザー操作を Widget test する

## Go アーキテクチャ（クリーンアーキテクチャ）

方針は **依存関係は内側（domain）へ**。HTTP・DB・外部 API は外側の adapter / infrastructure。handler は薄く、ユースケースを呼ぶだけにする。

### ディレクトリ（目標構成）

```text
apps/api/
├── cmd/api/main.go              # 起動、設定読込、依存の組み立て（composition root）
└── internal/
    ├── config/                  # 環境変数・設定
    ├── domain/                  # エンティティ、ドメインエラー、Repository インターフェース（必要になった機能から）
    ├── usecase/                 # アプリケーションルール（1 操作 ≒ 1 関数 or 小さな struct）
    ├── httpapi/                 # プレゼンテーション: ルート、handler、HTTP DTO、ミドルウェア
    └── repository/              # domain の interface 実装（DB、外部 API など）
```

現状は `httpapi` に handler が集約されている。レイヤは必要になった機能から追加し、空パッケージや将来用 interface は作らない。

- ヘルスチェックなど、ビジネスルールも永続化もない運用エンドポイントは `httpapi` だけでよい
- 入力に対する業務判断、複数処理の調整、権限判定などが生じたら `usecase` を追加する
- ドメイン固有の不変条件、エンティティ、永続化境界が生じたら `domain` を追加する
- DB・ストレージ・外部 API が必要なら domain の interface と `repository` の実装を追加し、`cmd/api` で注入する
- 既存の単純な handler を、構造を揃える目的だけで不要な層へ移さない

### レイヤと責務

| 層 | パッケージ | 責務 | 依存してよい相手 |
| --- | --- | --- | --- |
| **Domain** | `internal/domain` | ビジネス上の型とルール。Repository の **interface** のみ | 標準ライブラリのみ |
| **Usecase** | `internal/usecase` | 1 ユースケースの orchestration。domain の interface を使う | domain |
| **Adapter（HTTP）** | `internal/httpapi` | リクエスト解析、バリデーション、ステータスコード、JSON。**usecase を呼んで結果を HTTP に写す** | usecase、HTTP 用 DTO |
| **Infrastructure** | `internal/repository` | DB・ストレージ等の **interface 実装** | domain、必要なドライバ |

### 依存の向き

```text
httpapi → usecase → domain（interface）
repository（実装）→ domain（interface を満たす）
cmd/api → 全レイヤを new して注入
```

- **domain は usecase / httpapi / repository を import しない**
- **内部エラー・スタックは HTTP レスポンスに漏らさない**（ログは slog、クライアントには安定したエラー JSON）
- Framework / ORM は合意なしに追加しない。HTTP は `net/http`、`httptest` で handler テスト
- OpenAPI の request/response 型は **httpapi 側の DTO** とし、必要なら usecase の入出力型へマッピング
- HTTP 形式の検査（JSON 構文、必須フィールド、path/query の型）は httpapi、業務上の制約は usecase / domain で検査する
- domain / usecase のエラーは安定した sentinel error または型で表し、httpapi でステータスコードと OpenAPI のエラー JSON へ変換する。未知のエラーはログへ記録し、クライアントには詳細を返さない
- interface は利用側に置き、テスト差し替えだけを目的に全 struct へ interface を作らない

### 追加時チェック

- [ ] handler にビジネスロジックを書き足さず usecase へ置く
- [ ] 永続化が要る場合、interface は domain、実装は repository
- [ ] handler は `httptest` で method、正常系、入力不正、usecase 失敗を検証する
- [ ] usecase / domain を追加した場合は HTTP を介さない unit test を書く
- [ ] 公開契約の変更時は OpenAPI → Go 実装・テストの順で揃え、Flutter が利用する API なら Flutter も同一 PR で更新する

## 環境（要約）

- macOS / Linux / WSL2。Windows 日常開発は WSL2（Flutter Web + Go）。Android は Windows ネイティブ（別 clone）
- テキストは LF（`.gitattributes` / `.editorconfig`）
- Android: JDK は Android Studio 同梱。更新は専用 PR + ビルド確認

## ブランチ

```text
main ← develop ← feature/* | fix/* | refactor/* | chore/*
```

Codex でリポジトリスキルが表示されない場合は、プロジェクトを trusted に設定する（`~/.codex/config.toml` の `trust_level = "trusted"`）。
