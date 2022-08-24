
## getting started
##Use case 1 - supply chain demo

 Add Testing and Security Scanning to Your Application
In this section, you are going to:

Learn about supply chains
Discover available out of the box (OOTB) supply chains
OOTB Basic (default)
OOTB Testing
OOTB Testing+Scanning
Install OOTB Testing (optional)
Install OOTB Testing+Scanning (optional)
Introducing a Supply Chain
Supply Chains provide a way of codifying all of the steps of your path to production, more commonly known as continuous integration/Continuous Delivery (CI/CD). CI/CD is a method to frequently deliver applications by introducing automation into the stages of application development. The main concepts attributed to CI/CD are continuous integration, continuous delivery, and continuous deployment. CI/CD is the method used by supply chain to deliver applications through automation where supply chain allows you to use CI/CD and add any other steps necessary for an application to reach production, or a different environment such as staging.

Diagram depicting a simple path to production: CI to Security Scan to Build Image to Image Scan to CAB Approval to Deployment.

A path to production
A path to production allows users to create a unified access point for all of the tools required for their applications to reach a customer-facing environment. Instead of having four tools that are loosely coupled to each other, a path to production defines all four tools in a single, unified layer of abstraction, which may be automated and repeatable between teams for applications at scale.

Where tools typically are not able to integrate with one another and additional scripting or webhooks are necessary, there would be a unified automation tool to codify all the interactions between each of the tools. Supply chains used to codify the organization’s path to production are configurable, allowing their authors to add all of the steps of their application’s path to production.

Available Supply Chains
The Tanzu Application Platform provides three OOTB supply chains to work with the Tanzu Application Platform components, and they include:

1: OOTB Basic (default)
The default OOTB Basic supply chain and its dependencies were installed on your cluster during the Tanzu Application Platform install. The following table and diagrams provide descriptions for each of the supply chains and dependencies provided with the Tanzu Application Platform.

Diagram depicting the Source-to-URL chain: Watch Repo (Flux) to Build Image (TBS) to Apply Conventions to Deploy to Cluster (CNR).

Name	Package Name	Description	Dependencies
Out of the Box Basic (Default - Installed during Installing Part 2)	ootb-supply-chain-basic.tanzu.vmware.com	This supply chain monitors a repository that is identified in the developer’s workload.yaml file. When any new commits are made to the application, the supply chain:
Creates a new image.
Applies any predefined conventions.
Deploys the application to the cluster.
Flux/Source Controller
Tanzu Build Service
Convention Service
Tekton
Cloud Native Runtimes
If using Service References:
Service Bindings
Services Toolkit
2: OOTB Testing
The OOTB Testing supply chain runs a Tekton pipeline within the supply chain.

Diagram depicting the Source-and-Test-to-URL chain: Watch Repo (Flux) to Test Code (Tekton) to Build Image (TBS) to Apply Conventions to Deploy to Cluster (CNR).

Name	Package Name	Description	Dependencies
Out of the Box Testing	ootb-supply-chain-testing.tanzu.vmware.com	The Out of the Box Testing contains all of the same elements as the Source to URL. It allows developers to specify a Tekton pipeline that runs as part of the CI step of the supply chain.
The application tests using the Tekton pipeline.
A new image is created.
Any predefined conventions are applied.
The application is deployed to the cluster.
All of the Source to URL dependencies
3: OOTB Testing+Scanning
The OOTB Testing+Scanning supply chain includes integrations for secure scanning tools.

Diagram depicting the Source-and-Test-to-URL chain: Watch Repo (Flux) to Test Code (Tekton) to Build Image (TBS) to Apply Conventions to Deploy to Cluster (CNR).

Name	Package Name	Description	Dependencies
Out of the Box Testing and Scanning	ootb-supply-chain-testing-scanning.tanzu.vmware.com	The Out of the Box Testing and Scanning contains all of the same elements as the Out of the Box Testing supply chains but it also includes integrations out of the box with the secure scanning components of Tanzu Application Platform.
The application is tested using the provided Tekton pipeline.
The application source code is scanned for vulnerabilities.
A new image is created.
The image is scanned for vulnerabilities.
Any predefined conventions are applied.
The application deploys to the cluster.
All of the Source to URL dependencies, and:
The secure scanning components included with Tanzu Application Platform
Install OOTB Testing
This section introduces how to install the OOTB Testing supply chain and provides a sample Tekton pipeline that tests your sample application. The pipeline is configurable. Therefore, you can customize the steps to perform either additional testing or other tasks with Tekton Pipelines.

Note: You can only have one Tekton pipeline per namespace.

To apply this install method, follow the following steps:

You can activate the Out of the Box Supply Chain with Testing by updating our profile to use testing rather than basic as the selected supply chain for workloads in this cluster. Update tap-values.yaml (the file used to customize the profile in Tanzu package install tap --values-file=...) with the following changes:

- supply_chain: basic
+ supply_chain: testing

- ootb_supply_chain_basic:
+ ootb_supply_chain_testing:
    registry:
      server: "<SERVER-NAME>"
      repository: "<REPO-NAME>"
Update the installed profile by running:

tanzu package installed update tap -p tap.tanzu.vmware.com -v VERSION-NUMBER --values-file tap-values.yaml -n tap-install
Where VERSION-NUMBER is your Tanzu Application Platform version. For example, 1.1.0.

Tekton pipeline config example
In this section, a Tekton pipeline is added to the cluster. In the next section, the workload is updated to point to the pipeline and resolve any current errors.

Note: Developers can perform this step because they know how their application needs to be tested. The operator can also add the Tekton supply chain to a cluster before the developer get access.

To add the Tekton supply chain to the cluster, apply the following YAML to the cluster:

apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: developer-defined-tekton-pipeline
  labels:
    apps.tanzu.vmware.com/pipeline: test     # (!) required
spec:
  params:
    - name: source-url                       # (!) required
    - name: source-revision                  # (!) required
  tasks:
    - name: test
      params:
        - name: source-url
          value: $(params.source-url)
        - name: source-revision
          value: $(params.source-revision)
      taskSpec:
        params:
          - name: source-url
          - name: source-revision
        steps:
          - name: test
            image: gradle
            script: |-
              cd `mktemp -d`

              wget -qO- $(params.source-url) | tar xvz -m
              ./mvnw test
The preceding YAML defines a Tekton Pipeline with a single step. The step itself contained in the steps pull the code from the repository indicated in the developers workload and run the tests within the repository. The steps of the Tekton pipeline are configurable and allow the developer to add any additional items that is needed to test their code. Because this step is one of many in the supply chain (and the next step is an image build in this case), the developer is free to focus on testing their code. Any additional steps that the developer adds to the Tekton pipeline is independent for the image being built and any subsequent steps of the supply chain being executed.

The params are templated by the Supply Chain Choreographer. Additionally, Tekton pipelines require a Tekton pipelineRun in order to execute on the cluster. The Supply Chain Choreographer handles creating the pipelineRun dynamically each time that step of the supply requires execution.

Workload update
To connect the new supply chain to the workload, the workload must be updated to point at your Tekton pipeline.

Update the workload by running the following with the Tanzu CLI:

tanzu apps workload update tanzu-java-web-app \
  --git-repo https://github.com/sample-accelerators/tanzu-java-web-app \
  --git-branch main \
  --type web \
  --label apps.tanzu.vmware.com/has-tests=true \
  --yes
Create workload:
    1 + |---
    2 + |apiVersion: carto.run/v1alpha1
    3 + |kind: Workload
    4 + |metadata:
    5 + |  labels:
    6 + |    apps.tanzu.vmware.com/has-tests: "true"
    7 + |    apps.tanzu.vmware.com/workload-type: web
    8 + |  name: tanzu-java-web-app
    9 + |  namespace: default
   10 + |spec:
   11 + |  source:
   12 + |    git:
   13 + |      ref:
   14 + |        branch: main
   15 + |      url: https://github.com/sample-accelerators/tanzu-java-web-app

? Do you want to create this workload? Yes
Created workload "tanzu-java-web-app"
After accepting the workload creation, monitor the creation of new resources by the workload by running:

kubectl get workload,gitrepository,pipelinerun,images.kpack,podintent,app,services.serving
You will see output similar to the following example that shows the objects that were created by the Supply Chain Choreographer:

NAME                                    AGE
workload.carto.run/tanzu-java-web-app   109s

NAME                                                        URL                                                         READY   STATUS                                                            AGE
gitrepository.source.toolkit.fluxcd.io/tanzu-java-web-app   https://github.com/sample-accelerators/tanzu-java-web-app   True    Fetched revision: main/872ff44c8866b7805fb2425130edb69a9853bfdf   109s

NAME                                              SUCCEEDED   REASON      STARTTIME   COMPLETIONTIME
pipelinerun.tekton.dev/tanzu-java-web-app-4ftlb   True        Succeeded   104s        77s

NAME                                LATESTIMAGE                                                                                                      READY
image.kpack.io/tanzu-java-web-app   10.188.0.3:5000/foo/tanzu-java-web-app@sha256:1d5bc4d3d1ffeb8629fbb721fcd1c4d28b896546e005f1efd98fbc4e79b7552c   True

NAME                                                             READY   REASON   AGE
podintent.conventions.apps.tanzu.vmware.com/tanzu-java-web-app   True             7s

NAME                                      DESCRIPTION           SINCE-DEPLOY   AGE
app.kappctrl.k14s.io/tanzu-java-web-app   Reconcile succeeded   1s             2s

NAME                                             URL                                               LATESTCREATED              LATESTREADY                READY     REASON
service.serving.knative.dev/tanzu-java-web-app   http://tanzu-java-web-app.developer.example.com   tanzu-java-web-app-00001   tanzu-java-web-app-00001   Unknown   IngressNotConfigured
Install OOTB Testing+Scanning
Follow these steps to install the OOTB Testing+Scanning supply chain:

Note: When leveraging both Tanzu Build Service and Grype in your Tanzu Application Platform supply chain, you can receive enhanced scanning coverage for Java and Node.js workloads that includes application runtime layer dependencies.

Important: The grype must be installed for scanning.

Supply Chain Security Tools - Scan is installed as part of the profiles. Verify that both Scan Link and Grype Scanner are installed by running:

tanzu package installed get scanning -n tap-install
tanzu package installed get grype -n tap-install
If the packages are not already installed, follow the steps in Supply Chain Security Tools - Scan to install the required scanning components.

During installation of the Grype Scanner, sample ScanTemplates are installed into the default namespace. If the workload is deployed into another namespace, these sample ScanTemplates also must be present in the other namespace. One way to accomplish this is to install Grype Scanner again, and provide the namespace in the values file.

A ScanPolicy is required and the following code must be in the required namespace. You can either add the namespace flag to the kubectl command or add the namespace field to the template itself. Run:

kubectl apply -f - -o yaml << EOF
---
apiVersion: scanning.apps.tanzu.vmware.com/v1beta1
kind: ScanPolicy
metadata:
  name: scan-policy
spec:
  regoFile: |
    package policies

    default isCompliant = false

    # Accepted Values: "Critical", "High", "Medium", "Low", "Negligible", "UnknownSeverity"
    violatingSeverities := ["Critical","High","UnknownSeverity"]
    ignoreCVEs := []

    contains(array, elem) = true {
      array[_] = elem
    } else = false { true }

    isSafe(match) {
      fails := contains(violatingSeverities, match.Ratings.Rating[_].Severity)
      not fails
    }

    isSafe(match) {
      ignore := contains(ignoreCVEs, match.Id)
      ignore
    }

    isCompliant = isSafe(input.currentVulnerability)
EOF
(optional) To persist and query the vulnerability results post-scan, ensure that Supply Chain Security Tools - Store is installed using the following command. The Tanzu Application Platform profiles install the package by default.

tanzu package installed get metadata-store -n tap-install
If the package is not installed, follow the installation instructions.

Update the profile to use the supply chain with testing and scanning by updating tap-values.yaml (the file used to customize the profile in tanzu package install tap --values-file=...) with the following changes:

- supply_chain: testing
+ supply_chain: testing_scanning

- ootb_supply_chain_testing:
+ ootb_supply_chain_testing_scanning:
    registry:
      server: "<SERVER-NAME>"
      repository: "<REPO-NAME>"
Update the tap package:

tanzu package installed update tap -p tap.tanzu.vmware.com -v VERSION-NUMBER --values-file tap-values.yaml -n tap-install
Where VERSION-NUMBER is your Tanzu Application Platform version. For example, 1.1.0.

Workload update
To connect the new supply chain to the workload, update the workload to point to your Tekton pipeline:

Update the workload by running the following using the Tanzu CLI:

tanzu apps workload create tanzu-java-web-app \
  --git-repo https://github.com/sample-accelerators/tanzu-java-web-app \
  --git-branch main \
  --type web \
  --label apps.tanzu.vmware.com/has-tests=true \
  --yes
Example output:

Create workload:
      1 + |---
      2 + |apiVersion: carto.run/v1alpha1
      3 + |kind: Workload
      4 + |metadata:
      5 + |  labels:
      6 + |    apps.tanzu.vmware.com/has-tests: "true"
      7 + |    apps.tanzu.vmware.com/workload-type: web
      8 + |  name: tanzu-java-web-app
      9 + |  namespace: default
    10 + |spec:
    11 + |  source:
    12 + |    git:
    13 + |      ref:
    14 + |        branch: main
    15 + |      url: https://github.com/sample-accelerators/tanzu-java-web-app

? Do you want to create this workload? Yes
Created workload "tanzu-java-web-app"
After accepting the workload creation, view the new resources that the workload created by running:

kubectl get workload,gitrepository,sourcescan,pipelinerun,images.kpack,imagescan,podintent,app,services.serving
The following is an example output, which shows the objects that the Supply Chain Choreographer created:

NAME                                    AGE
workload.carto.run/tanzu-java-web-app   109s

NAME                                                        URL                                                         READY   STATUS                                                            AGE
gitrepository.source.toolkit.fluxcd.io/tanzu-java-web-app   https://github.com/sample-accelerators/tanzu-java-web-app   True    Fetched revision: main/872ff44c8866b7805fb2425130edb69a9853bfdf   109s

NAME                                                           PHASE       SCANNEDREVISION                            SCANNEDREPOSITORY                                           AGE    CRITICAL   HIGH   MEDIUM   LOW   UNKNOWN   CVETOTAL
sourcescan.scanning.apps.tanzu.vmware.com/tanzu-java-web-app   Completed   187850b39b754e425621340787932759a0838795   https://github.com/sample-accelerators/tanzu-java-web-app   90s

NAME                                              SUCCEEDED   REASON      STARTTIME   COMPLETIONTIME
pipelinerun.tekton.dev/tanzu-java-web-app-4ftlb   True        Succeeded   104s        77s

NAME                                LATESTIMAGE                                                                                                      READY
image.kpack.io/tanzu-java-web-app   10.188.0.3:5000/foo/tanzu-java-web-app@sha256:1d5bc4d3d1ffeb8629fbb721fcd1c4d28b896546e005f1efd98fbc4e79b7552c   True

NAME                                                          PHASE       SCANNEDIMAGE                                                                                                AGE   CRITICAL   HIGH   MEDIUM   LOW   UNKNOWN   CVETOTAL
imagescan.scanning.apps.tanzu.vmware.com/tanzu-java-web-app   Completed   10.188.0.3:5000/foo/tanzu-java-web-app@sha256:1d5bc4d3d1ffeb8629fbb721fcd1c4d28b896546e005f1efd98fbc4e79b7552c   14s

NAME                                                             READY   REASON   AGE
podintent.conventions.apps.tanzu.vmware.com/tanzu-java-web-app   True             7s

NAME                                      DESCRIPTION           SINCE-DEPLOY   AGE
app.kappctrl.k14s.io/tanzu-java-web-app   Reconcile succeeded   1s             2s

NAME                                             URL                                               LATESTCREATED              LATESTREADY                READY     REASON
service.serving.knative.dev/tanzu-java-web-app   http://tanzu-java-web-app.developer.example.com   tanzu-java-web-app-00001   tanzu-java-web-app-00001   Unknown   IngressNotConfigured
If the source or image scan has a “Failed” phase, then the scan has failed compliance and the supply chain stops.

Query for vulnerabilities
Scan reports are automatically saved to the Supply Chain Security Tools - Store, and can be queried for vulnerabilities and dependencies. For example, open-source software (OSS) or third party packages.

Query the tanzu-java-web-app image dependencies and vulnerabilities with the following commands:

insight image get --digest DIGEST
insight image vulnerabilities --digest  DIGEST
DIGEST is the component version, or image digest printed in the KUBECTL GET command.

Important: The Insight CLI is separate from the Tanzu CLI.

See Tanzu Insight plug-in overview additional information and examples.

Congratulations! You have successfully deployed your application on the Tanzu Application Platform.
Through the next two sections to learn about recommended supply chain security best practices and access to a powerful Services Journey experience on the Tanzu Application Platform by enabling several advanced use cases.
tanzu secret registry add registry-credentials --server "gcr.io" --username "_json_key" --password "$(cat /home/azureuser/sa-tap.json)"  --namespace dev1

 kubectl -n dev1 create secret docker-registry registry-credentials  --docker-server "gcr.io"  --docker-username "_json_key"  --docker-password "$(cat /home/azureuser/sa-tap.json)" 
 
 ---create default service account and assign cluster access rights to run the supply chain pipelines
 
 k apply -f dev.yml -n dev1
 
## RBAC to view app (optional as we are not integrating with identity management system)
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