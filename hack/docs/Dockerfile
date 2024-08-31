FROM golang:1.23-alpine
RUN \
   apk add \
       git && \
   git clone --depth 1 https://github.com/AndrewChubatiuk/helm-docs --branch tohtml-func && \
   cd helm-docs && \
   go build -o helm-docs ./cmd/helm-docs/... && \
   mv helm-docs /bin/helm-docs
