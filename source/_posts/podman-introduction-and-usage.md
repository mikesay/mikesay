---
title: Podman介绍和使用
toc: true
date: 2021-10-11 04:58:31
tags:
  - Container
  - Podman
  - Docker
---

最近Docker公司改变了Docker桌面版（Docker for Mac和Docker for Windows）的商业策略：最晚到2022/1/31号，需要购买付费订阅了，但对于员工人数小于250，且年收入少于1000万美元的公司仍然免费。虽说对于个人使用Docker桌面版没有影响，但在公司里还是要谨慎使用。 作为对Docker桌面版的替换，本文将对Podman及其使用做一简单的介绍。
<!-- more -->

# Podman
[Podman][1]是一个无守护进程的开源Linux 原生工具，旨在使用开放容器协议 (OCI) 容器和容器镜像轻松查找、运行、构建、共享和部署应用程序。对于无守护进程这一说法，主要是针对运行在Linux系统中的Podman，因为Podman原生是支持Linux系统的，而在Mac和Windows系统中，仍然需要启动一个Linux虚拟机来管理和运行容器。Podman的架构如下：
![](1.jpg)

Podman是从CRI-O独立出来的一个项目，目的是让CRI-O和Podman能够独立发展。Podman主要包含一个兼容Docker命令的CLI模块和libpod，libpod通过runc创建和执行容器进程。由于Podman底层使用的runc运行时，所以Podman能够使用任何符合OCI标准的镜像包括Docker镜像。

# 在Mac上安装Podman
通过brew命令来安装Podman：
```bash
brew install podman
```

通过以下命令在Mac主机上启动一个Podman管理的虚拟机：
```bash
podman machine init
podman machine start
```

可以通过一下命令列出Podman管理的虚拟机：
```bash
podman machine list
```
![](2.jpg)

# 拉取和执行Docker镜像
通过以下命令拉取Docker镜像：
```bash
podman pull nginx
```

通过以下命令检查所有Podman管理的镜像：
```bash
podman images
```
![](3.jpg)

通过以下命令启动镜像：
```bash
podman run --name nginx -d -p 8000:80 nginx:latest
```
通过以下命令列出运行的容器：
```bash
podman ps
```
![](4.jpg)

停止，删除运行的容器：
```bash
podman stop nginx
podman rm nginx
```

# 设置docker别名
由于podman与Docker CLI命令具有一对多映射，因此建议按如下所示设置docker别名。这样也可以确保继续使用之前的Docker命令经验。
```bash
alias docker=podman
```

[1]: https://podman.io/