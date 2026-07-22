# Flutter アプリ実装指示

このディレクトリでは、リポジトリルートの [`AGENTS.md`](../../AGENTS.md) に加えて、[`.claude/skills/dashitomo-policy/SKILL.md`](../../.claude/skills/dashitomo-policy/SKILL.md) または [`.codex/skills/dashitomo-policy/SKILL.md`](../../.codex/skills/dashitomo-policy/SKILL.md) の「Flutter アーキテクチャ（MVVM）」に従う。

- `features/<feature>/presentation` に View と ViewModel、`data` に Repository・Service・Modelを置く
- 依存方向は `View → ViewModel → Repository → Service → ApiClient`
- ViewからDio、Service、Repositoryを直接利用しない。機能処理はViewModelへ委譲する
- Viewから直接参照してよいのは、機能のViewModelと、表示に必要な`app` / `core`のProvider
- APIモデルはfreezedで定義し、生成物を手編集しない
- 新しいDomain Layerや抽象interfaceは、明示された要件なしに追加しない
- UIは[`docs/ui/responsive-layout.md`](../../docs/ui/responsive-layout.md)に従い、端末種別ではなく親の制約から構成する
- 静的アセットに文字や図形を重ねる画面では、レイアウト定数（重ね位置・色・サイズ・湾曲量など）を`presentation/<feature>_layout.dart`に分離し、Viewはそこを参照する。位置調整は原則この定義ファイルのみで行い、Viewの組み立てコードは変更しない（例: `features/home/presentation/home_layout.dart`）
  - 位置はアセット寸法に対する割合（0.0〜1.0）で持ち、画面サイズに依存させない
  - テキストは中心座標で定義し、可変長の入力でも中心基準で配置・自動縮小できるようにする
  - 横画面での肥大化を防ぐため、前景コンテンツの最大幅や要素高の上限も同ファイルで管理する
- 変更後はルートで`mise run check`を実行し、生成・format後の差分も確認する

現在のhealth機能は環境疎通用の初期実装であり、新機能の要件とスキルが異なる場合はスキルのMVVM方針を優先する。ただし、既存コードを依頼なく全面的に作り直さない。
