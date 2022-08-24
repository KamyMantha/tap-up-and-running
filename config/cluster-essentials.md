## cluster-essentials
## Download and unpack `tanzu-cluster-essentials-darwin-amd64-1.1.0.tgz` (for OS X)
##  or `tanzu-cluster-essentials-linux-amd64-1.1.0.tgz` (for Linux)
  - e.g.
    - `mkdir tanzu-cluster-essentials`
    - `cd tanzu-cluster-essentials`
    - `tar xzvf tanzu-cluster-essentials-darwin-amd64-1.1.0.tgz`

- (For air-gap users) Copy over bundle to your registry
  - e.g. `./imgpkg copy -b registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:ab0a3539da241a6ea59c75c0743e9058511d7c56312ea3906178ec0f3491f51d --to-repo registry.corp.com/tanzu-cluster-essentials/bundle`
    - you will have to provide credentials for both Tanzunet registry and destination registry

- Configure and run `install.sh` which will install kapp-controller and
  secretgen-controller on your cluster
  - e.g.
    - `export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:ab0a3539da241a6ea59c75c0743e9058511d7c56312ea3906178ec0f3491f51d`
    - `export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com`
    - `export INSTALL_REGISTRY_USERNAME="kmantha@vmware.com"`
    - `export INSTALL_REGISTRY_PASSWORD=VMware123!`
    - `./install.sh --yes`
  - (For air-gap users) if you have copied over bunle to your registry,
    ensure that above registry configuration and bundle points to your registry (digest of the bundle will remain the same).

- Install `kapp` CLI onto your `$PATH`
  - e.g. `sudo cp ./kapp /usr/local/bin/kapp`

- (optional) In case you want to uninstall installed components from the cluster
  - `./uninstall.sh --yes`
