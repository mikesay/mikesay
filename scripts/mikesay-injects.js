'use strict';

const path = require('path');

hexo.extend.filter.register('theme_inject', function(injects) {
    injects.postComments.file('donate', path.join(hexo.theme_dir, 'layout/_partials/donate.ejs'));
    injects.style.push(path.join(hexo.theme_dir, 'source/css/_donate/donate.styl'));
  });