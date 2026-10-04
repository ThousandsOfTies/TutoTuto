---
description: TutoTutoのGitHub Pages・API構成とローカル起動
---

# TutoTuto デプロイガイド

## フロントエンド

公開設定先は `https://thousandsofties.github.io/TutoTuto/`。
`.github/workflows/deploy.yml` が `main` のpush、または手動実行で動く。
GitHub PagesのSourceにはGitHub Actionsを使用する。

1. 固定済みサブモジュールを再帰的にcheckout。
2. Node.js 20とnpmで `make install`。
3. `make build` でビルド。
4. `repos/tutotuto-app/dist` をPagesの成果物として公開。

`VITE_API_URL` はWorkflowで指定し、Firebase設定は `VITE_FIREBASE_*` のRepository secretsからビルドへ渡る。
現在のAPI接続先は `https://hometeacher-api-736494768812.asia-northeast1.run.app`。

サブモジュールの変更は [更新手順](deployment-workflow.md) に従い、子のpush後にメタのgitlinkを更新する。
PWAは `registerType: 'prompt'` であり、更新通知から適用する。AI採点はオフラインでは利用できない。

## APIサーバー

フロントのWorkflowではAPIを公開しない。現行接続先のCloud Runサービス `hometeacher-api` はDoriDoriも共有する。
ローカル実装は `repos/tutotuto-app/server/src/index.ts`、ヘルスチェックは `GET /api/health`。

本番・stagingの公開元は `repos/tutotuto-app` に一本化する。DoriDori側の公開コマンドは誤上書きを防ぐため停止する。
共有サーバーには採点 `/api/grade-work`、追加質問 `/api/ask-question`、本の質問 `/api/book/*` を含める。
`npm run prepare:server` がサーバーの `src/`・型確認設定、兄弟の共通採点定義、専用の依存定義・`server/Dockerfile` を `.cloud-run` にまとめる。
`npm run deploy:server:staging` で3種類のAPIを検証してから `npm run deploy:server` で本番を更新する。
両コマンドはソース準備を先に行い、`.env` や認証ファイルはアップロード用ソースへ含めない。
詳細は [APIデプロイ手順](../../repos/tutotuto-app/server/DEPLOYMENT.md) を参照する。

APIベースURL末尾に `/api` を付けない。フロントが各エンドポイントのパスを付加する。

## ローカル起動

メタで初回 `make setup` 後、別ターミナルで実行：

```bash
make dev
make dev-server
```

フロントは既定 `http://localhost:3000`、APIは `http://localhost:3003`。
フロントの設定は `repos/tutotuto-app/.env.local`。
API設定は `repos/tutotuto-app/server/.env`。実行環境の変数が最優先で、従来のアプリ直下 `.env` も互換用に読む。
Makeなしでは `repos/tutotuto-app` で `npm run dev:all` を使用できる。
`VITE_API_URL=http://localhost:3003` と必要な `VITE_FIREBASE_*` を設定する。
秘密キーを `VITE_*` として公開しない。

ログは起動ターミナルに出力される。接続に失敗したら、API起動・ベースURL・CORS・Firebaseプロジェクトの対応を確認する。
