######################################################################
# @author      : Enno Boland (mail@eboland.de)
# @file        : Makefile
# @created     : Wednesday Jun 29, 2022 07:58:39 CEST
######################################################################

REGISTRY=127.0.0.1:5000

.PHONY: build push all

all: build

build:
	podman build \
		-t $(REGISTRY)/helmfile-cd \
		.

push: build
	podman push $(REGISTRY)/helmfile-cd

deploy:
	nk helm upgrade -n helmfile-cd \
		--install \
		--create-namespace \
		--reset-values \
		--set image.repository=$(REGISTRY)/helmfile-cd \
		--set image.tag=latest \
		--set image.pullPolicy=Always \
		--set git.authentication.existingSecret=helmfile-cd-key \
		--set git.repository=git@github.com:withlazers/infrastructure-withlazers.git \
		--set persistence.enabled=true \
		helmfile-cd charts/helmfile-cd

undeploy:
	nk helm delete -n helmfile-cd helmfile-cd
