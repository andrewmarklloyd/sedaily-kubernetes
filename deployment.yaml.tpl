apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: sedaily
  namespace: sedaily
  labels:
    app: sedaily
spec:
  replicas: 1
  selector:
    matchLabels:
      name: sedaily
  template:
    metadata:
      labels:
        name: sedaily
    spec:
      containers:
        - name: sedaily-mongo
          image: "softwaredaily/sedaily-mongo:develop"
          imagePullPolicy: IfNotPresent
        - name: sedaily-devops
          image: "softwaredaily/sedaily-devops:develop"
          imagePullPolicy: IfNotPresent
          env:{{ range $key, $value := .secrets.devops }}
          - name: "{{ $key }}"
            valueFrom:
              secretKeyRef:
                name: devops
                key: {{ $key }}{{ end }}
        - name: sedaily-api
          image: "softwaredaily/sedaily-rest-api:develop"
          imagePullPolicy: IfNotPresent
          env:{{ range $key, $value := .secrets.api }}
          - name: "{{ $key }}"
            valueFrom:
              secretKeyRef:
                name: api
                key: {{ $key }}{{ end }}
