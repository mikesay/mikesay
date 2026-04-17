#!/bin/bash

# Install packages
echo "Install packages"
npm install

# Customize theme icarus
echo "Customize theme icarus"
cp -f themes/icarus-mikesay/source/img/*.* node_modules/hexo-theme-icarus/source/img/