---
title: Kind创建本地Kubernetes集群
date: 2021-10-10 18:23:20
tags:
  - Kubernetes
  - K8s
  - Kind
---

在[Minikube创建本地Kubernetes集群][1]一文中提到过用Docker驱动创建的Kubernetes集群既不支持ingress，也不支持LoadBalancer类型的服务，所以基本上不可用。通过Hypervisor驱动创建的Kubernetes集群在VPN的情况下也无法访问。正好同事又在尝试一款新的工具Kind（论有一个不断进取的同事的重要性{% emoji smile %}），而且还解决了Minikube中遇到的问题。本文将简单介绍下Kind，并在Mac主机上用Kind创建一个Kubernetes集群。
<!-- more -->

# Kind介绍
Kind(Kubernetes In Docker)也是一个创建本地Kubernetes集群的工具，类似于Minikube通过Docker驱动创建Kubernetes集群，即在容器中创建并运行Kubernetes集群。通过Kind创建出来的集群支持Ingress和LoadBalancer类型的服务，也能和VPN很好的共存。

## 集群组件配置能力
Kind也提供了丰富的集群配置选项，有集群级别的，也有节点级别的。Kind缺省也是使用kubeadm创建和配置Kubernetes集群，通过Kubeadm Config Patches机制提供了针对Kubeadm的各种配置。详细可参考Kind[配置][3]这一节。

# Kind架构
![](1.png)

工作节点就是一个Docker容器，所有的Kubernetes集群的组件以及用户Pod都运行在这个容器中。

# 创建Kubernetes集群
通过以下命令和配置文件创建一个包含一个主节点和三个工作节点的Kubernetes集群。

```bash
kind create cluster --config mykind1.yaml
```

mykind1.yaml:
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: mykind1
networking:
  # the default CNI will not be installed
  disableDefaultCNI: true
  # WARNING: It is _strongly_ recommended that you keep this the default
  # (127.0.0.1) for security reasons. However it is possible to change this.
  apiServerAddress: "0.0.0.0"
  # By default the API server listens on a random open port.
  # You may choose a specific port but probably don't need to in most cases.
  # Using a random port makes it easier to spin up multiple clusters.
  apiServerPort: 6443
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  kubeProxyMode: "ipvs"
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  # port forward 80 on the host to 80 on this node
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    # optional: set the bind address on the host
    # 0.0.0.0 is the current default
    listenAddress: "0.0.0.0"
    # optional: set the protocol to one of TCP, UDP, SCTP.
    # TCP is the default
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    # optional: set the bind address on the host
    # 0.0.0.0 is the current default
    listenAddress: "0.0.0.0"
    # optional: set the protocol to one of TCP, UDP, SCTP.
    # TCP is the default
    protocol: TCP
- role: worker
- role: worker
- role: worker
```

一些配置参数说明：
+ 不安装Kind的缺省网络实现（"kindnetd"），否则在创建出来的Kubernetes集群无法解析外网域名，仅管CoreDNS看起来没有任何异常。
```yaml
networking:
  # the default CNI will not be installed
  disableDefaultCNI: true
```

+ control-plane中的配置用来将之后安装的ingress controller Pod调度到主节点上，并将NodePort类型的ingress controller服务的80和443端口映射到主机的80和443端口，这样用户可以通过主机IP访问Ingress服务。

## 配置Kubernetes集群

### 安装网络插件Calico
+ 下载Calico安装脚本
```bash
curl https://docs.projectcalico.org/manifests/calico.yaml -O
```

+ 设置环境变量FELIX_IGNORELOOSERPF的值为true，禁用Calico检查。
```yaml
# Source: calico/templates/calico-node.yaml
# This manifest installs the calico-node container, as well
# as the CNI plugins and network config on
# each master and worker node in a Kubernetes cluster.
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: calico-node
  namespace: kube-system
  labels:
    k8s-app: calico-node
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        k8s-app: calico-node
    spec:
      ...
      initContainers:
        ....
      containers:
        # Runs calico-node container on each Kubernetes node. This
        # container programs network policy and routes on each
        # host.
        - name: calico-node
          image: docker.io/calico/node:v3.20.1
          env:
            # Disable the Calico RPF check
            - name: FELIX_IGNORELOOSERPF
              value: "true"
```

> 详细参考[Calico官方安装文档][4]，以及博客文章[Creating a Kind Cluster With Calico Networking][5]。

### 安装Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### 安装METALLB
MetalLB是裸机Kubernetes集群的负载均衡实现，使用标准路由协议。
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/namespace.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" 
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/metallb.yaml
kubectl apply -f metallb-configmap.yaml
```

metallb-configmap.yaml：
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.18.255.150-172.18.255.250
```
从节点网段中选取一个IP地址范围设置在metallb-configmap.yaml中用来给LoadBalancer类型服务的IP地址。

可以通过以下下命令获取node网段：
```bash
$ docker network inspect -f '{{.IPAM.Config}}' kind

[{172.18.0.0/16  172.18.0.1 map[]} {fc00:f853:ccd:e793::/64  fc00:f853:ccd:e793::1 map[]}]
```

# Kind vs Minikube
+ Kind没有提供类似于Minikube的插件机制，方便用户快速地部署Kubernetes。

+ Kind并没有提供停止一个集群的功能。

+ 和Minikube相比，Kind比较轻量，就是使用Docker容器创建并运行Kubernetes集群的工具，但比Minikube的Docker驱动更全面。个人认为如果能够把Kind集成到Minikube中作为Docker驱动的实现，应该能更有助于两个项目的发展，用户也不需要学习两个工具了。

# 结束语
本文旨在简单介绍Kind，它的架构以及使用，希望能够帮助读者对Kind有个框架性的了解，从而决定是否需要深入使用。对于Kind更详细的用法，可以参考[官方文档][2]。

[1]: https://www.mikesay.com/2021/10/06/create-kubernetes-minikube/
[2]: https://kind.sigs.k8s.io/
[3]: https://kind.sigs.k8s.io/docs/user/configuration/
[4]: https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-50-nodes-or-less
[5]: https://alexbrand.dev/post/creating-a-kind-cluster-with-calico-networking/