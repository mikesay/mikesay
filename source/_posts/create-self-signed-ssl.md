---
title: 创建自签名TLS/SSL证书和私钥
tags:
  - System Management
  - TLS/SSL
date: 2018-12-30 15:22:24
---

TLS(Transport Layer Security)-传输层安全协议，及其前身SSL(Secure Sockets Layer)-安全套接层是一种安全协议，在传输层对网络连接进行加密。TLS协议由两层组成：TLS 记录协议（TLS Record）和 TLS 握手协议（TLS Handshake）。较低的层为 TLS 记录协议，位于某个可靠的传输协议（例如 TCP）上面，与具体的应用无关，所以，一般把TLS协议归为传输层安全协议。TLS握手协议使用该层中的公钥和证书来处理对等用户的认证，以及协商算法和加密实际数据传输的私钥。这个过程是在TLS记录协议的顶部执行的。TLS所采用的证书系统可以确保客户端与服务端传输的数据是被加密的，且服务端是被受信任的，但是前提是TLS所采用的证书是由信任的证书颁发机构(CA)颁发的。基于测试或内部使用的目的，本文将介绍如何创建自签名的TLS/SSL证书，如何配置Nginx使用这个自签名证书和私钥，以及如何在Linux, Windows和Mac客户端安装这个证书。需要说明的是自签名证书无法确认服务端是被受信任的。
<!-- more -->

# 生成自签名证书和私钥

> 本文是在Ubuntu 16.04系统上调用openssl工具生成自签名证书和私钥。

使用openssl命令生成自签名证书和私钥对：

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout selfsigned-key.key -out selfsigned-certificate.crt
```

+ openssl: 基本命令行工具，用来创建和管理OpenSSL证书，私钥和其它文件。
+ req: 子命令，主要是用来创建和处理PKCS#10格式的证书请求。它也能创建被用作根证书的自签名证书。
+ -x509: 这个选项告诉openssl创建一个自签名证书而不是一个证书请求。
+ -nodes: 这个选项告诉openssl不要加密私钥，否则当使用在Nginx上时，每次Nginx启动都要提示输入密码。
+ -days 365: 设置证书的有效期为1年（365天）。
+ -newkey rsa:2048: 这个选项告诉openssl在生成证书的同时生成私钥。rsa:2048说明创建一个2048比特长的RSA私钥。
+ -keyout: 告诉openssl生成的私钥的名字和路径。
+ -out: 告诉openssl生成的自签名证书和路径。
  
命令会提示以下的一些输入：

```bash
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:Shanghai
Locality Name (eg, city) []:Shanghai
Organization Name (eg, company) [Internet Widgits Pty Ltd]:<The company name>
Organizational Unit Name (eg, section) []:<The unit name of company>
Common Name (e.g. server FQDN or YOUR name) []:<Domain name or Server IP address>
Email Address []:<xxxx@xxx.xxx>
```

# 配置Nginx使用自签名证书和私钥

1. 将证书和私钥放在Nginx服务器上某个路径下，比如"/etc/nginx/ssl-certs"；
2. 编辑"/etc/nginx/sites-enabled"下的配置文件“*.conf”，在头部(server节点之外)加上以下两行：

   ```bash
   ssl_certificate       /etc/nginx/ssl-certs/selfsigned-certificate.crt;
   ssl_certificate_key   /etc/nginx/ssl-certs/selfsigned-key.key;
   ```

3. 重新加载配置文件：

   ```bash
   nginx -s reload
   ```

4. 重启Nginx服务：

   ```bash
   systemctl restart nginx
   ```
  
# 在客户端安装自签名证书

> 当自签名证书安装完后，不同的客户端程序为了能够识别和使用这个证书可能需要做不同的操作，比如docker客户端需要重新启动。

## Linux客户端

### Ubuntu, Debian

#### 添加

1. 将证书拷贝到目录“/usr/local/share/ca-certificates”:

   ```bash
   sudo cp selfsigned-certificate.crt /usr/local/share/ca-certificates
   ```

2. 更新CA存储

   ```bash
   sudo update-ca-certificates
   ```

#### 删除

1. 从目录“/usr/local/share/ca-certificates”中删除证书：

   ```bash
   sudo rm /usr/local/share/ca-certificates/selfsigned-certificate.crt
   ```

2. 更新CA存储

   ```bash
   sudo update-ca-certificates --fresh
   ```
  
### CentOS, RedHat

#### 添加

1. 将证书拷贝到目录“/etc/pki/ca-trust/source/anchors”:

   ```bash
   sudo cp selfsigned-certificate.crt /etc/pki/ca-trust/source/anchors
   ```

2. 更新CA存储

   ```bash
   sudo update-ca-trust
   ```
  
#### 删除

1. 从目录“/etc/pki/ca-trust/source/anchors”中删除证书：

   ```bash
   sudo rm /etc/pki/ca-trust/source/anchors/selfsigned-certificate.crt
   ```

2. 更新CA存储

   ```bash
   sudo update-ca-trust
   ```
  
## Mac客户端

#### 添加

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain selfsigned-certificate.crt
```

#### 删除

```bash
sudo security delete-certificate -c "<Common Name of existing certificate>"
```

> 这里的< Common Name of existing certificate>是指创建证书时提示输入的Common Name (e.g. server FQDN or YOUR name) \[\]: < Domain name or Server IP address>

或者通过证书的SHA-1码来删除：

```bash
sudo security delete-certificate -Z <SHA-1 Hash>"
```

> 通过命令"security find-ceritificate -a -Z -c < Common Name of existing certificate>"可以获得证书的SHA-1码。

## Windows客户端

#### 添加

```batch
certutil -addstore -f "Root" selfsigned-certificate.crt
```

#### 删除

```batch
certutil -delstore "Root" <Cert Serial Number>
```

> 通过命令"certutil -store "Root""可以获得证书的Serial Number。