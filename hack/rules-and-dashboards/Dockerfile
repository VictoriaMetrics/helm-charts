FROM golang:1.25-alpine3.22

RUN apk add make g++
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY ./main.go ./
ENV GOEXPERIMENT=jsonv2
RUN go build -o /app/hack .
ENTRYPOINT ["/app/hack"]
