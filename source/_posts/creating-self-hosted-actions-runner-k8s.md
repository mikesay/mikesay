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

GitHub Action是GitHub提供的CI/CD平台，用来自动化构建，测试和部署流水线。它缺省提供了基于虚拟机的多种类型的Runners供用户在自己的公有仓库中免费使用，而对于私有仓库的使用则需要收费（GitHub为付费用户提供了一定的免费使用额度，详细可以参考[GitHub Actions的计费][2]），如果不想付费使用GitHub提供的Runners，则需要自己部署自托管的Runner。本文将介绍利用开源项目[Actions Runner Controller][3]在Kubernetes中部署自托管的GitHub Action Runner。
<!-- more -->

# Actions Runner Controller
GitHub的官网只介绍了在虚拟机中[部署自托管的GitHub Action Runner][1]，但是随着云原生技术和Kubernetes的发展，越来越多的CI/CD系统开始运行在Kubernetes中，比如Jenkins。而Actions Runner Controller则是以Kubernetes Operator方式实现，通过CRD资源来定义、创建和配置运行在Kubernetes中的Runner。

# Helm方式安装Actions Runner Controller

## 安装cert-manager
```bash
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.8.0 --set installCRDs=true
```

## 添加helm chart仓库
```bash
helm repo add actions-runner-controller  https://github.com/actions-runner-controller/actions-runner-controller
```

## 更新本地的helm chart仓库
```bash
helm repo update
```

## 安装Actions Runner Controller
```bash
helm upgrade -i --namespace actions-runner-system --create-namespace\
  --set=authSecret.create=true\
  --set=authSecret.github_token="REPLACE_YOUR_TOKEN_HERE"\
  --wait actions-runner-controller actions-runner-controller/actions-runner-controller\
  --version <VERSION>\
  -n actions-runner-system
```

!!!note
  可以执行命令 ```helm search repo actions-runner-controller``` 查询最新的helm chart版本。

# 创建Runners


Create RunnerDeployment resource:
```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: mikesay-runner
  namespace: actions-runner-system
spec:
  replicas: 1
  template:
    spec:
      organization: mikesay
      group: default
      labels:
        - mikesay
      env: []
```

[1]: https://docs.github.com/en/enterprise-cloud@latest/actions/hosting-your-own-runners/adding-self-hosted-runners
[2]: https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions#about-spending-limits
[3]: https://github.com/actions/actions-runner-controller
