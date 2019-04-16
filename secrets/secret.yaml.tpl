apiVersion: v1
kind: Secret
metadata:
  name: api
type: Opaque
data:{{ range $key, $value := .secrets }}
  {{ $key }}: {{ $value }}{{ end }}
