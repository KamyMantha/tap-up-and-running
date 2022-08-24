

## TAP Instalation

##login to container registry
cat user.json | docker login -u _json_key --password-stdin https://gcr.io
## login to tanzu repo
docker login registry.tanzu.vmware.com  -u user -p password!


export INSTALL_REGISTRY_HOSTNAME="gcr.io"
export INSTALL_REGISTRY_USERNAME="_json_key"
export INSTALL_REGISTRY_PASSWORD_FILE="./user.json"
export TAP_VERSION="1.1.0"
## relocate package images
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo gcr.io/api-gw-on-gcp/tap-packages

## create ns
kubectl create ns tap-install

tanzu secret registry add tap-registry   --username "_json_key" --password "$(cat /home/azureuser/sa-tap.json)" --server "gcr.io" --export-to-all-namespaces --yes --namespace tap-install

tanzu package repository add tanzu-tap-repository  --url gcr.io/api-gw-on-gcp/tap-packages:$TAP_VERSION   --namespace tap-install  
kubectl -n dev1 create secret docker-registry registry-credentials  --docker-server "gcr.io"  --docker-username "_json_key"  --docker-password "$(cat /home/azureuser/user.json)"

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file tap-values.yaml -n tap-install

tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0  --values-file tap3b.yml -n tap-install
