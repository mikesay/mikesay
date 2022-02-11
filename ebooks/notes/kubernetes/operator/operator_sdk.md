## Install operator-sdk

https://sdk.operatorframework.io/docs/install-operator-sdk/

```bash
brew install operator-sdk
```

## A quickstart project
https://sdk.operatorframework.io/docs/golang/quickstart/  

+ Create new operator project
    ```bash
    operator-sdk new rra-operator
    ```

+ Add a new CRD resource (yaml and data structures in go code)
    ```bash
    operator-sdk add api --api-version=app.example.com/v1alpha1 --kind=AppService
    ```
    ![operator](../../_media/operator/operator3.png)

+ Add controller for the new CRD resource
    ```bash
    operator-sdk add controller --api-version=app.example.com/v1alpha1 --kind=AppService
    ```
    ![operator](../../_media/operator/operator4.png)

+ Update CRD Yaml resource and re-generate deepcopy code
    ```bash
    operator-sdk generate crds
    operator-sdk generate k8s
    ```
    ![operator](../../_media/operator/operator5.png)

## Setup operator debug environment

+ From Run panel, click "create a launch.json"

    ![operator](../../_media/operator/operator6.png)

+ Edit launch.json

    ![operator](../../_media/operator/operator7.png)

## Deploy operator

![operator](../../_media/operator/operator8.png)  

```bash
kubectl apply -f role.yaml
kubectl apply -f role_binding.yaml
kubectl apply service_account.yaml
kubectl apply -f operator.yaml
kubectl apply crds/xxx.yaml
```