---
title: Minikube创建本地Kubernetes集群
tags:
  - Kubernetes
  - K8s
  - Minikube
date: 2021-10-06 18:40:49
---

在学习和使用Kubernetes的过程中，都希望能够快速创建一个个人的Kubernetes集群用作测试之用。之前一直使用docker公司的docker for mac创建的Kubernetes集群，但是经常出现启动不起来的问题，又没有详细的日志定位问题，甚是苦恼。另外docker for mac创建的Kubernetes很难去改变系统组件的配置，比如修改API Server或Kubelet的参数，开启某些Alpaha版本的特性等。虽然Minikube已经存在很久，可能早于docker for mac创建的Kubernetes集群，但是由于种种原因没能尝试，后经同事强烈推荐，尝试了一下，确实蛮强大。本文将简单介绍下Minikube，以及在Mac主机上用Minikube创建一个测试集群。
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

```bash
minikube start --cpus=4 --memory='6g' --cni='flannel' --disk-size='60g' --driver='virtualbox' --kubernetes-version='v1.19.10' --extra-config=apiserver.service-node-port-range=1-65535 --extra-config=controller-manager.bind-address=0.0.0.0 --extra-config=scheduler.bind-address=0.0.0.0
```
创建了一个基于VirtualBox驱动的单节点集群。通过各个参数详细地配置了集群：

参数 | 用途
---|---
--cpus=4 | 指定了节点最大CPU数为4
--memory='6g' | 指定了工作节点的最大内存数为6g
--disk-size='60g' | 指定了节点的磁盘大小
-kubernetes-version='v1.19.10' | 指定创建的集群版本为v1.19.10
-extra-config=apiserver.service-node-port-range=1-65535 | 通过--extra-config配置apiserver，使得运行NodePort类型的服务能够使用1-65535范围的端口
--extra-config=controller-manager.bind-address=0.0.0.0 | 通过--extra-config配置controller-manager，使能够从外面访问controller-manager的API
--extra-config=scheduler.bind-address=0.0.0.0 | 通过--extra-config配置scheduler，使能够从外面访问scheduler的API

同样，执行以下命令可以查看创建的集群：
```bash
minikube profile list
```
![](5.jpg)

这个时候就可以通过命令安装ingress controller，从而支持通过ingress暴露内部服务：
```bash
minikube addons enable ingress
```

也可以安装并打开dashboard：
```bash
minikube addons enable metrics-server
minikube addons enable dashboard
minikube dashboard
```

通过以下命令，可以登录进工作节点：
```bash
minikube ssh
```

还可以通过命令查询工作节点的IP地址：
```bash
minikube ip
```

### 部署NodePoart和Loadbalance类型的服务
可以详细参考[访问应用][1]这篇文档，在这里就不赘述了。

# Minikbue的缺陷
目前Minikube在VPN的情况下可能存在问题。如果你的公司支持VPN远程办公，在拨上VPN的情况下，可能无法访问Minikube的集群，因为VPN会强制修改本地路由，除非公司IT同意将你的Minikube用到的网段加入VPN的白名单（这往往不现实）。对于这个问题可以详细参考[Proxies和VPN][2]这篇文档。

# 结束语
本文旨在简单介绍Minikube，它的架构以及使用，希望能够帮助读者对Minikube有个框架性的了解，从而决定是否需要深入使用。对于Minikube更详细的用法，可以参考[官方文档][3]。

[1]: https://minikube.sigs.k8s.io/docs/handbook/accessing/
[2]: https://minikube.sigs.k8s.io/docs/handbook/vpn_and_proxy/#vpn
[3]: https://minikube.sigs.k8s.io/docs/