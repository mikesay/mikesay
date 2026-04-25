---
title: Minikube创建本地Kubernetes集群
cover: /gallery/create-kubernetes-minikube/cover.jpg
thumbnail: /gallery/create-kubernetes-minikube/cover.jpg
toc: true
tags:
  - Kubernetes
  - Minikube
category_bar: true
categories:
  - Kubernetes
order: 1
date: 2021-10-06 18:40:49
---

在学习和使用Kubernetes的过程中，都希望能够快速创建一个本地的Kubernetes集群用作测试之用。之前一直使用docker公司的docker for mac创建的Kubernetes集群，但是经常出现启动不起来的问题，也没有详细的日志来定位问题，另外docker for mac创建的集群不支持改变系统组件的配置，比如修改API Server或Kubelet的参数，开启某些Alpaha版本的特性等。虽然Minikube已经存在很久，而且早于docker for mac，但是由于种种原因没能尝试，后经同事推荐，尝试了一下，确实蛮强大。本文将简单介绍下Minikube，以及在Mac主机上用Minikube创建和配置一个本地集群。
<!-- more -->

# Minikube介绍
Minikube是一个命令行工具用来在macOS，Linux和Windows平台中快速创建一个用于学习和开发为目的的Kubernetes集群，同时也提供了丰富的集群管理功能。因为Minikub的目标不是用来创建和管理生产用的Kubernetes集群，所以不会支持所有可能的Kubernetes部署配置，例如不同类型的存储，网络等。以下是Minikube的一些指导原则：
+ 用户友好
+ 支持所有Kuberenetes特性
+ 跨平台
+ 可靠
+ 最少的第三方软件依赖
+ 最少的资源消耗


## 集群创建能力的抽象
Minikube缺省使用kubeadm创建和配置Kubernetes集群，但是通过参数(-b, --bootstrapper)将底层创建集群的能力抽像出来，这就为集成其它的Kubernetes集群创建工具提供了可能。

## 丰富的插件
Minikube提供了丰富的开箱即用的插件用来帮助开发人员快速地配置Kubernetes集群，比如ingress插件用来安装ingress controller，dashboard插件用来安装Kubernetes的管理门户。通过命令```minikube addons list```可以列出支持的所有插件：
![](2.jpg)

## 丰富的集群组件配置能力
比起docker for mac创建的Kubernetes集群，Minikube提供了丰富的参数类型用来配置集群组件。可以参考https://minikube.sigs.k8s.io/docs/commands/start/ 查看```minikube start```命令中用于配置集群的参数，尤其是```--extra-config```参数可以用来对不同组件进行设置。参考https://minikube.sigs.k8s.io/docs/handbook/config/ 查看详细的集群配置功能。

## 丰富的集群管理命令
Minikube的start，stop和pause，unpause命令提供了不同级别的集群启停功能，从而释放出CPU，内存资源。Minikube stop命令会停掉运行Kubernetes集群的虚拟机，同时也会清理掉所有的容器镜像和持久卷，但仍旧会保留当前集群的所有的配置，而Minikube start命令则会重启虚拟机。Minikube pause命令不会停掉运行Kubernetes集群的虚拟机以及清理掉所有的容器镜像和持久卷，只会停掉Kubernetes集群，但也不会停掉docker的守护进程，而Minikube unpause命令会重新启动Kubernetes集群。

# Minikube的架构
![](1.jpg)

+ Minikube驱动层使用docker-machine创建不同类型的运行Kubernetes集群的工作节点。

+ Master和Worker就是Minikube通过驱动层创建出来的Kubernetes集群的工作节点。工作节点可以是运行在主机上的虚拟机、独立的容器，也可以是已经存在的且已经配置好的虚拟机（本地或远程的），或者就是主机本身。

## Hypervisor驱动
Minikube会根据指定的Hypervisor驱动在主机上启动一到多个虚拟机，并将它们配置成即将创建的Kubernetes集群的工作节点。不同类型的主机(Mac, Linux, Windows)支持的虚拟化技术有差异，所以会有不同的Hypervisor驱动。

### Linux主机支持的Hypervisor驱动
+ KVM2
+ VirtualBox

### Mac主机支持的Hypervisor驱动
+ Hyperkit
+ VirtualBox
+ Parallels
+ VMware

### Windows主机支持的Hypervisor驱动
+ Hyper-V
+ VirtualBox
+ VMware

## Docker驱动
当选择Docker驱动选项时，Minikube会利用docker in docker技术启动一到多个容器，并将它们配置成即将创建的Kubernetes集群的工作节点，即所谓的Kubernetes in docker。

### Linux主机的Docker驱动
+ Docker - container-based
+ Podman - container（试验阶段）

Docker是原生支持Linux系统的，所以在Linux主机中Docker的守护进程是直接运行在主机中的，相对来说性能会高点。Podman是另一个取代Docker的容器工具，完全兼容OCI标准。Podman也是原生支持Linux系统，而且在Linux系统中它是没有守护进程的，所谓的daemonless。目前Minikube支持Podman还处于试验阶段。

### Mac主机支持的Docker驱动
+ Docker - VM + Container (preferred)

Docker并没有原生支持Mac，所以Docker会在Mac主机上启动一个Hyperkit的虚拟机，并将它配置为Docker的服务端，而在Mac主机上的客户端则通过Unix Socket与Docker服务通信。

### Windows主机支持的Docker驱动
+ Docker - VM + Container (preferred)

通Mac一样，Docker也没有原生支持WIndows，所以需要在Windows主机上启动一Hyper-V虚拟机。

## SSH驱动
当使用SSH驱动时，Minikube实际上是通过SSH在已经存在并配置好的一台远程主机上创建Kuberenetes集群。

## None驱动
目前只支持Linux主机，也就是Minikube直接在当前的Linux主机上创建Kuberentes集群。

# 创建Kubernetes集群

## 用Docker驱动快速创建一个集群
```bash
minikube start -p mkdockerk8s --driver=docker
```
这个命令基于Docker驱动创建了一个单节点的Kubernetes集群。参数-p用来指定集群的名字。

执行以下命令可以查看创建的集群：
```bash
minikube profile list
```
![](3.jpg)

执行kubectl命令可以看到集群已经被加到kubeconfig中了：
```bash
kubectl config get-contexts
```
![](4.jpg)

执行以下命令安装dashboard:
```bash
minikube addons enable metrics-server
minikube addons enable dashboard
```
> Dashboard的一些特性依赖于metrics-server，所以先安装metrics-server。

**但是用docker driver创建的Kubernetes集群有很大的不足，基本上无法满足开发工作：**

+ 不支持ingress，当执行以下命令去安装ingress controller时，会出错
```bash
minikube addons enable ingress
```
```bash
❌  Exiting due to MK_USAGE: Due to networking limitations of driver docker on darwin, ingress addon is not supported.
Alternatively to use this addon you can use a vm-based driver:

	'minikube start --vm=true'

To track the update on this work in progress feature please check:
https://github.com/kubernetes/minikube/issues/7332

```

+ 不支持LoadBalance类型的服务，执行下面命令时，也会出错
```bash
minikube tunnel
```
```bash
🤷  The control plane node must be running for this command
👉  To start a cluster, run: "minikube start"
```

+ 同样无法打开前面安装好的dashboard
```bash
minikube dashboard
```
```bash
🤷  The control plane node must be running for this command
👉  To start a cluster, run: "minikube start"
```

所以，需要通过某个Hypervisor驱动创建一个虚拟机作为Kubernetes集群的工作节点，这样既能支持ingress，又能支持Loadbalance类型的服务，同时还能打开dashboard。下面将通过VirtualBox驱动创建集群。

## 用VirtualBox驱动创建集群
通过以下命令创建一个基于VirtualBox驱动的单节点集群。使用"--extra-config"可以配置Kubernetes系统组件，比如配置apiserver支持oidc认证等。  

```bash
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
可以通过命令```minikube config defaults kubernetes-version```列出minikube支持的所有Kubernetes版本。  

> 系统组件的详细配置文档：  
> apiserver: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/  
> controller-manager: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/  
> scheduler: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/  

通过以下命令可以列出minikube创建的所有集群集群：
```bash
minikube profile list
```
![](5.jpg)

### 安装MetalLB支持LoadBalancer类型的服务
> 参考[MetalLB官方安装和配置文档][4]

+ 设置ipvs模式的strictARP为true
  ```yaml
  kubectl edit configmap -n kube-system kube-proxy
  ```
  设置如下：
  ```yaml
  apiVersion: kubeproxy.config.k8s.io/v1alpha1
  kind: KubeProxyConfiguration
  mode: "ipvs"
  ipvs:
    strictARP: true
  ```

+ 通过minikube的metallb插件安装metallb
  ```bash
  minikube addons enable metallb
  ```

+ 修改MetalLB的配置添加IP地址池
  参考[Proxies and VPNs][5]，使用VirtualBox驱动创建的基于VM的集群节点IP地址池为192.168.59.0/24。可以从中选取一段用作给Loadbalancer类型的服务分配IP地址。
  ```bash
  kubectl edit cm config  -n metallb-system
  ```
  设置如下：
  ```bash
  apiVersion: v1
  data:
    config: |
      address-pools:
      - name: default
        protocol: layer2
        addresses:
        - 192.168.59.200 - 192.168.59.250
  ```
  重启metallb controller Pod。

### 安装Nginx Ingress Controller：
```bash
minikube addons enable ingress
```
> minikube自带的Nginx Ingress Controller插件的服务类型是NodePort，所以通过任何一个工作节点的IP就可以访问。

### 安装Kong Ingress Controller
```bash
minikube addons enable kong
```
> minikube自带的Kong Ingress Controller的服务类型是LoadBalancer类型，MetalLB会分配对应的IP地址。

### 安装dashboard
```bash
minikube addons enable metrics-server
minikube addons enable dashboard
```
> Dashboard中有关系统资源(CPU, Memory)的使用状态依赖于metrics-server组件，所以先安装metrics-server组件。

可以通过下面命令临时打开Dashboard，  
```bash
minikube dashboard
```
也可以为dashboard添加下面的Ingress资源将其通过测试域名(minikube.test)暴露出来：  
```sh
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minikube-dashboard-ingress
  namespace: kubernetes-dashboard
spec:
  ingressClassName: nginx
  rules:
    - host: minikube.test
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kubernetes-dashboard
                port:
                  number: 80
EOF
```

### 一些常用的命令
+ 登录进工作节点
  ```bash
  minikube ssh
  ```

+ 查询工作节点的IP地址
  ```bash
  minikube ip
  ```

+ 查看集群状态
  ```
  minikube status
  ```

# Minikbue在HTTP/HTTPS代理下的使用
当要设置HTTP/HTTPS代理才能上网时，需要将工作节点的主机网络地址段设置到NO_PROXY中，否则Minikube会无法访问主机里的资源。
> 详细参考[Proxies和VPN][5]中Proxy一节。

# Minikbue在VPN下的使用
使用VPN接入公司网络或者自己的私有网络时，VPN会截获Minikube访问主机的流量从而导致无法正常访问，因为VPN会强制修改本地路由，除非公司IT同意将你的Minikube用到的网段加入VPN的白名单（这往往不现实）。解决办法是通过端口转发的方法将对主机localhost或127.0.0.1的端口访问转发到集群工作节点的对应的端口上（前提是使用VM的驱动创建的集群）。以下是针对于VirtualBox驱动创建的集群添加的端口转发规则：

```bash
VBoxManage controlvm minikube natpf1 k8s-apiserver,tcp,127.0.0.1,8443,,8443
VBoxManage controlvm minikube natpf1 k8s-ingress,tcp,127.0.0.1,9080,,80
VBoxManage controlvm minikube natpf1 k8s-ingress-secure,tcp,127.0.0.1,9443,,443
VBoxManage controlvm minikube natpf1 docker,tcp,127.0.0.1,2376,,2376
```
比如针对集群API Server，将VirtualBox在本机打开的8443端口转发到集群节点(VM)的8443端口(集群API Server对应的端口)。这样在kubeconfig的配置文件中就可以通过`https://127.0.0.1:8443`来访问集群API Server：
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/mike/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Sat, 09 Apr 2022 18:42:47 CST
        provider: minikube.sigs.k8s.io
        version: v1.25.2
      name: cluster_info
    server: https://127.0.0.1:8443
  name: minikube
contexts:
- context:
    cluster: minikube
```

由于VirtualBox在Mac上是以非root账号运行的，所以只能打开本机1024以上的端口，但访问ingress暴露的HTTP/HTTPS服务时就需要加上端口号，使用起来并不友好。可以通过包过滤防火墙建立本机80，443端口到上面ingress的9080和9443端口的转发。Mac的配置参考如下：

## macOS Yosemite及以上版本
由于MacOS上的包过滤防火墙工具ipfw已经从macOS Yosemite和以上版本被移除了，所以需要通过以下方法使用pf。  

+ 创建一个锚文件
例如，/etc/pf.anchors/kubernetes.ingress-controller.forwarding

+ 在/etc/pf.anchors/kubernetes.ingress-controller.forwarding锚文件中, 输入:

  ```bash
  rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 9080
  rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 9443

  ```
  确保在末尾加一行空白行，否则会报格式错误。

+ 测试这个锚文件：  
  ```bash
  sudo pfctl -vnf /etc/pf.anchors/kubernetes.ingress-controller.forwarding
  ```

+ 创建/etc/pf-kubernetes-ingress-controller.conf文件  
  添加下面的配置：  
  ```bash
  rdr-anchor "forwarding" 
  load anchor "forwarding" from "/etc/pf.anchors/kubernetes.ingress-controller.forwarding"
  ```

+ 创建一个shell脚本，比如"./minikube-start/pf.sh"，配置在系统启动时执行  
  ```bash
  #!/bin/bash
  sudo pfctl -ef /etc/pf-kubernetes-ingress-controller.conf
  ```

## macOS 10.9和更早版本

执行以下命令配置端口转发：
```bash
sudo /sbin/ipfw add 102 fwd 127.0.0.1,9080 tcp from any to any 80 in
sudo /sbin/ipfw add 102 fwd 127.0.0.1,9443 tcp from any to any 443 in
```

# 结束语
本文旨在简单介绍Minikube，它的架构以及使用，希望能够帮助读者对Minikube有个框架性的了解，从而决定是否需要深入使用。对于Minikube更详细的用法，可以参考[官方文档][3]。

[1]: https://minikube.sigs.k8s.io/docs/handbook/accessing/
[2]: https://minikube.sigs.k8s.io/docs/handbook/vpn_and_proxy/#vpn
[3]: https://minikube.sigs.k8s.io/docs/
[4]: https://metallb.universe.tf/installation/
[5]: https://minikube.sigs.k8s.io/docs/handbook/vpn_and_proxy/