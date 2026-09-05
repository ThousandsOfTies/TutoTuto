---
description: TutoTutoのサブモジュール更新とフロント公開
---

# TutoTuto 更新手順

依存コミットはGitサブモジュールのgitlinkで固定する。`VERSIONS` と `make update-versions` は使用しない。

## 1. サブリポジトリの変更を公開

メタリポジトリを起点とする例：

```bash
cd repos/tutotuto-app
git status --short --branch
git switch main
git pull --ff-only
# 修正・検証後、変更ファイルを選んでgit addする
git commit -m "Describe the app change"
git push origin main
```

共通修正の場合は `home-teacher-common` または `drawing-common` で同様に作業する。
既存の未コミット変更を上書きしない。サブモジュール初期化直後はdetached HEADの場合がある。

## 2. メタリポジトリのgitlinkを更新

```bash
cd ../..
git diff --submodule
git add repos/tutotuto-app
git diff --cached --submodule
git commit -m "Update TutoTuto app"
git push origin main
git status --short --branch
```

サブリポジトリで先にpushしたコミットをメタで参照する。共通ライブラリ更新時は該当パスを指定する。
`main` へのpushで [.github/workflows/deploy.yml](../../.github/workflows/deploy.yml) がフロントを公開する。

## 固定コミットと更新コマンド

- `git ls-tree HEAD repos/tutotuto-app`：メタが記録したコミット。
- `git -C repos/tutotuto-app rev-parse HEAD`：現在のチェックアウト。
- `git submodule status`：全サブモジュールの一致状態。
- `make init`：メタに記録されたコミットを復元。
- `make update`：全サブモジュールを追従ブランチへ進める。内容を確認してからgitlinkをコミットする。

`make build` 等は `init` に依存する。gitlink更新前のコミットの検証は、サブリポジトリ内で直接ビルドする。
子リポジトリだけをpushしても、メタのgitlinkを更新しなければフロントの公開対象は変わらない。
Cloud Run APIの更新は [デプロイガイド](deployment.md) を参照。
