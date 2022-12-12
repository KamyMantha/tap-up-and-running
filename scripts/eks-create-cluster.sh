#create-eks-cluster
create-eks-cluster () {

    #must run after setting access via 'aws configure'

    cluster_name=$1
	number_of_nodes=$2

	#scripts/dektecho.sh info "Creating EKS cluster $cluster_name with $number_of_nodes nodes"

    eksctl create cluster \
		--name $cluster_name \
		--region $AWS_REGION \
		--without-nodegroup
	
	#docker to containerd bug workaround
		containerdAMI=$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id --region $AWS_REGION --query "Parameter.Value" --output text)
bootstrap_cmd="/etc/eks/bootstrap.sh $cluster_name --container-runtime containerd"

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

	add-ebs-csi-driver $cluster_name

}

#add-ebs-csi-driver
add-ebs-csi-driver() {

	cluster_name=$1
	eksctl utils associate-iam-oidc-provider --region=$AWS_REGION  --cluster=$cluster_name --approve
	eksctl create iamserviceaccount \
  		--name ebs-csi-controller-sa \
  		--namespace kube-system \
  		--cluster $cluster_name \
  		--attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  		--approve \
  		--role-only \
  		--role-name AmazonEKS_EBS_CSI_DriverRole
	sa_role="arn:aws:iam::$AWS_ACCOUNT_ID"":role/AmazonEKS_EBS_CSI_DriverRole"
	eksctl create addon --name aws-ebs-csi-driver \
		--cluster $cluster_name \
		--service-account-role-arn $sa_role \
		--force

}