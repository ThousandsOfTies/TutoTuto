---
description: TutoTutoのローカルコマンド実行
---

# コマンド実行

現在のチェックアウトは `D:\Yurufuwa\TutoTuto`。PowerShellではUTF-8を明示して文書を読む。

```powershell
Get-Content -Encoding utf8 README.md
git status --short --branch
git submodule status
npm --prefix repos/tutotuto-app run build
```

実行ポリシーで `npm.ps1` が拒否された場合は `npm.cmd` を使用する。

検索は `rg` を使用する。各サブリポジトリを作業ディレクトリにすると、親のignore設定に左右されず検索できる。
WindowsのNode.jsで作った `node_modules` をWSLのNode.jsから使い回さない。

MakefileはGNU MakeとUnix系シェルを前提とする。PowerShell単体でMakeが使えなければ、
各サブリポジトリでnpmを直接実行するか、GNU Makeを用意した環境を使う。
WSLの場合のプロジェクトパスは `/mnt/d/Yurufuwa/TutoTuto`。ディストリビューションとツールの有無は実行前に確認する。

ファイルの編集・削除は対象パスを確認し、既存のユーザー変更を上書きしない。
ビルド・デプロイの順序は [デプロイガイド](deployment.md) と [更新手順](deployment-workflow.md) を参照。
