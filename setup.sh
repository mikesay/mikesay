#!/bin/bash

# Install packages
echo "Install packages"
npm install

# Customize theme icarus
echo "Customize theme icarus"
cp -f themes/icarus-mikesay/source/img/*.* node_modules/hexo-theme-icarus/source/img/
cp -f themes/icarus-mikesay/languages/*.yml node_modules/hexo-theme-icarus/languages/
cp -f themes/icarus-mikesay/layout/common/*.jsx node_modules/hexo-theme-icarus/layout/common/
#cp -f themes/icarus-mikesay/include/style/*.styl node_modules/hexo-theme-icarus/include/style/