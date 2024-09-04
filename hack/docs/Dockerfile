FROM golang:1.23-alpine
RUN \
   apk add \
       git && \
   git clone \
      --depth 1 \
      --branch tohtml-func \
      https://github.com/AndrewChubatiuk/helm-docs && \
   cd helm-docs && \
   go build -o helm-docs ./cmd/helm-docs/... && \
   mv helm-docs /bin/helm-docs
