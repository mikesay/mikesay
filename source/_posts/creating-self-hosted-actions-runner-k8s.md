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

GitHub Workflow是GitHub提供的SaaS版CI工具，它提供了各种类型的基于虚拟机的Action Runners供使用GitHub免费服务的用户来构建他们的公开仓库，但只有GitHub付费用户才能使用GitHub托管的Action Runners来构建私有仓库的（GitHub为付费用户提供了一定的免费使用额度，详细可以参考[GitHub Actions的计费][2]），所以如果GitHub的免费用户想构建自己的私有仓库，需要部署自己托管的GitHub Action Runner。 GitHub的官网只介绍了在虚拟机中[创建自托管的GitHub Action Runner][1]，但是随着云原生技术和Kubernetes的发展，越来越多的CI/CD系统（包括CI/CD服务器和客户端代理）迁移到了Kubernetes上，比如Jenkins Master以及JNLP的客户端代理。本文将介绍利用开源项目actions-runner-controller在Kubernetes中创建自托管的GitHub Action Runner。
<!-- more -->

# actions-runner-controller
actions-runner-controller是Kubernetes Operator，通过CRD资源来定义、创建和配置运行在Kubernetes中的Action Runner。

Install cert-manager
```bash
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.8.0 --set installCRDs=true
```

Install actions-runner-controller
```bash
helm repo add actions-runner-controller  https://github.com/actions-runner-controller/actions-runner-controller
helm upgrade -i actions-runner-controller/actions-runner-controller . --version 0.17.3 -n actions-runner-system
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
