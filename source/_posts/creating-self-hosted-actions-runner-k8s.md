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

GitHub Workflow是GitHub提供的SaaS版CI/CD系统，也提供了许多基于虚拟机的Actions Runner，但是对于使用免费GitHub服务的用户来说，GitHub提供的Actions Runner只能用来构建公有仓库，所以用户需要创建自托管的GitHub Actions Runner用来构建私有仓库。 GitHub的官网只介绍了在虚拟机中[创建自托管的GitHub Actions Runner][1]，但是随着云原生技术和Kubernetes的发展，越来越多的CI/CD系统（包括CI/CD服务器和客户端代理）迁移到了Kubernetes上，比如Jenkins Master以及JNLP的客户端代理。本文将介绍利用开源项目actions-runner-controller在Kubernetes中创建自托管的GitHub Actions Runner。
<!-- more -->

# actions-runner-controller


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
