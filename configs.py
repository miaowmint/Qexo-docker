import pymysql,os

DOMAINS = ["127.0.0.1", "yoursite.com"]
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join('/usr/local/qexo/db' , 'db.sqlite3'),
    }
}
