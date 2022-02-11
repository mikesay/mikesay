# 持续交付和部署模式介绍
我们的持续交付和部署的模式已经经历了三个版本的演进，未来仍然会持续的改进。下面，我将逐一介绍这三个版本。 

## 仅使用Helm命令行的推模型 

持续交付架构图：

![logo](/_media/cd_helm.png)

这一版中，应用代码和部署资源文件(Helm模板文件)被放在同一个Git仓库里(见下图代码仓库的结构)。无论是应用代码的变更还是部署资源文件的变更都会触发CI流水线构建出新的Docker镜像和Helm Chart，接着CI流水线会依次自动触发部署流水线部署最新的应用到开发和测试环境中。CI流水线包含了这么几个阶段:代码构建、单元测试、静态代码质量检测(SonarQube Scan)、编译器警告 (Compiler Warning)检测、无用和冗余代码(Dead Code)检测、编码标准(Code Standard)检测、打包和上传。部署流水线可以被多个应用共享，除了自动部署应用外，还会根据不同的环境执行对应的自动化测试。其它高阶环境的部署则需要相关负责人确认后手动触发部署流水线并输入要部署的应用和版本。

代码仓库的结构：

![logo](/_media/cd_helm1.png)

在深入使用这一版本的过程中，我们也逐渐发现了一些问题：  
(1) 安全问题 
为了实现推模型,每个Jenkins agent(Docker容器或VM)需要安装Helm命令行工具，并配置kubeconfig设置连接Kubernetes集群的账号，而且这个账号需要相对较高的权限，这样才能对集群中的资源进行增、删、改、查的操作，这就使得 Jenkins成为了Kubernetes集群的一个很大的攻击面。一个恶意的Jenkins job可以任意操作集群，另外，如果Jenkins agent镜像泄露的话，它也会被用作跳板来访问和攻击集群。Jenkins的Kubernetes持续部署插件(https://plugins.jenkins.io/kubernetes-cd/#documentation) 可以将Kubernetes 账号信息保存在Jenkins master中，只有在构建时才会通过ssh动态地从Jenkins master拉取账号信息，这样避免了因Jenkins agent镜像泄露而造成的风险，但还是无法避免恶意Job的⻛险。这个插件本身也有局限性,比如它不支持Helm部署，只支持部署 Kubernetes的基本资源文件等等。

(2) 非不可变更部署(Non Immutable Deployment) 
这种推模型在部署完后，就不会持续监测Kubernetes集群中实际运行的资源是否与之前部署的版本一致。如果有人手动修改了Kubernetes集群中某个应用的资源，出现了问题，有时除了本人还真需要花点时间来定位。这种情况经常出现在开发环境,因为开发环境是面向开发人员的，所以我们是允许开发人员访问dev命名空间。 

(3) 重复的部署资源文件
这一版中，我们是把Helm的模板文件和代码放在一个仓库里面，每次构建时都会打包出新版本的Helm Chart，其实也就是将Helm的版本和引用的Docker镜像版本更改成当前的版本。但是为了添加一个新的部署逻辑，比如添加Istio的资源文件以支持Istio服务网格，我们需要往多个代码仓库里添加Helm模板文件，工作量大不说，重复的手工操作也很容易出错。在版本2时，我们改变了策略，提取出了通用的Helm资源模板文件。 

## 基于FluxCD和Helm Operator的拉模型

持续交付架构图: 

![logo](/_media/cd_flux.png)

FluxCD(https://fluxcd.io/) 是一款开源的实现GitOps的工具，其核心思想是将所有部署资源文件保存在Git仓库中作为唯一事实来源，FluxCD持续监听这一事实来源并将其同步到Kubernetes集群中，这就解决了我们版本1中遇到的第2个问题，即非不可变更部署。由于我们是利用Helm模板文件作为我们的部署资源文件，所以需要安装FluxCD的另一个工具Helm Operator。 从上面的持续交付架构可以看出，FluxCD和Helm Operator是部署在目标 Kubernetes集群中的，负责同步Git仓库中的部署资源文件。而CI流水线和部署流水线只需往Git仓库中提交变更来声明部署需求，因此在Jenkins和Agent中不需要存储Kubernetes集群的账号信息，降低了安全⻛险。 

为了解决Helm模板文件在不同的应用代码仓库中重复存在的问题，我们抽取出了一个通用的Helm模板并将其打包成一个通用的Helm Chart供每个具体应用的部署资源文件引用。这个通用的Helm Chart也有自己独立的流水线以保证持续的缺陷修复和新功能添加。同时，为了适应FluxCD的工作方式，将产品的部署资源抽取到一个单独的Git仓库中,具体的示例结构如下：

![logo](/_media/cd_flux1.png)

(1) Chart.yaml描述了当前应用的版本信息，以及所使用的通用Helm Chart的版本，示例代码如下：

```yaml
apiVersion: v2 
name: service2 
version: 8.0.9 
appVersion: 8.0.9 
dependencies: 
- name: common-chart 
  version: 1.0.1 
  repository: https://xxxx/charts 
```

(2) values.yaml设置了针对具体环境的参数值,示例代码如下：

```yaml
common-chart: 
  image: 
    repository: docker-registry.local/service2 
    tag: 8.0.9 
    pullPolicy: IfNotPresent 
  ingress: 
    enabled: true 
    annotations: 
      kubernetes.io/ingress.class: nginx 
      kubernetes.io/tls-acme: "true" 
      nginx.ingress.kubernetes.io/rewrite-target: /$2 
    hosts: [] 
    paths: 
    - /service2/dev(/|$)(.*) 
```

由于FluxCD只能绑定一个Git仓库，因此所有项目的部署资源文件都会放在这个仓库中。如上图所示，dev目录下既包含了project1，也包含了project2的部署资源文件。 随着FluxCD这一GitOps工具的引入，我们的持续交付由面向过程的模式变为面向资源以Git为中心的声明式的模式。但是在使用过程中也存在着一些问题：

(1) FluxCD的部署不是实时的 
FluxCD是每隔一定的时间(可以设置)扫描一次Git仓库，如果有新的版本,就会将其同步到Kubernetes集群中。为了能够实时地检测部署是否成功，需要每个应用提供一个健康检查接口用来返回当前版本是否运行正常，在部署流水线中持续访问这个接口直到获取部署成功的状态，或者超时的错误状态。FluxCD提供了一个命令行工具fluxctl，通过命令"fluxctl sync"可以实时触发FluxCD去同步，也就是推模型，而不必等待FluxCD的轮询，但是这就需要在客户端配置 kubeconfig存储集群的账号来访问Kubernetes集群。 

(2) 无法实时方便地检查最新Pod的日志
对于开发人员来说，当收到部署流水线失败的通知后，如果能够通过部署流水线快速看到最新Pod的运行日志，是非常有助于他们快速定位和修复问题的，但是 FluxCD并没有提供这样的便捷接口。 

(3) 各个应用的部署资源文件相互干扰
由于所有应用的部署资源文件放在一个Git仓库中,当某个应用的部署资源文件出现问题，比如语法有错，整个同步过程会失败，其它应用的最新资源就无法同步到Kubernetes集群中。

以上的问题促使我们对另一个GitOps工具ArgoCD进行了研究和尝试，这也是我们第三个版本的持续交付模式。

## 基于ArgoCD的推拉结合的模型 

持续交付架构图：

![logo](/_media/cd_argo.png)

ArgoCD(https://argoproj.github.io/argo-cd/)作为GitOps工具，其核心功能和 FluxCD相同，通过间隔扫描Git仓库并同步最新的部署资源到Kubernetes集群中完成部署，但是相比于FluxCD，ArgoCD提供了更多的功能，而这些功能为我们构建基于GitOps的安全的持续交付流水线提供了更多的便利。

以下是ArgoCD的一些功能：
(1) ArgoCD不需要在每个目标集群中部署，它可以部署在一个独立的环境中(VM 或者Kubernetes集群)作为统一的Kubernetes应用部署平台。所有目标集群可以注册进ArgoCD，注册粒度可以是命名空间级别，也可以是整个集群级别；

(2) ArgoCD有项目(Project)和应用(Application)的概念，应用属于某个项目，可以做到应用级别的隔离。一个ArgoCD项目可以代表一个具体的项目，比如电商网站，一个ArgoCD应用(Application)可以代表某个实际的应用在某个集群或命名空间里面的部署，这样可以实现应用之间的部署资源相互隔离避免部署时相互干扰。ArgoCD项目可以设置黑白名单来限制项目中的应用能够访问的Git仓库和集群或者集群的命名空间，这样即使应用被恶意触发，它的部署行为也是可控的；

(3) ArgoCD对外提供了两个接口：Web和基于gRPC的API接口。Web接口可视 化了部署状态，DevOps工程师和开发工程师通过这个Web接口可以方便地查看应用的资源结构，资源同步状态和Pod日志等。下面是通过ArgoCD Web接口可以看到的一些信息。

部署资源在Kubernetes集群中的静态结构：

![logo](/_media/cd_argo1.png)

应用的网络流向图: 

![logo](/_media/cd_argo2.png)

可以看到网络流量从负载均衡器进入，经过Ingress和Service的转发到达实际的工作负载Pod。 
查看Pod的日志：

![logo](/_media/cd_argo3.png)

ArgoCD的gRPC接口提供了编程的方式管理ArgoCD。ArgoCD也提供了一个命令行工具argocd，这个命令通过gRPC接口管理ArgoCD的应用。命令行工具 argocd和fluxctl不同的是它不直接和Kubernetes集群通信，所以不需要设置 Kuberetes账号，它只是通过gRPC接口给ArgoCD发送指令，由ArgoCD完成对 Kubernetes集群的操作。所以在我们的部署流水线里集成argocd，主动地触发 ArgoCD去同步Git仓库来实现推模型；

(4) ArgoCD支持基于RBAC的用户权限管理，我们可以灵活地定义不同的角色和权限。比如，以项目为粒度定义出开发、DevOps、管理员等角色，而开发角色可以是只读权限，这样当开发收到部署流水线失败的通知后，可以登录ArgoCD快速地查看和定位错误信息。

目前基于ArgoCD的Kubernetes应用的持续交付是我们主推的模式，更多的问题有待于我们在深入使用的过程中去发现和解决。
