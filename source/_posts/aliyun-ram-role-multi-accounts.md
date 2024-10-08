---
title: 阿里云通过RAM角色管理多云账号下的资源
toc: true
tags:
  - Aliyun
  - RAM
category_bar: true
categories:
  - ["Aliyun", "RAM"]
date: 2021-01-05 22:45:00
---

云计算经过十几年的发展已经变得很成熟，无论是传统企业还是初创企业都将云计算平台作为其数字化策略的支撑平台。在国内，阿里云是使用最广泛的公有云平台，很多本土企业和外资企业在华的分支机构都是首选阿里云来构建和运行他们的数字化方案。为了能够高效地使用阿里云，同时又能对接阿里云产品服务团队，在这些公司里逐渐地出现了一个新的角色或团队来统一规划、管理阿里云平台，我们就暂且称这个团队为云团队。大部分公司云团队往往需要管理多个阿里云账号，而在不同的账号里的用户创建、登录、登出的操作往往会变的很麻烦。本文介绍通过切换身份的方式扮演[RAM角色][1]来管理多云账号下的资源。
<!-- more -->

# 多云账号
公司在使用阿里云的过程中，基于不同的目的或者受组织架构的约束，或多或少都会创建多个云账号。传统的公司或者绝大部分外资公司在财务上都会为不同的部门或团队创建不同的成本中心(cost center)并分配对应的预算，部门或团队的开支都是走自己的成本中心。这就决定了当某个部门或团队在使用阿里云的时候，必定会创建自己的云账号，而不会去使用别的成本中心下的阿里云账号。一些中小型的互联网公司或者创业公司的财务不会那么复杂，研发可能就一个成本中心，但是往往需要多个阿里云账号来隔离不同的环境，例如开发，测试，预生产和和生产环境。

使用多个阿里云账号有以下一些优点：

+ 不同账号的云资源是完全隔离的，相互之间不受影响。
+ 可以单独出账单，做到按不同成本中心核算。
+ 如果构建的微服务系统涉及到多个业务部门或团队，各个业务部门或团队在自己的阿里云账号里只维护或运行自己负责的微服务，这样可以降低单个阿里云账号下架构的复杂性。

但是云团队在管理多个阿里云账号时也会遇到很多麻烦：

+ 需要重复地登录，登出和双因素认证来切换不同的账号。
+ 阿里云支持单点登录(SSO)，这样可以省掉双因素认证的步骤，但当出现问题时，无法创建一个非SSO账号给阿里云技术支持用来临时登录进账号调试问题。
+ 团队成员入职，离职时都需要通知产品拥有者在阿里云账号里创建和删除RAM用户。
+ 每个云团队成员都需要需要记住很多云账号。

# 通过RAM角色管理多云账号

为了解决多云账号管理的痛点，可以通过RAM用户扮演RAM角色的方式来登录阿里云其它账号。

## 什么是RAM角色
RAM角色（RAM role）与RAM用户一样，都是RAM身份类型的一种。RAM角色是一种虚拟用户，没有确定的身份认证密钥，需要被一个受信的实体用户扮演才能正常使用。

RAM角色是一种虚拟用户，与实体用户（云账号、RAM用户和云服务）和教科书式角色（Textbook role）不同。
+ 实体用户：拥有确定的登录密码或访问密钥。
+ 教科书式角色：教科书式角色或传统意义上的角色是指一组权限集合，类似于RAM里的权限策略。如果一个用户被赋予了这种角色，也就意味着该用户被赋予了一组权限，可以访问被授权的资源。
+ RAM角色：RAM角色有确定的身份，可以被赋予一组权限策略，但没有确定的登录密码或访问密钥。RAM角色需要被一个受信的实体用户扮演，扮演成功后实体用户将获得RAM角色的安全令牌，使用这个安全令牌就能以角色身份访问被授权的资源。

## RAM角色使用方法
+ RAM角色指定可信实体，即指定可以扮演角色的实体用户身份。

+ 可信实体通过控制台或调用API扮演角色并获取角色令牌。
  ![](6.png)

+ 为RAM角色绑定权限策略。

+ 受信实体通过扮演角色，使用角色令牌访问阿里云资源。

## RAM角色类型
根据RAM可信实体的不同，RAM支持以下三种类型的角色：

+ 阿里云账号：允许RAM用户所扮演的角色。扮演角色的RAM用户可以属于自己的云账号，也可以属于其他云账号。此类角色主要用来解决跨账号访问和临时授权问题。

+ 阿里云服务：允许云服务所扮演的角色。此类角色主要用于授权云服务代理您进行资源操作。

+ 身份提供商：允许受信身份提供商下的用户所扮演的角色。此类角色主要用于实现与阿里云的SSO。

## RAM角色切换的方式管理多云账号的实现
实现多云账号管理需要满足以下的前提条件：

+ 云团队拥有自己的云账号，假设账号ID为123456789012****，每个成员都有对应的RAM用户。

+ 假设某个业务部门的云账号为128888789012****。

### 实现架构

![RAM用户通过扮演不同云账号里的RAM角色来管理账号里的资源](7.png)

### 实现步骤

+ 产品拥有者参考“[创建可信实体为阿里云账号的RAM角色][2]”，在自己的云账号下为云团队的账号123456789012****创建RAM角色"CloudAdmin"，并给角色分配"AdministratorAccess"权限
  ![选择授信实体为阿里云账号](1.png)
  ![选择其它云账号，并输入云团队的账号](2.png)
  ![给这个RAM角色授予管理员权限](3.png)

+ 设置以下授信策略。授信实体为云团队的账号“123456789012****”，并开放给有“AliyunSTSAssumeRoleAccess”权限的RAM用户
  ```json
  {
      "Statement": [
          {
              "Action": "sts:AssumeRole",
              "Effect": "Allow",
              "Principal": {
                  "RAM": [
                      "acs:ram::123456789012****:root"
                  ]
              }
          }
      ],
      "Version": "1"
  }
  ```
  > 也可以将某个授信实体限制为账号下的某个RAM用户，比如mikejianzhang
  > ```json
    {
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Effect": "Allow",
                "Principal": {
                    "RAM": [
                        "acs:ram::123456789012****:user/mikejianzhang"
                    ]
                }
            }
        ],
        "Version": "1"
    }
    ```

+ 云团队在自己的云账号里为RAM用户授予角色扮演权限"AliyunSTSAssumeRoleAccess"。

+ 云团队的某个RAM用户首先登录云团队的账号，然后通过切换角色并输入业务部门云账号或者别名，以及对应的角色"CloudAdmin"就能切换进业务部门云账号里。

  ![](4.png)
  ![](5.png)

+ 完成管理任务后点击“返回登录身份”退回到自己的账号。
  ![](8.png)

+ 当有云团队成员入职或离职时，只需要在云团队的阿里云账号里添加和删除对应的RAM用户即可。

这样，通过RAM角色切换的方法，云团队就可以管理多个业务部门的云账号。另外，RAM角色切换的方法还有以下两个使用场景：

+ 通过RAM角色临时授权给阿里云的技术支持帮助调试问题，尤其是在云账号开启了单点登录(SSO)的情况下，只有通过这种方法才能让阿里云的技术支持登录进来。
+ 当一个企业希望将部分业务授权给另一个企业时，也可以通过RAM角色进行跨阿里云账号授权来管理资源的访问。例如，企业A购买了多种阿里云资源（ECS实例、RDS实例、SLB实例等），但是企业A希望能专注于业务，仅作为资源拥有者。企业A希望可以授权企业B账号来对云资源进行运维，监控和管理，企业A也希望企业B的员工入职和离职时，无需做任何权限变更，同时也希望合同终止时，可以随时撤销对企业B的授权。这种情况下，企业A可以创建一定权限的角色并授权给企业B的阿里云账号，企业B的RAM用户可以通过角色切换的方法登录进企业A的账号对资源进行运维管理。

[1]: https://help.aliyun.com/document_detail/93689.html?spm=a2c4g.11186623.6.581.77ae30b7l5Hupx
[2]: https://help.aliyun.com/document_detail/93691.html?spm=a2c4g.11186623.6.584.312068f9HVtYvh 