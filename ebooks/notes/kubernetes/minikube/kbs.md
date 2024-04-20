## Minikube

### Start a Minikube kubernetes

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

If had proxy, set the proxy environment and the NO_PROXY especially https://minikube.sigs.k8s.io/docs/handbook/vpn_and_proxy/:  
```bash
export https_proxy=http://192.168.0.208:7890
export http_proxy=http://192.168.0.208:7890
export all_proxy=socks5://192.168.0.208:7891
export no_proxy=localhost,127.0.0.1,192.168.0.208,.aliyuncs.com,.youku.com,k8s.mikesay.com,wp.mikesay.com,docker-registry.local,10.96.0.0/12,192.168.99.0/24,192.168.39.0/24,192.168.49.0/24,192.168.64.0/24

export HTTPS_PROXY=$https_proxy
export HTTP_PROXY=$http_proxy
export ALL_PROXY=$all_proxy
export NO_PROXY=$no_proxy
```
  
#### Use hyperkit driver:  
```bash
minikube start --cpus=4 --memory='6g' --cni='flannel' --disk-size='60g' --driver='hyperkit' --kubernetes-version='v1.19.10' --extra-config=apiserver.service-node-port-range=1-65535
```

#### Use virtualbox driver:  
```bash
minikube start --cpus=4 --memory='6g' --cni='flannel' --disk-size='60g' --driver='virtualbox' --kubernetes-version='v1.19.10' --extra-config=apiserver.service-node-port-range=1-65535 --extra-config=controller-manager.bind-address=0.0.0.0 --extra-config=scheduler.bind-address=0.0.0.0
```

### Make Minikube work in Corporate VPN

#### Port forwarding localhost:xxx -> minikube_IP:xxx
http://tdongsi.github.io/blog/2018/12/31/minikube-in-corporate-vpn/

This approach is the more convenient and more reliable in my experience. All you need to do is to set up a list of port forwarding rules for minikube’s VirtualBox:

```bash
VBoxManage controlvm minikube natpf1 k8s-apiserver,tcp,127.0.0.1,8443,,8443
VBoxManage controlvm minikube natpf1 k8s-dashboard,tcp,127.0.0.1,30000,,30000
VBoxManage controlvm minikube natpf1 jenkins,tcp,127.0.0.1,30080,,30080
VBoxManage controlvm minikube natpf1 docker,tcp,127.0.0.1,2376,,2376
```

In real setup, we could consider port forwarding from local to api server(8443), to docker(2376), to ingress controller(80, 443), and all the services will be exported by ingress:
```bash
VBoxManage controlvm minikube natpf1 k8s-apiserver,tcp,127.0.0.1,8443,,8443
VBoxManage controlvm minikube natpf1 k8s-ingress,tcp,127.0.0.1,9080,,80
VBoxManage controlvm minikube natpf1 k8s-ingress-secure,tcp,127.0.0.1,9443,,443
VBoxManage controlvm minikube natpf1 docker,tcp,127.0.0.1,2376,,2376
```

Since Mac(Unix) can't listen at ports lower than 1024 with no-root user, we have to specify local port 9080 and 9443 to map 80 and 443. However, in order to let user use local 80 and 443, we can setup port-forwarding in local Mac by refering following articles:  
https://www.zhiqiexing.com/2.html  
https://www.zhiqiexing.com/128.html  
https://www.zhiqiexing.com/127.html  

Steps:
+ Create /etc/pf.anchors/kubernetes.ingress-controller.forwarding with following content
```bash
rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 9080
rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 9443
```

+ Create /etc/pf-kubernetes-ingress-controller.conf with following content
```bash
load anchor "forwarding" from "/etc/pf.anchors/kubernetes.ingress-controller.forwarding"
```

+ Create a shell /Users/xxxx/.mikestart/pf.sh script which will be run during machine startup to enable port-forwarding
```bash
#!/bin/bash
sudo pfctl -ef /etc/pf-kubernetes-ingress-controller.conf
```
> Need to enable non password for sudo

+ Change the shell script to be executable
```bash
sudo chmod a+x /Users/xxxx/.mikestart/pf.sh
```

+ Register this script to be run during machine starup  

![Login Item](../_media/k8s/minikube1.jpeg) 

Then, you can set up a new Kubernetes context for working with VPN:

```bash
kubectl config set-cluster minikube-vpn --server=https://127.0.0.1:8443 --insecure-skip-tls-verify
kubectl config set-context minikube-vpn --cluster=minikube-vpn --user=minikube
```
When working on VPN, you can set kubectl to switch to the new context:

```bash
kubectl config use-context minikube-vpn
```

All Minikube URLs now must be accessed through localhost in browser. For example, the standard Kubernetes dashboard URL such as:

```bash
minikube dashboard --url
http://192.168.99.100:30000
```

must now be accessed via localhost:30000. Similar applies to other services that are deployed to minikube, such as jenkins shown above.

In addition, the eval $(minikube docker-env) standard pattern to reuse minikube’s Docker deamon would not work anymore.

```bash
minikube docker-env
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/tdongsi/.minikube/certs"
export DOCKER_API_VERSION="1.23"
```

Run this command to configure your shell:
eval $(minikube docker-env)

```bash
echo $DOCKER_HOST
tcp://192.168.99.100:2376
docker images
```

Cannot connect to the Docker daemon at tcp://192.168.99.100:2376. Is the docker daemon running?
Instead, you have to adjust DOCKER_HOST accordingly and use docker --tlsverify=false ....

```bash
export DOCKER_HOST="tcp://127.0.0.1:2376"
alias dockervpn="docker --tlsverify=false"
dockervpn images
...
```
Finally, when not working on VPN, you can set kubectl to switch back to the old context:

```bash
kubectl config use-context minikube
```


### Use minikube as docker daemon
https://itnext.io/goodbye-docker-desktop-hello-minikube-3649f2a1c469  

https://www.chevdor.com/post/2021/02/docker_to_k8s/

## Kubernetes 配置管理最佳方法
https://www.kubernetes.org.cn/3031.html

## Change Kubernetes subdomains
https://stackoverflow.com/questions/48326773/how-to-change-the-cluster-local-default-domain-on-kubernetes-1-9-deployed-with-k#:~:text=You%20can%20change%20the%20cluster,the%20clusterDomain%20during%20kubeadm%20init%20.&text=Then%20change-,kubernetes%20cluster.,.arpa%20%7B%20...%20%7D

I assume you are using CoreDNS.  

You can change the cluster base DNS by editing the kubelet config file on ALL Nodes, located here /var/lib/kubelet/config.yaml or set the clusterDomain during kubeadm init.  

Change  

```yaml
clusterDomain: cluster.local
```

to:  

```yaml
clusterDomain: my.new.domain  
```

Now you also need to change the CoreDNS configuration. CoreDNS uses a ConfigMap for this. You can get your current CoreDNS ConfigMap by running  

```yaml
kubectl get -n kube-system cm/coredns -o yaml
```

Then change  

```yaml
kubernetes cluster.local in-addr.arpa ip6.arpa {
    ...
}
to match your new domain like this:

kubernetes my.new.domain in-addr.arpa ip6.arpa {
    ...
}
```

Now apply the changes to the CoreDNS ConfigMap. If you restart kubelet and your CoreDNS pods then your cluster should use the new domain.  

If you have for example a service called grafana-service, this can now be accessed with this address: grafana-service.default.svc.my.new.domain  

Test:  
```yaml
kubectl get service
NAME              TYPE         CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
grafana-service   ClusterIP    <Internal-IP>   <none>        3000/TCP   100m

# nslookup grafana-service.default.svc.my.new.domain
Server:    <Internal-IP>
Address 1: <Internal-IP> kube-dns.kube-system.svc.my.new.domain

Name:      grafana-service.default.svc.my.new.domain
Address 1: <Internal-IP> grafana-service.default.svc.my.new.domain
```