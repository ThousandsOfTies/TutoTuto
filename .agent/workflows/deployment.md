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
ローカル実装は `repos/tutotuto-app/server/index.ts`、ヘルスチェックは `GET /api/health`。

アプリ内にCloud Run用スクリプトとDockerfileがあるが、現行サーバーは兄弟の
`home-teacher-common/src/constants/grading.ts` をimportする。
アプリ単体をコンテキストにした既存Dockerfileはそのファイルを含めないため、そのまま再デプロイできる構成とは扱わない。
APIを更新する際は、共有ファイルを含むビルドコンテキストと既存サービスの環境設定を整備・検証すること。

APIベースURL末尾に `/api` を付けない。フロントが各エンドポイントのパスを付加する。

## ローカル起動

メタで初回 `make setup` 後、別ターミナルで実行：

```bash
make dev
make dev-server
```

フロントは既定 `http://localhost:3000`、APIは `http://localhost:3003`。
フロントの設定は `repos/tutotuto-app/.env.local`。
API設定は `repos/tutotuto-app/.env`。Gemini APIキーはここに置く。
Makeなしでは `repos/tutotuto-app` で `npm run dev:all` を使用できる。
`VITE_API_URL=http://localhost:3003` と必要な `VITE_FIREBASE_*` を設定する。
秘密キーを `VITE_*` として公開しない。

ログは起動ターミナルに出力される。接続に失敗したら、API起動・ベースURL・CORS・Firebaseプロジェクトの対応を確認する。
