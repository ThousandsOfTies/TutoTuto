---
description: TutoTutoのGitHub Pages・API構成とローカル起動
---

# TutoTuto デプロイガイド

## フロントエンド

公開設定先は `https://thousandsofties.github.io/TutoTuto/`。
`.github/workflows/deploy.yml` が `main` のpush、または手動実行で動く。
GitHub PagesのSourceにはGitHub Actionsを使用する。

1. 固定済みサブモジュールを再帰的にcheckout。
2. Node.js 20とnpmで `make install-frontend`。
3. `make build` でビルド。
4. `repos/tutotuto-app/dist` をPagesの成果物として公開。

`VITE_API_URL` はWorkflowで指定し、Firebase設定は `VITE_FIREBASE_*` のRepository secretsからビルドへ渡る。
現在のAPI接続先は `https://hometeacher-api-736494768812.asia-northeast1.run.app`。

サブモジュールの変更は [更新手順](deployment-workflow.md) に従い、子のpush後にメタのgitlinkを更新する。
PWAは `registerType: 'prompt'` であり、更新通知から適用する。AI採点はオフラインでは利用できない。

## APIサーバー

フロントのWorkflowではAPIを公開しない。現行接続先のCloud Runサービス `hometeacher-api` はDoriDoriも共有する。
サーバーのソースと公開元は独立リポジトリ `repos/home-teacher-api`、ヘルスチェックは `GET /api/health`。

両アプリでAPIのサブモジュールを固定し、アプリ側にはサーバーのコピーを保持しない。
API専用CIで検証し、API側の `npm run deploy:staging`、動作確認、`npm run deploy:production` の順で公開する。
旧アプリの公開コマンドは移行先を案内して停止する。公開したコミットはCloud Runの `git-sha` ラベルで記録する。
APIの `prepare:deploy` は許可リストにあるソースだけを `.cloud-run` にまとめ、秘密情報を含めない。
詳細は [API公開手順](https://github.com/ThousandsOfTies/home-teacher-api/blob/main/DEPLOYMENT.md) を参照。

APIベースURL末尾に `/api` を付けない。フロントが各エンドポイントのパスを付加する。

## ローカル起動

メタで初回 `make setup` 後、別ターミナルで実行：

```bash
make dev
make dev-server
```

フロントは既定 `http://localhost:3000`、APIは `http://localhost:3003`。
フロントの設定は `repos/tutotuto-app/.env.local`。
API設定は `repos/home-teacher-api/.env`。実行環境の変数が最優先で、アプリから起動した場合は従来のアプリ `server/.env` とアプリ直下 `.env` も互換用に読む。
Makeなしでは `repos/tutotuto-app` で `npm run dev:all` を使用できる。
`VITE_API_URL=http://localhost:3003` と必要な `VITE_FIREBASE_*` を設定する。
秘密キーを `VITE_*` として公開しない。

ログは起動ターミナルに出力される。接続に失敗したら、API起動・ベースURL・CORS・Firebaseプロジェクトの対応を確認する。
