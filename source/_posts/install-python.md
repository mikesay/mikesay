---
title: 安装Python并搭建Python的虚拟开发环境
toc: true
tags:
  - Python
date: 2020-01-31 21:48:00
---

虽然Python的安装之于开发来说比较简单，但弄清楚Python及其相关工具在各个平台上的安装对于之后的开发，打包都是很有帮助的，正所谓工欲善其事，必先利其器！本文将介绍如何在Mac，Windows，Ubuntu和CentOS中同时安装和设置Python2和Python3，以及利用virtualenv命令创建Python的虚拟开发环境。为什么要Python2和Python3共存？尽管官方已经不支持Python2了，但还是有很多Python2的程序存在，有很多Python2的库没有迁移到Python3，所以在很长的一段时间里是需要Python2和Python3的开发和运行环境共存。

<!-- more -->

# 在Mac中安装Python2和Python3

从Python的官网中下载Python的Mac安装包，按照向导缺省安装即可。
![](7.png)
  
![](8.png)

## 设置Python3为缺省的Python
```sh
sudo rm /Library/Frameworks/Python.framework/Versions/Current
sudo ln -s /Library/Frameworks/Python.framework/Versions/3.8 /Library/Frameworks/Python.framework/Versions/Current
cd /usr/local/bin/
sudo python
sudo ln -s ../../../Library/Frameworks/Python.framework/Versions/3.8/bin/python3 python
sudo rm pip
sudo ln -s ../../../Library/Frameworks/Python.framework/Versions/3.8/bin/pip3 pip
```
这样，在Mac中缺省的是Python3，命令行直接调用python或pip即可。如果需要使用Python2，命令行调用python2或pip2。

在文件“~/.bash_profile”中注释掉或者删除Python安装程序添加的PATH环境变量，因为我们已经在系统路径/usr/local/bin下建立了Python相关命令的软链接，而且许多工具缺省也是从这个路径下搜索Python的。

```sh
# Setting PATH for Python 3.8
# The original version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:${PATH}"
#export PATH

# Setting PATH for Python 2.7
# The original version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
#export PATH
```

## 升级pip工具
Python安装包里包含的pip工具可能不是最新版本，所以需要升级一下。

### 缺省python3
```sh
curl https://bootstrap.pypa.io/get-pip.py | sudo -E -H /usr/loca/bin/python
```

### python2
```sh
curl https://bootstrap.pypa.io/get-pip.py | sudo -E -H /usr/local/bin/  python2
```

## 安装virtualenv工具

### 缺省Python3
```sh
pip install virtualenv
cd /usr/local/bin/
sudo ln -s ../../../Library/Frameworks/Python.framework/Versions/3.8/bin/virtualenv virtualenv
```

### Python2
```sh
pip2 install virtualenv
cd /usr/local/bin/
sudo ln -s ../../../Library/Frameworks/Python.framework/Versions/2.7/bin/virtualenv virtualenv2
```
## 创建Python的虚拟开发环境

### Python3
```sh
virtualenv --always-copy pyenv3
```

### Python2
```sh
virtualenv --always-copy -p python2 pyenv2
```

# 在CentOS中安装Python2和Python3
Python的官方文档并没有提供Linux的二进制安装包或者提供yum的安装方法，因为大部分Linux都包含了Python。但是Linux缺省自带的Python都不是最新版本，比如CentOS 7缺省自带Python2.7.5， 所以我们需要通过源代码构建并安装最新版的Python。

## 安装构建Python2和Python3的依赖

[参考官方文档][2]，执行以下shell命令：
```sh
sudo yum install yum-utils
sudo yum-builddep python3
```

> 也可以显式安装所有的依赖：
> ```sh
  # 首先确保你的系统是最新的:
  yum update
  # 安装编译器和相关的工具:
  yum groupinstall -y "development tools"
  # 安装编译全功能Python所需的依赖库:
  yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libffi-devel libpcap-devel xz-devel expat-devel
  # 如果你的CentOS是”最小化“安装，你需要安装wget工具：
  yum install -y wget
  ```

## 源码安装Python2和Python3

1. 下载最新Python2的源代码并解压
[https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz][3]

2. 下载最新Python3的源代码并解压
[https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz][4]

3. 分别在Python2和Python3的源码根目录中执行下面命令配置，构建并安装Python2和Python3
  ```sh
  ./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
  make && make altinstall
  ```
  > 为了区别CentOS中缺省的自带Python，用altinstall将Python安装到不同的路径下。
  > 下面是Python2的安装目录：
  > ```sh
    /usr/local/bin/
    /usr/local/lib/
    /usr/local/lib/python3.8/
    /usr/local/lib/python2.7/
    ```

4. 设置Python3为缺省的Python
```sh
cd /usr/local/bin
sudo ln -s python3.8 python3
sudo ln -s python3 python
sudo ln -s python2.7 python2
```

## 安装或升级pip工具

```sh
curl https://bootstrap.pypa.io/get-pip.py | sudo -E -H /usr/local/bin/python
curl https://bootstrap.pypa.io/get-pip.py | sudo -E -H /usr/local/bin/python2
cd /usr/local/bin
sudo rm pip
sudo ln -s pip3 pip
```

## 安装virtualenv工具

```sh
sudo -E -H /usr/local/bin/pip2 install virtualenv
sudo mv virtualenv virtualenv2
sudo -E -H /usr/local/bin/pip install virtualenv
```

## 创建Python的虚拟开发环境

### Python3
```sh
virtualenv --always-copy pyenv3
```

### Python2
```sh
virtualenv --always-copy -p python2 pyenv2
```

# 在Ubuntu中安装Python2和Python3
与CentOS相同，我们需要通过源代码构建并安装最新版的Python。

## 安装构建Python3和Python2的依赖

[参考官方文档][2]，编辑/etc/apt/sources.list，为Ubuntu 18添加“deb-src http://archive.ubuntu.com/ubuntu/ bionic main”，或为Ubuntu 16添加“deb-src http://archive.ubuntu.com/ubuntu/ xenial main”。执行下面命令安装编译Python2或Python3的依赖：

```sh
sudo apt-get update
```

```sh
sudo apt-get build-dep python3.6
```
> 如果依赖包的版本找不到，试着降低小版本号，比如python3.5。

## 源码安装Python2和Python3
与CentOS的过程一样，可以参照CentOS章节。

## PPA(Personal Package Archive)安装Python
[PPA][5]库包含了为Ubuntu打包的最新的Python版本，但不一定包含所有的版本，所以不是太推荐这个方法。以下是通过PPA安装Python3.8的步骤：

### 为apt添加PPA库

```sh
sudo apt-get update
sudo apt install -y software-properties-common
sudo -E -H add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
```

### 安装Python3.8

```sh
sudo apt-get -y -f --allow-unauthenticated install python3.8-dev
```

# 在Windows中安装Python2和Python3

在Windows中同时安装Python2和Python3相对来说比较容易，下载对应的安装包，按向导安装到缺省目录下即可。
![](1.png)


在安装Python2向导中，选择同时安装工具pip以及将python.exe加入Path环境变量中：
![](2.png)

在安装Python3向导中，选择自定义安装：
![](3.png)

并选择安装工具pip：
![](4.png)

将安装目录设置到和Python2相同的地方C:\Python37：
![](5.png)

如果要设置Python2为缺省的Python，可以将C:\Python27\;C:\Python27\Scripts放到Python3的配置前面：
![](6.png)

[1]: https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
[2]: https://devguide.python.org/setup/#linux
[3]: https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
[4]: https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz
[5]: https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa