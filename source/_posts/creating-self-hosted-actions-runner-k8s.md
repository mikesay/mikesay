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

GitHub Action是GitHub提供的CI/CD平台，用来自动化构建，测试和部署流水线。GitHub提供了基于虚拟机的Action Runners供用户免费构建公有仓库，但只有GitHub的付费用户才能使用这些Runners构建私有仓库（GitHub为付费用户提供了一定的免费使用额度，详细可以参考[GitHub Actions的计费][2]），而另一种办法就是部署自托管的Action Runner。 GitHub的官网只介绍了在虚拟机中[部署自托管的GitHub Action Runner][1]，但是随着云原生技术和Kubernetes的发展，越来越多的CI/CD系统开始运行在Kubernetes中，比如Jenkins。本文将介绍利用开源项目actions-runner-controller在Kubernetes中部署自托管的GitHub Action Runner。
<!-- more -->

# actions-runner-controller
actions-runner-controller是以Kubernetes Operator方式实现，通过CRD资源来定义、创建和配置运行在Kubernetes中的Action Runner。

# Helm方式安装actions-runner-controller

## Install cert-manager
```bash
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.8.0 --set installCRDs=true
```

## Add repository
```bash
helm repo add actions-runner-controller  https://github.com/actions-runner-controller/actions-runner-controller
```

## Install actions-runner-controller
```bash
helm upgrade -i --namespace actions-runner-system --create-namespace\
  --set=authSecret.create=true\
  --set=authSecret.github_token="REPLACE_YOUR_TOKEN_HERE"\
  --wait actions-runner-controller actions-runner-controller/actions-runner-controller\
  --version <VERSION>\
  -n actions-runner-system
```

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
