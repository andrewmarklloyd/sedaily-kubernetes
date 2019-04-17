#!/bin/bash

namespace="sedaily"
deploymentName="sedaily"
serviceName="sedaily"
secretsName="sedaily"
kube="kubectl -n ${namespace}"

function createNamespace() {
  kubectl create -f namespace.yaml
}

function deleteNamespace() {
  kubectl delete -f namespace.yaml
}

function createDeployment() {
  deploymentFile="deployment.yaml"
  secret_template="tmp_deploy_template.yaml"
  rm -f ${secret_template}
  touch ${secret_template}
  echo "secrets:" > ${secret_template}
  for secretsFile in ./secrets/*.env; do
    sec=${secretsFile%\.*}
    sec=${sec#*secrets\/}
    echo "  ${sec}:" >> ${secret_template}
    while IFS=\= read key value
    do
      encodedValue=$(echo -n ${value} | base64)
      echo "    ${key}: ${encodedValue}" >> ${secret_template}
    done < ${secretsFile}
  done
  gotpl "./deployment.yaml.tpl" < ${secret_template} > ${deploymentFile}
  ${kube} apply -f ${deploymentFile}
  rm ${deploymentFile}
  rm ${secret_template}
}

function deleteDeployment() {
  ${kube} delete deployment ${deploymentName}
}

function createService() {
  ${kube} expose deployment ${deploymentName} --type=LoadBalancer --port=4040 --name=sedaily
  minikube -n sedaily service sedaily
}

function applySecrets() {
  cd secrets/
  for sec in *.env; do
    sec=${sec%\.*}
    secretsFile="./${sec}.env"
    if [[ ! -f "${secretsFile}" ]]; then
      echo "No file found named 'secrets' See README for instructions."
      exit 1
    fi
    secret_template="tmp_secret_template.yaml"
    rm -f ${secret_template}
    rm -f secrets.yaml
    touch ${secret_template}
    echo "name: ${sec}" > ${secret_template}
    echo "secrets:" >> ${secret_template}
    while IFS=\= read key value
    do
      encodedValue=$(echo -n ${value} | base64)
      echo "  ${key}: ${encodedValue}" >> ${secret_template}
    done < ${secretsFile}
    gotpl "./secret.yaml.tpl" < ${secret_template} > secrets.yaml
    ${kube} apply -f secrets.yaml
    rm secrets.yaml
    rm ${secret_template}
  done
}

function podInfo() {
  pods=$(${kube} get pods)
  echo "$pods"
  pod1=$(echo "$pods" | sed -n 2p | awk '{print $1}')
  ${kube} logs "$pod1" sedaily-api
  ${kube} describe pod $pod1 -n ${namespace}
}

function configureMinikubeEnvironment() {
  eval $(minikube docker-env)
}

function cleanup() {
  deleteDeployment
  deleteSecrets
  deleteNamespace
}

function createAll() {
  createNamespace
  applySecrets
  createDeployment
  createService
}

if [[ -z $DOCKER_HOST ]]; then
  echo 'You need to run "eval $(minikube docker-env)" to use this script...'
  exit 1
fi

if [[ ${1} == 'create' ]]; then
  createAll $@
elif [[ ${1} == 'deploy' ]]; then
  createDeployment
elif [[ ${1} == 'cleanup' ]]; then
  cleanup
elif [[ ${1} == 'minikube-config' ]]; then
  configureMinikubeEnvironment
elif [[ ${1} == 'pod-info' ]]; then
  podInfo
elif [[ ${1} == 'secret-info' ]]; then
  getSecrets
elif [[ ${1} == 'build-deploy' ]]; then
  buildAndDeployLocal
elif [[ ${1} == 'apply-secrets' ]]; then
  applySecrets
elif [[ ${1} == 'delete-secrets' ]]; then
  deleteSecrets
elif [[ ${1} == 'setup-local' ]]; then
  createEnvvars
else
  echo "Argument not recognized, see script args for more info."
fi
