---
title: 基于Jenkins Freestyle Job构建CI/CD流水线
tags:
  - DevOps
  - CI/CD
  - Jenkins
category_bar: true
categories:
  - ["Jenkins"]
order: 2
date: 2018-10-07 22:07:44
---

可能有人会问：“现在流行的是Jenkins Pipeline 2.0(Jenkinsfile)，所有人都在谈论和使用, 为什么还在用Freestyle Job, 是不是太low了！”。的确，Jenkins Pipeline 2.0现在很流行，几乎就等同于Jenkins平台上构建CI/CD流水线的标准，如果你不使用Jenkins Pipeline 2.0，那么就等于不懂CI/CD。我承认Jenkins Pipeline 2.0带来了很多革命性的理念，比如Build As Code, 但是我想说的是Jenkins Pipeline 2.0不等于CI/CD Pipeline,而且它的革命也不是很彻底。不过本文不会过多地去议论方法或工具的好坏，只是在Jenkins上利用一种非Jenkins Pipeline 2.0的方式去构建CI/CD流水线，并说明这种流水线的优缺点，以期能够给读者一次思维上的刷新。
<!-- more -->

# 一个典型的CI/CD流水线

![](2.png)

上图是个典型的CI/CD流水线，由5个阶段（Phase）组成：Build/UT，Code Static Check，QA，STAGE和PROD。每个阶段（Phase）由一到多个任务（Task）组成，每个阶段（Phase）都有一个主任务（Task），阶段（Phase）之间的提升（Promotion）是由主任务（Task）的提升（Promotion）完成。同一个阶段（Phase）之间的任务（Task）可以串行执行，也可以并行执行。

如果一个任务（Task）是通过提升（Promotion）的方式触发的，那么在当前流水线中这个任务（Task）可以被重复触发。这为流水线带来了两个好处：

+ 流水线可以从失败的点重新启动，而无需重新启动一个新的流水线实例：
  当一个任务（Task）的执行由于某种临时原因失败了，比如网络不稳定，磁盘空间满了，断电等，可以通过重新提升（Promotion）再次触发。尤其是在前置阶段（Phase）和任务（Task）比较耗时，或者需要征用外部资源的时候，这一点更显得重要。

+ 调试CI/CD流水线时，无需重复启动一个新的流水线实例：
  这一点其实是上优点的延伸。调试流水线时往往是从前往后一个阶段（Phase）一个阶段（Phase）的调试，正是由于流水线可以从失败的点重新启动，可以直接略过通过的阶段（Phase），从失败的阶段（Phase）开始调试。

手动提升（Manual Promote）策略需要有权限的批准者根据提前制定好的质量关卡来决定是否需要提升（Promote）到下一个阶段（Phase）。在这个流水线中，QA阶段（Phase）到STAGE阶段（Phase），STAGE阶段（Phase）到PROD阶段（Phase）都需要手动提升（Mannual Promote），它们并不是在每一个流水线实例中都需要被触发。在开发的早期，软件还不是很稳定的时候，每一次的代码提交都会触发一个流水线实例，流水线实例往往会根据自动提升（Auto Promote）策略最大限度地往后续阶段（Phase）流转，如果在某一阶段（Phase）失败了，则会及时通知到相关开发人员，从而实现了及时反馈当前代码提交对软件质量的影响。

只要没有被清理掉， 流水线实例可以在任何时间被重新启动，状态也会自动恢复。这为流水线带来了以下的好处：

+ 有时候由于质量和时间的原因，不一定会将最新版本的流水线实例从STAGE阶段（Phase）提升到PROD阶段（Phase），而是需要将几天前的已经处于STAGE阶段（Phase）的流水线实例提升到PROD阶段（Phase）；
  
+ 流水线在停止状态不会占用任何Jenkins Master 或者 Slave节点资源。

> 往往是在第一个阶段（Phase）的构建（Build）任务（Task）中生成状态文件，后续阶段（Phase）只是拷贝和恢复，也有可能会添加更多的状态。

下图是状态存储与恢复的过程。

![](3.png)

在上游阶段（Phase）的任务（Task）也就是Jenkins作业（Job）中将需要持久的状态以key-value的方式存储到build-info.prop文件中，并通过Jenkins Job的存档功能（Archive）将build-info.prop存到当前作业（Job）上，下游被触发的Jenkin作业（job）将上游作业（Job）的build-info.prop拷贝到本地工作区，将它注入为环境变量。

# 在Jenkins上实现这个CI/CD流水线

## Jenkins和必要的插件

1. Jenkins
   从Jenkins官网（[https://jenkins.io][1]）上下载最新版本的Jenkins并安装。或者，至少保证你的Jenkins版本在2.0以上，1.x版本还是太旧了。

2. 必要的插件
   + Parameterized Trigger Plugin
     [https://wiki.jenkins.io/display/JENKINS/Parameterized+Trigger+Plugin][2]

     在Jenkins pipeline2.0之前，Job之前的调用与被调用关系是通过这个插件或者一系列同类的插件实现的。

   + Delivery Pipeline Plugin
     [https://wiki.jenkins.io/display/JENKINS/Delivery+Pipeline+Plugin][3]

     将Job的上下游调用关系图形化显示为流水线。这个插件实现了CI/CD流水线的两个概念：阶段（Phase）和任务（Task）。一个任务（Task）就是一个Jenkins Freestyle Job（作业），一个阶段（Phase）可以包含多个任务（Task）。下图是从插件的网站上截取出来的最终CI/CD流水线的样式：
     ![](1.png)

   + Promte Builds Plugin
     [https://wiki.jenkins.io/display/JENKINS/Promoted+Builds+Plugin][4]

     这个插件提供了一系列上下游作业（Job）之间的触发策略，主要分为自动触发，手动批准触发和自定义条件触发。除了三种主要的触发策略，还提供了一些更精细的控制策略，比如当前的提升（promotion）依赖于另一个提升（promotion）。可参考插件的wiki文档和内联的注释详细了解每一个触发策略，选中适合当前CI/CD流水线建设的要求。

   + Copy Artifact Plugin
     [https://wiki.jenkins.io/display/JENKINS/Copy+Artifact+Plugin][5]

     这个插件实现了实现了上下游作业（Job）传递数据的功能。在构建CI/CD流水线时，会将流水线的状态数据以key-value值的方式记录在文本文件中，并存档在当前的作业（Job）中。下游的作业（Job）可以通过这个插件从触发它的上游作业（Job）拷贝这个状态数据文件，加载成环境变量，从而实现状态的恢复。

   + EnvInject Plugin
     [https://wiki.jenkins.io/display/JENKINS/EnvInject+Plugin][10]

     利用这个插件可以将流水线的以key-value值的方式存储的状态文件加载为当前阶段（Phase）当前任务（Task）的环境变量。
     > 注意，key的名字不要包含中划线，否则Jenkins 作业（Job）不识别。
     > 以上五个插件是实现CI/CD流水线必需的插件，装这四个插件可能还会自动安装一些依赖的插件。
  
   + Description Setter Plugin
     [http://wiki.jenkins-ci.org/display/JENKINS/Description+Setter+Plugin][6]

     这个插件比较简单了，主要是用来设置Job(Task)的描述，这样在CI/CD流水线中能显示更多的信息。

   + Flexible Publish Plugin
     [https://wiki.jenkins.io/display/JENKINS/Flexible+Publish+Plugin][7]

     这个插件主要是用来实现作业（Job）中的步骤（step）的控制流，扩展了Jenkins 作业（Job）的步骤（steps）只能顺序执行的方式。

   + Email-ext Plugin
     [https://wiki.jenkins.io/display/JENKINS/Email-ext+plugin][8]

     扩展的邮件插件，能够定制复杂的邮件内容。邮件通知是一个成熟的CI/CD流水线必要的特征。

   + Token Macro Plugin
     [https://wiki.jenkins.io/display/JENKINS/Token+Macro+Plugin][9]

     在作业（Job）的描述或通知邮件的内容中可以通过引用Jenkins当前构建（build）的环境变量实现描述或邮件内容的模板化。Token Macro插件则负责在运行时解析这些变量引用。

## Jenkins Job配置

为了实现这个CI/CD流水线，下图是一个Jenkins Job所需的步骤，但并不是所有的Job都需要实现所有的步骤。比如Build/UT阶段（Phase）的Build任务（Task）是整个流水线的第一个Jenkins作业（Job），所以不需要步骤3去拷贝流水线状态文件，也不需要步骤4去加载状态文件，而最后一个Smoke Test任务（Task）也不要步骤2去提升（Promote）到下一个阶段（Phase）或者任务（Task）。

![](4.png)

步骤的一些说明：

1. 配置“Delivery Pipeline”节。“Stage Name”是阶段（Phase）名，“Task Name”是这个Jenkins Job在这个阶段（Phase）中的任务（Task）名字；

2. Jenkins作业（Job）提升（Promotion）的配置。在“Criteria”下选择提升（Promotion）的策略，在“Actions”中选择待触发的下游Jenkins作业（Job）；

3. 从上游作业（Job）拷贝流水线状态文件；

4. 将状态文件加载为当前作业（Job）的环境变量。

## 如何提升（Promote）阶段（Phase）或任务（Task）

下图展示了如何提升（Promote）阶段（Phase）或任务（Task），也就是Jenkins作业（Job）：
![](5.png)

步骤的一些说明：

1. 在当前的流水线实例中打开上游作业（Job）的构建（Build）页面，点击左侧链接“Promotions Status”；

2. 只有在“Approvers”列表里的用户有权手动批准提升（Promotion）；

3. 点击“Approve”按钮触发提升（Promotion）；

4. Jenkins管理员有权限强制提升（Promotion）；

5. 通过点击“Re-execute promotion"可重复提升（Promote）当前的作业（Job）。

# 结束语

每一种方法有它的优点，必定也有它的缺点，没有一种方法是银弹，可以解决一切问题，打败天下无敌手。是否使用它，就要自己去权衡：是它的优点给你带来了更多，还是它的缺点是当前的最大障碍。这种方法的缺点大致如下：

1. 仅管“Delivery Pipeline Plugin”可以图形化显示Jenkins Pipeline 2.0（Jenkinsfile）作业（Job）的上下游调用关系，但是“Promotes Builds Plugin”不支持Jenkins Pipeline 2.0（Jenkinsfile），所以太多的Freestyle Job要去创建，设置和维护，这些Job只能作为配置存储在Jenkins Master服务器上，而不能作为代码存储在Git中；

2. 会多占用一些Slave节点的线程，因为作业（Job）的提升其实也是作业（Job）需要占用一个Slave线程。

期待“Promotes Builds Plugin”能够支持Jenkins Pipeline 2.0 （Jenkinfile），这样所有的任务（Task）也就是Jenkins作业（Job）全部可以作为代码存储在Git中，而且维护起来也很方便。

[1]: https://jenkins.io
[2]: https://wiki.jenkins.io/display/JENKINS/Parameterized+Trigger+Plugin
[3]: https://wiki.jenkins.io/display/JENKINS/Delivery+Pipeline+Plugin
[4]: https://wiki.jenkins.io/display/JENKINS/Promoted+Builds+Plugin
[5]: https://wiki.jenkins.io/display/JENKINS/Copy+Artifact+Plugin
[6]: http://wiki.jenkins-ci.org/display/JENKINS/Description+Setter+Plugin
[7]: https://wiki.jenkins.io/display/JENKINS/Flexible+Publish+Plugin
[8]: https://wiki.jenkins.io/display/JENKINS/Email-ext+plugin
[9]: https://wiki.jenkins.io/display/JENKINS/Token+Macro+Plugin
[10]: https://wiki.jenkins.io/display/JENKINS/EnvInject+Plugin