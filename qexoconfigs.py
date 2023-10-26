import os

DOMAINS = ["127.0.0.1", "yourqexo.com"]
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join('/data/qexo/db' , 'db.sqlite3'),
    }
}
