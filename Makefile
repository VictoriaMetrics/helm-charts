URL=https://victoriametrics.github.io/helm-charts/

# Run linter for helm chart
lint:
	@helm lint charts/victoria-metrics-cluster &&\
	helm lint charts/victoria-metrics-single &&\
	helm lint charts/victoria-metrics-agent -f hack/vmagent-lint-hack.yaml && \
	helm lint charts/victoria-metrics-alert -f hack/vmalert-lint-hack.yaml && \
	helm lint charts/victoria-metrics-auth -f hack/vmauth-lint-hack.yaml

# Package chart into zip file
package:
	helm package charts/* -d packages

# Create index file (use only for initial setup)
index:
	helm repo index --url ${URL} .

# Update index file add new version of package into it
merge:
	helm repo index --url ${URL} --merge index.yaml .