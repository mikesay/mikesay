## Helm issues

### Helm post render
+ The kustomize post-render of helm  doesn't acknowledge test yaml in test folder  
    ```bash
    helm upgrade -i ilab-otel-demo open-telemetry/opentelemetry-demo --version 0.22.3 -f "../../../values.yaml" --dry-run --post-renderer ./kustomize
    ```

    ```bash
    #!/bin/bash

    cat <&0 > all.yaml

    kustomize build . && rm all.yaml
    ```
    > Sample of kustomize post-render of helm: https://github.com/thomastaylor312/advanced-helm-demos/tree/master/post-render  


### Helm Release Upgrade Failure Fix  
*(Deprecated API Version Issue)*  

#### Problem  
Fails to upgrade outdated Helm releases due to deprecated Kubernetes API versions (e.g., `autoscaling/v2beta2`).  
Example error:  
> ```error  
> resource mapping not found for name: "monitoring-stack-grafana" namespace: "monitoring-stack" from "temp.yaml":  
> no matches for kind "HorizontalPodAutoscaler" in version "autoscaling/v2beta2"  
> ensure CRDs are installed first  
> ```  

#### Solution  
1. **Delete deprecated resources**  
   Remove resources using outdated API versions via:  
   ```bash  
   kubectl delete hpa monitoring-stack-grafana -n monitoring-stack 
   ```  

2. Update Helm manifests  
    Edit the release manifest to remove deprecated API references.
    (See guide: [Modify Helm 3 Release Manifest](https://itnext.io/modify-helm-3-release-manifest-c3870b90213))  

3. Retry upgrade  
    ```bash
    helm upgrade <release-name> <chart-path> -n <namespace>    
    ```  



