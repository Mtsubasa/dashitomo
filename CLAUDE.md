# だしトモ（Claude Code 向け）

食事記録アプリ。健康管理アプリではない。栄養評価や健康指標は明示要件なしに追加しない。

## ドキュメント

- セットアップ・起動: [README.md](README.md)
- 実装方針（環境・Git・技術選定）: [docs/development-policy.md](docs/development-policy.md)
- DB設計: [docs/database/schema.md](docs/database/schema.md)
- 設計判断: [docs/adr/](docs/adr/)
- エージェント向け制約: [AGENTS.md](AGENTS.md)

## 作業の前提

- モノレポ: `apps/app`（Flutter）、`apps/api`（Go）。API の正は `docs/api/openapi.yaml`
- 対象: Android / iOS。Flutter Web は開発・PR レビュー用のみ。Desktop は作らない
- コマンドは `mise run`（作業後は `mise run check`）。ツール版本は `mise.toml` 固定、`latest` や無断更新禁止
- ブランチ: 通常は `develop` から `feature/*` 等。`main` へ直接 push しない
- コミット: Conventional Commits、日本語要約
- 公開API変更: OpenAPI + Go handler/テストを揃え、Flutterが利用するAPIならModel/Service/テストも同一PR
- 未確定の値は推測で埋めない

詳細は [docs/development-policy.md](docs/development-policy.md) と [AGENTS.md](AGENTS.md) に従う。
