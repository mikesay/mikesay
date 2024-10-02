---
title: Git安装与配置
toc: true
tags:
  - Git
date: 2020-12-31 08:22:00
---


[Git][1]是目前使用最广泛的分布式版本管理系统。相对于集中式代码管理系统，例如Subversion, Perforce等，来说，它有着无法比拟的优势，比如轻量级的分支管理，适合不同场景的分支合并策略，离线状态下的版本管理和变更历史查询等，而这些优势也正好符合了当前敏捷和精益的软件开发方法。本文将介绍如何在Linux，Mac和Windows系统中安装并配置Git。

<!-- more -->
# 安装Git
本文只介绍Git命令行的安装，因为使用命令行更能掌握Git的本质，且对于DevOps或系统维护人员来说，使用命令行也是日常的基本功。当掌握了Git命令行的使用后，再去使用图形化客户端，也会变得更容易。

## 在Mac中的安装
Mac Xcode自带了Git。如果你的Mac电脑上已经安装了Xcode，就已经有Git可以使用了，Git命令的安装路径为/usr/bin/git。但是这个Git不一定是比较新的版本，可以通过Homebrew或第三方提供的DMG安装包，重新安装一个比较新的版本。

+ 通过Homebrew安装

    ```sh
    brew install git
    ```
    Homebrew将Git安装在/usr/local/Cellar/git/2.29.2/路径下，同时会建立一个符号链接/usr/local/bin/git指向Git命令/usr/local/Cellar/git/2.29.2/bin/git。2.29.2是当前Homebrew支持的最新版本。
    > 在PATH环境变量中确保路径/usr/local/bin在/usr/bin之前，这样Homebrew安装的Git命令会被优先使用。

+ 通过DMG安装包安装

    可以从https://sourceforge.net/projects/git-osx-installer/ 下载较新的版本去安装。通过DMG安装的Git被安装在/usr/local/git下, 并且会在/usr/local/bin和/usr/share/man/中建立符号链接。
    
    可以通过下面的命令卸载Git.
    ```sh
    sudo /usr/local/git/uninstall.sh
    ```
  
{% note info %}
推荐用Homebrew的方式安装Git，不但能获得较新的版本，而且以后升级也方便。
{% endnote %}

## 在Linux中的安装
Linux系统也缺省自带了Git，不过一般不是最新的版本，但不影响使用。如果想安装最新版本或相对较新的版本的话，可以参照下面方法安装。

### 在Ubuntu中安装最新版本的Git

Ubuntu自带的Git是安装在路径/usr/bin/git下。在Ubuntu中，可以通过[PPA（Personal Package Archive）][2]安装最新版本的Git，安装完后会覆盖旧的版本。以下是安装步骤：

+ 添加Git的PPA库
    ```sh
    sudo add-apt-repository ppa:git-core/ppa
    ```

+ 更新APT缓存
    ```sh
    sudo apt update
    ```

+ 搜索最新版本的Git
    ```sh
    sudo apt-cache madison git
    ```

+ 安装Git
    ```sh
    sudo apt install git
    ```
  
{% note info %}
这里选择的是Ubuntu18。
{% endnote %}

### 在CentOS中安装最新版本的Git

CentOS 7自带的Git非常旧，还是1.x的版本，执行```rpm -qa | grep git```可以看到Git包为”git-1.8.3.1-23.el7_8.x86_64“，安装路径为/usr/bin/git。在CentOS中，可以通过Endpoint仓库安装最新版本的Git。以下是安装步骤：

+ 删除旧的Git
    ```sh
    sudo yum remove git*
    ```

+ 添加CentOS 7 Endpoint仓库
    ```sh
    sudo yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
    ```

+ 更新Yum缓存
    ```sh
    sudo yum update
    ```

+ 搜索最新版本的Git
    ```sh
    sudo yum list git
    ```

+ 安装Git
    ```sh
    sudo yum install git
    ```
  
{% note info %}
这里选择的是CentOS 7。
{% endnote %}

## 在Windows中的安装

从https://git-scm.com/download/win 下载最新版本的Windows安装包，并安装。

{% gi 8 4-4 %}
  {% asset_img 1.png %}
  {% asset_img 2.png %}
  {% asset_img 3.png %}
  {% asset_img 4.png %}
  {% asset_img 5.png %}
  {% asset_img 6.png %}
  {% asset_img 7.png %}
  {% asset_img 8.png %}
{% endgi %}

{% note info %}
尽量选择红色框里的选项，这样能最大限度地用Linux的方式使用Git命令。
{% endnote %}

# 配置Git

为了更好地使用Git命令行客户端，需要做一些必要的设置，有些设置是不同平台共享的，有些设置是平台独有的。

## 共享配置

+ 设置用户名和邮件地址

    ```sh
    git config --global user.name mikejianzhang
    git config --global user.email mikejianzhang@163.com
    ```

+ 设置引用路径为false

    ```sh
    git config --global core.quotepath false
    ```

    {% note info %}
    如果文件名或路径中含有非英文字符或者允许的控制字符，例如中文字符，反斜杠，双引号等，当不设置"core.quotepath"或者设置它的值为true时，Git命令在显示这些文件名或路径时会用双引号引用这些文件名或路径，并对这些字符进行转义显示，即对非英文字符用八进制格式显示UTF-8编码，而对控制字符则通过反斜杠进行转义，当设置"core.quotepath"为false时，则对非英文字符会显示原来的文本，但是对控制字符仍然会转义显示。  

    下面的两个文件名中既包含了中文字符又包含了控制字符，反斜杠和双引号。
    ```sh
    mikepro:git-test mike$ ls -l
    total 16
    -rw-r--r--  1 mike  staff  12 Jan  1 19:33 你好\上海 "大家们".txt
    -rw-r--r--  1 mike  staff  13 Jan  1 19:28 你好祖国.txt
    ```
    当不设置"core.quotepath"或者设置它的值为true时，```git status```显示如下：
    ```txt
    mikepro:git-test mike$ git status
    On branch master

    No commits yet

    Untracked files:
    (use "git add <file>..." to include in what will be committed)
        "\344\275\240\345\245\275\\\344\270\212\346\265\267 \"\345\244\247\345\256\266\344\273\254\".txt"
        "\344\275\240\345\245\275\347\245\226\345\233\275.txt"
    ```
    
    当设置"core.quotepath"为false时，```git status```显示如下：
    ```txt
    mikepro:git-test mike$ git status
    On branch master

    No commits yet

    Untracked files:
    (use "git add <file>..." to include in what will be committed)
        "你好\\上海 \"大家们\".txt"
        你好祖国.txt
    ```
    {% endnote %}

+ 设置永久缓存Git账号

    当通过http协议访问Git仓库时，需要提供用户名和密码，为了避免每次都要输入用户名和密码，可以设置永久缓存Git账号。

    ```sh
    git config --global credential.helper store
    ```
    {% note info %}
    在Mac系统中，账号会被缓存到Keychain里，而在Linux/Windows中，账号会被缓存到文件~/.git-credentials中。
    {% endnote %}

+ 设置安全的换行符
    ```sh
    git config --global core.safecrlf true
    ```
    {% note info %}
    严格检查文本或代码文件的换行符是否正确，例如在Linux/Mac/Unix平台上，应该都是LF格式，在Windows平台上，应该是CRLF格式，或者是在.gitattribute中，通过选项”eol“显式指定的换行符，如果不正确则阻止提交。
    {% endnote %}

+ 设置忽略ssl证书验证

    ```sh
    git config --global http.sslverify false
    ```
    {% note info %}
    如果Git通过http协议访问代码仓库，可以设置忽略ssl证书验证，尤其是Git服务器用的是自签名证书。
    {% endnote %}

+ 设置空格处理

    ```sh
    git config --global core.whitespace cr-at-eol,-trailing-space
    ```
    {% note info %}
    在执行```git diff```和```git apply```命令时，如何处理空格或换行很重要，否则在团队协同开发的过程中会产生很大的干扰。

    cr-at-eol: 如果行尾为CR字符，当做换行符处理，不显示^M
    -trailing-space: 执行```git apply```时，对于行末或文末的空格不提示错误
    {% endnote %}

## Linx/Mac中的配置

+ 设置文件检出时的换行符

    ```sh
    git config --global core.autocrlf input
    ```
    {% note info %}
    在Linx/Mac系统中，从代码仓库检出文件时，保持服务端的文件换行符，因为Git服务端是按照Linux格式的换行符存储文本或代码文件的。
    {% endnote %}

## Windows中的配置

+ 设置文件检出时的换行符

    ```sh
    git config --global core.autocrlf true
    ```
    {% note info %}
    在Windows系统中，从代码仓库检出文件时，将文本或代码文件的换行符自动转换成Windows格式的换行符CRLF，除非在.gitattribute中显式指定某些文件的换行符为Linux格式的换行符LF。
    {% endnote %}

+ 设置允许长路径文件

    ```sh
    git config --global core.longpaths true
    ```
    {% note info %}
    设置Windows中的Git命令支持长路径（大于260字节）。
    {% endnote %}

[1]: https://git-scm.com/
[2]: https://launchpad.net/ubuntu/+ppas