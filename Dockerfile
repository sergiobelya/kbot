FROM quay.io/projectquay/golang:1.22 as builder

ARG TARGETOS
ARG TARGETARCH
WORKDIR /go/src/app
COPY . .
RUN make TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH} build


FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]
