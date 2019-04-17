apiVersion: v1
kind: Secret
metadata:
  name: {{ .name }}
type: Opaque
data:{{ range $key, $value := .secrets }}
  {{ $key }}: {{ $value }}{{ end }}
