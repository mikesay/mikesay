---
title: 在Kubernetes中创建自托管GitHub Actions Runner
tags:
  - DevOps
  - CI/CD
  - Git
  - Github
  - Kubernetes
  - K8s
date: 2022-04-11 02:21:47
---

GitHub Actions 是一个持续集成和持续交付 (CI/CD) 平台，利用工作流（Workflow）可以创建自动化构建、测试和部署管道。GitHub Actions 不仅限于 DevOps，还允许在代码仓库中发生其它事件时运行工作流， 例如，可以运行一个工作流，当代码仓库中有新的问题创建时自动添加适当的标签。GitHub Runner是执行工作流的服务器，本文介绍了利用开源项目[Actions Runner Controller][3]在Kubernetes中部署和管理自托管的容器版本的GitHub Action Runner。

<!-- more -->

# GitHub Runner
![](1.png)
上图是GitHub Actions包含的组件。

+ Workflows（工作流）是一个可配置的自动化过程，它运行一个或多个Jobs（作业）。  
+ Events（事件）是代码仓库中触发工作流的特定活动。  
+ Jobs（作业）是在同一GitHub Runner上执行的工作流中的一组步骤。  
+ Actions（动作）是GitHub Actions平台的自定义应用程序，执行复杂但经常重复的任务。  
+ GitHub Runner是在工作流被触发时运行您的工作流的服务器。每个GitHub Runner一次可以运行一个作业。 GitHub Runner 可以在 GitHub 托管的云或自托管环境中运行。 自托管环境提供了对硬件、操作系统和软件工具的更多控制。 它们可以在物理机、虚拟机或容器中运行。 容器化环境轻量级、松散耦合、高效并且可以集中管理。 然而，它们并不易于使用。GitHub提供了虚拟机版本的Runner包括Ubuntu Linux、Microsoft Windows 和 macOS，每个工作流运行都将运行在一个全新的的虚拟机中。

# Actions Runner Controller
但是GitHubGitHub上的私有仓库如果需要收费使用GitHub提供的Runner， GitHub为付费用户提供了一定的免费使用额度，详细可以参考[GitHub Actions的计费][2]）， 。
GitHub的官网只介绍了在虚拟机中[部署自托管的GitHub Action Runner][1]部署自托管Runner的方法，但是随着云原生技术和Kubernetes的发展，越来越多的CI/CD系统逐渐容器化并运行在Kubernetes平台中，从而使系统本身变得更具弹性和韧性，比如Jenkins的agent。GitHub Runner也可以通过容器运行在Kubernetes平台中，而Actions Runner Controller是一个自定义的Kubernetes Operator，通过声明式的方式来定义、创建、配置和管理运行在Kubernetes中的GitHub Runner。

# 安装GitHub Runner
## 设置GitHub API认证
本文选择PAT（Personal Access Token，个人访问令牌）的方式认证GitHub API。另一种认证方式为GitHub App，两种认证方式的区别以及配置GitHub App认证可以参考[Authenticating to the GitHub API][4]。  

点击[创建PAT](https://github.com/settings/tokens/new)，并参考以下不同级别的Runner所需要的权限创建PAT：

**代码仓库级别的Runner需要的权限**

* repo (Full control)

**组织(org)级别的Runner需要的权限**

* repo (Full control)
* admin:org (Full control)
* admin:public_key (read:public_key)
* admin:repo_hook (read:repo_hook)
* admin:org_hook (Full control)
* notifications (Full control)
* workflow (Full control)

**企业级别的Runners需要的权限**

* admin:enterprise (manage_runners:enterprise)

  > 当您部署企业Runner时，它们将获得对GitHub组织（Org）的访问权限，但是，默认情况下**不允许**访问代码仓库本身。 每个GitHub组织（Org）都必须允许在代码仓库中使用企业Runner Group作为初始的一次性配置步骤，这只需要完成一次，之后对于该Runner Group来说是永久性的。
  > ![](3.jpg) 
  > 组织和企业级别的Runner需要创建在Runner Group里，通过Runner Group对这些Runners分类和统一赋权，即哪些代码仓库和工作流可以使用这个Group里的Runners。
  > ![](4.jpg)

## 安装cert-manager  
```bash
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version ${CERT_MANAGER_VERSION} --set installCRDs=true
```
{% note info %}
Actions Runner Controller中的admission webhook需要使用cert-manager创建一个自签名的ssl证书。
{% endnote %}

## Kubectl方式部署
+ 用前面生成的PAT创建一个名为“controller-manager”的secret资源  
```bash
kubectl create secret generic controller-manager \
    -n actions-runner-system \
    --from-literal=github_token=${GITHUB_TOKEN}
```

+ 执行kubectl命令部署指定版本的action runner controller  
```bash
kubectl create -f https://github.com/actions/actions-runner-controller/releases/download/${ACTION_RUNNER_CONTROLLER_VERSION}/actions-runner-controller.yaml \
    -n actions-runner-system
```
{% note info %}
用期望的版本替换变量${ACTION_RUNNER_CONTROLLER_VERSION}。
{% endnote %}

## Helm方式安装Actions Runner Controller
+ 添加helm chart仓库  
```bash
helm repo add actions-runner-controller  https://github.com/actions-runner-controller/actions-runner-controller
```

+ 更新本地的helm chart仓库  
```bash
helm repo update
```

+ 安装Actions Runner Controller  
```bash
helm upgrade -i actions-runner-controller actions-runner-controller/actions-runner-controller \
  -i --create-namespace \
  --set=authSecret.create=true \
  --set=authSecret.github_token=${GITHUB_TOKEN} \
  --wait \
  --version ${ACTION_RUNNER_CONTROLLER_VERSION}> \
  -n actions-runner-system
```

  > + 可以执行命令 ```helm search repo actions-runner-controller``` 查询最新的helm chart版本：  
  > ![](2.png)  
  > + actions runner controller缺省会关注所有命名空间的runner资源。可以通过添加选项```--set=scope.singleNamespace=true```只关注actions runner controller所在的命名空间的runner资源。

  {% note info %}
  helm方式的安装会为参数中提供的GitHub PAT自动生成一个名为“controller-manager”的secret资源。也可以参考kubectl部署方式，提前创建好"controller-manager" secret，在执行helm命令时，就不需要设置authSecret.create和authSecret.github_token。
  {% endnote %}


# 创建GitHub Runners
GitHub自托管Runners可以部署在管理层次结构的各个级别  
+ 代码仓库级别
+ 组织级别
+ 企业级别

Action Runner Controller提供了两种CRD资源定义Runners：
+ RunnerDeployment (和k8s's Deployments类似, 基于Pods)  
+ RunnerSet (基于k8s's StatefulSets)

## 创建repository级别的Runner
```bash
cat << EOF | kubectl apply -n actions-runner-system -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: mikesay-mikesay-spikes-runner
spec:
  replicas: 1
  template:
    spec:
      repository: mikesay/mikesay-spikes
      labels:
        - mikesay
        - mikesay-spikes
EOF
```

## 创建orgnization级别的Runner
```bash
cat << EOF | kubectl apply -n actions-runner-system -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: mikesay-runner
spec:
  replicas: 1
  template:
    spec:
      organization: mikesay
      group: default
      labels:
        - mikesay
      env: []
EOF
```
{% note info %}
Runner Group用来限制对应GitHub组织里的哪些代码仓库和工作流能够使用GitHub Runners。只有升级到GitHub企业版，才能创建自定义的group，否则只能用default组。
{% endnote %}

## 使用RunnerSet创建repository级别的Runner
```bash
cat << EOF | kubectl apply -n actions-runner-system -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerSet
metadata:
  name: mikesay-mikesay-spikes-runnerset
spec:
  ephemeral: false
  persistentVolumeClaimRetentionPolicy:
    whenDeleted: Retain
    whenScaled: Retain
  replicas: 2
  repository: mikesay/mikesay-spikes
  labels:
    - mikesay
    - mikesay-spikes
  selector:
    matchLabels:
      app: mikesay
  serviceName: mikesay
  template:
    metadata:
      labels:
        app: mikesay
      name: mikerunner
    spec:
      containers:
      - name: runner
        volumeMounts:
        - name: www
          mountPath: /runner/data
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"
      resources:
        requests:
          storage: 200M
EOF
```


[1]: https://docs.github.com/en/enterprise-cloud@latest/actions/hosting-your-own-runners/adding-self-hosted-runners
[2]: https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions#about-spending-limits
[3]: https://github.com/actions/actions-runner-controller
[4]: https://github.com/actions/actions-runner-controller/blob/master/docs/authenticating-to-the-github-api.md
