# Introduction
mikesay is the source code of my blog which is based on Hexo. In order to setup the blog, install node and npm.

> Do not run below hexo command to deploy the site, because it will always delete existing static site from git repo which 
> will cause github page remove the configuration of custom domain, so that each deploy will have to re-enable the custom domain
> manually:
> ```
> hexo clean
> hexo deploy
> ```

## Deploy blog site

+ Clone blog source code
```sh
git clone https://github.com/mikesay/mikeblog.git
cd mikeblog
```

+ Run shell scripts to install npm dependencies
```sh
./setup.sh
```

+ Generate static site
```sh
hexo generate
```
> The static site will be generated in public folder

+ Add ebooks and adhoc files supporiting GitHub page
```sh
touch public/.nojekyll
echo www.mikesay.com > public/CNAME
rsync -av --delete ./ebooks ./public/
```
> ebooks including additional static site created from docisfy

+ Clone git repo which include static site
```sh
git clone https://github.com/mikesay/mikesay.github.io.git mikesay
```

+ Update static site with latest generated site
```sh
cd ..
rsync -av --delete --exclude '.git*' ./public/ ./mikesay/
```

+ Push latest static site
```sh
cd mikesay
git add .
git commit -m "Update site."
```

## Build additional static site created from mkdocs
> Take ArgoCD document as an example.

+ Run below command to install mkdocs
```bash
pip install mkdocs
```

+ Clone forked ArgoCD repository of branch translate_docs
```bash
git clone -b translate_docs https://github.com/mikesay/argo-cd.git
```

+ Build the static site files
```bash
cd argo-cd
mkdocs build
```

+ Sync latest document to mike blog
```bash
cd argo-cd
rsync -a -P --delete --force site/ mikeblog/ebooks/argocd/
```