---
title: 在Kubernetes中创建自托管GitHub Actions Runner
toc: true
tags:
  - DevOps
  - CI/CD
  - Git
  - Github
  - Kubernetes
  - K8s
date: 2022-04-11 02:21:47
---

GitHub Actions 是一个持续集成和交付 (CI/CD) 平台，利用工作流（Workflow）可以创建自动化构建、测试和部署管道。GitHub Actions不仅限于构建CI/CD工作流，它可以定义任意的工作流完成某个自动化的功能， 例如，定义一个工作流，当代码仓库中有新的问题创建时自动添加适当的标签。GitHub Action Runner是执行工作流的组件。本文介绍了利用开源项目[Actions Runner Controller][3]在Kubernetes中部署和管理自托管的容器版本的GitHub Action Runner。

<!-- more -->

# GitHub Action
下图是GitHub Actions概念或组件：
![](1.png)

+ Workflow（工作流）是一个可配置的自动化过程，它由一个或多个Job（作业）组成。  
+ Event（事件）是代码仓库中触发工作流的特定活动。  
+ Job（作业）是一组步骤的组合，运行在同一个GitHub Action Runner上。  
+ Action（动作）由Job中的步骤调用。GitHub Actions提供了很多开箱即用的Actions，用户也可以封装一些通用的actions供组织使用。  
+ GitHub Action Runner是在工作流被触发时执行工作流的组件。一个GitHub Action Runner一次可以执行一个作业，当Job结束后，Runner会重启恢复到干净的状态。GitHub提供了一些缺省的Runners供公共仓库免费使用，而私有仓库则需要付费使用（GitHub为付费用户提供了一定的免费使用额度，详细可以参考[GitHub Actions的计费][2]）。替代方案就是自己部署GitHub Action Runner。

# Actions Runner Controller
GitHub的官网只提供了在虚拟机中[部署自托管的GitHub Action Runner][1]的文档，但是随着云原生技术和Kubernetes的发展，越来越多的CI/CD系统逐渐容器化并运行在Kubernetes平台中，从而使系统本身变得更具弹性和韧性，比如Jenkins的agent。GitHub Action Runner也支持通过容器运行在Kubernetes平台中，Actions Runner Controller是一个自定义的Kubernetes Operator，通过声明式的方式来定义、创建、配置和管理运行在Kubernetes中的GitHub Action Runner，具体架构如下图：
![](5.png)

# 安装Actions Runner Controller
推荐使用Helm的方式安装Actions Runner Controller，因为Actions Runner Controller的Helm Chart提供了丰富的模板参数用来定制安装。

## 设置GitHub API认证
本文选择PAT（Personal Access Token，个人访问令牌）的方式认证GitHub API。

> 另一种认证方式为GitHub App，两种认证方式的区别以及配置GitHub App认证可以参考[Authenticating to the GitHub API][4]。

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
> Actions Runner Controller中的admission webhook需要使用cert-manager创建一个自签名的ssl证书。

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
    --version ${ACTION_RUNNER_CONTROLLER_VERSION} \
    -n actions-runner-system
  ```

  > + 可以执行命令 ```helm search repo actions-runner-controller``` 查询最新的helm chart版本：  
  > ![](2.png)  
  > + actions runner controller缺省会监听所有命名空间中的Runner CRD资源。可以通过添加选项```--set=scope.singleNamespace=true```只关注actions runner controller所在的命名空间的runner资源。

## 降低Docker Hub限流的影响
从2020年11月20日开始，Docker Hub对匿名和免费认证的使用开始了限流措施。匿名和免费Docker Hub 用户每六小时只能发出 100 和 200 个容器映像拉取请求。 您可以在[这里](5)获取更多详细信息。如果部署频率不是很高，比如个人测试用，直接用上面的命令部署应该不会有问题，但是如果部署频率比较高，或者在公司内网的环境中部署，而公司的公网出口IP往往是固定的，则很有可能会触发限流导致部署失败。其中一个解决办法就是使用免费账号来拉取镜像，这样可以享受每6个小时200个容器镜像拉取请求。具体的操作步骤为：

1. 参考[创建Docker Hub账号](6)注册一个Docker Hub免费账号
2. 参考[创建账号对应的PAT(个人访问凭证)][7]生成一个个人访问凭证（官方推荐用个人访问凭证的方式认证Docker Hub）
3. 如果是使用docker命令行拉取镜像，先执行下面的命令登陆Docker Hub，并且在提示密码时输入个人访问凭证
  ```bash
  docker login --username ${DOCKER_HUB_USERNAME}
  ```
4. 如果是Kubernetes中的部署要拉取镜像，先执行下面的命令在对应的命名空间里创建docker pull secret，并且在Pod的部署yaml文件中显式添加这个secret
  ```bash
  kubectl create secret docker-registry image-pull-secret \
      --docker-server=docker.io\
      --docker-username=${DOCKER_HUB_USERNAME} \
      --docker-password=${DOCKER_HUB_USER_PAT} \
      -n ${NAMESPACE}
  ```

另一个解决办法就是部署一个带有proxy功能的私有镜像仓库，比如[Harbor](8)，[Nexus](9)，或者[Artifactory](10)或者，配置一个Docker Hub的代理（可以通过免费用户来认证），每次部署时通过代理来拉取docker镜像并缓存，这样可以降低因拉取重复镜像而消耗限流额度。随着时间的推移，常用的docker镜像基本上都能缓存到私有仓库里。

以上两种方式都需要我们在部署actions runner controller时配置docker pull secret用来拉取镜像，且第二种方法还需要更改镜像地址。对于Helm chart的部署方式，基本上只需要定制它的values.yaml文件即可。具体步骤如下：
1. 执行下面命令获取Helm chart缺省的values.yaml文件
  ```bash
  helm show values actions-runner-controller/actions-runner-controller --version ${ACTION_RUNNER_CONTROLLER_VERSION} > values.yaml
  ```

2. 修改缺省的values.yaml文件添加docker pull secret或者更改docker镜像地址
  ```yaml
  image:
    repository: "${DOCKER_HUB_PROXY_SERVER}/summerwind/actions-runner-controller"
    actionsRunnerRepositoryAndTag: "${${DOCKER_HUB_PROXY_SERVER}/summerwind/actions-runner:latest"
    dindSidecarRepositoryAndTag: "${${DOCKER_HUB_PROXY_SERVER}}/docker:dind"
    pullPolicy: IfNotPresent
    # The default image-pull secrets name for self-hosted runner container.
    # It's added to spec.ImagePullSecrets of self-hosted runner pods.
    actionsRunnerImagePullSecrets:
      - ${DOCKER_PULL_SECRET}

  imagePullSecrets:
    - name: ${DOCKER_PULL_SECRET}
  ```  
  > + .image.repository是actions-runner-controller的镜像地址  
  > + .image.actionsRunnerRepositoryAndTag是连接GitHub的Action Runner镜像地址  
  > + .image.dindSidecarRepositoryAndTag是docker server的镜像地址（Action Runner是使用的dind的方式构建应用镜像的，所以一个Action Runner Pod会包含两个容器，一个是runner服务本身，另一个是docker服务，runner通过环境变量DOCKER_HOST引用docker服务。） 
  > + image.actionsRunnerImagePullSecrets是拉取Action Runnder镜像所需要的secret  
  > + .image.imagePullSecrets是拉取actions-runner-controller的镜像地址  

3. 用定制的values.yaml文件安装actions-runner-controller
  ```bash
  helm upgrade -i actions-runner-controller actions-runner-controller/actions-runner-controller \
    --version ${ACTION_RUNNER_CONTROLLER_VERSION} \
    -f values.yaml \
    -n actions-runner-system
  ```

# 创建GitHub Action Runners
GitHub自托管Runners可以部署在管理层次结构的各个级别  
+ 代码仓库级别
+ 组织级别
+ 企业级别

Action Runner Controller提供了两种CRD资源定义Runners：
+ RunnerDeployment (类似于Kubernetes的Deployment资源，无状态)  
+ RunnerSet (类似于Kubernetes的StatefulSets资源，有状态)

## 创建repository级别的Runner
```bash
cat << EOF | kubectl apply -n actions-runner-system -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: mikesay-runner
spec:
  replicas: 2
  template:
    spec:
      volumeMounts:
      - name: docker-config
        mountPath: /home/runner/.docker
      volumes:
      - name: docker-config
        secret:
          secretName: ${DOCKER_PULL_SECRET}
          items:
          - key: .dockerconfigjson
            path: config.json
      repository: mikesay/mikesay-spikes
      labels:
        - mikesay
        - mikesay-spikes
EOF
```  

> 通过volumes和volumeMounts可以将docker镜像拉取的secret配置进Runner容器，这样Runner在执行Job时也可以从私有镜像仓库拉取和上传镜像了。如果不需要，也可以不添加。

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
      volumeMounts:
      - name: docker-config
        mountPath: /home/runner/.docker
      volumes:
      - name: docker-config
        secret:
          secretName: ${DOCKER_PULL_SECRET}
          items:
          - key: .dockerconfigjson
            path: config.json
      organization: mikesay
      group: default
      labels:
        - mikesay
      env: []
EOF
```  
> Runner Group用来限制对应GitHub组织里的哪些代码仓库和工作流能够使用GitHub Runners。只有升级到GitHub企业版，才能创建自定义的group，否则只能用缺省的default组。

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
      volumeMounts:
      - name: www
        mountPath: /runner/data
      - name: docker-config
        mountPath: /home/runner/.docker
      volumes:
      - name: docker-config
        secret:
          secretName: ${DOCKER_PULL_SECRET}
          items:
          - key: .dockerconfigjson
            path: config.json
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
[5]: https://docs.docker.com/docker-hub/download-rate-limit/?_gl=1*31w0cv*_ga*MTMzMzk4NTk4NC4xNjkyMjU4NjM4*_ga_XJWPQMJYHQ*MTY5MzI3NzE0NS44LjEuMTY5MzI3NzE0OC41Ny4wLjA.
[6]: https://docs.docker.com/docker-id/
[7]: https://docs.docker.com/docker-hub/access-tokens/
[8]: https://goharbor.io/
[9]: https://www.sonatype.com/products/sonatype-nexus-repository
[10]: https://jfrog.com/artifactory