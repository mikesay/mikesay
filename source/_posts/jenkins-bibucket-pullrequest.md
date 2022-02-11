---
title: Jenkins构建Bitbucket合并请求(Pull Request)
tags:
  - DevOps
  - CI/CD
  - Jenkins
  - Git
  - Bitbucket
date: 2020-02-23 18:46:00
---


在["Jenkins随笔(3)  Jenkins构建Github合并请求(Pull Request)"][1]中介绍了用Jenkins构建Github合并请求(Pull Request)的方法以及preflight流水线的意义。本文将继续介绍如何配置Jenkins和Bitbucket来构建Bitbucket合并请求(Pull Request)。
<!-- more -->
Bitbucket官网提供了以下两种方法来配置Jenkins构建Bitbucket合并请求(Pull Request):

1. Jenkins [Git插件][8]结合Bitbucket插件[Webhook to Jenkins for Bitbucket][9]
2. Jenkins [Bitbucket Branch Source][2]插件
  
方法1中的Bitbucket插件Webhook to Jenkins for Bitbucket是商业版的，需要收费，个人觉得不值得，也没有尝试。方法2中的Jenkins Bitbucket Branch Source插件适合于Jenkins多分支流水线， 也不是本文讨论的范围。除此之外，Jenkins还有这三个插件可用：

+ Jenkins [Bitbucket Pullrequest Builder][3]插件
+ Jenkins [Bitbucket][4]插件
+ Jenkins [Bitbucket Push and Pull Request][5]插件

Bitbucket Pullrequest Builder插件有一些严重的问题[(https://plugins.jenkins.io/bitbucket-pullrequest-builder/)][10]，所以不能采用。Bitbucket插件是目前网上大部分文章讨论用到的插件，但是测试下来发现个问题，即提交代码到现有的合并请求(Pull Request)不会触发新的合并请求(Pull Request)的构建，这个问题首先是Bitbucket Webhook并没有提供一个这样的事件([网上也有类似的讨论][12])，其次Bitbucket插件也没有提供足够的灵活性方便解决它。最终测试下来觉得Bitbucket Push and Pull Request插件可以使用，首先它是从Bitbucket插件继承过来的，包含了Bitbucket插件的所有功能，其次通过使用Bitbucket Push and Pull Request插件，可以配置一个临时的方法解决我们发现的Bitbucket插件和Bitbucket Webhook的问题。下面将详细介绍利用Jenkins Bitbucket Push and Pull Request插件来构建Bitbucket合并请求(Pull Request)。

# 配置Jenkins

## 安装Bitbucket Push and Pull Request插件

1. 点击Jenkins -> Manage Jenkins -> Manage Plugins打开Plugin Manager页面

2. 打开Available页面，选择Github Pull Request Builder，点击Install without restart按钮
   ![](1.png)

3. 必要时重启Jenkins让插件生效

安装完插件后，生成的Web hook url地址为`http://<jenkins url>/bitbucket-hook/`。

# 配置Bitbucket代码仓库

1. 点击"Repository settings" -> "Webhooks"打开Webhooks创建页面
   ![](2.png)

2. 点击"Create webhook"按钮打开添加Webhook页面
   ![](3.png)

添加以下的信息后点击保存按钮创建新的Webhook:
+ URL: 设置为Bitbucket Push and Pull Request插件生成的Web hook url地址：`http://<jenkins url>/bitbucket-hook/`
+ Pull request事件: 选择"Opened"和"Modified"
+ Repository事件: 选择"Push"
  > 这里选择Push事件是为了解决文章开头提到的Bitbucket插件和Bitbucket Webhook的问题，即提交代码到已有的合并请求(Pull Request)不会触发新的合并请求(Pull Request)的构建。

# 创建Jenkins pipeline job用来构建合并请求(pull/merge request)

## Jenkinsfile

```groovy
pipeline {
    agent {
        label 'common'
    }
    triggers {
        bitBucketTrigger(
            [
                [
                    $class: 'BitBucketPPRPullRequestServerTriggerFilter',
                    actionFilter: [$class: 'BitBucketPPRPullRequestServerCreatedActionFilter', allowedBranches: '']
                ], 
                [
                    $class: 'BitBucketPPRPullRequestServerTriggerFilter', 
                    actionFilter: [$class: 'BitBucketPPRPullRequestServerUpdatedActionFilter', allowedBranches: '']
                ],
                [
                    $class: 'BitBucketPPRRepositoryTriggerFilter', 
                    actionFilter: [
                                    $class: 'BitBucketPPRServerRepositoryPushActionFilter', 
                                    allowedBranches: '', 
                                    triggerAlsoIfNothingChanged: true, 
                                    triggerAlsoIfTagPush: false
                                ]
                ]
            ]
        )
    }
    environment {
        BITBUCKET_URL = "http://130.147.249.221:7990"
        BITBUCKET_ORG = "miks"
        BITBUCKET_REPO = "mikesay-test-1"
    }
    options {
        skipDefaultCheckout()
        ansiColor('xterm')
    }
    stages {
        stage('Checkout') {
            steps {
                script{
                    def scmVars =   checkout(
                                        [$class: 'GitSCM', branches: [[name: "origin/pr/*/merge"]], 
                                        doGenerateSubmoduleConfigurations: false,
                                        submoduleCfg: [], 
                                        extensions: [
                                            [$class: 'RelativeTargetDirectory', relativeTargetDir: 'codes'],
                                            [$class: 'CleanBeforeCheckout']
                                        ],
                                        userRemoteConfigs: [
                                                [
                                                    credentialsId: 'ghe_account', 
                                                    name: 'origin', 
                                                    refspec: '+refs/pull-requests/*:refs/remotes/origin/pr/*', 
                                                    url: "${BITBUCKET_URL}/scm/${BITBUCKET_ORG}/${BITBUCKET_REPO}.git"
                                                ]
                                            ]
                                        ]
                                    )
                    env.GIT_BRANCH = "${scmVars.GIT_BRANCH}"
                    env.GIT_COMMIT = "${scmVars.GIT_COMMIT}"
                }
            }
        }
        stage('Build') {
            steps {
                dir('codes') {
                    sh '''#!/bin/bash -l
                        echo "Start building!"
                    '''
                }
            }
        }
    }
}
```

8行-24行: 配置Job触发事件，分别是合并请求(Pull Request)的创建(Create)，更新(Update)事件，以及Git仓库的推送(Push)事件，同时设置"triggerAlsoIfNothingChanged"的值为true。勾选Git仓库的推送(Push)事件和设置"triggerAlsoIfNothingChanged"的值为true是为了过滤前面Webhook中设置的Git仓库的推送(Push)事件，这样当有新的提交推送到合并请求(Pull Request)后，Job也能被触发。

53行：设置拉取合并请求(Pull Request)的配置。可以参考之前的文章["Git随笔(1) Git合并请求(pull/merge request)的本质"][11]。

42行：构建分支设置为```origin/pr/*/merge```，这样可以构建所有合并请求(Pull Request)对应的分支。Bitbucket Push and Pull Request插件在触发构建时会传递一个环境变量"BITBUCKET_PULL_REQUEST_ID"到构建Job中，这个环境变量的值就是合并请求(Pull Request)的ID号。利用这个环境变量可以将构建分支设置的更精确一点，比如```origin/pr/${BITBUCKET_PULL_REQUEST_ID}/merge```，但只有合并请求(Pull Request)的创建，关闭和重新打开的事件触发的构建Job才会传递这个变量，所以不怎么通用。
> 将构建分支设置为通用的合并请求(Pull Request)分支也带来了个缺陷，就是当构建Job创建好后，必须手动触发多次以获取所有未完成的合并请求(Pull Request)分支的信息以便后续合并请求(Pull Request)有更新时，能够触发正确的构建。

## 创建Jenkins job引用Jenkinsfile

1. 点击"New Item"
   
2. 选择Job类型为"Pipeline"，输入Job的名字，比如"bitbucket-preflight"，点击"Ok"按钮
   ![](4.png)

3. 在"Pipeline"段，引用Jenkinsfile(Jenkinsfile是单独放在一个独立的Git仓库中的)
   ![](5.png)

4. 点击"Save"按钮保存Jenkins Job

5. 手动触发Jenkins Job多次以获取所有未完成的合并请求(Pull Request)分支的信息。如果目前没有未完成的合并请求(Pull Request)，也需要手动触发Job一次让Jenkinsfile中设置的触发规则配置到job中。
   ![](6.png)

# 创建合并请求(pull/merge request)触发构建

1. Bitbucket的合并请求(pull/merge request)
   ![](7.png)

2. 触发的构建
   ![](8.png)

细心的读者可能发现，和Github合并请求(Pull Request)的构建相比少了很多有用的信息，比如构建描述中没有显示合并请求(Pull Request)号，不太容易知道当前的构建是由哪个合并请求(Pull Request)触发的，而在合并请求(Pull Request)的页面中也看不到当前构建的状态。这些都是由Jenkins插件提供的功能多少决定的，对于Bitbucket合并请求(Pull Request)的构建，我们需要更多的自定义工作以提供足够多的信息，比如从当前构建中获取合并请求(Pull Request)分支，提取出合并请求(Pull Request)号并且设置到构建描述中。

[1]: http://www.mikesay.com/2020/01/30/jenkins-github-pullrequest/
[2]: https://plugins.jenkins.io/cloudbees-bitbucket-branch-source/
[3]: https://plugins.jenkins.io/bitbucket-pullrequest-builder/
[4]: https://plugins.jenkins.io/bitbucket/
[5]: https://plugins.jenkins.io/bitbucket-push-and-pull-request/
[6]: https://mohamicorp.atlassian.net/wiki/spaces/DOC/pages/381288449/Configuring+Webhook+To+Jenkins+for+Bitbucket+Git+Plugin
[7]: https://mohamicorp.atlassian.net/wiki/spaces/DOC/pages/381419546/Configuring+Webhook+To+Jenkins+for+Bitbucket+Bitbucket+Branch+Source+Plugin
[8]: https://plugins.jenkins.io/git/
[9]: https://marketplace.atlassian.com/apps/1211284/webhook-to-jenkins-for-bitbucket/version-history
[10]: https://plugins.jenkins.io/bitbucket-pullrequest-builder/
[11]: http://www.mikesay.com/2020/01/29/pullrequest-essential/
[12]: https://community.atlassian.com/t5/Bitbucket-questions/How-to-trigger-a-webhook-when-a-commit-is-pushed-to-an-open-pull/qaq-p/1029556