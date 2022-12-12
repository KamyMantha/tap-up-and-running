# getting started #workload is being deployed to default workspce
# step 1 prepare developer namespace
# create default service account and assign cluster access rights to run the supply chain pipelines
# Skip creating registry credentials as you will authenticate/ authorize by providing workload arn, please check dev-aws.yaml

 kubectl apply -f dev_aws.yml -n default
 
# step2 create repos for namespace -- cannot dynamcally create repos for ECR // will be addressed in future TAP releases
aws ecr create-repository --repository-name tanzu-application-platform/tanzu-java-web-app-default --region $AWS_REGION
aws ecr create-repository --repository-name tanzu-application-platform/tanzu-java-web-app-default-bundle --region $AWS_REGION

# step3 run sample app workload
tanzu apps workload create tanzu-java-web-app --git-repo https://github.com/sample-accelerators/tanzu-java-web-app --git-branch main --type web --label app.kubernetes.io/part-of=tanzu-java-web-app --yes --namespace default

# step4 validate
 http://tanzu-java-web-app-default.cnr.tap.kamymantha.ninja


 