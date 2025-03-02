FROM golang:1.24-alpine
RUN \
   apk add \
       git && \
   git clone \
      --depth 1 \
      --branch tohtml-func \
      https://github.com/AndrewChubatiuk/helm-docs && \
   cd helm-docs && \
   go build -o docs ./cmd/helm-docs/... && \
   mv docs /bin/helm-docs
