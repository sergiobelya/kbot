APP=$(shell basename $(shell git remote get-url origin) .git)
REGISTRY=sergiobelya
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=darwin
# TARGETOS=linux
TARGETARCH=amd64
# TARGETARCH=arm64
# TARGETARCH=$(shell dpkg --print-architecture)

get:
	go get

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

appversion:
	echo ${APP} ${VERSION}

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o kbot -ldflags "-X="github.com/sergiobelya/kbot/cmd.appVersion=${VERSION}

build-mac:
	${MAKE} TARGETOS=darwin TARGETARCH=amd64 build

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} --no-cache

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
