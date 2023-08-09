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