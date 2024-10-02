---
title: Git合并请求(Pull/Merge request)的本质
toc: true
tags:
  - DevOps
  - Git
  - Github
  - Gitlab
  - Bitbucket
  - TFS Git
date: 2020-01-29 22:37:10
---


Git以及基于Git的各代码开发协作平台，比如Github, Gitlab, Bitbucket, TFS Git等正逐渐成为首选的代码版本管理工具，而基于Git的基本开发流程则是开发者创建个人的私有分支并在个人的私有分支上提交代码，代码完成后创建合并请求(pull/merge request)到主分支让相关人员做代码评审，评审通过后将合并请求(pull/merge request)合并到主分支上。合并请求(pull/merge request)不是Git本身的特性，而是各代码协作平台提供的特性，它提供的代码评审功能几乎取代了独立的代码评审工具，同时它也方便了分布于世界各地的开源代码贡献者合并自己的代码。那么合并请求(pull/merge request)到底是什么东西？它看的见摸得着吗？本文将通过目前比较流行的代码开发协作平台(Github, Gitlab, Bitbucket, TFS Git)对合并请求(pull/merget request)的实现来阐明合并请求(pull/merge request)的本质。<!-- more -->

实际上，合并请求(pull/merge request)在代码层面上是Git仓库中的一个特殊分支。当开发在代码协作平台上创建并提交合并请求(pull/merge request)后，代码协作平台在服务器端将私有分支和主分支临时合并产生一个合并提交(merge commit)，同时创建一个特殊分支指向这个合并提交(merge commit)。如果临时合并出现冲突，则在Web层面显示有冲突，需要开发提交新的代码到个人分支以消除冲突。

要真正的理解合并请求(pull/merge request)这一特殊分支，我们需要先理解下Git的分支。

# Git分支

相对于传统的版本管理工具创建分支的操作，Git的分支方式及其轻巧，分支操作几乎是实时的，并且在分支之前切换也非常快。许多人认为Git这一分支模式算得上是一个“杀手级”功能。下图描述了一个含有三个文件的文件夹，且只有一个提交的Git仓库：

![](1.png)

在Git中，数据是以树形结构存储，每个文件对应着一个blob对象，每个文件夹对应着一个tree对象。每一次Git提交(commit)，都会根据文件或路径的变化创建一系列新的blog对象或tree对象，checksum不变的对象会被重复引用，其中最顶层的tree对象由于每次都需要变化，所以每次都会创建新的顶层tree对象，同时会创建一个commit对象指向新的顶层tree对象，整个过程犹如给数据做了个快照，而当前的commit对象则是这个快照的标签。如果要获取这个快照对应的代码，只要git checkout到这个commit对象即可。

当再次提交时，新创建的commit对象会保存一个指针指向前面的一个commit对象形成一个提交链(快照链)。下图就是Git仓库中的一个提交链：

![](2.png)

而Git中的分支则是一个轻量的可移动的指针指向其中一个commit对象。缺省的分支名字叫master，每一次新的提交master分支都会移动并指向到最新的commit对象。下图是Git中的分支和提交历史：

![](3.png)

HEAD对象是指针的指针，它指向当前所在的分支。切换分支时，只要将HEAD指向新的分支即可，所以说Git切换分支的操作是相当轻量的。

所以正如前文所说，合并请求(pull/merge request)也是个分支，也就是指针，它是指向私有分支和主分支临时合并后产生的合并提交(commit)对象。下图是Git中的合并请求(pull/merge request)分支：

![](4.png)

如图"defect235"分支是为了修复defect235而创建的私有分支，commit"f40ac"是代码协作平台临时合并分支"defect235"和"master"而创建的合并提交对象，分支"refs/pull/1/merge"则是那个特殊的分支，指向合并提交对象"f40ac"。不过,常规的Git克隆或者拉取是无法获取这个分支信息的，因为常规Git只会认为在缺省路径“refs/heads/"下的分支是Git分支。当开发在Web界面中合并合并请求(pull/merge request)后，私有分支"defect235"和特殊的分支也会被删除掉(通常代码协作平台会提供一些设置来控制是否要删除私有分支和合并请求分支)。下图是Git中合并请求被合并后的分支情况：

![](5.png)

不同的代码协作平台在实现合并请求(pull/merget request)的原理上是相同的，但是也有一些细微的差别。

# GitHub合并请求(Pull Request)

+ 配置本地Git仓库使得每次执行Git拉取操作都能得到最新合并请求(pull request)的信息
  ```sh
  git config --add remote.origin.fetch +refs/pull/*:refs/remotes/origin/pr/*
  git pull --rebase
  git branch -a

  add_test
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/add_test
  remotes/origin/master
  remotes/origin/pr/1/head
  remotes/origin/pr/1/merge

  git checkout  -b pr/1 origin/pr/1/merge
  ```
  origin/pr/1/head: 指向当前合并请求(pull request)中的私有分支
  origin/pr/1/merge: 指向临时合并的提交对象

+ 仅拉取某个合并请求(pull request)的信息
  ```sh
  git fetch origin +refs/pull/1/*:refs/remotes/origin/pr/1/*
  git checkout  -b pr/1 origin/pr/1/merge
  ```
  
# GitLab合并请求(Merge Request)

+ 配置本地Git仓库使得每次执行Git拉取操作都能得到最新合并请求(merge request)的信息
  ```sh
  git config --add remote.origin.fetch +refs/merge-requests/*:refs/remotes/origin/mr/*
  git pull --rebase
  git branch -a

  change2
  change_readme
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/change2
  remotes/origin/change_readme
  remotes/origin/master
  remotes/origin/mr/1/head
  remotes/origin/mr/2/head

  git checkout -b mr/2 origin/mr/2/head
  ```
  origin/mr/1/head: 指向临时合并的提交对象

+ 仅拉取某个合并请求(pull request)的信息
  ```sh
  git fetch origin +refs/merge-requests/2/*:refs/remotes/origin/mr/2/*
  git checkout -b mr/2 origin/mr/2/head
  ```
  
# Bitbuckt合并请求(pull Request)

+ 配置本地Git仓库使得每次执行Git拉取操作都能得到最新合并请求(pull request)的信息
  ```sh
  git config --add remote.origin.fetch +refs/pull-requests/*:refs/remotes/origin/pr/*
  git pull --rebase
  git branch -a

  fix_defect1
* master
  remotes/origin/fix_defect1
  remotes/origin/master
  remotes/origin/pr/1/from
  remotes/origin/pr/1/merge

  git checkout -b pr/1 origin/pr/1/merge
  ```
  origin/pr/1/from: 指向当前合并请求(pull request)中的私有分支
  origin/pr/1/merge: 指向临时合并的提交对象

+ 仅拉取某个合并请求(pull request)的信息
  ```sh
  git fetch origin +refs/pull-requests/1/*:refs/remotes/origin/pr/1/*
  git checkout -b pr/1 origin/pr/1/merge
  ```
  
# TFS Git合并请求(pull Request)

  + 配置本地Git仓库使得每次执行Git拉取操作都能得到最新合并请求(pull request)的信息
  ```sh
  git config --add remote.origin.fetch +refs/pull/*:refs/remotes/origin/pr/*
  git pull --rebase
  git branch -a

  fix_defect1
* master
  remotes/origin/fix_defect1
  remotes/origin/master
  remotes/origin/pr/1/merge

  git checkout -b pr/1 origin/pr/1/merge
  ```

  origin/pr/1/merge: 指向临时合并的提交对象

+ 仅拉取某个合并请求(pull request)的信息
  ```sh
  git fetch origin +refs/pull/1/*:refs/remotes/origin/pr/1/*
  git checkout -b pr/1 origin/pr/1/merge
  ```

当然，除了上面四个基于Git的代码协作平台外，还有许多优秀的平台，比如国内的码云[https://gitee.com/][1]，各大公有云平台也都提供了自己的代码协作平台。读者可以根据本文的说明自行研究合并请求(pull/merge request)。

[1]: https://gitee.com/