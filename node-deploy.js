const K8sConfig = require('kubernetes-client').config
const path = '~/.kube/config'
const config = K8sConfig.fromKubeconfig(path)
const Client = require('kubernetes-client').Client
const client = new Client({ config, version: '1.9' })

const deploymentManifest = require('./deployment.json')
const create = client.apis.apps.v1.namespaces('sedaily').deployments.post({ body: deploymentManifest }).then(response => {
  console.log(response)
}).catch(e => {
  console.log(e)
})
