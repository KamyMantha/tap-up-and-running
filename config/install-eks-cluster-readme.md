## Install EKS 

export cluster_name=tap-aws-13
export number_of_nodes=3
export AWS_REGION=us-east-2
# script did not work so pasted the individual commands from the script

  ./scripts/eks-create-cluster.sh tap-aws-13 3
#export creds
export AWS_ACCESS_KEY_ID=xx
export AWS_SECRET_ACCESS_KEY=yy
export AWS_SESSION_TOKEN=zz
 
  #create cluster
  eksctl create cluster --name $cluster_name --region $AWS_REGION --without-nodegroup
  
 #get container AMI // did not work for my ID -- Gabry provided her id
 export containerdAMI=$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id --region $AWS_REGION --query "Parameter.Value" --output text)
 
 # update cluster with containerd
  export containerAMI=ami-0136f2e4cb92702e4
  export bootstrap_cmd="/etc/eks/bootstrap.sh $cluster_name --container-runtime containerd"
 
export containerdAMI=ami-0136f2e4cb92702e4
 
 cat <<EOF | eksctl create nodegroup -f -
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: $cluster_name
  region: $AWS_REGION

managedNodeGroups:
  - name: $cluster_name-containerd-ng
    ami: $containerdAMI
    instanceType: $AWS_INSTANCE_TYPE
    desiredCapacity: $number_of_nodes
    volumeSize: 100
    overrideBootstrapCommand: $bootstrap_cmd
EOF
#create oidc provider -- issue document is missing export in front of oidc //line 41
export oidcProvider=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION | jq '.cluster.identity.oidc.issuer' | tr -d '"' | sed 's/https:\/\///')
cat << EOF > build-service-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${oidcProvider}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${oidcProvider}:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "${oidcProvider}:sub": [
                        "system:serviceaccount:kpack:controller",
                        "system:serviceaccount:build-service:dependency-updater-controller-serviceaccount"
                    ]
                }
            }
        }
    ]
}
EOF

cat << EOF > build-service-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecr:DescribeRegistry",
                "ecr:GetAuthorizationToken",
                "ecr:GetRegistryPolicy",
                "ecr:PutRegistryPolicy",
                "ecr:PutReplicationConfiguration",
                "ecr:DeleteRegistryPolicy"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "TAPEcrBuildServiceGlobal"
        },
        {
            "Action": [
                "ecr:DescribeImages",
                "ecr:ListImages",
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:BatchGetRepositoryScanningConfiguration",
                "ecr:DescribeImageReplicationStatus",
                "ecr:DescribeImageScanFindings",
                "ecr:DescribeRepositories",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:GetRegistryScanningConfiguration",
                "ecr:GetRepositoryPolicy",
                "ecr:ListTagsForResource",
                "ecr:TagResource",
                "ecr:UntagResource",
                "ecr:BatchDeleteImage",
                "ecr:BatchImportUpstreamImage",
                "ecr:CompleteLayerUpload",
                "ecr:CreatePullThroughCacheRule",
                "ecr:CreateRepository",
                "ecr:DeleteLifecyclePolicy",
                "ecr:DeletePullThroughCacheRule",
                "ecr:DeleteRepository",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:PutImageScanningConfiguration",
                "ecr:PutImageTagMutability",
                "ecr:PutLifecyclePolicy",
                "ecr:PutRegistryScanningConfiguration",
                "ecr:ReplicateImage",
                "ecr:StartImageScan",
                "ecr:StartLifecyclePolicyPreview",
                "ecr:UploadLayerPart",
                "ecr:DeleteRepositoryPolicy",
                "ecr:SetRepositoryPolicy"
            ],
            "Resource": [
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/tap-build-service",
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/tap-images"
            ],
            "Effect": "Allow",
            "Sid": "TAPEcrBuildServiceScoped"
        }
    ]
}
EOF
# Note aws-cregion and aws account has to be replaced with actual value as variable substitution does'nt seem to work
cat << EOF > workload-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecr:DescribeRegistry",
                "ecr:GetAuthorizationToken",
                "ecr:GetRegistryPolicy",
                "ecr:PutRegistryPolicy",
                "ecr:PutReplicationConfiguration",
                "ecr:DeleteRegistryPolicy"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "TAPEcrWorkloadGlobal"
        },
        {
            "Action": [
                "ecr:DescribeImages",
                "ecr:ListImages",
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:BatchGetRepositoryScanningConfiguration",
                "ecr:DescribeImageReplicationStatus",
                "ecr:DescribeImageScanFindings",
                "ecr:DescribeRepositories",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:GetRegistryScanningConfiguration",
                "ecr:GetRepositoryPolicy",
                "ecr:ListTagsForResource",
                "ecr:TagResource",
                "ecr:UntagResource",
                "ecr:BatchDeleteImage",
                "ecr:BatchImportUpstreamImage",
                "ecr:CompleteLayerUpload",
                "ecr:CreatePullThroughCacheRule",
                "ecr:CreateRepository",
                "ecr:DeleteLifecyclePolicy",
                "ecr:DeletePullThroughCacheRule",
                "ecr:DeleteRepository",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:PutImageScanningConfiguration",
                "ecr:PutImageTagMutability",
                "ecr:PutLifecyclePolicy",
                "ecr:PutRegistryScanningConfiguration",
                "ecr:ReplicateImage",
                "ecr:StartImageScan",
                "ecr:StartLifecyclePolicyPreview",
                "ecr:UploadLayerPart",
                "ecr:DeleteRepositoryPolicy",
                "ecr:SetRepositoryPolicy"
            ],
            "Resource": [
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/tap-build-service",
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/tanzu-application-platform/tanzu-java-web-app",
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/tanzu-application-platform/tanzu-java-web-app-bundle",
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/tanzu-application-platform",
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/tanzu-application-platform/*"
            ],
            "Effect": "Allow",
            "Sid": "TAPEcrWorkloadScoped"
        }
    ]
}
EOF

cat << EOF > workload-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${oidcProvider}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${oidcProvider}:sub": "system:serviceaccount:default:default",
                    "${oidcProvider}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF


# Create the Build Service Role
aws iam create-role --role-name tap-build-service --assume-role-policy-document file://build-service-trust-policy.json
# Attach the Policy to the Build Role
aws iam put-role-policy --role-name tap-build-service --policy-name tapBuildServicePolicy --policy-document file://build-service-policy.json

# Create the Workload Role
aws iam create-role --role-name tap-workload --assume-role-policy-document file://workload-trust-policy.json
# Attach the Policy to the Workload Role
aws iam put-role-policy --role-name tap-workload --policy-name tapWorkload --policy-document file://workload-policy.json

# install CSI driver
 export  AWS_REGION=us-east-2
 export cluster_name=tap-aws-13
 export AWS_ACCOUNT_ID=699139306504
 eksctl utils associate-iam-oidc-provider --region=$AWS_REGION  --cluster=tap-aws-13 --approve
  #  create iamservice account
 eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster $cluster_name --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole 
  
aws eks describe-addon-versions --addon-name aws-ebs-csi-driver

eksctl get addon --name aws-ebs-csi-driver --cluster $cluster_name

eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster $cluster_name --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole

eksctl create addon --name aws-ebs-csi-driver --cluster $cluster_name --service-account-role-arn arn:aws:iam::699139306504:role/AmazonEKS_EBS_CSI_DriverRole --force

 # Validate storage driver
ksctl get addon --name aws-ebs-csi-driver --cluster $cluster_name
kubectl get rs -A
kubectl describe rs ebs-csi-controller-54cdcb8479 -n kube-system
eksctl get addon --name aws-ebs-csi-driver --cluster $cluster_name
kubectl get all -l app.kubernetes.io/name=aws-ebs-csi-driver -n kube-system
eksctl get addon --name aws-ebs-csi-driver --cluster $cluster_name
kubectl get pvc -A
kubectl get pv -A

# install cluster essentials
export  AWS_REGION=us-east-2
export cluster_name=tap-aws-13
export AWS_ACCOUNT_ID=699139306504


kubectl create namespace kapp-controller
set INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54bf611711923dccd7c7f10603c846782b90644d48f1cb570b43a082d18e23b9
set INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
set INSTALL_REGISTRY_USERNAME="kmantha@vmware.com"
set INSTALL_REGISTRY_PASSWORD="VMware123!"
cd $HOME/tanzu-cluster-essentials

## Issues
Issue 1 - C:\Users\kmantha\tanzu-cluster-essentials>install.bat --yes
"## Creating namespace tanzu-cluster-essentials"

kapp: Error: Building Core clientset: exec plugin: invalid apiVersion "client.authentication.k8s.io/v1alpha1"
"Failed to deploy kapp-controller" 
resolution - changed kubeconfig file updates aws cluster to use v1beta1


## Issue 2 - C:\Users\kmantha\tanzu-cluster-essentials>kubectl get po
##Unable to connect to the server: getting credentials: exec plugin is configured to use API version client.authentication.k8s.io/v1beta1, plugin returned version client.authentication.k8s.io/v1alpha1

#Resolution - upgraded aws cli
