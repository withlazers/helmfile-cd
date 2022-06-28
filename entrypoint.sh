#!/bin/sh -e
die() {
	echo "$@" >&2
	exit 1
}

SSH='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
if [ -e "/auth/key" ]; then
	SSH="$SSH -i /auth/key"
fi

export GIT_SSH_COMMAND="$SSH"
export GIT_ASKPASS="/askpass.sh"

if [ -d /work/repo ]; then
	git_branch=$(git -C /work/repo branch --show-current)
	if [ -n "$GIT_BRANCH" ] && [ "$git_branch" != "$GIT_BRANCH" ]; then
		die "Branch mismatch: $git_branch != $GIT_BRANCH"
	fi
	git -C /work/repo fetch origin "$git_branch"
	git -C /work/repo reset --hard FETCH_HEAD
else
	git clone --depth 1 \
		${GIT_BRANCH:+-b "${GIT_BRANCH}"} \
		"$GIT_REPOSITORY" /work/repo
fi


cd "/work/repo/$GIT_DIRECTORY"
echo "##### Checking templates"
helmfile template > /dev/null
echo "##### Templates OK, rolling out"
if ! helmfile apply; then
	echo "##### helmfile apply failed, falling back to helmfile sync" >&2
	exec helmfile sync
fi
