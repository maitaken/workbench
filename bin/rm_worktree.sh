#!/bin/sh

# メイン以外のGit worktreeをfzfに一覧表示し、選択したworktreeを削除する。
# Tabキーで複数選択でき、選択を確定すると各git worktree removeコマンドを
# 表示してから順番に実行する。未コミット変更があるworktreeは強制削除しない。

set -eu

# エラーメッセージを標準エラー出力へ表示して終了する。
# 入力例: die "fzf is not installed"
# 出力例: rm_worktree: fzf is not installed
# 終了値: 1
die() {
    echo "rm_worktree: $*" >&2
    exit 1
}

# メインworktree以外のworktreeパスを取得する。
# git worktree listの先頭に出力されるメインworktreeを除外する。
# 入力例: removable_worktrees
# 出力例:
#   /Users/example/ghq/git.example.com/maitaken/workbench_feature_login
#   /Users/example/ghq/git.example.com/maitaken/workbench_fix_header
removable_worktrees() {
    git worktree list --porcelain |
        sed -n 's/^worktree //p' |
        sed '1d'
}

# fzfで削除対象のworktreeを複数選択する。
# Tabキーで複数選択し、Enterキーで確定する。
# 入力例: select_worktrees
# 出力例:
#   /Users/example/ghq/git.example.com/maitaken/workbench_feature_login
#   /Users/example/ghq/git.example.com/maitaken/workbench_fix_header
select_worktrees() {
    command -v fzf >/dev/null 2>&1 ||
        die "fzf is not installed"

    removable_worktrees |
        fzf --multi --prompt='remove worktree> '
}

# fzfで選択したworktreeを削除する。
# 入力例: rm_worktrees
# 結果例: 選択した各パスに対してgit worktree removeを実行する。
# 未コミット変更があるworktreeはGitの保護により削除しない。
rm_worktrees() {
    selected_worktrees=$(select_worktrees) || exit $?
    [ -n "$selected_worktrees" ] || exit 0

    printf '%s\n' "$selected_worktrees" |
        while IFS= read -r worktree; do
            echo "git worktree remove \"$worktree\""
            git worktree remove "$worktree"
        done
}

rm_worktrees
