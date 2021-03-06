# README #

### Recommended server configuration ###

Ubuntu 14.04 LTS

Apache/2.4.7 (Ubuntu)

MySQL 5.5

### Apache/Mysql installation ###

```
#!

sudo apt-get update && sudo apt-get install apache2 mysql-server python3-dev libmysqlclient-dev libapache2-mod-wsgi-py3 

```
You should be prompted for database root user password.

### Project source code ###
Clone project into apache web directory

```
#!

cd /var/www/html
sudo git clone https://<user>@bitbucket.org/axisbits/data-management-platform.git
```

### Python environment setup ###

Switch to apache web directory and create directory for environments:

```
#!

cd /var/www/html
sudo mkdir .virtualenvs && sudo chmod -R o+rwx .virtualenvs/
```
Install pip and virtualenv tools for python 3:
To avoid errors caused by undefined locale valriables, set them to UTF8 and reconfigure locales, you will be prompted for few options during setup, so just keep default options.

```
#!
export LC_ALL="en_US.UTF-8" && export LC_CTYPE="en_US.UTF-8" && sudo dpkg-reconfigure locales
sudo apt-get update && sudo apt-get install python3-pip && pip3 install virtualenv
```


Create and activate new virtual environment for project:

```
#!

virtualenv -p python3 .virtualenvs/dmp
source /var/www/html/.virtualenvs/dmp/bin/activate
```
Install dependencies for project into virtual environment:

```
#!

pip3 install -r /var/www/html/data-management-platform/dmp/requirements.txt
```

### WSGI script ###

Create wsgi script.

Copy wsgi template and check 2 paths (edit if necessary).Just check that paths are exists becuase it depends on your virtual environment setup, files location and version of python available on OS distribution (used by default in **Python environment setup** section - python 3.5):

1. Site packages path ('/var/www/html/.virtualenvs/dmp/lib/python3.5/site-packages')
2. Activate env script path ('/var/www/html/.virtualenvs/dmp/bin/activate_this.py') 

```
#!

cd /var/www/html/data-management-platform/dmp
sudo touch wsgi.py
```



Notice:
/var/www/html/.virtualenvs/dmp - path to virtual environment mentioned in **Python environment setup** section



```
#!

import os
import sys
import site

# Add the site-packages of the chosen virtualenv to work with
site.addsitedir('/var/www/html/.virtualenvs/dmp/lib/python3.5/site-packages')

# Add the app's directory to the PYTHONPATH
sys.path.append('/var/www/html/data-management-platform/dmp')
sys.path.append('/var/www/html/data-management-platform/dmp/dmp')

os.environ['DJANGO_SETTINGS_MODULE'] = 'dmp.settings'

# Activate your virtual env
activate_env=os.path.expanduser("/var/www/html/.virtualenvs/dmp/bin/activate_this.py")
#python2+ style
#execfile(activate_env, dict(__file__=activate_env))

#python3+ style
exec(compile(open(activate_env, "rb").read(), activate_env, 'exec'), dict(__file__=activate_env))
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
```

 

### Virtual host setup ###
Update default apache hosts configuration file (000-default.conf)

```
#!

cd /etc/apache2/sites-available
sudo cp 000-default.conf 000-default.conf.backup
sudo touch dmp.conf 
sudo nano dmp.conf
```

Paste listed configuration into dmp.conf and save:

```
#!

<VirtualHost *:80>

       WSGIScriptAlias / /var/www/html/data-management-platform/dmp/wsgi.py

       <Directory /var/www/html/data-management-platform/dmp/>
                <Files wsgi.py>
                       Require all granted
                </Files>
        </Directory>

        Alias /static/ /var/www/html/data-management-platform/dmp/dmp/static/
        Alias /favicon.ico /var/www/html/data-management-platform/dmp/dmp/static/images/favicon.ico
        Alias /media/ /var/www/html/data-management-platform/dmp/dmp/media/

        <Location "/static/">
                Options -Indexes
        </Location>
        <Directory /var/www/html/data-management-platform/dmp/dmp/static>
                Require all granted
        </Directory>
        <Location "/media/">
                Options -Indexes
        </Location>
 <Directory /var/www/html/data-management-platform/dmp/dmp/media>
                Require all granted
        </Directory>
</VirtualHost>
```
Replace defult configuration with updated content and restart web-server:

```
#!


sudo cp dmp.conf 000-default.conf
sudo service apache2 restart
```

### Database setup ###
Create database, user and grant all privileges to user on created database (replace <database_name>, <user_name>, <user_pass> with actual values).

```
#!

mysql -u root -p
```
You should be prompted for root user password.

There are 2 ways to create project's database:

1.Setup db with custom credentials:

```
#!

CREATE DATABASE <database_name> CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '<user_name>'@'localhost' IDENTIFIED BY '<user_pass>';
GRANT ALL PRIVILEGES ON <database_name>.* TO <user_name>@'localhost';
```
Copy file to setup local settings from example file:


```
#!

cd /var/www/html/data-management-platform/dmp/dmp
sudo cp local_settings_example.py local_settings.py
sudo nano local_settings.py
```

Edit database credentials in local_settings.py and save:

```
#!
'NAME': '<database_name>'
'USER': '<user_name>'
'PASSWORD': '<user_pass>'
```


2.Setup db with default credentials:

```
#!

CREATE DATABASE dmp CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'dmp'@'localhost' IDENTIFIED BY 'fdir498djd4';
GRANT ALL PRIVILEGES ON dmp.* TO dmp@'localhost';
```




Run project database migrations:

```
#!

cd /var/www/html/data-management-platform/dmp/
python3 manage.py migrate
```

Load initial data for providers

```
#!

python3 manage.py loaddata data_provider_initial
```

### Static files ###
Create folders for static and media files (css, images, uploads etc) and run command to collect static content in one place for web-server.
```
#!

sudo mkdir /var/www/html/data-management-platform/dmp/static && sudo chmod 777 -R /var/www/html/data-management-platform/dmp/static
sudo mkdir /var/www/html/data-management-platform/dmp/dmp/static && sudo chmod 777 -R /var/www/html/data-management-platform/dmp/dmp/static
sudo mkdir /var/www/html/data-management-platform/dmp/dmp/media && sudo chmod 777 -R /var/www/html/data-management-platform/dmp/dmp/media
python3 manage.py collectstatic
```
### Create new user ###

```
#!

source /var/www/html/.virtualenvs/dmp/bin/activate
cd /var/www/html/data-management-platform/dmp
python3 manage.py add_user
```
You will be prompted for email and password.

## Project architecture ##

### Current state ###

[Link to fullsize image](images/DMPCurrentFlowDiagram.png)

![DMPCurrentFlowDiagram.png](images/DMPCurrentFlowDiagram.png)

### Project architecture TBD ###

[Link to fullsize image](images/DMPFlowDiagram.png)

![DMPFlowDiagram.png](images/DMPFlowDiagram.png)


### DB scheme ###

**Diagram A: General DB scheme**

[Link to fullsize image](images/DBdiagram.png)

![DBdiagram.png](images/DBdiagram.png)

**Diagram B: DataSources** 

[Link to fullsize image](images/DataSourcesDiagram.png)

![DataSourcesDiagram.png](images/DataSourcesDiagram.png)