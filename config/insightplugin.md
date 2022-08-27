Configure target endpoint and certificate


-- ** install insight plugin**
 tanzu plugin install insight --local cli
 ** configure plugin

export METADATA_STORE_DOMAIN="metadata-store.your-tap-domain"
export METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets -n metadata-store -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='metadata-store-read-write-client')].data.token}" | base64 -d)
 tanzu insight config set-target http://$METADATA_STORE_DOMAIN --ca-cert insight-ca.crt --access-token $METADATA_STORE_ACCESS_TOKEN
- **validate connectivity **
 tanzu insight health

** 



