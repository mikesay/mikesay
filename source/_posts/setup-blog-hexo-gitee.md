---
title: Hexo+Gitee(码云)搭建静态博客网站
date: 2018-08-17 21:06:58
comments: true
tags:
- Hexo
- Gitee
---
直接注册和使用当下比较流行的博客网站比如csdn, oschina, 博客园等等，觉得不是自己专属，而且还有很多广告。选择一款开源或免费的CMS(内容管理系统)，自己买云主机和域名搭建博客，费钱又费时。有时我们只是希望有一个功能不太复杂，自己专属的或者看起来自己专属的（至少没有一堆广告）博客网站来写写和分享自己的文章。不需要花费太多的时间和钱，除非你的博客和文章已经足够热门。基于以上的期望，本文将介绍如何使用Hexo搭建静态博客网站，并将其发布到GITEE(码云)免费提供的静态网页空间里。
<!-- more -->

# Hexo是什么

Hexo是一款免费的用来快速搭建静态博客网站的框架。支持插件机制，简单又不失强大。Hexo是基于Node.js开发的，提供了一组命令用来创建和管理博客应用，创建和管理博客文章，将博客应用和文章发布成静态博客网站。Hexo使用Markdown语言来写博客，方便、快捷，不需要什么额外的排版工具就能使你的文章布局看起来很美观。下图是Hexo博客网站的结构：
![](1.png)

# Gitee是什么

Gitee（码云 [gitee.com][1]）是国内的一款基于Git的代码托管和协作开发平台，和GitHub, GitLab属于同一类型的产品。同GitHub和GitLab相比，Gitee具有以下几点优势：

+ 支持免费的私有Git代码仓库
+ 在国内，不需要科学上网，访问速度快  

Gitee平台也提供了免费的静态页面托管服务“码云Pages”，可以用来托管博客，项目官网等静态网页。“码云Pages Pro”是这个服务的高阶收费版，支持发布代码仓库中的某个目录，支持自定义域名。
> 要详细了解Gitee的概念和使用，可以参考Gitee的官方在线帮助文档：https://gitee.com/help

本文将会在Gitee上创建Git代码仓库管理Hexo博客应用的代码和静态博客网站，同时将静态博客网页托管到“码云Pages”。

# 从零开始搭建专属博客

介绍完Hexo和Gitee后，明白了它们的概念和用途。下面我们就从零开始完整地搭建一个自己专属的博客。

## 安装必备的软件

+ 安装Node.js
  + Mac上安装
  + Linux上安装
  + Windows上安装
+ 安装Git客户端
  + Mac上安装
  + Linux上安装
  + Windows上安装

## 安装Hexo

运行以下命令安装Hexo（Hexo命令行）到Node.js的全局空间：

```bash
npm install -g hexo-cli
```

> Hexo是用Node.js开发的，所以它以npm包格式发布。

## 创建一个新的博客应用

1. 依次执行以下shell命令创建一个缺省的博客应用：

    ```bash
    hexo init hexo-test-blog
    cd hexo-test-blog
    npm install
    ```

    > 博客应用的文件结构：  
    > .  
    > ├── _config.yml  
    > ├── package.json  
    > ├── scaffolds  
    > │   ├── draft.md  
    > │   ├── page.md  
    > │   └── post.md  
    > ├── source
    > │   └── _posts  
    > │   └── _drafts
    > └── themes
    > │   └── landscape  
    > + _config.yml  
    >   博客站点配置文件。
    > + package.json
    >   博客应用引用的第三方Node.js包。
    > + scaffolds
    >   脚手架是用来快速创建博客页面的模板。有三类模板，“文章”，“草稿”和“页面”。脚手架不是最终博客页面显示的模板，显示是由当前主题的layout文件夹中的模板负责。
    > + source
    >   博客文章的存放目录。分为“_posts”和“_drafts”两个子目录，分别存放正式文章和草稿文章。
    > + themes
    >   Hexo博客的主题。缺省安装的主题是“landscape”。

2. 执行以下命令构建博客应用，生成静态博客网站
    ```bash
    npm intall
    hexo generate
    ```

3. 执行以下命令启动一个本地http服务查看静态博客网站  

    ```bash
    hexo server
    ```
    > 在浏览器中输入http<nolink>://localhost:4000打开博客网站。

4. 设置一些“应用配置”(_config.yml)

    > 这里将根目录下的配置文件”_config.yml“称为”应用配置“以便与后面的“主题配置”区分看来。”主题配置“是位于博客应用的主题根目录下的配置文件，名字也是”_config.yml“。

    + title: 若一拾得
    + subtitle: 若一不一，知之不知
    + description:
    + keywords: DevOps, Infrastructure As Code(IAC), CI/CD, Operation, Monitor, Python
    + author: 若一
    + language: zh-Hans
    + timezone: Asia/Shanghai
    + url: [http://www.ruokiy.com][2]
    + root: /
    + permalink: :year/:month/:day/:title/ => 文章页面的永久链接
    + permalink_defaults:

      > 可以参考Hexo的官方文档了解更多的Hexo命令。

## 为博客应用安装新的主题

Hexo自带的主题“landscape”看起来平平，不够简洁也不够富丽，所以大部分人安装和初始化完Hexo博客应用后，接下来的一步就是安装配置自己喜欢的主题。下面就以以简洁著称的“NexT”主题为例，介绍安装和配置主题的步骤。

“NexT”主题在GitHub上，地址为[https://github.com/theme-next/hexo-theme-next][3]。
> 注意：GitHub上还有很多“NexT”的fork版, 上面的地址是官方最新的版本。[https://github.com/iissnan/hexo-theme-next][4]是“NexT”的一个老版本。

### 安装步骤

1. 克隆“NexT”主题到博客应用的themes目录

    ```bash
    git clone https://github.com/theme-next/hexo-theme-next themes/next
    ```

2. 修改“应用配置”使用“NexT”主题
    + theme: next

### 对“NexT”主题的一些配置

这个段落加上后面的对接第三发系统部分将介绍一些常用的配置。如果需要更多的设置，可详细浏览“应用配置”和“主题配置”中的每一个可更改的配置，并参考对应的文档，或者Google、Baidu来了解配置的作用，分析是否能满足你的要求。

+ 去除页脚中的有关“NexT”的信息和链接
  
  编辑“主题配置”，将“footer|powered|enable”，“footer|powerer|version”，“footer|theme|enable”以及“footer|theme|version”都设成“false”。

+ 添加“about”和“tags”页
  Hexo缺省支持这两个类型的页面。
  (1) 执行下面的命令，在根目录下的source目录中分别创建“about”和“tags”文件夹
    ```bash
    hexo new page about
    hexo new page tags
    ```
  (2) 编辑“根目录/source/tags/index.md”，在头部加上“type: tags”

    ```yaml
    ---
    title: tags
    date: 2018-08-17 14:57:19
    type: tags
    comments: false
    ---
    ```
  (3) 编辑“主题配置”，将“menu|about”和“menu|tags”打开

+ 设置博客版面样式
  也就是博客网站的样式，比如一列或者两列。可以通过“主题配置”中的“scheme”来设置。

+ 开启博客首页文章自动摘录，以及摘录字数限制
  编辑“主题配置”，将“auto_excerpt|enable”设成“true”，设置“auto_excerpt|length”为指定的摘录字数。
  > 根据描述，你也可以用符号“<\!\-\- more \-\->”来精确控制自动摘录的结束点。
  
## 对接第三发系统完善博客应用

由于Hexo产生的是静态博客网站，没有自己的独立数据库，所以很多功能需要利用第三方服务或者插件来完成。

### 评论系统

如果不能科学上网的话，基本上不太可能使用国外的评论系统比如Disqus，Hypercomments，LiveRe等，要么访问速度慢，要么被墙。而国内可用的第三方评论系统也不是很多，多说和网易云跟帖已经关闭，畅言需要提供你的网站ICP备案号，否则只有15天的试用期。经过比较，发现Valine是一个比较轻量级的评论系统，速度快，不需要网站备案（说不定以后需要，先用着再说！）。
> 如果非要尝试畅言的话，可以参考这个博客文章[https://blog.csdn.net/qq_32518231/article/details/78080184][5]

给你的博客应用设置Valine评论系统的步骤：
(1) 在LeanCloud[https://www.leancloud.cn][6]上注册一个账号；

    博客的评论将存储在LeadCloud中。

(2) 进入控制台，创建一个开发版的应用；

(3) 点击进入这个应用，并进入设置|应用key页面获取APP ID和APP KEY；

(4) 修改主题配置，将valine|enable设为true，valine|appid设为上一步获取的APP ID，valine|appkey设为上一步获取的APP KEY。

    需要将你的静态博客发布到线上才会看到文章末尾的valine评论模块

### 文章统计

+ 添加“文章字数”和“文章平均阅读时间”统计。

    (1) 在博客应用的根目录执行以下命令安装“hexo-sysmbols-count-time”插件

    ```bash
    npm install hexo-symbols-count-time --save
    ```

    (2) 修改**应用配置**添加以下配置加载“hexo-symbols-count-time”插件

    ```yaml
    symbols_count_time:
    symbols: true
    time: true
    total_symbols: true
    total_time: true
    ```

    (3) 修改**主题配置**中的以下配置

    ```yaml
    symbols_count_time:
    separated_meta: true
    item_text_post: true
    item_text_total: true
    awl: 4
    wpm: 275
    ```
  
### 社交分享

添加模块[https://github.com/theme-next/theme-next-needmoreshare2][7]获得博客文章社交分享的功能。

(1) 执行以下命令安装needmoreshare模块

```bash
cd themes/next
git clone https://github.com/theme-next/theme-next-needmoreshare2 source/lib/needsharebutton
```
    注意，这里一定得是克隆到“source/lib/needsharebutton”目录，名字不能错。

(2) 修改“主题配置”“needmoreshare2”的子选项开启社交分享功能

### 博客搜索

(1) 在博客应用的根目录安装插件[https://github.com/theme-next/hexo-generator-searchdb][8]

```bash
npm install hexo-generator-searchdb --save
```

(2) 在“应用配置”中添加以下配置开启博客搜索功能

```yaml
symbols_count_time:
  symbols: true
  time: true
  total_symbols: true
  total_time: true
```

## 部署静态博客网站到码云(Gitee)静态页面空间

1. 在码云上创建一个与你账号同名的Git代码仓库，比如"ruokiy";
   > 在创建时选择用README初始化仓库，这样创建出来的代码仓库缺省会带有master分支

2. 安装插件hexo-deployer-git

   ```bash
   npm install hexo-deployer-git --save
   ```

3. 在“应用配置”中添加一下配置

   ```yaml
   deploy:
    - type: git
      repo: https://gitee.com/ruokiy/ruokiy.git
      branch: master
   ```

   > 注意，最终deploy过程是将产生的静态博客网站文件提交到新创建的Git代码仓库的master分支上，所以做deploy的机子上需要能够写访问Git代码仓库。这里是通过https协议访问Git代码仓库的，所以你需要在deploy的机子上，也就是装有Git客户端的机子上设置以下的Git配置：
   > git config --global credential.helper store
   > 尝试手动克隆一次代码仓库，根据提示输入用户名和密码，这样你的用户名和密码就会被缓存到机子上了。之后的访问都不要用户名和密码了。

4. 在博客应用的根目录执行以下命令完成静态博客文件的上传

    ```bash
    hexo clean
    hexo deploy
    ```

5. 如下图，在码云上点击刚创建的代码仓库页面，点击菜单“Service|Gitee Pages”，在左侧选择“master”分支，点击“create”按钮
    ![](2.png)

不到一分钟，你的静态博客网站就生成了。可以拷贝生成的网址输入到浏览器打开你的博客了，同时你也可以把这个网址分享给你的朋友，或者放在你的个人简介中。

# 最后一公里 - 将博客应用的代码托管到码云

这里会用到Git submodule的概念。

[1]: https://gitee.com/
[2]: http://www.ruokiy.com
[3]: https://github.com/theme-next/hexo-theme-next
[4]: https://github.com/iissnan/hexo-theme-next
[5]: https://blog.csdn.net/qq_32518231/article/details/78080184
[6]: https://www.leancloud.cn
[7]: https://github.com/theme-next/theme-next-needmoreshare2
[8]: https://github.com/theme-next/hexo-generator-searchdb