---
name: Bug report
about: Create a report to help us improve
title: 'bug:'
labels: ''
assignees: ''

---

**Chart name and version**
chart: victoria-metrics-operator
version: v0.6.0

**Describe the bug**
A clear and concise description of what the bug is.

**Custom values**
Please provide only custom values (excluding default ones):
```yaml
vmcluster:
  spec:
    extraArgs:
      http.pathPrefix: /unknown
```
