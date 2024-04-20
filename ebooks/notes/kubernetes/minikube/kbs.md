## Minikube

+ Start a new minikube  
```sh
# apiserver: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
# controller-manager: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
# scheduler: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/
minikube start --driver='virtualbox' --kubernetes-version='v1.28.0-rc.1' \
        --cpus=4 --memory='6g' --disk-size='60g' --cni='flannel' \
        --extra-config=apiserver.bind-address=0.0.0.0 \
        --extra-config=apiserver.service-node-port-range=1-65535 \
        --extra-config=apiserver.oidc-issuer-url=https://control-plane.minikube.internal:1443/auth/realms/minikube  \
        --extra-config=apiserver.oidc-client-id=minikube \
        --extra-config=apiserver.oidc-username-claim=name \
        --extra-config=apiserver.oidc-username-prefix=- \
        --extra-config=apiserver.oidc-ca-file=/var/lib/minikube/certs/ca.crt \
        --extra-config=controller-manager.bind-address=0.0.0.0 \
        --extra-config=scheduler.bind-address=0.0.0.0 \
        --extra-config=kubelet.cgroup-driver=systemd
```