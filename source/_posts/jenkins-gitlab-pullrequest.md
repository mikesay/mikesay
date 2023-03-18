---
title: Jenkins构建GitLab合并请求(Merge Request)
tags:
  - DevOps
  - CI/CD
  - Jenkins
  - Git
  - GitLab
category_bar: true
categories:
  - ["Jenkins"]
order: 4
date: 2020-03-09 18:00:00
---


写了两篇这样的文章，我们大概可以总结出Jenkins构建合并请求(Merge Request)的原理：首先，需要在Jenkins上安装一个插件以便提供一个Webhook接口，配置插件连通对应的代码协作平台以便将构建状态写回代码协作平台(并不是所有的插件都提供这个功能)；其次，在对应的Git仓库中设置Webhook监听Git事件，比如合并请求(Merge Request)的创建、编辑等。当有监听的事件发生时，Webhook触发Jenkins的Webhook接口，Webhook接口解析请求数据，创建一些有用的环境变量，比如合并请求(Merge Request)ID，合并请求(Merge Request)的原分支和目标分支等，并触发对应的Jenkins pipeline；最后，创建一个Jenkins pipeline(目前主要是Pipeline2.0的Jenkinsfile)，设置被触发的条件和如何克隆对应的代码，以及实际的构建逻辑。接前面的系列，本文将继续介绍如何配置Jenkins和GitLab来构建GitLab合并请求(Merge Request)。
<!-- more -->

GitLab[官方文档][1]有写到用Jenkins去构建GitLab中的代码，但是用到了"Jenkins CI"这个项目服务，而这个服务在GitLab免费版本(社区版)中并没有提供，所以不去过多的讨论此方法。下面将利用Jenkins的[Git插件][2]和[GitLab插件][3]去实现Jenkins构建GitLab的合并请求(Merge Request)。

# 配置Jenkins

## 安装GitLab插件(如果Git插件不存在，会作为GitLab插件的依赖被安装)

1. 点击Jenkins -> Manage Jenkins -> Manage Plugins打开Plugin Manager页面

2. 打开Available页面，选择GitLab插件，点击Install without restart按钮

   ![](1.png)

3. 必要时重启Jenkins让插件生效

安装完插件后，生成的Web hook url地址为`https://JENKINS_URL/project/YOUR_JOB`。

## 创建Gitlab Personal Access Token

1. 点击Settings打开用户设置页面，并点击Access Tokens打开创建Personal Access Token页面
   
   ![](3.png)

2. 在Name字段填上Token的名字，在Scope字段选上需要的权限，api的权限应该足够了。如果需要设置有效期限，可以设置Expires at字段，否则Token永不过期

3. 点击Create personal access token按钮创建Token。注意，需要立即复制这个Token值，否则页面刷新后就会被隐藏掉

## 配置Jenkins Gitlab插件

1. 点击Jenkins -> Manage Jenkins -> Config System打开系统配置页面
   
2. 定位到”GitLab“段落，点击Add菜单打开创建Jenkins认证信息对话框
   ![](2.png)

3. 选择"GitLab API Token"类型的凭证，在API token字段里输入前面创建的Gitlab Personal Access Token，设置Token的ID和描述
   ![](4.png)

4. 设置Gitlab详细的连接信息
   ![](5.png)

   设置Connection name，Gitlab host URL，选择刚刚创建的GitLab API Token，连接和读取超时可以稍微设大一点。可以点击Test Connection测试是否能连通。

5. 点击"Save"按钮保存配置

# 创建Jenkins pipeline job用来构建合并请求(Merge Request)

## Jenkinsfile

```groovy
pipeline {
    agent {
        label 'common'
    }
    triggers {
        gitlab(
            triggerOnPush: false,
            triggerOnMergeRequest: true,
            triggerOpenMergeRequestOnPush: "source",
            triggerOnNoteRequest: true,
            noteRegex: ".*\\[run\\W+ci\\].*",
            skipWorkInProgressMergeRequest: true,
            ciSkip: true,
            setBuildDescription: true,
            addNoteOnMergeRequest: true,
            addCiMessage: true,
            addVoteOnMergeRequest: true,
            acceptMergeRequestOnSuccess: false,
            branchFilterType: "NameBasedFilter",
            includeBranchesSpec: "master",
            excludeBranchesSpec: ""
        )
    }
    environment {
        GITLAB_URL = "http://mygitlab.philips.com"
        GITLAB_ORG = "mikesay"
        GITLAB_REPO = "mikesay-test-1"
    }
    options {
        skipDefaultCheckout()
        ansiColor('xterm')
        gitLabConnection 'mygitlab'
    }
    stages {
        stage('Checkout') {
            steps {
                script{
                    def scmVars =   checkout(
                                        [$class: 'GitSCM', branches: [[name: "origin/mr/${gitlabMergeRequestId}/head"]], 
                                        doGenerateSubmoduleConfigurations: false,
                                        submoduleCfg: [], 
                                        extensions: [
                                            [$class: 'RelativeTargetDirectory', relativeTargetDir: 'codes'],
                                            [$class: 'CleanBeforeCheckout']
                                        ],
                                        userRemoteConfigs: [
                                                [
                                                    credentialsId: 'gitlab_account', 
                                                    name: 'origin', 
                                                    refspec: '+refs/heads/*:refs/remotes/origin/* +refs/merge-requests/*:refs/remotes/origin/mr/*', 
                                                    url: "${GITLAB_URL}/${GITLAB_ORG}/${GITLAB_REPO}.git"
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
    post {
      failure {
        updateGitlabCommitStatus name: 'build', state: 'failed'
      }
      success {
        updateGitlabCommitStatus name: 'build', state: 'success'
      }
    }
}
```

1. 6行-22行设置GitLab触发器，主要设置如下：

   | 变量                                                       | 事例值                                                                                                                   |
   | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
   | triggerOnPush                                              | 任何推送事件都会触发构建。因为是用来构建合并请求(Merge Request)，只需要监听合并请求(Merge Request)事件，所以不需要打开。 |
   | triggerOnMergeRequest                                      | 设置合并请求(Merge Request)事件触发构建，需要打开。                                                                      |
   | triggerOpenMergeRequestOnPush                              | 当合并请求(Merge Request)的原分支有新的推送触发构建，需要打开。                                                          |
   | triggerOnNoteRequest                                       | 合并请求(Merge Request)的评论有更新时触发构建，需要打开，并且配合noteRegex设置具体的触发构建的字符串。                   |
   | ciSkip                                                     | 当合并请求(Merge Request)的评论包括字符串"[ci-skip]"时，不会构建这个合并请求(Merge Request)。                            |
   | branchFilterType, includeBranchesSpec, excludeBranchesSpec | 设置哪些分支上的合并请求(Merge Request)会触发构建。                                                                      |

2. 50行: 添加refspec获取合并请求(merge request)的分支信息

    ```groovy
    refspec: '+refs/merge-requests/*:refs/remotes/origin/mr/*'
    ```

3. 39行: branches选择"origin/mr/${gitlabMergeRequestId}/head", 是合并后的分支。环境变量"gitlabMergeRequestId"是合并请求(merge request)的ID号

    ```groovy 
    [$class: 'GitSCM', branches: [[name: "origin/mr/${gitlabMergeRequestId}/head"]]
    ```

除了"gitlabMergeRequestId"外，Gitlab插件还往当前构建中注入了许多变量供构建Job使用：

```groovy
gitlabBranch
gitlabSourceBranch
gitlabActionType
gitlabUserName
gitlabUserUsername
gitlabUserEmail
gitlabSourceRepoHomepage
gitlabSourceRepoName
gitlabSourceNamespace
gitlabSourceRepoURL
gitlabSourceRepoSshUrl
gitlabSourceRepoHttpUrl
gitlabMergeRequestTitle
gitlabMergeRequestDescription
gitlabMergeRequestId
gitlabMergeRequestIid
gitlabMergeRequestState
gitlabMergedByUser
gitlabMergeRequestAssignee
gitlabMergeRequestLastCommit
gitlabMergeRequestTargetProjectId
gitlabTargetBranch
gitlabTargetRepoName
gitlabTargetNamespace
gitlabTargetRepoSshUrl
gitlabTargetRepoHttpUrl
gitlabBefore
gitlabAfter
gitlabTriggerPhrase
```

## 创建Jenkins job引用Jenkinsfile

1. 点击"New Item"
   
2. 选择Job类型为"Pipeline"，输入Job的名字，比如"gitlab-preflight"，点击"Ok"按钮
   ![](6.png)

3. 在"Pipeline"段，引用Jenkinsfile(Jenkinsfile是单独放在一个独立的Git仓库中的)
   ![](7.png)

4. 点击"Save"按钮保存Jenkins Job

5. 手动触发Job一次让Jenkinsfile中设置的触发规则配置到job中。
   ![](8.png)

# 配置Gitlab

## 创建Jenkins API token

1. 进入Jenkins用户设置页面
   ![](11.png)

2. 点击Add new Token，并点击Generate按钮产生当前用户的API Token，注意立即复制保存，因为页面刷新后，将被隐藏
   ![](12.png)

3. 点击Save按钮保存

## 创建Gitlab Web hook

1. 进入具体的项目页面，点击Settings -> Integrations打开创建Web hook的页面
   ![](13.png)

2. 设置Web hook详细信息
   ![](14.png)

在URL地址里输入Jenkins Gitlab插件生成的Web hook地址，包括Jenkins的认证信息，比如```https://<jenkins user>:<user's api token>@mykube.com/jenkins/project/gitlab-preflight```，选择"Comments"和"Merge request events"用来监听合并请求(merge request)事件，包括评论更新事件。

3. 点击Add webhook按钮添加Web hook

# 创建合并请求(merge request)触发构建

1. Gitlab的合并请求(merge request)
   ![](9.png)

2. 触发的构建
   ![](10.png)

从构建的描述来看，Jenkins Gitlab插件提供了比较全面的功能，显示了合并请求(merge request)的信息，同时在Gitlab的合并请求(merge request)页面也显示了构建的信息。


[1]: https://docs.gitlab.com/ee/integration/jenkins.html
[2]: https://plugins.jenkins.io/git/
[3]: https://plugins.jenkins.io/gitlab-plugin/
