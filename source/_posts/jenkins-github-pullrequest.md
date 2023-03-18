---
title: Jenkins构建GitHub合并请求(Pull Request)
tags:
  - DevOps
  - CI/CD
  - Jenkins
  - Git
  - Github
category_bar: true
categories:
  - ["Jenkins"]
order: 3
date: 2020-01-30 22:17:00
---


在我的文章["Git合并请求(pull/merge request)的本质"][1]中已经说明了合并请求(pull/merge request)在代码层面上实际是Git仓库中的一个特殊分支，它指向了私有分支和主分支临时合并后产生的合并提交(merge commit)。如果我们能够在这个合并请求(pull/merge request)被真正合并进主分支之前对它做一次构建，就能尽早发现私有分支上的代码是否有问题，从而将问题拦截在主分支之外，减少主分支上持续交付流水线的失败率。对合并请求(pull/merge request)的构建除了编译代码(必要时可增量编译)和单元测试外，还可以增加更多额外的检查，比如代码的静态扫描。业界把这个放在持续交付流水线之前的检查称为preflight流水线(可参考《Continuous Delivery》这本书第三章67页对preflight构建的详细介绍)。本文将介绍如何配置Jenkins和Github来构建Github合并请求(Pull Request)。
<!-- more -->

# 配置Jenkins

## 安装Github Pull Request Builder插件

1. 点击Jenkins -> Manage Jenkins -> Manage Plugins打开Plugin Manager页面

2. 打开Available页面，选择Github Pull Request Builder，点击Install without restart按钮
   ![](1.png)

3. 必要时重启Jenkins让插件生效

## 配置Github Pull Request Builder插件

1. 点击Jenkins -> Manage Jenkins -> Config System打开系统配置页面
   
2. 定位到”Github Pull Request Builder“插件，点击Add菜单打开创建Jenkins认证信息对话框
   ![](2.png)

3. 创建"Username with password"类型的凭证，用户名和密码是有足够权限的Github账号和密码
   ![](3.png)

4. 配置GitHub Server API URL，选择步骤3创建的凭证，可以点击"Connect to API"按钮测试基本连接
   ![](4.png)

   对于GitHub Server API URL的值，GitHub和GitHub Enterprise是有区别的：

    | GitHub Server     | API Endpoint                | 说明                                     |
    | ----------------- | --------------------------- | ----------------------------------------|
    | GitHub Enterprise | http(s)://[hostname]/api/v3 |                                         |
    | GitHub            | https://api.github.com      | Receive the v3 version of the REST API. |

5. 点击"Save"按钮保存配置

# 配置Github代码仓库

1. 打开Git仓库设置页面，点击Hooks -> Add webhook
   ![](5.png)

2. 输入Palyload URL(`http://jenkins-url/github-webhook/`)，选择Content Type为application/json
   ![](6.png)

3. 选择"Let me select individual envents"自定义webhook触发事件
   ![](7.png)

4. 只选择"Pull requests"事件，并点击"Add webhook"保存Webhook
   ![](8.png)

# 创建Jenkins pipeline job用来构建合并请求(pull/merge request)

## Jenkinsfile

```groovy
pipeline {
    agent {
        label 'common'
    }
    environment {
        GITHUB_URL = "http://xxx.github.xxxx.com"
        GITHUB_ORG = "MikeSay"
        GITHUB_REPO = "mikesay-test-1"
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
                                        [$class: 'GitSCM', branches: [[name: "${ghprbActualCommit}"]], 
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
                                                    refspec: '+refs/pull/*:refs/remotes/origin/pr/*', 
                                                    url: "${GITHUB_URL}/${GITHUB_ORG}/${GITHUB_REPO}.git"
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
                        cat README.md
                    '''
                }
            }
        }


    }
    post {
        always {
            junit allowEmptyResults: true, testResults: 'codes/build/test-results/test/**/*.xml'
            // send to email
            emailext(
                subject: '$DEFAULT_SUBJECT',
                body: '$DEFAULT_CONTENT',
                recipientProviders: [
                [$class: 'CulpritsRecipientProvider'],
                [$class: 'RequesterRecipientProvider'],
                [$class : 'DevelopersRecipientProvider']
                ],
                replyTo: '$DEFAULT_REPLYTO',
                to: '$DEFAULT_RECIPIENTS'
            )
        }
    }
}
```

30行: 添加refspec获取合并请求(pull/merge request)的分支信息
```groovy
refspec: '+refs/pull/*:refs/remotes/origin/pr/*'
```
19行: branches选择环境变量"ghprbActualCommit"，它是合并请求(pull/merge request)分支对应的提交号
```groovy 
[$class: 'GitSCM', branches: [[name: "${ghprbActualCommit}"]]
``` 
除了"ghprbActualCommit"外，github pull request builder插件还往当前构建中注入了许多变量供构建Job使用，如下表：

| 变量                  | 事例值                                                    | 说明                                                                                   |
| --------------------- | --------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| sha1                  | origin/pr/6/merge                                         | 合并请求(pull/merge request)分支。在构建Job中也可以用${sha1}来代替${ghprbActualCommit} |
| ghprbAuthorRepoGitUrl | http://xxxx.github.xxxx.com/MikeSay/mikesay-test-1.git    | 合并请求(pull/merge request)所在仓库的http地址                                         |
| ghprbPullId           | 6                                                         | 合并请求(pull/merge request)的ID号                                                     |
| ghprbTargetBranch     | master                                                    | 合并请求(pull/merge request)的主分支                                                   |
| ghprbSourceBranch     | test9                                                     | 合并请求(pull/merge request)的私有分支                                                 |
| ghprbPullTitle        | Test9.                                                    | 合并请求(pull/merge request)的标题                                                     |
| ghprbPullLink         | http://xxxx.github.xxxx.com/MikeSay/mikesay-test-1/pull/6 | 合并请求(pull/merge request)的http地址                                                 |

可以从当前合并请求(pull/merge request)的构建参数中获得所有变量名和当前值：
![](16.png)

## 创建Jenkins job引用Jenkinsfile

1. 点击"New Item"
   
2. 选择Job类型为"Pipeline"，输入Job的名字"github-preflight"，点击"Ok"按钮
   ![](9.png)

3. 在"GitHub Project"段，输入"Project url"。注，"Project url"是Git仓库的http地址去除".git"后缀
   ![](10.png)

4. 在"Build Triggers"段，选择"GitHub Pull Request Builder"
   ![](11.png)

   + GitHub API credentials: 之前配置的GitHub API
   + Trigger phrase: 在合并请求(pull/merge request)的注释或标题里加入trigger phrase内容会自动触发新的构建
   + Skip build phrase: 在合并请求(pull/merge request)的注释或标题里加入skip build phrase内容则不会触发构建

5. 如果需要构建每个合并请求(pull/merge request)，勾选"Build every pull request automatically without asking (Dangerous)"，在"Whitelist Target Branches"输入主分支"master"
   ![](12.png)

6. 在"Pipeline"段，引用Jenkinsfile
   ![](13.png)

# 创建合并请求(pull/merge request)触发构建

1. Github的合并请求(pull/merge request)
   ![](14.png)

2. 触发的构建
   ![](15.png)

[1]: http://www.mikesay.com/2020/01/29/pullrequest-essential/