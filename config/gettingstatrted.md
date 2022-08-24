==== getting started
== prepare developer namespace
tanzu secret registry add registry-credentials --server "gcr.io" --username "_json_key" --password "$(cat /home/azureuser/sa-tap.json)"  --namespace dev1

 kubectl -n dev1 create secret docker-registry registry-credentials  --docker-server "gcr.io"  --docker-username "_json_key"  --docker-password "$(cat /home/azureuser/sa-tap.json)" 
 
 ---create default service account and assign cluster access rights to run the supply chain pipelines
 
 k apply -f dev.yml -n dev1
 
 --- not needed
 tanzu plugin install rbac --local linux-amd64
 tanzu rbac binding add -g GROUP-FOR-APP-VIEWER -n dev1 -r app-viewer
tanzu rbac binding add -g GROUP-FOR-APP-EDITOR -n dev1 -r app-editor
 k apply -f dev_rbac.yml -n dev3

------------------
== step2 run sample app workload
tanzu apps workload create tanzu-java-web-app --git-repo https://github.com/sample-accelerators/tanzu-java-web-app --git-branch main --type web --label app.kubernetes.io/part-of=tanzu-java-web-app --yes --namespace dev1

validate
 http://tanzu-java-web-app-dev1.cnr.tap.kamymantha.ninja
== step3 install ootb sample templates

tanzu package install ootb-templates --package-name ootb-templates.tanzu.vmware.com  --version 0.7.0  --namespace tap-install --values-file ootb-templates-values.yaml

-- include ootb testing template to supply chain
Modify tap values file
Apply tekton pipeline yaml to workload
 k apply -f tekton-pipeline.yaml -n dev1
 
tanzu apps workload create tanzu-java-web-app 
  --git-repo https://github.com/sample-accelerators/tanzu-java-web-app \
  --git-branch main \
  --type web \
  --label apps.tanzu.vmware.com/has-tests=true \
  --yes
  
--  install insight plugin

kubectl get secret app-tls-cert -n metadata-store -o json|jq -r '.data."ca.crt"'|base64 -d > /tmp/ca.crt  

kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode
== app accelerator

 export METADATA_STORE_DOMAIN="metadata-store.tap.kamymantha.ninja"
export METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets -n metadata-store -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='metadata-store-read-write-client')].data.token}" | base64 -d)

 tanzu insight config set-target http://$METADATA_STORE_DOMAIN --ca-cert insight-ca.crt --access-token $METADATA_STORE_ACCESS_TOKEN
