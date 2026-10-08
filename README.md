# TutoTuto

PDF教材への手書き解答をAIで採点し、解説や追加質問で理解を深める学習アプリです。DoriDori・CopiCopiの派生元です。

[TutoTutoを開く](https://thousandsofties.github.io/TutoTuto/) · [使い方](USAGE.md)

## 主な機能

- PDF・画像の取り込み、A/Bページ切替・左右分割、手書き・文字入力。
- 問題と解答の範囲を選んでAI採点し、正誤・解説を表示。
- 解説への追加質問、Markdown・数式の表示、質問の分岐と履歴の保存。
- SNSリンク・利用時間設定、Googleログイン、課金連携、日本語・英語表示。

教材・書き込み・履歴は端末内のIndexedDB `TutoTutoDB` に保存します。AI採点にはネットワーク接続が必要です。

## 構成

このメタリポジトリが、Gitサブモジュールの使用コミットとビルド・公開を管理します。

| 場所 | 役割 |
|---|---|
| `repos/tutotuto-app` | TutoTutoのフロントエンド |
| `repos/home-teacher-api` | TutoTuto・DoriDoriの共有Express API |
| `repos/home-teacher-common` | 共通UI・PDF表示・保存・認証 |
| `repos/drawing-common` | 描画基盤 |

APIのソースと公開元は独立した [home-teacher-api](https://github.com/ThousandsOfTies/home-teacher-api) です。
DoriDoriの本文索引・読書機能とCopiCopiの模写評価は、それぞれのアプリで管理します。

## ローカル開発

Node.js 20（フロントCIと同じ）、npm、Gitを使用します。Makeの利用にはGNU MakeとUnix系シェルが必要です。

```bash
git clone --recurse-submodules https://github.com/ThousandsOfTies/TutoTuto.git
cd TutoTuto
make setup
```

フロントの `repos/tutotuto-app/.env.local` に `VITE_FIREBASE_*` と `VITE_API_URL=http://localhost:3003` を設定します。
APIは [設定例](https://github.com/ThousandsOfTies/home-teacher-api/blob/main/.env.example) を参考に `repos/home-teacher-api/.env` を用意します。APIキーはサーバー側のみ、ベースURL末尾に `/api` は付けません。

別々のターミナルで起動します。

```bash
make dev         # フロント: http://localhost:3000
make dev-server  # 共有API: http://localhost:3003
```

Makeなしの場合は、描画・共通UI・アプリで `npm install`、APIで `npm ci`、描画で `npm run build` を実行します。
以降はアプリ内の `npm run dev:all` で両方を起動できます。アプリから起動する場合は従来の `server/.env` も互換用に読みます。PowerShellで `npm.ps1` が拒否される場合は `npm.cmd` を使用します。

`make build` でフロントをビルドします。アプリ内では `npm run typecheck` と `npm test`、ビルド後は `npm run test:bundle` で確認できます。APIの検証はAPIリポジトリ内の `npm test` を使用します。

## 更新・公開

サブリポジトリを先にcommit・pushし、その後このリポジトリのgitlinkを更新します。手順と翻訳ルールは [AGENTS.md](AGENTS.md) を参照してください。
`make init` は固定コミットを復元し、`make update` は追従ブランチへ進めます。gitlink更新前の検証は各サブリポジトリで直接行います。

このリポジトリの `main` へのpushでGitHub Pagesへ公開します。共有Cloud Run APIはAPIリポジトリから別途公開します。
サブモジュールの固定コミットと本番APIの版は別管理です。詳しくは [フロントのデプロイガイド](.agent/workflows/deployment.md) と [API公開手順](https://github.com/ThousandsOfTies/home-teacher-api/blob/main/DEPLOYMENT.md) を参照してください。
