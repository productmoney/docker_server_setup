#!/bin/bash

echo ""
echo "----------"
echo "Please enter your github username"
read -r GITHUB_USERNAME

echo "Please enter your github email"
read -r GITHUB_EMAIL

echo "Please enter your github auth token"
echo "If you don't have one, can create at https://github.com/settings/tokens being sure to include the right permissions"
read -r GITHUB_AUTH_TOKEN

HOSTNAME=$(hostname)
echo "Key will have the name: $HOSTNAME (from using command hostname)"

echo ""
echo "----------"
echo "ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa -C \"$GITHUB_USERNAME\" <<<y 2>&1 >/dev/null"
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa -C "$GITHUB_USERNAME" <<<y 2>&1 >/dev/null
echo "eval \"\$(ssh-agent -s)\""
eval "$(ssh-agent -s)"
echo 'ssh-add ~/.ssh/id_rsa'
ssh-add ~/.ssh/id_rsa
echo "pub=\$(cat ~/.ssh/id_rsa.pub)"
pub=$(cat ~/.ssh/id_rsa.pub)
# shellcheck disable=SC2016
echo 'curl -H "Authorization: token $GITHUB_AUTH_TOKEN" -X POST -d "{\"title\":\"`hostname`\",\"key\":\"$pub\"}" https://api.github.com/user/keys'
curl -H "Authorization: token $GITHUB_AUTH_TOKEN" -X POST -d "{\"title\":\"$HOSTNAME\",\"key\":\"$pub\"}" https://api.github.com/user/keys

echo ""
echo "----------"
echo 'echo "StrictHostKeyChecking no " > ~/.ssh/config'
echo "StrictHostKeyChecking no " > ~/.ssh/config

cat > ~/.gitconfig << EOL
[user]
	email = $GITHUB_EMAIL
[core]
        mergeoptions = --no-commit
[alias]
        pff = pull --ff-only
        quick = log -1 --format='%h - %an - %ad - %s' --date=local --name-status
        squash = merge --squash
        blog = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative
        bdiff = show --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --name-only --date=relative origin/master..HEAD
        files = git show --pretty=\"format:\" --name-only
        hist = show --pretty=\"format:\" --name-only
        ci = commit
        co = checkout
        st = status
        mom = !git fetch && git merge origin/master
        rom = !git fetch && git reset --hard origin/master
        pom = push origin master
        ammend = commit --amend -C HEAD
        ll = log --stat --abbrev-commit
        pob = !git fetch && git merge origin/$1 && git push
        z = reset --soft HEAD^
        c = !git add . --all && git commit -m
[merge]
        commit = no
[color]
        branch = auto
        diff = auto
        status = auto
[color "branch"]
        current = yellow reverse
        local = yellow
        remote = green
[color "diff"]
        meta = yellow bold
        frag = magenta bold
        old = red bold
        new = green bold
[color "status"]
        added = yellow
        changed = green
        untracked = cyan
[push]
	default = upstream
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
[difftool "sourcetree"]
	cmd = opendiff \"$LOCAL\" \"$REMOTE\"
[mergetool "sourcetree"]
	cmd = /Applications/Sourcetree.app/Contents/Resources/opendiff-w.sh \"$LOCAL\" \"$REMOTE\" -ancestor \"$BASE\" -merge \"$MERGED\"
	trustExitCode = true
[url "https://$GITHUB_AUTH_TOKEN:@github.com/"]
	insteadOf = https://github.com/
EOL
