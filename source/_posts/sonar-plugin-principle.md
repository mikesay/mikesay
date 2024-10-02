---
title: 浅析SonarQube插件的运行原理
toc: true
tags:
  - SonarQube
  - Code Quality
date: 2021-01-17 23:39:00
---

最近公司的某个Java项目的[SonarQube][1]静态代码扫描出了问题，虽然最终解决了，但是在排查问题的过程中走了一些弯路，多花了点时间。分析下来，主要原因还是对SonarQube插件的运行机制不是很清楚。本文从分析SonarQube扫描的问题出发简单地介绍下SonarQube插件的运行原理。
<!-- more -->

# 问题分析

项目是用Maven构建的，Maven的[SonarScanner插件][2]用来做静态代码扫描。最近项目的Java版本升级到14，SonarQube扫描就遇到了下面的问题：

```txt
[ERROR] Failed to execute goal org.sonarsource.scanner.maven:sonar-maven-plugin:3.7.0.1746:sonar
(default-cli) on project aid-range-ocean: Unsupported Java version for PMD: 14 -> [Help 1]
[ERROR]
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR]
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1]
```

从错误日志看，PMD不支持Java14。再从下面的Sonar扫描的日志看，当前使用的PMD版本为6.10.0版本。

```txt
[INFO] Load metrics repository
[INFO] Load metrics repository (done) | time=268ms
[INFO] Sensor JavaSquidSensor [java]
[INFO] Sensor JavaSquidSensor [java] (done) | time=2289ms
[INFO] Sensor PmdSensor [pmd]
[INFO] Execute PMD 6.10.0
[INFO] Execute PMD 6.10.0 (done) | time=15ms
```

在[PMD的GitHub网站][3]看到PMD从6.22.0版本才开始支持Java14。刚开始，最直接的想法是如何让Maven的SonarScanner插件使用新版本的PMD，所以引入了[Maven PMD插件][4]并设置PMD的版本为6.29.0，以下是Maven的POM文件：

```xml
<properties>
  <pmd.plugin.version>3.14.0</pmd.plugin.version>
  <pmd.version>6.29.0</pmd.version>
</properties>
<build>
  <pluginManagement>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-pmd-plugin</artifactId>
        <version>${pmd.plugin.version}</version>
        <dependencies>
          <dependency>
            <groupId>net.sourceforge.pmd</groupId>
            <artifactId>pmd-core</artifactId>
            <version>${pmd.version}</version>
          </dependency>
          <dependency>
            <groupId>net.sourceforge.pmd</groupId>
            <artifactId>pmd-java</artifactId>
            <version>${pmd.version}</version>
          </dependency>
          <dependency>
            <groupId>net.sourceforge.pmd</groupId>
            <artifactId>pmd-javascript</artifactId>
            <version>${pmd.version}</version>
          </dependency>
          <dependency>
            <groupId>net.sourceforge.pmd</groupId>
            <artifactId>pmd-jsp</artifactId>
            <version>${pmd.version}</version>
          </dependency>
        </dependencies>
      </plugin>
    </plugins>
  </pluginManagement>
  <plugins>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-pmd-plugin</artifactId>
        <configuration>
            <!-- failOnViolation is actually true by default, but can be disabled -->
            <failOnViolation>true</failOnViolation>
            <!-- printFailingErrors is pretty useful -->
            <printFailingErrors>true</printFailingErrors>
            <targetJdk>14</targetJdk>
        </configuration>
        <executions>
            <execution>
                <goals>
                    <goal>check</goal>
                </goals>
            </execution>
        </executions>
    </plugin>
  </plugins>
</build>
```
但是运行下来发现问题并没有解决，而且又多了次PMD扫描。这个扫描来自于Maven PMD插件，用的版本确实是我们设置的6.29.0版本，也确实能够支持Java14。
```txt
[INFO] --- maven-pmd-plugin:3.14.0:check (default) @ xxxx ---
[INFO] PMD version: 6.29.0
[INFO] You have 41 PMD violations. For more details see: xxxx/target/pmd.xml
```
所以，Maven PMD插件和Sonar扫描是没有关系的，即使没有SonarQube，Maven PMD插件也能够单独扫描Java代码。接下来，我们就把思路转到SonarQube的插件上了，而且发现SonarQube的服务端确实安装了一个[SonarQube的PMD插件][5]，且版本为3.2.1。从SonarQube PMD插件的GitHub页面看，版本3.2.1支持的PMD版本为6.9.0，确实不支持Java14, 而SonarQube的PMD插件从3.3.x版本才开始支持PMD 6.30.0版本，也就能够支持Java14。当把SonarQube的PMD插件升级为3.3.0后，问题解决了。再仔细分析客户端SonarQube扫描日志发现Maven SonarScanner插件会将SonarQube的PMD插件下载到本地缓存目录中，所以应该是Maven SonarScanner插件调用SonarQube PMD插件做PMD扫描。

```txt
[INFO] --- sonar-maven-plugin:3.7.0.1746:sonar (default-cli) @ xxxx ---
[INFO] User cache: /xxxx/.sonar/cache
[INFO] SonarQube version: 7.9.4
[INFO] Default locale: "en_CN", source code encoding: "UTF-8"
[INFO] Load global settings
[INFO] Load global settings (done) | time=1676ms
[INFO] Server id: 9C01C42E-1505da3410fc976
[INFO] User cache: /xxxx/.sonar/cache
[INFO] Load/download plugins
[INFO] Load plugins index
[INFO] Load plugins index (done) | time=295ms
[INFO] Load/download plugins (done) | time=501ms
```

搜索了下SonarQube本地缓存目录，确实发现了SonarQube PMD插件：
```txt
/xxxx/.sonar/cache/5528f475b7c3651f5a42841b092164fa

Jan 18:58 sonar-pmd-plugin.jar
Jan 18:58 sonar-pmd-plugin.jar_unzip
```

看了下SonarQube PMD插件的解压目录，它引用了PMD 6.30.0版本：
```txt
/xxxx/.sonar/cache/5528f475b7c3651f5a42841b092164fa/sonar-pmd-plugin.jar_unzip/META-INF/lib

-rw-r--r--  1 mizha53  619956085  1241504 13 Jan 18:58 pmd-core-6.30.0.jar
-rw-r--r--  1 mizha53  619956085  1141858 13 Jan 18:58 pmd-java-6.30.0.jar
```
到此，我们已经完全搞清楚SonarQube PMD扫描的调用顺序：Maven SonarScanner插件下载SonarQube PMD插件到本地缓存目录（如果不存在的话）, Maven SonarScanner插件调用SonarQube PMD插件，SonarQube PMD插件最终调用PMD完成扫描。但是SonarQube的插件仅仅是运行在客户端吗，扫描后的结果上传到服务端后如何处理，由谁来处理？答案还是SonarQube插件，SonarQube插件是对SonarQube的扩展，既可以运行在客户端也可以运行在服务端。接下来，我们就了解下SonarQube插件的原理。

# SonarQube插件原理

## SonarQube架构

![SonarQube架构](1.png)

+ SonarQube服务包含了三个进程：
    + Web服务给开发人员或者经理浏览代码质量快照并配置SonarQube实例
    + 基于ElasticSearch的搜索服务支持从UI界面搜索信息
    + 计算引擎服务负责处理代码分析报告并将它们存储在SonarQube数据库中

+ SonarQube数据库用来存储：
    + SonarQube实例的配置（安全，插件配置等）
    + 项目或视图的质量快照

+ 安装在服务端的多个SonarQube插件，包括语言，SCM，集成，认证和管理插件

+ 运行在构建或持续集成服务器上的一个多个SonarScanner用来分析项目

+ 集成在不同IDE中的SonarLint插件，在开发人员的IDE中实时分析代码质量

## SonarQube插件

SonarQube在以下的四个技术栈中提供了扩展点：
+ 扫描器(Scanner)，执行源代码分析
+ 计算引擎，整合扫描器的结果
+ Web应用
+ SonarLint

一个SonarQube插件可以对一个，多个或所有的技术栈实现扩展。例如，下面的SonarQube PMD插件实现了所有技术栈的扩展：
![SonarQube PMD插件扩展SonarQube](2.png)

每一个扩展点都是一个Java类，而一个扩展点可以同时实现多个技术栈。例如，PmdSensor即扩展了SonarLint，又扩展了SonarQube Scanner，也就是Java类PmdSensor即运行在SonarLint中，也运行在SonarScanner中。"SonarLintSide"，“ScannerSide”，“ServerSide”和“ComputeEngineSide”是Java中用来标注扩展点的Java类。例如：

```java
@ScannerSide
public class PmdConfiguration {
    static final String PROPERTY_GENERATE_XML = "sonar.pmd.generateXml";
    private static final String PMD_RESULT_XML = "pmd-result.xml";
    private static final Logger LOG = Loggers.get(PmdConfiguration.class);
    private final FileSystem fileSystem;
    private final Configuration settings;

    public PmdConfiguration(FileSystem fileSystem, Configuration settings) {
        this.fileSystem = fileSystem;
        this.settings = settings;
    }
...
```

所以，由上面SonarQube插件的分析来看，SonarQube的插件具体运行在什么地方，就看它扩展了哪些技术栈。如果它扩展了扫描器(Scanner)，那么客户端的扫描器(Scanner)在执行代码扫描的时候就会下载这个插件到本地缓存目录并执行里面的Java类。

[1]: https://www.sonarqube.org/
[2]: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/
[3]: https://github.com/pmd/pmd/releases/tag/pmd_releases%2F6.22.0#java-14-support
[4]: https://maven.apache.org/plugins/maven-pmd-plugin/
[5]: https://github.com/jensgerdes/sonar-pmd
