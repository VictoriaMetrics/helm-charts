FROM golang:1.26-alpine3.22 AS builder

RUN apk add --no-cache make g++ ca-certificates
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . ./
RUN GOEXPERIMENT=jsonv2 CGO_ENABLED=0 go build -o /app/sync-job .

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /app/sync-job /sync-job
ENTRYPOINT ["/sync-job"]
