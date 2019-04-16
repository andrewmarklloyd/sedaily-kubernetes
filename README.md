## Softwaredaily On Kubernetes
This is a proof of concept for deploying all of the
[collection of open source projects](https://github.com/SoftwareEngineeringDaily) necessary for the [Softwaredaily](https://www.softwaredaily.com) web application on Kubernetes.

This is in conjunction with providing a one-click deploy to upgrade a [Podsheet](podsheets.com) to include a social network as richly functional as Softwaredaily. See the [FindCollabs](https://findcollabs.com/project/IQNarf2tJ8Un4esfoXck) project for more context.

### Architecture
For a high level application architecture see the Softwaredaily [open source guide](https://softwareengineeringdaily.github.io/High_Level/architecture/). Essentially this project seeks to allow for an easy build and deploy of all Softwaredaily components necessary for the web application:
- Node.js backend API
- Vue.js frontend
- MongoDB instance: 1 per cluster with 1 table per tenant
- Node.js event stream API
- InfluxDB event stream storage
- Grafana event stream visualization

### Requirements
**Phase 1**: For an MVP this project will use `kubectl` to deploy all hard-coded softwaredaily specific k8s manifests. All secrets will be created using a `sed` replacement scripting. MongoDB will be part of the deployment, phase 2 will seek to utilize an already provisioned instance and only add a table for the namespace (use Ansible?). To mock having more than one 'application' we will scale this deployment to multiple replicas.

**Phase 2**: Deployment of a unique social network from configuration and env vars using a single MongoDB instance in the cluster and a table created at deployment.

To be determined:
- all tenants in the same namespace?
- how to populate data without mining Wordpress
