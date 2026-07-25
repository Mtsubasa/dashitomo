# ADR 0001: PostgreSQLとSupabaseを採用する

- Status: Accepted
- Date: 2026-07-25

## Context

食事、だしトモの世代、見送りをtransactionで整合させる必要がある。将来のデプロイ先としてSupabaseを想定しており、認証にはSupabase Authの匿名サインインを使う。

Flutterからアプリケーションデータへ直接接続すると、認可と業務ルールがFlutter、RLS、Goへ分散する。だしトモの世代交代や見送りは複数レコードを同時に更新するため、Go APIを一つの境界にしたい。

## Decision

- アプリケーションDBにはPostgreSQLを使い、Supabaseへデプロイする
- ローカル開発にはSupabase CLIのlocal stackを使う
- schema変更は`supabase/migrations`で管理する
- アプリケーションテーブルはData APIへ公開しない`app` schemaに置く
- FlutterはSupabase Authで認証し、アプリケーションデータはGo APIだけを経由する
- Supabase AuthのUUIDを`app.users`の主キーとして共有する
- 食事写真はCloudflare R2へ保存し、DBには`object_key`だけを保持する

## Consequences

ローカルDBの起動にはDocker互換runtimeが必要になる。DBの確認は`mise run db:*`へ分け、FlutterやGoだけを扱う作業で常時local stackを要求しない。

Go APIはSupabaseのJWTを検証し、認可とDB transactionを担う。RLSをアプリケーションデータの主な認可境界にはしない。

Supabase AuthとPostgreSQL以外のSupabase機能へ依存しないため、Storageは無効化する。R2へのupload方式や本番DBの接続方式は別の設計判断として扱う。
