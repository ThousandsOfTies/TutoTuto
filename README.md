# TutoTuto

PDF教材への手書き解答をAIで採点し、SNS報酬につなげるオリジナルの学習アプリ。DoriDoriとCopiCopiの派生元です。

公開用フロントエンドの設定先：[TutoTuto](https://thousandsofties.github.io/TutoTuto/)

## 現在の機能

- PDF・画像の取り込み、教材一覧、画像のPDF化と補正。
- PDFページの表示・A/B操作、ペン・消しゴム・テキスト入力。
- 問題と解答の範囲を選択してAI採点し、正誤・解説を表示。
- 採点結果・解説の一部を囲んで追加質問し、Markdown・数式で回答を表示。
- 採点結果は範囲選択中もホイール・スクロールバーで読める。解答・質問のテキスト入力欄上では、入力欄だけをスクロールする。
- 学習範囲と追加質問の分岐を保存し、履歴から再開。
- 採点履歴、SNSリンク・利用時間設定、Googleログイン、課金連携。

TutoTutoの追加質問は教材の採点結果を深掘りする機能。
DoriDoriの本の本文を検索する読書用UI・索引機能、CopiCopiの模写評価はそれぞれのアプリで管理する。
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
    ├── home-teacher-api/    # 両アプリの共有Express API・通信仕様
    └── tutotuto-app/      # アプリ固有のReact UI
```

依存コミットはGitサブモジュールのgitlinkで固定する。`VERSIONS`、`Repos.mk`、`make update-versions` は使用しない。
アプリのVite/TypeScriptエイリアスは兄弟サブモジュールの `src` を参照する。

## データとAPI

- PDF・書き込み・設定・採点履歴・追加質問の分岐は端末のIndexedDB `TutoTutoDB` に保存する。
- 共通ライブラリには既定DB名がなく、`VITE_INDEXED_DB_NAME` の指定が必須。各アプリのVite設定で明示し、同一オリジン上でもデータを分離する。未指定・空白のみの場合は起動時に例外になる。
- Googleログインとユーザー・課金情報はFirebase Authentication／Firestoreを使用する。
- 採点はブラウザからExpress APIを経由してGeminiへ送信する。
- 採点は `/api/grade-work`、採点結果への追加質問は `/api/ask-question` を使う。追加質問には質問画像と直前の結果を送り、会話履歴全体やPDF全ページは送らない。
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
描画・共通UI・アプリの3サブモジュールで `npm install`、`repos/home-teacher-api` で `npm ci`、
`repos/drawing-common` で `npm run build` を実行する。

`repos/tutotuto-app` 内では次を使用する。

```bash
npm run dev          # Vite: http://localhost:3000
npm run dev:server   # Express: http://localhost:3003
npm run build:server # サーバーの型確認・本番ビルド
npm run test:server  # サーバーの設定互換性・API起動テスト
npm run dev:all      # 両方を起動
npm run build       # フロントエンドの本番ビルド
npm run typecheck
```

サーバーの実装・依存・Dockerfileは兄弟サブモジュール `repos/home-teacher-api` にまとめる。
[APIの設定例](https://github.com/ThousandsOfTies/home-teacher-api/blob/main/.env.example) を参考にAPI直下 `.env` へ `GEMINI_API_KEY` を設定する。
実行環境の変数、API直下 `.env` の順に優先する。アプリから起動した場合だけ、従来のアプリ `server/.env` とアプリ直下 `.env` も互換用に読む。
単体起動・ビルド・専用CIは [API README](https://github.com/ThousandsOfTies/home-teacher-api) を参照。
認証・課金を試す場合はサーバーのFirebase/Stripe設定も必要。
フロント用の `.env.local` には `VITE_FIREBASE_*` と必要に応じて
`VITE_API_URL=http://localhost:3003` を設定する。ベースURL末尾に `/api` を付けない。
APIキーなどの秘密情報を `VITE_*` に入れない。

## ビルド・依存更新・公開

`make build` は描画ライブラリとフロントエンドをビルドする。
`main` へのpushでGitHub Actionsが固定済みサブモジュールをcheckoutし、npmでビルド、
`repos/tutotuto-app/dist` をGitHub Pagesに公開する。Cloud Run APIは別デプロイ。

共有Cloud Run APIの本番・stagingのソースと公開元は独立リポジトリ `home-teacher-api`。
API側で `npm run deploy:staging` により検証してから `npm run deploy:production` で公開する。両アプリの旧公開コマンドは移行先を案内して停止する。
API専用CIがテストとDockerビルドを担当し、PagesのCIは `make install-frontend` によりフロント依存だけをインストールする。
公開したAPIのコミットはCloud Runの `git-sha` ラベルで記録する。アプリが固定するAPIの版と本番の版は別管理で、既存フロントとの互換性を確認する。
詳しくは [API公開手順](https://github.com/ThousandsOfTies/home-teacher-api/blob/main/DEPLOYMENT.md) を参照。

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
 

## 日本語・英語の表示

言語は画面の言語メニューで切り替えます。共通UIの文言は `repos/home-teacher-common/src/i18n/locales/ja.json` と `en.json`、TutoTuto固有の文言は `repos/tutotuto-app/src/i18n/locales/ja.json` と `en.json` で管理します。

画面に固定文言を直書きせず、両言語に同じキー・差し込み項目を追加してください。ユーザーが入力した内容やAI回答そのものは翻訳対象に含めません。単独HTMLページもアプリの翻訳ファイルを使用し、公開時に自動コピーします。`public/locales` に別の翻訳を作成しないでください。

アプリ内で `npm run test:i18n` を実行すると、翻訳キー・差し込み項目の一致と直書きを検査します。ビルド後の `npm run test:bundle` は、単独ページの翻訳が最新版で、オフライン用キャッシュにも含まれることを確認します。
