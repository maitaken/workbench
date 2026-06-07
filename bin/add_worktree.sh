#!/bin/sh

set -eu

# エラーメッセージを標準エラー出力へ表示して終了する。
# 入力例: die "origin remote is not configured"
# 出力例: add_worktree: origin remote is not configured
# 終了値: 1
die() {
    echo "add_worktree: $*" >&2
    exit 1
}

# originのURLから末尾のリポジトリ名を取得する。
# 入力例: origin = git@git.example.com:maitaken/workbench.git
# 出力例: workbench
repo_name() {
    remote_url=$(git remote get-url origin 2>/dev/null) ||
        die "origin remote is not configured"

    remote_path=${remote_url#*://}
    remote_path=${remote_path#*@}
    case "$remote_path" in
        *:*) remote_path=${remote_path#*:} ;;
        */*) remote_path=${remote_path#*/} ;;
    esac

    name=${remote_path##*/}
    name=${name%.git}
    [ -n "$name" ] || die "cannot determine the repository name from origin"
    printf '%s\n' "$name"
}

# 指定した名前とディレクトリ名が完全一致するworktreeのパスを取得する。
# 入力例: origin_worktree "workbench"
# 出力例: /Users/example/ghq/git.example.com/maitaken/workbench
# 該当するworktreeがない場合は何も出力しない。
origin_worktree() {
    expected_name=$1

    git worktree list --porcelain |
        sed -n 's/^worktree //p' |
        while IFS= read -r path; do
            if [ "${path##*/}" = "$expected_name" ]; then
                printf '%s\n' "$path"
                break
            fi
        done
}

# 新規ブランチの作成元としてmaster、次にmainを検索する。
# ローカルブランチを優先し、なければoriginのremote-tracking branchを使う。
# 入力例: default_branch
# 出力例: master、main、origin/master、またはorigin/main
default_branch() {
    for branch in master main; do
        if git show-ref --verify --quiet "refs/heads/$branch"; then
            printf '%s\n' "$branch"
            return
        fi
        if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            printf '%s\n' "origin/$branch"
            return
        fi
    done

    die "neither main nor master exists"
}

# ブランチ名をworktreeのディレクトリ名に利用できる形式へ変換する。
# 入力例: path_branch_name "feature/login"
# 出力例: feature_login
path_branch_name() {
    # A slash is valid in a branch name but would create nested directories.
    printf '%s\n' "$1" | tr '/' '_'
}

# 新規ブランチのworktreeを元リポジトリと同じ階層へ作成する。
# 第一引数に新規ブランチ名、第二引数に作成元ブランチ名を指定する。
# 入力例: add_worktree "feature/login" "develop"
# 作成例: .../workbench_feature_login（ブランチ名はfeature/login）
# 第二引数を省略した場合はmaster、次にmainを作成元として使用する。
add_worktree() {
    [ "$#" -ge 1 ] && [ "$#" -le 2 ] ||
        die "usage: add_worktree <new-branch> [base-branch]"

    branch_name=$1
    base_branch=${2:-}

    git check-ref-format --branch "$branch_name" >/dev/null 2>&1 ||
        die "invalid branch name: $branch_name"
    if git show-ref --verify --quiet "refs/heads/$branch_name" ||
        git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        die "branch already exists: $branch_name"
    fi

    repository_name=$(repo_name)
    repository_worktree=$(origin_worktree "$repository_name")
    [ -n "$repository_worktree" ] ||
        die "cannot find a worktree named exactly '$repository_name'"

    destination="$(dirname "$repository_worktree")/${repository_name}_$(path_branch_name "$branch_name")"
    [ ! -e "$destination" ] || die "destination already exists: $destination"

    if [ -z "$base_branch" ]; then
        base_branch=$(default_branch)
    elif git show-ref --verify --quiet "refs/heads/$base_branch"; then
        :
    elif git show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
        base_branch="origin/$base_branch"
    else
        die "base branch does not exist: $base_branch"
    fi

    git worktree add -b "$branch_name" "$destination" "$base_branch"
}

add_worktree "$@"
