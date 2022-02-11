#!/bin/bash

# Install packages
echo "Install packages"
npm install

# Customize theme fluid
echo "Customize theme fluid"
cp -f themes/fluid-dev/layout/post.ejs node_modules/hexo-theme-fluid/layout/
cp -f themes/fluid-dev/layout/_partial/nav.ejs node_modules/hexo-theme-fluid/layout/_partial/
cp -f themes/fluid-dev/layout/_partial/comments/changyan-lite.ejs node_modules/hexo-theme-fluid/layout/_partial/comments/
cp -f themes/fluid-dev/layout/_partial/donate.ejs node_modules/hexo-theme-fluid/layout/_partial/
cp -r themes/fluid-dev/source/css/_changyan node_modules/hexo-theme-fluid/source/css/
cp -r themes/fluid-dev/source/css/_donate node_modules/hexo-theme-fluid/source/css/
cp -r themes/fluid-dev/source/css/_pages/_post/post.styl node_modules/hexo-theme-fluid/source/css/_pages/_post/
cp -f themes/fluid-dev/source/css/main.styl node_modules/hexo-theme-fluid/source/css/
cp -f themes/fluid-dev/source/img/aboutme.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/alipay.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/archive.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/avatar.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/favicon.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/friends.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/s57-10.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/f15e-1.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/j10c_3.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/post1.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/j10c_4.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/tag.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/wechatpay.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/wechat_mp.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/gregg.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/cloudnative.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/oam.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/prometheus.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/opa.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-dev/source/img/coffee.jpeg node_modules/hexo-theme-fluid/source/img/