
# install cluster essentials
export  AWS_REGION=us-east-2
export cluster_name=tap-aws-13
export AWS_ACCOUNT_ID=699139306504


kubectl create namespace kapp-controller
set INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54bf611711923dccd7c7f10603c846782b90644d48f1cb570b43a082d18e23b9
set INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
set INSTALL_REGISTRY_USERNAME="xx"
set INSTALL_REGISTRY_PASSWORD="yy"
cd $HOME/tanzu-cluster-essentials

C:\Users\kmantha\tanzu-cluster-essentials>install.bat --yes
#Issues
Error 1 -
kapp: Error: Building Core clientset: exec plugin: invalid apiVersion "client.authentication.k8s.io/v1alpha1"
"Failed to deploy kapp-controller" 
resolution - changed kubeconfig file updates aws cluster to use v1beta1


#Issue 2 - C:\Users\kmantha\tanzu-cluster-essentials>kubectl get po
##Unable to connect to the server: getting credentials: exec plugin is configured to use API version client.authentication.k8s.io/v1beta1, plugin returned version client.authentication.k8s.io/v1alpha1

#Resolution - upgraded aws cli