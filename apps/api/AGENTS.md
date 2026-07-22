# Go API 実装指示

このディレクトリでは、リポジトリルートの [`AGENTS.md`](../../AGENTS.md) に加えて、[`.claude/skills/dashitomo-policy/SKILL.md`](../../.claude/skills/dashitomo-policy/SKILL.md) または [`.codex/skills/dashitomo-policy/SKILL.md`](../../.codex/skills/dashitomo-policy/SKILL.md) の「Go アーキテクチャ（クリーンアーキテクチャ）」に従う。

- HTTPの解析・HTTP DTO・レスポンス変換は`internal/httpapi`
- 業務判断や処理の調整が必要になったら`internal/usecase`を追加する
- ドメイン固有の不変条件や永続化境界が必要になったら`internal/domain`を追加する
- DB・外部サービスの実装は`internal/repository`、依存の組み立ては`cmd/api`
- ヘルスチェックなど単純な運用エンドポイントのために、空のdomain/usecaseや将来用interfaceを作らない
- 内部エラーをHTTPレスポンスへ漏らさず、handler変更時は`httptest`を更新する
- 公開API契約を変更するときは、先に`docs/api/openapi.yaml`を更新する
- 変更後はルートで`mise run check`を実行し、format後の差分も確認する
