#!/bin/bash

# Install packages
echo "Install packages"
npm install

# Customize theme fluid
echo "Customize theme fluid"
cp -f themes/fluid-mikesay/source/img/default.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/aboutme.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/avatar.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/favicon.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/friends.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home_afg.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home_tj.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home_tj1.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home_tj2.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/home_dzw1.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/post.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/archive.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/category.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/tag.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/pay_dzw1.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/pay_dzw2.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/pay_dzw3.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/pay_dzw4.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/pay_dzw5.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/pay_dzw6.jpg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/gregg.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/cloudnative.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/oam.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/prometheus.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/opa.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/coffee.jpeg node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/yuan1.png node_modules/hexo-theme-fluid/source/img/
cp -f themes/fluid-mikesay/source/img/yuan2.png node_modules/hexo-theme-fluid/source/img/

# Customize theme fluid
echo "Customize theme fluid"
cp -f themes/icarus-mikesay/source/img/*.* node_modules/hexo-theme-icarus/source/img/