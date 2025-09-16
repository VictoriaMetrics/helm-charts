{{- define "vm-operator.crds" -}}
crds:
  - names:
      kind: VLAgent
      listKind: VLAgentList
      plural: vlagents
      singular: vlagent
    name: vlagents.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1
  - names:
      kind: VLCluster
      listKind: VLClusterList
      plural: vlclusters
      singular: vlcluster
    name: vlclusters.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1
  - names:
      kind: VLogs
      listKind: VLogsList
      plural: vlogs
      singular: vlogs
    name: vlogs.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VLSingle
      listKind: VLSingleList
      plural: vlsingles
      singular: vlsingle
    name: vlsingles.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1
  - names:
      kind: VMAgent
      listKind: VMAgentList
      plural: vmagents
      singular: vmagent
    name: vmagents.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMAlertmanagerConfig
      listKind: VMAlertmanagerConfigList
      plural: vmalertmanagerconfigs
      singular: vmalertmanagerconfig
    name: vmalertmanagerconfigs.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMAlertmanager
      listKind: VMAlertmanagerList
      plural: vmalertmanagers
      shortNames:
        - vma
      singular: vmalertmanager
    name: vmalertmanagers.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMAlert
      listKind: VMAlertList
      plural: vmalerts
      singular: vmalert
    name: vmalerts.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMAnomaly
      listKind: VMAnomalyList
      plural: vmanomalies
      singular: vmanomaly
    name: vmanomalies.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1
  - names:
      kind: VMAuth
      listKind: VMAuthList
      plural: vmauths
      singular: vmauth
    name: vmauths.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMCluster
      listKind: VMClusterList
      plural: vmclusters
      singular: vmcluster
    name: vmclusters.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMNodeScrape
      listKind: VMNodeScrapeList
      plural: vmnodescrapes
      singular: vmnodescrape
    name: vmnodescrapes.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMPodScrape
      listKind: VMPodScrapeList
      plural: vmpodscrapes
      singular: vmpodscrape
    name: vmpodscrapes.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMProbe
      listKind: VMProbeList
      plural: vmprobes
      singular: vmprobe
    name: vmprobes.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMRule
      listKind: VMRuleList
      plural: vmrules
      singular: vmrule
    name: vmrules.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMScrapeConfig
      listKind: VMScrapeConfigList
      plural: vmscrapeconfigs
      singular: vmscrapeconfig
    name: vmscrapeconfigs.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMServiceScrape
      listKind: VMServiceScrapeList
      plural: vmservicescrapes
      singular: vmservicescrape
    name: vmservicescrapes.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMSingle
      listKind: VMSingleList
      plural: vmsingles
      singular: vmsingle
    name: vmsingles.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMStaticScrape
      listKind: VMStaticScrapeList
      plural: vmstaticscrapes
      singular: vmstaticscrape
    name: vmstaticscrapes.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VMUser
      listKind: VMUserList
      plural: vmusers
      singular: vmuser
    name: vmusers.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1beta1
  - names:
      kind: VTCluster
      listKind: VTClusterList
      plural: vtclusters
      singular: vtcluster
    name: vtclusters.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1
  - names:
      kind: VTSingle
      listKind: VTSingleList
      plural: vtsingles
      singular: vtsingle
    name: vtsingles.operator.victoriametrics.com
    group: operator.victoriametrics.com
    versions:
      - v1
{{- end -}}
