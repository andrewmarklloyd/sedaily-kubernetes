apiVersion: apps/v1
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
          imagePullPolicy: Always
        - name: sedaily-frontend
          image: "softwaredaily/sedaily-frontend:develop"
          imagePullPolicy: Always
        - name: sedaily-api
          image: "softwaredaily/sedaily-rest-api:develop"
          imagePullPolicy: Always
          env:{{ range $key, $value := .secrets.api }}
          - name: "{{ $key }}"
            valueFrom:
              secretKeyRef:
                name: api
                key: {{ $key }}{{ end }}
