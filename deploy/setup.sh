#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='git@github.com:ashwinighodake/Django-project.git'

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Set Ubuntu Language
sudo locale-gen en_GB.UTF-8

# Install Python, SQLite and pip

# Install Python, SQLite, pip, and other dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git

# Create the app directory
sudo mkdir -p $PROJECT_BASE_PATH
sudo chown $USER:$USER $PROJECT_BASE_PATH

git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
cd $PROJECT_BASE_PATH/profiles_project

python3 -m venv $PROJECT_BASE_PATH/env

$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/profiles_project/requirements.txt

# Run migrations
$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/profiles_project/manage.py migrate

# Setup Supervisor to run our uwsgi process.
sudo cp $PROJECT_BASE_PATH/profiles_project/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart profiles_api

# Setup nginx to make our application accessible.
sudo cp $PROJECT_BASE_PATH/profiles_project/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
sudo systemctl restart nginx.service

echo "DONE! :)"
