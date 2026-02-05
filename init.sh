#!/bin/bash

# --------------------- 1. Manage uv ---------------------
if ! command -v uv &> /dev/null; then
    echo "uv is not installed. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "uv is already installed. Updating uv..."
    uv self update
fi

# --------------------- 2. Initialize Project ---------------------
echo "Initializing uv project..."
uv init .
rm -f main.py

echo "Installing Django and dependencies..."
echo "Installing Core dependencies..."
uv add django django-cors-headers djangorestframework djangorestframework-simplejwt drf-yasg "isort>=5.13.2" "black>=24.4.2" python-decouple django-extensions gunicorn whitenoise psycopg2-binary sentry-sdk[django] boto3 django-storages

echo "Installing Auth & Social dependencies..."
uv add "pre-commit>=3.6.0"

echo "Setting up Django Project..."
source .venv/bin/activate
django-admin startproject core .


# --------------------- 3. Create Apps ---------------------
echo "creating apps folder"
mkdir -p apps
touch apps/__init__.py

echo "------------------------------------------------"
read -p "Enter app names separated by spaces (e.g., users admin): " apps
echo "------------------------------------------------"

for app in $apps; do
    python manage.py startapp "$app"
    mv "$app" apps/
    
    # Fix the app name in apps.py and add a unique label to avoid conflicts (e.g., with 'admin')
    # Using a combined sed for better reliability
    sed -i "s/name = [\"']$app[\"']/name = 'apps.$app'\n    label = 'apps_$app'/g" "apps/$app/apps.py"
    
    # Create industry-standard files
    touch "apps/$app/serializers.py"
    cat > "apps/$app/urls.py" << EOF
from django.urls import path

urlpatterns = [
    # Add your routes here
]
EOF

    echo "Successfully created and moved app: $app (with urls.py and serializers.py)"
done

# --------------------- 4. Creating .env file ---------------------
echo "Creating .env file..."
cat > .env << EOF
# -------------------------------
# Django settings
# -------------------------------
DEBUG=True
SECRET_KEY=django-insecure-$(openssl rand -base64 32)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

ALLOWED_HOSTS=localhost,127.0.0.1,api.example.com,www.api.example.com
CORS_ALLOWED_ORIGINS=http://localhost:3001,http://api.example.com,http://www.api.example.com
 



# -------------------------------
# AWS S3 Settings
# -------------------------------
AWS_ACCESS_KEY_ID=test-access-key
AWS_SECRET_ACCESS_KEY=test-secret-key
AWS_STORAGE_BUCKET_NAME=test-bucket
AWS_S3_REGION_NAME=us-east-1
AWS_S3_FILE_OVERWRITE=False
AWS_DEFAULT_ACL=None
AWS_S3_VERITY=True
DEFAULT_FILE_STORAGE=storages.backends.s3boto3.S3Boto3Storage

# -------------------------------
# PostreSQL Connection Settings
# -------------------------------
DB_ENGINE=django.db.backends.postgresql
DB_NAME=test-db
DB_USER=test-user
DB_PASSWORD=test-password
DB_HOST=localhost
DB_PORT=5432

# -------------------------------
# Django Superuser Credentials
# -------------------------------
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@gmail.com
DJANGO_SUPERUSER_PASSWORD=admin

 
# -------------------------------
# Email configuration
# -------------------------------
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-password


# -------------------------------
# Redis Connection Settings
# -------------------------------
# REDIS_HOST=redis  # for production
REDIS_HOST=localhost
REDIS_PORT=6379

# -------------------------------
# Sentry
# -------------------------------
SENTRY_DSN=
EOF

# --------------------- 5. Generate local app routes for core/urls.py ---------------------
LOCAL_APP_URLS=""
for app in $apps; do
    LOCAL_APP_URLS+="    path('v1/$app/', include('apps.$app.urls')),
"
done

echo "Updating core/urls.py..."
cat > core/urls.py << EOF
from django.contrib import admin
from django.urls import path, include
from django.shortcuts import redirect


#--------------------------------------
# DRF-YASG API Documentation
#--------------------------------------
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
    openapi.Info(
        title="Project API - Made by Shemanto Sharkar",
        default_version='v1',
        description="API documentation for the project by Shemanto",
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)
#--------------------------------------



#--------------------------------------
# Sentry Error Trigger
#--------------------------------------
def trigger_error(request):
    division_by_zero = 1 / 0
#--------------------------------------



#--------------------------------------
# Redirect backend root to docs
#--------------------------------------
def redirect_to_docs(request):
    """Redirect root URL to API documentation"""
    return redirect('schema-swagger-ui')
#--------------------------------------



urlpatterns = [
    path('admin/', admin.site.urls),

    # Sentry Error Trigger
    path('sentry-debug/', trigger_error),

    # Local app routes (v1 prefix)
${LOCAL_APP_URLS}
    
    # API Documentation
    path('api/docs/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('api/swagger.json', schema_view.without_ui(cache_timeout=0), name='schema-json'),

    # Redirect root to docs
    path('', redirect_to_docs, name='root-redirect'),
]
EOF


# --------------------- 6. Update settings.py ---------------------
echo "Updating settings.py with production-ready template..."

# Format the apps list for Python
PYTHON_APPS_LIST=$(echo $apps | sed "s/ /', 'apps./g" | sed "s/^/'apps./" | sed "s/$/'/")

cat > core/settings.py << EOF
from pathlib import Path
from datetime import timedelta
from decouple import config
from urllib.parse import urlparse
import os

# -------------------------------
# Build paths
# -------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent

# -------------------------------
# Environment variables
# -------------------------------
SECRET_KEY = config('SECRET_KEY', cast=str, default='django-insecure-4@#)8^@!$&*0g3v1j2z5x6y7z8w9q0r1s2t3u4v5w6')
DEBUG = config('DEBUG', cast=bool, default=True)

# AWS Settings
AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID', cast=str, default='test-access-key')
AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY', cast=str, default='test-secret-key')
AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME', cast=str, default='test-bucket')
AWS_S3_CUSTOM_DOMAIN = config('AWS_S3_CUSTOM_DOMAIN', cast=str, default='test-bucket.s3.amazonaws.com')
AWS_S3_FILE_OVERWRITE = config('AWS_S3_FILE_OVERWRITE', cast=bool, default=False)
AWS_S3_REGION_NAME = config('AWS_S3_REGION_NAME', cast=str, default='us-east-1')


# -------------------------------
# Sentry Settings
# -------------------------------
if not DEBUG:
    SENTRY_DSN = config('SENTRY_DSN', cast=str, default='')
    if SENTRY_DSN:
        import sentry_sdk
        from sentry_sdk.integrations.django import DjangoIntegration
        sentry_sdk.init(
            dsn=SENTRY_DSN,
            send_default_pii=True,
            traces_sample_rate=0.2,
            integrations=[DjangoIntegration()],
            environment='production',
        )

# -------------------------------
# Security & Hosts
# -------------------------------
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
ALLOWED_HOSTS = ["*"]

# CORS Settings
CORS_ALLOW_ALL_ORIGINS = True 
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS']
CORS_ALLOW_HEADERS = [
    'accept', 'accept-encoding', 'authorization', 'content-type',
    'origin', 'user-agent', 'x-csrftoken', 'x-requested-with',
]

CSRF_TRUSTED_ORIGINS = [
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]

# -------------------------------
# Application definition
# -------------------------------
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

EXTERNAL_APPS = [
    # DRF
    'rest_framework',
    'rest_framework.authtoken',
    'rest_framework_simplejwt.token_blacklist',

    # Utils
    'drf_yasg',
    'storages',
    'corsheaders',

    # Local Dynamic Apps
    $PYTHON_APPS_LIST
]

INSTALLED_APPS += EXTERNAL_APPS
SITE_ID = 1

# -------------------------------
# Middleware
# -------------------------------
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'core.wsgi.application'

# -------------------------------
# Database
# -------------------------------
DATABASE_URL = config("DATABASE_URL", default="postgresql://user:password@localhost:5432/dbname")
tmpPostgres = urlparse(DATABASE_URL)

if DEBUG:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': tmpPostgres.path.replace('/', ''),
            'USER': tmpPostgres.username,
            'PASSWORD': tmpPostgres.password,
            'HOST': tmpPostgres.hostname,
            'PORT': tmpPostgres.port,
        }
    }

# -------------------------------
# Auth & JWT
# -------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_DIRS = [BASE_DIR / "static"] if (BASE_DIR / "static").exists() else []

if DEBUG:
    STORAGES = {
        "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
        "staticfiles": {"BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage"},
    }
else:
    STORAGES = {
        "default": {"BACKEND": "storages.backends.s3boto3.S3Boto3Storage"},
        "staticfiles": {
            "BACKEND": "storages.backends.s3boto3.S3Boto3Storage",
            "OPTIONS": {"location": "static"},
        },
    }

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# JWT Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=31),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
}

EOF


# --------------------- 7. Run Migrations & Create Superuser ---------------------
echo "Running migrations..."
python manage.py makemigrations
python manage.py migrate

echo "Creating superuser..."
export DJANGO_SUPERUSER_USERNAME=admin
export DJANGO_SUPERUSER_EMAIL=admin@gmail.com
export DJANGO_SUPERUSER_PASSWORD=admin123
python manage.py createsuperuser --noinput || echo "Superuser already exists."

# --------------------- 8. Add gitignore ---------------------
cat <<'EOF' > .gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[codz]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py.cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
#   For a library or package, you might want to ignore these files since the code is
#   intended to run in multiple environments; otherwise, check them in:
# .python-version

# pipenv
#   According to pypa/pipenv#598, it is recommended to include Pipfile.lock in version control.
#   However, in case of collaboration, if having platform-specific dependencies or dependencies
#   having no cross-platform support, pipenv may install dependencies that don't work, or not
#   install all needed dependencies.
#Pipfile.lock

# UV
#   Similar to Pipfile.lock, it is generally recommended to include uv.lock in version control.
#   This is especially recommended for binary packages to ensure reproducibility, and is more
#   commonly ignored for libraries.
#uv.lock

# poetry
#   Similar to Pipfile.lock, it is generally recommended to include poetry.lock in version control.
#   This is especially recommended for binary packages to ensure reproducibility, and is more
#   commonly ignored for libraries.
#   https://python-poetry.org/docs/basic-usage/#commit-your-poetrylock-file-to-version-control
#poetry.lock
#poetry.toml

# pdm
#   Similar to Pipfile.lock, it is generally recommended to include pdm.lock in version control.
#   pdm recommends including project-wide configuration in pdm.toml, but excluding .pdm-python.
#   https://pdm-project.org/en/latest/usage/project/#working-with-version-control
#pdm.lock
#pdm.toml
.pdm-python
.pdm-build/

# pixi
#   Similar to Pipfile.lock, it is generally recommended to include pixi.lock in version control.
#pixi.lock
#   Pixi creates a virtual environment in the .pixi directory, just like venv module creates one
#   in the .venv directory. It is recommended not to include this directory in version control.
.pixi

# PEP 582; used by e.g. github.com/David-OConnor/pyflow and github.com/pdm-project/pdm
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.envrc
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# PyCharm
#  JetBrains specific template is maintained in a separate JetBrains.gitignore that can
#  be found at https://github.com/github/gitignore/blob/main/Global/JetBrains.gitignore
#  and can be added to the global gitignore or merged into this file.  For a more nuclear
#  option (not recommended) you can uncomment the following to ignore the entire idea folder.
#.idea/

# Abstra
# Abstra is an AI-powered process automation framework.
# Ignore directories containing user credentials, local state, and settings.
# Learn more at https://abstra.io/docs
.abstra/

# Visual Studio Code
#  Visual Studio Code specific template is maintained in a separate VisualStudioCode.gitignore 
#  that can be found at https://github.com/github/gitignore/blob/main/Global/VisualStudioCode.gitignore
#  and can be added to the global gitignore or merged into this file. However, if you prefer, 
#  you could uncomment the following to ignore the entire vscode folder
# .vscode/

# Ruff stuff:
.ruff_cache/

# PyPI configuration file
.pypirc

# Cursor
#  Cursor is an AI-powered code editor. `.cursorignore` specifies files/directories to
#  exclude from AI features like autocomplete and code analysis. Recommended for sensitive data
#  refer to https://docs.cursor.com/context/ignore-files
.cursorignore
.cursorindexingignore

# Marimo
marimo/_static/
marimo/_lsp/
__marimo__/


.terraform/
*.tfstate
*.tfstate.backup
terraform.tfvars
*aws-credentials/

hosts.ini
*.pem
.env
EOF

# --------------------- 9. ERD bash file ---------------------
echo "Creating ERD bash file..."
cat <<EOF > erd.sh
#!/bin/bash
# Generate Entity Relationship Diagram for all models

python manage.py graph_models -a -g -o erd.jpg
EOF
chmod +x erd.sh

# --------------------- 10. Docker Related Files ---------------------
echo "Creating docker files..."
PROJECT_NAME=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# .dockerignore
cat <<'EOF' > .dockerignore
# Environment files
.env
.env.local
.env.development
.env.production
.backend.env
.frontend.env

# Docker
.dockerignore
docker-compose.override.yml
.venv
__pycache__

# Logs
*.log
npm-debug.log*
yarn-debug.log*
pnpm-debug.log*

# OS / Editor
.DS_Store
Thumbs.db
.vscode/
.idea/
*.swp
*.swo
*.bak

# Coverage / Testing
.coverage
htmlcov/
.tox/
nosetests.xml
coverage.xml
*.cover
*.py,cover
.cache
pytest_cache/

# Git
.gitignore
EOF

# Dockerfile
cat <<EOF > Dockerfile
# Base image
FROM python:3.12-slim-bullseye

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1  
ENV PYTHONUNBUFFERED=1

# Install uv
RUN pip install uv

# Set the working directory
WORKDIR /app

# Copy only dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen

# adding venv's bin to PATH
ENV PATH="/app/.venv/bin:\$PATH"

# Copy the rest of the application code
COPY . .

# Copy entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose the port the app runs on
EXPOSE 8000

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Start server using Python module (most reliable with uv)
CMD ["python", "-m", "gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "4", "--timeout", "120"]
EOF

# docker-compose.dev.yml
cat <<EOF > docker-compose.dev.yml
version: "3.9"

services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    image: ${PROJECT_NAME}-backend
    container_name: ${PROJECT_NAME}-backend
    ports:
      - "8000:8000"
    env_file:
      - .env
    restart: always
EOF

# docker-compose.prod.yml
cat <<EOF > docker-compose.prod.yml
version: "3.9"

services:
  backend:
    image: shemanto27/${PROJECT_NAME}:backend-latest
    container_name: ${PROJECT_NAME}-backend
    ports:
      - "8000:8000"
    env_file:
      - .env
    restart: always
EOF

# entrypoint.sh
cat <<'EOF' > entrypoint.sh
#!/bin/sh
set -e

echo "Starting Django entrypoint script..."

# 1. Wait for database (only if DATABASE_URL is set)
if [ -n "$DATABASE_URL" ]; then
  echo "Waiting for database..."
  sleep 3
fi

# 2. Apply database migrations
echo "Running migrations..."
python manage.py migrate --noinput

# 3. Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

# 4. Create superuser only if credentials are provided
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "Creating superuser..."
  python manage.py createsuperuser --noinput || echo "Superuser already exists or creation failed"
else
  echo "Skipping superuser creation - credentials not provided"
fi

echo "Entrypoint script completed successfully!"

# 5. Execute the CMD from Dockerfile
echo "Starting Gunicorn..."
exec "$@"
EOF

chmod +x entrypoint.sh
echo "Docker files created successfully!"


# --------------------- 11. CI/CD setup ---------------------
echo "Creating CI/CD files for GitHub Actions..."
mkdir -p .github/workflows

cat <<EOF > .github/workflows/pipeline.yml
# name: CI/CD Pipeline
# 
# on:
#   push:
#     branches:
#       - main
# 
# env:
#   DOCKER_REPO: shemanto27/${PROJECT_NAME}
#   BACKEND_TAG_LATEST: backend-latest
# 
#   
# jobs:
#   dockerhub:
#     name: Build, Tag and Push on Docker Hub
#     runs-on: ubuntu-latest
# 
#     steps:
#       - name: Checkout code
#         uses: actions/checkout@v3
# 
#       # Optional: run tests
#       - name: Run tests
#         run: |
#           echo "Skipping tests (add your test commands)"
# 
#       - name: Log in to Docker Hub
#         env:
#           DOCKERHUB_USERNAME: \${{ secrets.DOCKERHUB_USERNAME }}
#           DOCKERHUB_TOKEN: \${{ secrets.DOCKERHUB_TOKEN }}
#         run: |
#           echo "\$DOCKERHUB_TOKEN" | docker login -u "\$DOCKERHUB_USERNAME" --password-stdin
# 
#       - name: Build backend image
#         run: |
#           docker build --no-cache -t \$DOCKER_REPO:\$BACKEND_TAG_LATEST .
# 
#       - name: Push backend image
#         run: docker push \$DOCKER_REPO:\$BACKEND_TAG_LATEST
#         
# 
#   deploy:
#     name: Deploy to EC2
#     runs-on: ubuntu-latest
#     needs: dockerhub
# 
#     steps:
#       - name: SSH to EC2 and deploy
#         uses: appleboy/ssh-action@v1.0.0
#         with:
#           host: \${{ secrets.EC2_HOST }}
#           username: \${{ secrets.EC2_USER }}
#           key: \${{ secrets.EC2_SSH_PRIVATE_KEY }}
#           script: |
#             set -e
#             cd /home/ubuntu/backend
#             docker compose -f docker-compose.prod.yml down
#             docker compose -f docker-compose.prod.yml pull
#             docker compose -f docker-compose.prod.yml up -d --force-recreate --remove-orphans
#             sudo systemctl restart nginx
EOF
echo "CI/CD files created (commented out by default)."

# --------------------- 12. IaC setup ---------------------
echo "Creating Infrastructure as Code (IaC) files..."
mkdir -p infra/ansible infra/terraform

# Ansible hosts.ini
cat <<EOF > infra/ansible/hosts.ini
[webservers]
ec2-1 ansible_host=YOUR_EC2_PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/mykey.pem
EOF

# Ansible playbook.yml
cat <<EOF > infra/ansible/playbook.yml
- hosts: webservers
  become: yes

  vars:
    backend_path: /home/ubuntu/backend
    website_domain: example.com           
    certbot_email: your-email@example.com 
    env_file_src: ../../.env
    docker_compose_src: ../../docker-compose.prod.yml
    nginx_conf_src: ../../nginx.backend.conf

  tasks:
    - name: Update apt packages
      apt:
        update_cache: yes
        upgrade: dist

    - name: Install dependencies
      apt:
        name:
          - docker.io
          - docker-compose
          - nginx
          - certbot
          - python3-certbot-nginx
        state: present

    - name: Create backend folder
      file:
        path: "{{ backend_path }}"
        state: directory
        mode: "0755"

    - name: Copy .env file from local to EC2
      copy:
        src: "{{ env_file_src }}"
        dest: "{{ backend_path }}/.env"
        mode: "0600"

    - name: Copy docker-compose.prod.yml to EC2
      copy:
        src: "{{ docker_compose_src }}"
        dest: "{{ backend_path }}/docker-compose.yml"
        mode: "0644"
      notify:
        - restart docker-compose

    - name: Copy Nginx config to EC2
      copy:
        src: "{{ nginx_conf_src }}"
        dest: /etc/nginx/sites-available/backend
        mode: "0644"
      notify:
        - reload nginx

    - name: Enable Nginx site
      file:
        src: /etc/nginx/sites-available/backend
        dest: /etc/nginx/sites-enabled/backend
        state: link
      notify:
        - reload nginx

    - name: Remove default Nginx site
      file:
        path: /etc/nginx/sites-enabled/default
        state: absent
      notify:
        - reload nginx

    - name: Obtain SSL certificate via Certbot
      command: >
        certbot --nginx
        -d {{ website_domain }}
        --non-interactive
        --agree-tos
        -m {{ certbot_email }}
      args:
        creates: /etc/letsencrypt/live/{{ website_domain }}/fullchain.pem

  handlers:
    - name: reload nginx
      service:
        name: nginx
        state: reloaded

    - name: restart docker-compose
      command: docker-compose up -d
      args:
        chdir: "{{ backend_path }}"
EOF

# Terraform main.tf
cat <<EOF > infra/terraform/main.tf
# AWS Key Pair
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key-${PROJECT_NAME}"
  public_key = file("~/.ssh/id_rsa.pub")
}


# EC2 instance
resource "aws_instance" "ec2_server_1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "${PROJECT_NAME}"
  }
}

# Elastic IP
resource "aws_eip" "static_ip" {
  instance = aws_instance.ec2_server_1.id
}


# S3 bucket
resource "aws_s3_bucket" "media" {
  bucket = var.bucket_name
}


# RDS Postgres
resource "aws_db_instance" "postgres" {
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "${PROJECT_NAME}db"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.ec2_sg.id] 
  publicly_accessible    = false                          
}
EOF

# Terraform outputs.tf
cat <<'EOF' > infra/terraform/outputs.tf
output "ec2_public_ip" {
  value = aws_eip.static_ip.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.media.bucket
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS instance endpoint (hostname)"
  sensitive   = true
}

output "rds_username" {
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

output "rds_password" {
  value       = aws_db_instance.postgres.password
  sensitive   = true
}
EOF

# Terraform provider.tf
cat <<EOF > infra/terraform/provider.tf
provider "aws" {
  region  = "us-east-1"
  profile = "terraform-user-1"
}
EOF

# Terraform security_groups.tf
cat <<'EOF' > infra/terraform/security_groups.tf
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-allow-all-testing"
  description = "Allow all inbound traffic for testing only"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Django / API
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-allow-all-testing"
  }
}
EOF

# Terraform variables.tf
cat <<'EOF' > infra/terraform/variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami" {
  description = "AMI"
  default     = "ami-061fe7df6ad657197"
}

variable "bucket_name" {
  description = "S3 bucket name"
}

variable "ec2_name" {
  description = "Name tag for EC2 instance"
}

variable "db_username" {
  description = "RDS Postgres username"
}

variable "db_password" {
  description = "RDS Postgres password"
  sensitive   = true
}
EOF

echo "IaC files created successfully!"

# --------------------- 13. Code Formatting Setup ---------------------
echo "Setting up code formatting tools..."

# .pre-commit-config.yaml
cat <<EOF > .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-toml
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 24.4.2
    hooks:
      - id: black
        language_version: python3
        args: ['--line-length=120']

  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: ['--profile', 'black', '--line-length=120']
EOF

# Append black and isort configuration to pyproject.toml
cat <<EOF >> pyproject.toml

[tool.black]
line-length = 120
target-version = ['py312']

[tool.isort]
profile = "black"
line_length = 120
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
EOF

# Install pre-commit hooks using uv to ensure it's linked to the project's venv
if [ -d ".git" ] || [ -f ".git" ]; then
    uv run pre-commit install
else
    # If git isn't initialized yet, we'll initialize it now to make pre-commit work
    git init
    uv run pre-commit install
fi

echo "Code formatting setup complete!"

# --------------------- 14. Github setup ---------------------

echo "------------------------------------------------"
read -p "Enter GitHub Repository URL (or press Enter to skip): " GITHUB_URL
echo "------------------------------------------------"

if [ -n "$GITHUB_URL" ]; then
    # Convert HTTPS URL to SSH if it matches standard github format
    if [[ $GITHUB_URL == https://github.com/* ]]; then
        REPO_PATH=${GITHUB_URL#https://github.com/}
        # Remove trailing slash if exists
        REPO_PATH=${REPO_PATH%/}
        # Ensure .git suffix isn't doubled
        REPO_PATH=${REPO_PATH%.git}
        SSH_URL="git@github.com:${REPO_PATH}.git"
    else
        SSH_URL=$GITHUB_URL
    fi

    echo "Initializing Git and pushing to $SSH_URL..."
    
    # Initialize and push
    git init
    if [ ! -f "README.md" ]; then
        echo "# Project Created with One-Click Production-Ready Django Setup" > README.md
    fi
    git add .
    git commit -m "first commit"
    git branch -M main
    git remote add origin "$SSH_URL"
    # git push -u origin main
    
    echo "Local Git initialized and remote 'origin' added. You can now push your code."
else
    echo "GitHub setup skipped."
fi

echo "-------------------🎉🎉🎉-------------------"
echo ""
echo "This setup is made by Shemanto Sharkar"
echo "🚩 Github: https://github.com/shemanto27"
echo "🚩 LinkedIn: https://linkedin.com/in/shemanto"
echo ""
echo "Initialization complete! Your project is production-ready. This is for Django Backend project deployable in AWS with CI/CD pipeline(GitHub Actions), Sentry Error tracking, Docker, Ansible, Terraform, ERD generation, Pre-commit code formatting, and Github setup"
echo "-------------------🎉🎉🎉-------------------"
