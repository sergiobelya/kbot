APP=$(shell basename $(shell git remote get-url origin) .git)
REGISTRY=sergiobelya
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

show-vars:
	@echo APP: ${APP}
	@echo VERSION: ${VERSION}
	@echo TARGET: ${TARGET}
	@echo TARGETOS: ${TARGETOS}
	@echo TARGETARCH: ${TARGETARCH}

get:
	go get

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

# build kbot app
build: format get show-vars
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o kbot -ldflags "-X="github.com/sergiobelya/kbot/cmd.appVersion=${VERSION}

linux:
	${MAKE} TARGET=linux build

arm:
	${MAKE} TARGET=arm build

macos:
	${MAKE} TARGET=macos build

windows:
	${MAKE} TARGET=windows build
# -----

# build docker image with kbot app
image: show-vars
	@echo TAG: ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}_${TARGETARCH}
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}_${TARGETARCH} \
		--build-arg="TARGETOS=${TARGETOS}" \
		--build-arg="TARGETARCH=${TARGETARCH}"

image-linux:
	${MAKE} TARGET=linux image

image-arm:
	${MAKE} TARGET=arm image

image-macos:
	${MAKE} TARGET=macos image

image-windows:
	${MAKE} TARGET=windows image
# -----

push: show-vars
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}_${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi $(shell docker images ${REGISTRY}/${APP} -q)
