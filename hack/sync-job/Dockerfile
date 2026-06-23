FROM --platform=$BUILDPLATFORM golang:1.26-alpine3.22 AS builder

ARG TARGETOS TARGETARCH

RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . ./
RUN GOEXPERIMENT=jsonv2 CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /app/sync-job .

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /app/sync-job /sync-job
ENTRYPOINT ["/sync-job"]
