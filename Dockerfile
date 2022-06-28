FROM alpine:3.16

ARG HELM=3.9.0
ARG HELM_DIFF=3.5.0
ARG HELM_GIT=0.11.2
ARG HELMFILE=0.144.0

ENV HELM_PLUGINS /helm-plugins

RUN apk add git openssh-client-default && \
	wget -O- https://get.helm.sh/helm-v${HELM}-linux-amd64.tar.gz | \
		tar -C /usr/local/bin --strip-components=1 -xz linux-amd64/helm && \
	wget -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v${HELMFILE}/helmfile_linux_amd64 && \
	helm plugin install --version ${HELM_DIFF} https://github.com/databus23/helm-diff && \
	helm plugin install --version ${HELM_GIT} https://github.com/aslafy-z/helm-git && \
	chmod +x /usr/local/bin/* && \
	adduser -u 1000 -D helmfile

COPY entrypoint.sh /entrypoint.sh
COPY askpass.sh /askpass.sh

USER 1000

ENTRYPOINT ["/entrypoint.sh"]
