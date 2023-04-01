FROM python:3.11.2
MAINTAINER miaowmint
EXPOSE 8000

RUN usermod -s /bin/bash root

RUN mkdir -p /usr/local/qexo && chmod -R 755 /usr/local/qexo && mkdir -p /usr/local/hexo && chmod -R 755 /usr/local/hexo && mkdir -p /usr/local/hugo && chmod -R 755 /usr/local/hugo && mkdir -p /www/site && chmod -R 755 /www/site && mkdir -p /www/log && chmod -R 755 /www/log

RUN apt update && apt install -y sudo && sudo apt update && sudo apt install -y cron && sudo apt install -y nginx

WORKDIR /root

RUN curl https://get.acme.sh | sh -s && ln -sf /root/.acme.sh/acme.sh /usr/local/bin/acme.sh

WORKDIR /usr/local/hexo

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

RUN npm install -g hexo-cli && ln -sf /usr/local/hexo/node_modules/.bin/hexo /usr/local/bin/hexo

WORKDIR /usr/local/hugo

RUN LATEST=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")') && DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/${LATEST}/hugo_${LATEST#?}_linux-amd64.tar.gz" && wget "${DOWNLOAD_URL}" -O hugo.tar.gz && tar -xzf hugo.tar.gz && rm hugo.tar.gz

RUN ln -sf /usr/local/hugo/hugo /usr/local/bin/hugo

WORKDIR /usr/local/qexo

RUN wget https://raw.githubusercontent.com/Qexo/Qexo/master/requirements.txt

RUN pip install -r requirements.txt

CMD bash /usr/local/qexo/run.sh
