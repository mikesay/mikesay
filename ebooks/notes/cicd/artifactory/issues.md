## Artifactory issues

### non_authenticated user error while accessing helm repo
#### Problem description
The helm repo "artifactory_generic" is already added with correct user and password locally. However, when run command ```helm fetch artifactory_generic/alertmanager --version 0.11.0```, will meet below error:

```bash
2021-12-27T01:21:29.810Z|e2af5619a798bc60|10.229.231.60|non_authenticated_user|GET|/api/helm/mikesay-helm-virtual/alertmanager-0.11.0.tgz|401|-1|0|0|Helm/3.7.2
```

#### Solution:
Add helm repo with flag ```--pass-credentials```
```bash
helm repo add artifactory_generic https://artifactory.mikesay.com/artifactory/mikesay-helm-virtual --username mike --pass-credentials
```