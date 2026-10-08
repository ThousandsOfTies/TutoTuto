# TutoTuto プロジェクトルール

## 対象と構成

このファイルは `D:\Yurufuwa\TutoTuto` 以下に適用する。
TutoTutoは、教材への書き込み・AI採点・SNS報酬を扱うオリジナルの学習アプリ。

- メタリポジトリ：このディレクトリ（`main`）
- アプリ：`repos/tutotuto-app`（`main`）
- DoriDoriと共有するAPI：`repos/home-teacher-api`（`main`）
- 共通UI・PDF表示・保存・認証：`repos/home-teacher-common`（`main`）
- 描画基盤：`repos/drawing-common`（`main`）

旧 `C:\VibeCode` のパスを使用しない。このワークスペースには `TutoTutoDev` はない。
別途 `tutotuto-app` の `dev` 環境を扱う場合は、そのチェックアウトとデプロイ設定を確認する。
DoriDori・CopiCopi固有の機能をTutoTutoへ自動的に取り込まない。
TutoTutoにも採点結果への追加質問がある。DoriDoriの本文索引・検索や読書用UIとは個別に管理する。

## 依存管理と修正先

依存リポジトリはGitサブモジュール。構成・追従ブランチは `.gitmodules`、使用コミットはメタリポジトリのgitlinkで管理する。
`VERSIONS` と `make update-versions` は旧方式であり、使用しない。

- TutoTuto固有の変更は `repos/tutotuto-app` に入れる。
- 採点・追加質問・本文参照・認証・課金の共有APIは `repos/home-teacher-api` に入れる。アプリ側にサーバー実装を複製しない。
- 共通UI・PDF表示・保存・認証は `repos/home-teacher-common`、描画基盤は `repos/drawing-common` に入れる。
- 共通ライブラリを変更する際は、TutoTuto・DoriDori・CopiCopiで必要な互換性を確認する。各メタが固定するコミットは異なる場合がある。
- サブモジュールは初期化直後にdetached HEADになり得る。変更前に状態を確認し、作業ブランチを選ぶ。
- 既存の未コミット変更を上書きしない。

## 更新と公開の順序

**状態確認 → pull --ff-only → 修正 → 検証 → サブリポジトリをcommit・push → メタのgitlinkをcommit・push**

```bash
# サブリポジトリ側
cd repos/tutotuto-app
git status --short --branch
git switch main
git pull --ff-only
# 修正・検証後、対象ファイルを選んでgit addする
git commit -m "Describe the app change"
git push origin main

# メタリポジトリ側
cd ../..
git diff --submodule
git add repos/tutotuto-app
git diff --cached --submodule
git commit -m "Update TutoTuto app"
git push origin main
git status --short --branch
```

サブリポジトリをpushする前に、未公開コミットをメタのgitlinkとして公開しない。
`make init` は固定済みコミットを復元する。`make update` は全サブモジュールを追従ブランチへ進めるため、変更内容を確認して使用する。
`make build` なども `init` に依存する。gitlink更新前の新しいサブモジュールコミットを検証する場合は、各サブリポジトリで直接ビルドする。

## パスエイリアスとデータ

アプリの `vite.config.ts` と `tsconfig.json` は、兄弟サブモジュールのソースを参照する。

- `@home-teacher/common` → `../home-teacher-common/src`
- `@thousands-of-ties/drawing-common` → `../drawing-common/src`

マシン固有の絶対パスをエイリアスに追加しない。
IndexedDB名は `TutoTutoDB`。Vite設定で `VITE_INDEXED_DB_NAME` を明示する。共通ライブラリに既定DB名はなく、未指定・空白のみは例外になる。
DB名やスキーマを変更する場合は既存データの移行・互換性を検討する。

## 起動・デプロイ

- フロント：メタで `make dev`、または `repos/tutotuto-app` で `npm run dev`（Vite、既定3000）。
- API：メタで `make dev-server`、または `repos/tutotuto-app` で `npm run dev:server`（Express、既定3003）。
- サーバーのソースは `repos/home-teacher-api/src`。依存・ビルド設定・Dockerfile・専用CIはAPIリポジトリで管理する。採点定義用にAPI内の `repos/home-teacher-common` を別途版固定する。
- API設定は実行環境の変数、API直下 `.env` の順に優先する。アプリから起動した場合だけ、互換用のアプリ `server/.env` とアプリ直下 `.env` も読む。既存の秘密設定ファイルを移行時に削除しない。
- 共有Cloud Run APIは、本番・stagingとも `repos/home-teacher-api` から公開する。アプリ側の旧公開コマンドは案内して停止する。公開したコミットはCloud Runの `git-sha` ラベルで記録する。
- APIの更新はAPIの検証・commit・push・専用CI確認を先に行い、その後にアプリとメタのgitlinkを更新する。API公開時は既存フロントとの互換性を確認する。
- APIキーはサーバー側のみ。`VITE_API_URL` はAPIのベースURLで、末尾に `/api` を付けない。
- ログは起動ターミナルへ出力される。固定の `/tmp/proto-server.log` は作成されない。
- メタの `main` へのpushでGitHub Actionsが固定済みサブモジュールをビルドし、GitHub Pagesへ公開する。
- Cloud Run APIはフロントと別デプロイ。READMEと `repos/home-teacher-api/DEPLOYMENT.md` を参照する。

## 表示文言と翻訳

- 共通UIの文言は `repos/home-teacher-common/src/i18n/locales/{ja,en}.json`、TutoTuto固有の文言は `repos/tutotuto-app/src/i18n/locales/{ja,en}.json` に置く。アプリ専用文言は `tutotuto` 名前空間を使う。
- 固定の表示文言・操作案内・アクセシビリティ用ラベルを画面に直書きしない。両言語でキーと差し込み項目を揃える。
- 単独HTMLの翻訳もアプリのJSONから公開時にコピーする。`public/locales` に重複した辞書を追加しない。
- 文言の変更はアプリで `npm run test:i18n`、ビルド後に `npm run test:bundle` で確認する。保存済みの本文・絵・ユーザー入力・AI回答を言語切り替えで書き換えない。
