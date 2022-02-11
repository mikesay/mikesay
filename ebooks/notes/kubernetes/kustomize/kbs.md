## Materials

+ Kustomize guide  
https://kubectl.docs.kubernetes.io/guides/  

+ Kustomize reference  
https://kubectl.docs.kubernetes.io/references/  

+ Strategic Merge Patch  
https://github.com/kubernetes/community/blob/master/contributors/devel/sig-api-machinery/strategic-merge-patch.md

+ Field Merge Semantics  
https://kubectl.docs.kubernetes.io/references/architecture/field_merge_semantics/

+ Use Kustomize to post-render Helm charts in ArgoCD  
https://dev.to/camptocamp-ops/use-kustomize-to-post-render-helm-charts-in-argocd-2ml6

May be some old masterials:  
+ Kustomize feature list  
https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#kustomize-feature-list  

+ Transformer configurations  
https://github.com/kubernetes-sigs/kustomize/tree/master/examples/transformerconfigs  

## Pain points of Kustomize

+ Based on patch mechanism like programming, there will be various writing from various person, so it lacks consistent which will lead to hard to manitain, like Gradle

+ Along with the upgrading of kustomize, some old grammar maybe deprected and may not be referenced from latest documents which make it hard to read and understand old kustomize files

+ Undeploy the deployment by kustomize must use the same version of kustomize manifests as the one used for current deployment
```bash
kustomize build deployment/overlays/dev | kubectl apply -f -
kustomize build deployment/overlays/dev | kubectl delete -f -
```