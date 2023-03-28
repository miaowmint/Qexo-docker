FROM python:3.11.2
MAINTAINER miaowmint
EXPOSE 8000

RUN usermod -s /bin/bash root

RUN mkdir -p /usr/local/qexo && mkdir -p /usr/local/qexo/db && chmod -R 755 /usr/local/qexo && mkdir -p /usr/local/hexo && chmod -R 755 /usr/local/hexo && mkdir -p /usr/local/hugo && chmod -R 755 /usr/local/hugo

WORKDIR /usr/local/hexo

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

RUN npm install -g hexo-cli && ln -sf /usr/local/hexo/node_modules/.bin/hexo /usr/local/bin/hexo

WORKDIR /usr/local/hugo

COPY hugo ./hugo

RUN ln -sf /usr/local/hugo/hugo /usr/local/bin/hugo

WORKDIR /usr/local/qexo

COPY db.sqlite3 /usr/local/qexo/db/db.sqlite3

RUN chmod 755 /usr/local/qexo/db/db.sqlite3

COPY requirements.txt ./requirements.txt

RUN pip install -r requirements.txt

CMD python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000 --noreload
