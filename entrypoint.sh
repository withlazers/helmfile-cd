#!/bin/sh -e
die() {
	echo "$@" >&2
	exit 1
}

echo '##### Configuration'
ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
if [ -e "/auth/key" ]; then
	ssh="${ssh} -i /auth/key"
fi
export GIT_SSH_COMMAND="${ssh}"
export GIT_ASKPASS="/askpass.sh"

echo '##### Retrieve current revision'
if [ -d /work/repo ]; then
	GIT_BRANCH=$(git -C /work/repo branch --show-current)
	if [ -n "${CONFIG_GIT_BRANCH}" ] && \
			[ "${GIT_BRANCH}" != "${CONFIG_GIT_BRANCH}" ]; then
		die "Branch mismatch: ${GIT_BRANCH} != ${CONFIG_GIT_BRANCH}"
	fi
	git -C /work/repo fetch origin "${GIT_BRANCH}"
	git -C /work/repo reset --hard FETCH_HEAD
else
	git clone --depth 1 \
		${CONFIG_GIT_BRANCH:+-b "${CONFIG_GIT_BRANCH}"} \
		"${CONFIG_GIT_REPOSITORY}" /work/repo
fi

echo '##### Check for changes'
NEW_GIT_REV=$(git -C /work/repo rev-parse HEAD)
echo "Current state:    ${STATE_GIT_REV:-'<none>'}"
echo "New state:        ${NEW_GIT_REV}"
if [ -n "${STATE_GIT_REV}" ] && [ "${NEW_GIT_REV}" = "${STATE_GIT_REV}" ]; then
	echo "-> No changes"
	exit 0
fi

echo '##### Apply changes (helm sync)'
cd "/work/repo/${CONFIG_GIT_DIRECTORY}"
helmfile sync

echo '##### Update state'
exec kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${STATE_NAME}
  namespace: ${NAMESPACE}
data:
  GIT_REV: "${NEW_GIT_REV}"
EOF
