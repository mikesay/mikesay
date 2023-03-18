'use strict';

const path = require('path');

hexo.extend.filter.register('theme_inject', function(injects) {
    injects.postComments.file('donate', 'themes/fluid-mikesay/layout/_partials/donate/donate.ejs');
    injects.style.push('themes/fluid-mikesay/source/css/_donate/donate.styl');
    injects.style.push('themes/fluid-mikesay/source/css/_changyan/changyan.styl');
  });