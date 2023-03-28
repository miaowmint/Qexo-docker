项目地址：[https://github.com/miaowmint/Qexo-docker](https://github.com/miaowmint/Qexo-docker) <br/><br/>
运行一键脚本 <br/>
`wget -O qexoinstall.sh https://ghproxy.com/https://raw.githubusercontent.com/miaowmint/Qexo-docker/master/qexoinstall.sh && chmod +x qexoinstall.sh && bash qexoinstall.sh`<br/><br/>
或者手动部署Qexo-Docker：<br/>
`git clone https://ghproxy.com/https://github.com/Qexo/Qexo.git /data/qexo && cd /data/qexo && wget https://ghproxy.com/https://raw.githubusercontent.com/miaowmint/Qexo-docker/main/configs.py && mkdir -p /data/qexo/db && cd db && wget https://ghproxy.com/https://raw.githubusercontent.com/miaowmint/Qexo-docker/main/db.sqlite3`<br/>
然后修改 configs.py<br/>
`nano /data/qexo/configs.py`<br/>
将`127.0.0.1`改为你服务器的IP，将`yoursite.com`改为你用来反代的域名<br/>
然后运行docker容器<br/>
`docker run -dit --name qexo --hostname qexo --restart always -v /data/qexo:/usr/local/qexo -v /www/wwwroot/hexo:/www/wwwroot/hexo -p 8000:8000 miaowmint/qexo-docker:2.6.3.1`<br/>
如果博客部署在本地，将 -v /www/wwwroot/hexo:/www/wwwroot/hexo 中两个的/www/wwwroot/hexo都更改为博客源码的绝对路径<br/>
如果博客没有部署在本地，将 -v /www/wwwroot/hexo:/www/wwwroot/hexo 删去即可<br/>
直接访问`服务器IP:8000`或者将127.0.0.1:8000反代后访问你的域名即可开始Qexo的初始化配置<br/>
关于Qexo的初始化配置可参考[https://www.oplog.cn/qexo/configs/provider.html](https://www.oplog.cn/qexo/configs/provider.html)<br/><br/>
你也可以根据Dockerfile自行构建docker镜像<br/>
cd到Dockerfile的目录下然后`docker buildx build -t qexo-docker:v1 .`<br/>
运行docker容器`docker run -dit --name qexo --hostname qexo --restart always -v /data/qexo:/usr/local/qexo -v /www/wwwroot/hexo:/www/wwwroot/hexo -p 8000:8000 qexo-docker:v1`<br/>
