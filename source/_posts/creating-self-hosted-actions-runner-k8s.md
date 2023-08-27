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

# GitHub Action
![](1.png)
上图是GitHub Action包含的组件。

+ Workflows（工作流）是一个可配置的自动化过程，它运行一个或多个Jobs（作业）。  
+ Events（事件）是代码仓库中触发工作流的特定活动。  
+ Jobs（作业）是在同一GitHub Runner上执行的工作流中的一组步骤。  
+ Actions（动作）是GitHub Actions平台的自定义应用程序，执行复杂但经常重复的任务。  
+ GitHub Action Runner是在工作流被触发时运行工作流的软件。一个GitHub Action Runner一次可以执行一个作业。 GitHub提供了一些缺省的Runners供公共仓库免费使用，但是私有仓库则需要付费使用（GitHub为付费用户提供了一定的免费使用额度，详细可以参考[GitHub Actions的计费][2]），另一种方法就是自己部署GitHub Action Runner。

# Actions Runner Controller
GitHub的官网只介绍了在虚拟机中[部署自托管的GitHub Action Runner][1]部署自托管Runner的方法，但是随着云原生技术和Kubernetes的发展，越来越多的CI/CD系统逐渐容器化并运行在Kubernetes平台中，从而使系统本身变得更具弹性和韧性，比如Jenkins的agent，GitHub Action Runner也可以通过容器运行在Kubernetes平台中。Actions Runner Controller是一个自定义的Kubernetes Operator，通过声明式的方式来定义、创建、配置和管理运行在Kubernetes中的GitHub Action Runner。

# 安装Actions Runner Controller
推荐使用Helm的方式安装Actions Runner Controller，因为Actions Runner Controller的Helm Chart提供了丰富的模板参数用来定制安装。

## 设置GitHub API认证
本文选择PAT（Personal Access Token，个人访问令牌）的方式认证GitHub API。

{% note info %}
另一种认证方式为GitHub App，两种认证方式的区别以及配置GitHub App认证可以参考[Authenticating to the GitHub API][4]。
{% endnote %}

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

> 当您部署企业Runner时，它们将获得对GitHub组织（Org）的访问权限，但是，默认情况下**不允许**访问代码仓库本身。 每个GitHub组织（Org）都必须允许在代码仓库中使用企业> Runner Group作为初始的一次性配置步骤，这只需要完成一次，之后对于该Runner Group来说是永久性的。
> ![](3.jpg) 
> 组织和企业级别的Runner需要创建在Runner Group里，通过Runner Group对这些Runners分类和统一赋权，即哪些代码仓库和工作流可以使用这个Group里的Runners。
> ![](4.jpg)


## 安装cert-manager  
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version ${CERT_MANAGER_VERSION} --set installCRDs=true
```
{% note info %}
Actions Runner Controller中的admission webhook需要使用cert-manager创建一个自签名的ssl证书。
{% endnote %}

## Helm方式安装Actions Runner Controller
+ 创建命名空间
```bash
kubectl create ns acr-system
```

+ 用前面生成的PAT创建一个名为“controller-manager”的secret资源  
```bash
kubectl create secret generic controller-manager \
    -n actions-runner-system \
    --from-literal=github_token=${GITHUB_TOKEN}
```

+ 添加helm chart仓库并更新
```bash
helm repo add actions-runner-controller  https://github.com/actions-runner-controller/actions-runner-controller
helm repo update
```

+ 安装Actions Runner Controller  
```bash
helm upgrade -i actions-runner-controller actions-runner-controller/actions-runner-controller \
  --version ${ACTION_RUNNER_CONTROLLER_VERSION}> \
  -n actions-runner-system
```

  > + 可以执行命令 ```helm search repo actions-runner-controller``` 查询最新的helm chart版本：  
  > ![](2.png)  
  > + actions runner controller缺省会监听所有命名空间中的Runner CRD资源。可以通过添加选项```--set=scope.singleNamespace=true```只关注actions runner controller所在的命名空间的runner资源。


# 创建GitHub Action Runners
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
