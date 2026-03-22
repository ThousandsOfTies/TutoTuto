#!/bin/bash
# サブリポジトリのコミットIDをVERSIONSファイルに記録

REPOS_DIR="repos"

echo "# 依存リポジトリのバージョン" > VERSIONS
echo "# 更新: make update-versions" >> VERSIONS
echo "" >> VERSIONS

# drawing-common
if [ -d "$REPOS_DIR/drawing-common/.git" ]; then
    COMMIT=$(cd "$REPOS_DIR/drawing-common" && git rev-parse HEAD)
    echo "drawing-common=$COMMIT" >> VERSIONS
else
    echo "drawing-common=" >> VERSIONS
fi

# home-teacher-common
if [ -d "$REPOS_DIR/home-teacher-common/.git" ]; then
    COMMIT=$(cd "$REPOS_DIR/home-teacher-common" && git rev-parse HEAD)
    echo "home-teacher-common=$COMMIT" >> VERSIONS
else
    echo "home-teacher-common=" >> VERSIONS
fi

# tutotuto-app
if [ -d "$REPOS_DIR/tutotuto-app/.git" ]; then
    COMMIT=$(cd "$REPOS_DIR/tutotuto-app" && git rev-parse HEAD)
    echo "tutotuto-app=$COMMIT" >> VERSIONS
else
    echo "tutotuto-app=" >> VERSIONS
fi

echo "VERSIONSファイルを更新しました:"
cat VERSIONS
