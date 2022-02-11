---
title: 从Git仓库中永久清理脏数据
tags:
  - Git
date: 2020-09-26 09:37:00
---

在代码开发的过程中，有时会将不该提交的文件误提交到Git仓库中，比如编译产生的临时二进制文件（忘了添加.gitignore），或者包含账号，密码等敏感信息的文件。临时的二进制文件放在Git仓库中没有意义，而且如果频繁改动的话，也会导致Git仓库逐渐变大，而敏感信息会导致信息泄露且不符合信息安全标准。这些不该提交的文件或内容被称为Git仓库的脏数据，需要被清理掉。重新提交一个新的变更来清理这些脏数据是远远不够的，因为从历史版本中仍然能够找到它们。本文将介绍如何使用开源工具[BFG Repo-Cleaner][1]从Git仓库的变更历史中永久清除这些脏数据。
<!-- more -->
如果不借助第三方工具，要实现从Git仓库中永久清理脏数据，就需要使用Git的高级命令["git-filter-branch"][2]重写历史记录。"git-filter-branch"功能强大，但也相对较复杂，所以就出现了第三方的开源工具封装"git-filter-branch"并提供简单易用的接口，[BFG Repo-Cleaner][1]就是其中比较出色的一个。仅管[BFG Repo-Cleaner][1]没有"git-filter-branch"的功能强大，但是它相对简洁、高效，并且基本上能满足日常大部分的需求。

# 安装BFG Repo-Cleaner

+ 从[官网][1]中下载BFG Repo-Cleaner(jar file)到某个路径下，并命名为bfg.jar

+ 执行以下命令创建BFG Repo-Cleaner命令的别名，或者将下面的命令添加到shell的初始化文件中，以便自动添加这个命令的别名
  ```bash
    alias bfg='java -jar /xxxx/bfg.jar'
  ```
  
# 使用BFG Repo-Cleaner

BFG Repo-Cleaner主要有以下两种类型的应用：
+ 替换文件中的敏感信息
+ 删除文件或文件夹

可以执行命令获取BFG Repo-Cleaner的帮助信息：
```bash
bfg --help
```

BFG Repo-Cleaner缺省不会清理最新版本代码里的脏数据，因为你的最新代码可能已经部署到生产环境，而且可能会依赖于这些已经存在的敏感信息或文件，所以你需要手动地清理这些敏感信息或文件并修复代码运行时可能存在的错误。如果你确认清理最新版本代码里的脏数据对代码运行不会产生影响，则可以在命令中显式地加上参数“--no-blob-protection”。

## 替换文件中的敏感信息

这个操作主要是把文件中的敏感信息用指定的文本替换掉。比如文件中包含password=123456，我们需要用文本"\*\*\*hidden\*\*\*"去替换"123456"。

### 准备工作

+ 通过mirror的方式克隆代码仓库

  ```bash
  git clone --mirror https://github.com/xxxx/test-history-clean.git
  ```

+ 创建文本替换文件（例如replace-text.txt）
  如果使用BFG缺省的替换文本"\*\*\*REMOVED\*\*\*"，文本替换文件中只需要列出需要替换的敏感信息的文本，一行一个，比如：
  ```txt
  123456
  89fsafaaf
  ```

  如果需要使用自定义的替换文本，文本替换文件的格式如下：
  ```txt
  regex:xxxx==>yyyy
  ```
  或者：
  ```txt
  glob:xxxx==>yyyy
  ```

  比如：
  ```txt
  regex:123.*==>***hidden***
  regex:test123==>***hidden***
  ```
  或者：
  ```txt
  glob:123*==>***hidden***
  ```

  > Regex和Glob的区别可以参考https://www.linuxjournal.com/content/globbing-and-regex-so-similar-so-different

### 常用的敏感信息替换操作

{% note warning %}
在执行bfg命令前，请先确保最新代码里的敏感信息已经被替换（手工提交一个新的Git提交），否则在执行bfg命令时需要显式地加上参数“--no-blob-protection”以确保最新代码里的敏感信息也会被替换。
{% endnote %}

+ 替换所有文件中的指定的敏感信息
  ```bash
  bfg -rt replace-text.txt test-history-clean.git
  cd test-history-clean.git
  git reflog expire --expire=now --all && git gc --prune=now --aggressive
  git push --force
  ```
  > 需要打开强制推送到Git仓库的功能

+ 替换指定文件中的敏感信息

  ```bash
  bfg -rt replace-text.txt -fi test3.txt test-history-clean.git
  cd test-history-clean.git
  git reflog expire --expire=now --all && git gc --prune=now --aggressive
  git push --force
  ```
  > bfg不能指定具体文件的路径
  > -fi参数可以通过过glob语法指定某一类文件，比如*.{txt,properties}

+ 替换除了指定的文件外的所有文件中的敏感信息

  ```bash
  bfg -rt replace-text.txt -fe test3.txt test-history-clean.git
  cd test-history-clean.git
  git reflog expire --expire=now --all && git gc --prune=now --aggressive
  git push --force
  ```
  > bfg不能指定具体文件的路径
  > -fe参数可以通过过glob语法指定某一类文件，比如*.{txt,properties}


## 删除文件或文件夹

如果Git仓库中不小心提交了比较大的文件，或者整个文件夹，可以通过下面的操作从变更历史中把他们清理掉。

{% note warning %}
在执行bfg命令前，请先确保最新代码里的文件或文件夹已经被删除（手工提交一个新的Git提交），否则在执行bfg命令时需要显式地加上参数“--no-blob-protection”以确保最新代码里的文件或文件夹也会被删除。
{% endnote %}

### 删除文件名为“test3.tar.gz”的文件

```bash
bfg -D test3.tar.gz test-history-clean.git
cd test-history-clean.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### 删除某一类文件

BFG Repo-Cleaner的-D参数可以通过glob格式指定某一类型的文件，例如删除后缀为dll或bin的文件：
```bash
bfg -D *{dll,bin} test-history-clean.git
cd test-history-clean.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### 从变更历史中精确地删除某个文件

BFG Repo-Cleaner可以删除某个blob（git仓库的变更历史中存储的文件称为blob），而参数-bi(--strip-blobs-with-ids)可以用来指定待删除的blob id号。

+ 获取指定文件在所有变更历史中对应的blob id号

```bash
git log --all --pretty=format:%H -- a/b/c/test1.txt  | xargs -n 1 -I {} sh -c "git ls-tree  {} a/b/c/test1.txt" | awk '{print $3}' > blob-ids.txt
```

+ 从变更历史中删除指定的文件(Blob)

```bash
bfg -bi blob-ids.txt test-history-clean.git
cd test-history-clean.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### 删除超过某个大小的文件

```bash
bfg -b 500M test-history-clean.git
cd test-history-clean.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### 删除前几个最大的文件

```bash
bfg -B 5 test-history-clean.git
cd test-history-clean.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### 删除某个文件夹

```bash
bfg --delete-folders .svn test-history-clean.git
cd test-history-clean.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

> 可以通过glob格式指定一类文件夹，例如*-tmp。



[1]: https://rtyley.github.io/bfg-repo-cleaner
[2]: https://git-scm.com/docs/git-filter-branch