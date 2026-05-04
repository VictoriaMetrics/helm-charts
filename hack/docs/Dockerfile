FROM golang:1.26-alpine
RUN \
   apk add \
       git && \
   git clone \
      --depth 1 \
      --branch extra \
      https://github.com/AndrewChubatiuk/helm-docs && \
   cd helm-docs && \
   go build -o docs ./cmd/helm-docs/... && \
   mv docs /bin/helm-docs
