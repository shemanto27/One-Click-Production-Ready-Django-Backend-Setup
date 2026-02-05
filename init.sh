#!/bin/bash

# --- 1. Manage uv ---
if ! command -v uv &> /dev/null; then
    echo "uv is not installed. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "uv is already installed. Updating uv..."
    uv self update
fi

# --- 2. Initialize Project ---
echo "Initializing uv project..."
uv init .
rm -f main.py

echo "Installing Django and dependencies..."
uv add django django-cors-headers djangorestframework djangorestframework-simplejwt drf-yasg isort black python-decouple django-extensions gunicorn whitenoise psycopg2-binary sentry-sdk[django] boto3 django-storages

echo "Setting up Django Project..."
source .venv/bin/activate
django-admin startproject core .


# --- 3. Create Apps ---
echo "creating apps folder"
mkdir -p apps
touch apps/__init__.py

echo "------------------------------------------------"
read -p "Enter app names separated by spaces (e.g., users admin): " apps
echo "------------------------------------------------"

for app in $apps; do
    python manage.py startapp "$app"
    mv "$app" apps/
    # Fix the app name in apps.py
    sed -i "s/name = [\"']$app[\"']/name = 'apps.$app'/g" "apps/$app/apps.py"
    echo "Successfully created and moved app: $app"
done

# --- 4. Creating .env file ---
echo "Creating .env file..."
cat > .env << EOF
DEBUG=True
SECRET_KEY=django-insecure-$(openssl rand -base64 32)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# AWS
AWS_ACCESS_KEY_ID=test-access-key
AWS_SECRET_ACCESS_KEY=test-secret-key
AWS_STORAGE_BUCKET_NAME=test-bucket
AWS_S3_REGION_NAME=us-east-1
AWS_S3_CUSTOM_DOMAIN=test-bucket.s3.amazonaws.com
AWS_S3_FILE_OVERWRITE=False

# OpenAI
OPENAI_API_KEY=sk-test-chatgpt-key

# Google OAuth
GOOGLE_WEB_CLIENT_ID=test-google-client-id
GOOGLE_WEB_CLIENT_SECRET=test-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:3001

# Sentry
SENTRY_DSN=
EOF

# --- 5. Update settings.py ---
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

# Keys
OPENAI_API_KEY = config('OPENAI_API_KEY', cast=str, default='test-chatgpt-key')
GOOGLE_WEB_CLIENT_ID = config('GOOGLE_WEB_CLIENT_ID', cast=str, default='test-google-client-id')
GOOGLE_WEB_CLIENT_SECRET = config('GOOGLE_WEB_CLIENT_SECRET', cast=str, default='test-google-client-secret')
GOOGLE_CALLBACK_URL = config('GOOGLE_CALLBACK_URL', cast=str, default='http://localhost:3001')    

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
    "https://api.menusidekick.app", "https://menusidekick.app",
    "http://api.menusidekick.app", "http://menusidekick.app",
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

    # Auth & Social
    'django.contrib.sites',
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.google',
    'dj_rest_auth',
    'dj_rest_auth.registration',

    # Utils
    'drf_yasg',
    'storages',
    'corsheaders',

    # Local Dynamic Apps
    $PYTHON_APPS_LIST
]

INSTALLED_APPS += EXTERNAL_APPS
SITE_ID = 4

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
    "allauth.account.middleware.AccountMiddleware",
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

# -------------------------------
# Allauth Settings
# -------------------------------
ACCOUNT_USER_MODEL_USERNAME_FIELD = None
ACCOUNT_USERNAME_REQUIRED = False
ACCOUNT_EMAIL_REQUIRED = True
ACCOUNT_AUTHENTICATION_METHOD = 'email'
ACCOUNT_EMAIL_VERIFICATION = "none"
ACCOUNT_UNIQUE_EMAIL = True

SOCIALACCOUNT_PROVIDERS = {
    'google': {
        'SCOPE': ['profile', 'email'],
        'AUTH_PARAMS': {'prompt': 'select_account'},
        'OAUTH_PKCE_ENABLED': True,
        'APP': {
            'client_id': GOOGLE_WEB_CLIENT_ID,
            'secret': GOOGLE_WEB_CLIENT_SECRET,
        }
    }
}
EOF


# --- 5. Add gitignore ---
cat <<EOF > .gitignore
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
EOF



# --- 6. Github setup ---
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
    git push -u origin main
    
    echo "Successfully pushed to GitHub!"
else
    echo "GitHub setup skipped."
fi

echo "-------------------🎉🎉🎉-------------------"
echo ""
echo "This setup is made by Shemanto Sharkar"
echo "🚩 Github: https://github.com/shemanto27"
echo "🚩 LinkedIn: https://linkedin.com/in/shemanto"
echo ""
echo "Initialization complete! Your project is production-ready. This is for Django Backend project deployable in AWS with CI/CD pipeline(GitHub Actions), Sentry Error tracking, Docker, Ansible, Terraform, Github setup"
echo "-------------------🎉🎉🎉-------------------"
