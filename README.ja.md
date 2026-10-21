# TutoTuto

[English](README.md) | **日本語**

**先に勉強。あとでSNS。**

TutoTutoは、いつもの教材での学習と、そのあとのSNSの時間をつなぐアプリです。PDFや保存した画像を取り込み、解答を書き込んでAIで採点。正誤や解説を確認したら、設定したリンクからSNSへ進み、タイマーで利用時間を確認できます。

[TutoTutoを開く](https://thousandsofties.github.io/TutoTuto/) · [使い方](USAGE.md)

## 紹介動画

45秒・日本語・BGMあり／ナレーションなし

https://github.com/user-attachments/assets/a779a3cf-f6e8-4c13-8e36-324bc7d0883e

[ブラウザーでTutoTutoを試す](https://thousandsofties.github.io/TutoTuto/)

## 主な機能

- **いつもの教材を取り込む：** PDF・保存した画像ファイルに対応。紙のプリントは、スマホやタブレットのカメラアプリで撮影・保存してから取り込めます。TutoTuto自体に撮影機能はありません。
- **教材に直接書き込む：** 手書き・文字入力、A/Bページ切替・左右分割に対応。
- **AIで採点する：** 問題文と解答を含む範囲を選び、正誤と解説を確認できます。
- **解説から追加で質問する：** 気になる部分を質問し、会話を分岐して続けられます。Markdown・数式の表示と履歴の保存にも対応。
- **勉強のあとにSNSへ：** 採点後、設定したSNSリンクを開き、タイマーで残り時間を確認できます。タイマーは時間を知らせるもので、端末内の他のアプリをブロックする機能ではありません。
- **日本語・英語を選ぶ：** アプリ内で表示言語を切り替えられます。Googleログイン・課金連携にも対応。

教材・書き込み・採点履歴・追加質問は、ブラウザーのIndexedDB `TutoTutoDB` に保存します。ブラウザーのサイトデータを削除すると、これらの記録も失われます。AI採点にはネットワーク接続が必要です。

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
