# TutoTuto

PDF教材への手書き解答をAIで採点し、SNS報酬につなげるオリジナルの学習アプリ。DoriDoriとCopiCopiの派生元です。

公開用フロントエンドの設定先：[TutoTuto](https://thousandsofties.github.io/TutoTuto/)

## 現在の機能

- PDF・画像の取り込み、教材一覧、画像のPDF化と補正。
- PDFページの表示・A/B操作、ペン・消しゴム・テキスト入力。
- 問題と解答の範囲を選択してAI採点し、正誤・解説を表示。
- 採点履歴、SNSリンク・利用時間設定、Googleログイン、課金連携。

DoriDoriの追加質問パネルやCopiCopiの模写評価とは別のアプリとして管理する。
使い方は [USAGE.md](USAGE.md)、公開手順は [デプロイガイド](.agent/workflows/deployment.md) を参照。

## 構成

```text
TutoTuto/
├── .gitmodules              # サブモジュールと追従ブランチ
├── .github/workflows/       # GitHub Pagesへのデプロイ
├── Makefile                 # 統合ビルド・開発コマンド
└── repos/
    ├── drawing-common/      # Canvas描画基盤
    ├── home-teacher-common/ # 教材管理・PDF表示・保存・認証・API通信
    └── tutotuto-app/ # アプリ固有のReact UI・Express API
```

依存コミットはGitサブモジュールのgitlinkで固定する。`VERSIONS`、`Repos.mk`、`make update-versions` は使用しない。
アプリのVite/TypeScriptエイリアスは兄弟サブモジュールの `src` を参照する。

## データとAPI

- PDF・書き込み・設定・採点履歴は端末のIndexedDB `TutoTutoDB` に保存する。
- 共通ライブラリの既定DB名は `TutoTutoDB`。各アプリのVite設定で上書きし、同一オリジン上でもデータを分離する。
- Googleログインとユーザー・課金情報はFirebase Authentication／Firestoreを使用する。
- 採点はブラウザからExpress APIを経由してGeminiへ送信する。
- 現行のフロント接続先は `.github/workflows/deploy.yml` の `VITE_API_URL`。TutoTutoとDoriDoriは同じCloud Run APIを使用する。
- PWAは更新通知から適用する方式。AI採点や認証にはネットワーク接続が必要。

## ローカル開発

Node.js 20（CIと同じメジャーバージョン）、npm、Git、GNU MakeとUnix系シェルを使用する。
WindowsのPowerShellでは下記のnpmコマンドを直接実行できる。MakeコマンドはGNU Makeのある環境で実行する。
PowerShellの実行ポリシーで `npm.ps1` が拒否される場合は、`npm` を `npm.cmd` に読み替える。

```bash
git clone --recurse-submodules https://github.com/ThousandsOfTies/TutoTuto.git
cd TutoTuto
make setup
make dev
# 別ターミナルでAPIを起動
make dev-server
```

Makeなしの初期設定は、メタで `git submodule update --init --recursive`、
3つのサブモジュールそれぞれで `npm install`、
`repos/drawing-common` で `npm run build` を実行する。

`repos/tutotuto-app` 内では次を使用する。

```bash
npm run dev          # Vite: http://localhost:3000
npm run dev:server   # Express: http://localhost:3003
npm run dev:all      # 両方を起動
npm run build       # フロントエンドの本番ビルド
npm run typecheck
```

サーバーが読む `repos/tutotuto-app/.env` に `GEMINI_API_KEY` を設定する。
認証・課金を試す場合はサーバーのFirebase/Stripe設定も必要。
フロント用の `.env.local` には `VITE_FIREBASE_*` と必要に応じて
`VITE_API_URL=http://localhost:3003` を設定する。ベースURL末尾に `/api` を付けない。
APIキーなどの秘密情報を `VITE_*` に入れない。

## ビルド・依存更新・公開

`make build` は描画ライブラリとフロントエンドをビルドする。
`main` へのpushでGitHub Actionsが固定済みサブモジュールをcheckoutし、npmでビルド、
`repos/tutotuto-app/dist` をGitHub Pagesに公開する。Cloud Run APIは別デプロイ。

Cloud Runの更新はアプリ内の `npm run deploy:server` を使用する。
共通コードを含む専用ソースを生成してからデプロイする。
詳しくは [APIデプロイ手順](repos/tutotuto-app/server/DEPLOYMENT.md) を参照。

サブリポジトリの変更を先にcommit・pushし、その後メタで対象gitlinkをcommit・pushする。

```bash
# サブリポジトリの変更・検証・pushが完了した後、メタで実行
git diff --submodule
git add repos/tutotuto-app
git diff --cached --submodule
git commit -m "Update TutoTuto app"
git push origin main
```

共通ライブラリの場合も同様に対象の `repos/home-teacher-common` または `repos/drawing-common` を更新する。
サブモジュールは初期化後にdetached HEADになり得るため、編集前に作業ブランチと状態を確認する。

- `make init`：メタに固定されたコミットを復元。
- `make update`：全サブモジュールを追従ブランチの最新へ移動。更新内容を確認してgitlinkをコミットする。
- `make status`：メタと各サブモジュールの状態を表示。
- `make clean`：生成されたビルド成果物を削除。サブモジュールは残す。

`make build` などは `init` に依存するため、gitlink更新前の新しいコミットの検証は各サブリポジトリで直接行う。
 
