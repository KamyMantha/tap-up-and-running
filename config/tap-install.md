
## TAP installation
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=nnn
export INSTALL_REGISTRY_PASSWORD=mm

export AWS_ACCOUNT_ID=0000
export AWS_REGION=${AWS_REGION}
export TAP_VERSION=1.3.2
export INSTALL_REGISTRY_HOSTNAME=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
export INSTALL_REPO=tap-images

## login to container registry
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
## login to tanzu repo
docker login registry.tanzu.vmware.com  -u user -p password!

## create registry credentials

 tanzu secret registry add tanzu-net --username kmantha@vmware.com --password 'VMware123!'   --server registry.tanzu.vmware.com   --export-to-all-namespaces --yes --namespace tap-install

tanzu secret registry update  tap-registry   --username "_json_key" --password "$(cat /home/azureuser/sa-tap.json)" --server "gcr.io" --export-to-all-namespaces --yes --namespace tap-install

## relocate package images
 imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/tap-images --registry-verify-certs=false

## create ns
kubectl create ns tap-install

## add tap repository
## add package

set AWS_ACCOUNT_ID=xxx
set AWS_REGION=yy
set TAP_VERSION=1.3.2
set INSTALL_REGISTRY_HOSTNAME=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
set INSTALL_REPO=tap-images

tanzu package repository add tanzu-tap-repository  --url ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}:$TAP_VERSION  --namespace tap-install



## Install TAP
tanzu package install tap -p tap.tanzu.vmware.com -v 1.3.2  --values-file tap-values-aws.yml -n tap-install

## Tap installation issues

## issue 1 - with certificates
## Fixed by adding flag
$ imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
Error: Collecting images: Working with registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:1.3.2: Get "https://registry.tanzu.vmware.com/v2/": x509: certificate signed by unknown authority

## Issue 2 - resource authentication issue
##  Addressed by running installation using windows command line instead of git bash
it is failing due to auth issues rror: resource reconciliation failed: vendir: Error: Syncing directory '0':
  Syncing directory '.' with imgpkgBundle contents:
    Imgpkg: exit status 1 (stderr: imgpkg: Error: Fetching image:
  GET https://registry.tanzu.vmware.com/v2/tanzu-application-platform/tap-packages/manifests/1.3.2:
    UNAUTHORIZED: unauthorized to access repository: tanzu-application-platform/tap-packages, action: pull: unauthorized to access repository: tanzu-application-platform/tap-packages, action: pull


## Issue 3 -- Packages did not reconcile
# Reconciliation issues fixed by adding new nodes and storage driver
USEFUL-ERROR-MESSAGE:    kapp: Error: waiting on reconcile packageinstall/metadata-store (packaging.carvel.dev/v1alpha1) namespace: tap-install:
  Finished unsuccessfully (Reconcile failed:  (message: Error (see .status.usefulErrorMessage for details)))

https://vmware.slack.com/archives/C02D60T1ZDJ/p1670276742181139
