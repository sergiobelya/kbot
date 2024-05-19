APP=$(shell basename $(shell git remote get-url origin) .git)
GCLOUD_PROJECT_ID=strange-theme-417619
# REGISTRY=eu.gcr.io/${GCLOUD_PROJECT_ID}
# REGISTRY=sergiobelya
REGISTRY=ghcr.io/sergiobelya
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=
TARGETARCH=
# TARGETARCH=$(shell dpkg --print-architecture)
TARGET=
ifeq ($(TARGET),linux)
	TARGETOS=linux
	TARGETARCH=amd64
endif
ifeq (${TARGET},arm)
	TARGETOS=darwin
	TARGETARCH=arm64
endif
ifeq (${TARGET},macos)
	TARGETOS=darwin
	TARGETARCH=amd64
endif
ifeq (${TARGET},windows)
	TARGETOS=windows
	TARGETARCH=amd64
endif
TAG=${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

show-vars:
	@echo APP: ${APP}
	@echo VERSION: ${VERSION}
	@echo TARGET: ${TARGET}
	@echo TARGETOS: ${TARGETOS}
	@echo TARGETARCH: ${TARGETARCH}
	@echo TAG: ${TAG}

get:
	go get

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

# Build kbot app
# make TARGET=linux build
# make TARGET=arm build
# make TARGET=macos build
# make TARGET=windows build
build: format get show-vars
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o kbot -ldflags "-X="github.com/sergiobelya/kbot/cmd.appVersion=${VERSION}
# -----

# Build docker image with kbot app
# make TARGET=linux image
# make TARGET=arm image
# make TARGET=macos image
# make TARGET=windows image
image: show-vars
	@echo TAG: ${TAG}
	docker build . -t ${TAG} \
		--build-arg="TARGETOS=${TARGETOS}" \
		--build-arg="TARGETARCH=${TARGETARCH}"
# -----

# Auth before push
auth:
# run export CR_PAT before
	echo ${CR_PAT} | docker login ghcr.io -u sergiobelya --password-stdin
# gcloud auth login
# gcloud config set project ${GCLOUD_PROJECT_ID}
# gcloud auth configure-docker eu.gcr.io

# make TARGET=linux push
# make TARGET=arm push
# make TARGET=macos push
# make TARGET=windows push
push: show-vars
	docker push ${TAG}

clean:
	rm -rf kbot
	docker rmi $(shell docker images ${REGISTRY}/${APP} -q)
