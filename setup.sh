#!/bin/bash

# Install packages
echo "Install packages"
npm install

# Customize theme fluid
echo "Customize theme fluid"
#cp -f themes/fluid-mikesay/layout/_partials/changyan/changyan-lite.ejs node_modules/hexo-theme-fluid/layout/_partials/comments/
#cp -f themes/fluid-mikesay/layout/_partial/donate/donate.ejs node_modules/hexo-theme-fluid/layout/_partials/
#cp -r themes/fluid-mikesay/source/css/_changyan node_modules/hexo-theme-fluid/source/css/
#cp -r themes/fluid-mikesay/source/css/_donate node_modules/hexo-theme-fluid/source/css/
cp -f themes/fluid-mikesay/source/img/default.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/aboutme.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/alipay.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/alipay1.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/avatar.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/favicon.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/friends.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home_afg.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/post.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/archive.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/tag.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/wechatpay.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/wechatpay1.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/wechat_mp.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/gregg.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/cloudnative.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/oam.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/prometheus.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/opa.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/coffee.jpeg node_modules/hexo-theme-fluid/source/img/