
1.	Change  the redacted values to SSH keys and PAT (personal access token) and apply the yaml to development workspace
 
Git authentication (vmware.com)
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.1/tap/GUID-scc-git-auth.html

2.	Update tap values as follows

 
ootb_supply_chain_testing_scanning:
  registry:
    server: --redacted --
    # TBS will write container images to this OCI registry 
    repository: "project/supply-chain"  # contairezed app images will go into this repo 
  gitops:
    repository_prefix: https://github.com/yourproject/devops-
    ssh_secret: git-ssh
 
3. Update yaml TAP
 
tanzu package installed update tap -p tap.tanzu.vmware.com -v 1.1.0 --values-file tap_testing.yml -n tap-install
 
4. Recreate the workload—please ensure that you have a repo to store the configuration
 
tanzu apps workload delete tanzu-java-web-app-testing -n dev3
 
tanzu apps workload create tanzu-java-web-app \
  --app tanzu-java-web-app \
  --type web \
  --git-repo https://github.com/sample-accelerators/tanzu-java-web-app \
  --git-branch main \
  --param gitops_ssh_secret=git-secret \
  --param gitops_repository=https://github.com/yourproject/yourconfigrepo
 
5. Validation
You should be able to view the configuration checked into Git repository 

