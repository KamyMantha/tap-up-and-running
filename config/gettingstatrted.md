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

