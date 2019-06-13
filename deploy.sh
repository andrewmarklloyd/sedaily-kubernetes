#!/bin/bash

namespace="sedaily"
deploymentName="sedaily"
serviceName="sedaily"
kube="kubectl -n ${namespace}"


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

function createService() {
  ${kube} expose deployment ${deploymentName} --type=LoadBalancer --port=4040 --name=sedaily-api
  minikube -n sedaily service sedaily-api
  ${kube} expose deployment ${deploymentName} --type=LoadBalancer --port=5000 --name=sedaily-frontend
  minikube -n sedaily service sedaily-frontend
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

function configureMinikubeEnvironment() {
  eval $(minikube docker-env)
}

if [[ -z $DOCKER_HOST ]]; then
  echo 'You need to run "eval $(minikube docker-env)" to use this script...'
  exit 1
fi


if [[ ${1} == 'minikube-config' ]]; then
  configureMinikubeEnvironment
elif [[ ${1} == 'secrets' ]]; then
  applySecrets
elif [[ ${1} == 'deploy' ]]; then
  createDeployment
elif [[ ${1} == 'service' ]]; then
  createService
else
  echo "Argument not recognized, see script args for more info."
fi
