#!/bin/bash

###############################################################################
# Script de Instalación Automatizada - Servidor Web Ubuntu 24.04 LTS
# Stack: Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js
# Autor: DevOps Senior
# Fecha: 2025-10-16
###############################################################################

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
print_step() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}ADVERTENCIA: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Verificar que se ejecuta como root o con sudo
if [[ $EUID -ne 0 ]]; then
   print_error "Este script debe ejecutarse como root o con sudo"
   exit 1
fi

###############################################################################
# 1. CARGAR VARIABLES DE ENTORNO
###############################################################################

print_step "1. Configurando variables de entorno..."

mkdir -p /etc/arush

cat > /etc/arush/env.sh <<'EOF'
# ===== Variables obligatorias =====
export TIMEZONE="America/Mexico_City"
export LAN_CIDR="192.168.1.0/24"
export SRV_IP="192.168.1.13"
export DOMAIN="arush.local"

# Hostname del sistema (FQDN) requerido para DNS interno y servicios
export HOSTNAME="app.arush.local"

# Vhosts
export APP_HOST="app.${DOMAIN}"
export FRONT_HOST="front.${DOMAIN}"
export BLOG_HOST="blog.${DOMAIN}"

# Raíces de proyecto
export APP_ROOT="/var/www/app"
export FRONT_ROOT="/var/www/front"
export BLOG_ROOT="/var/www/blog"

# TLS/CA
export CA_DIR="/etc/ssl/localCA"
export CERT_DIR="/etc/ssl/certs"
export KEY_DIR="/etc/ssl/private"
export CERT_NAME="arush-local-san"
export CRT_FILE="${CERT_DIR}/${CERT_NAME}.crt"
export KEY_FILE="${KEY_DIR}/${CERT_NAME}.key"
export FULLCHAIN="${CERT_DIR}/${CERT_NAME}-fullchain.pem"
export DH_PARAM="${CERT_DIR}/dhparam.pem"

# Snippets Nginx
export TLS_SNIPPET="/etc/nginx/snippets/tls-arush.conf"
export HDRS_SNIPPET="/etc/nginx/snippets/headers-arush.conf"

# Usuarios/grupos
export WEB_USER="www-data"
export DEV_USER="suburbak"

# Laravel runtime
export STORAGE_DIR="${APP_ROOT}/storage"
export CACHE_DIR="${APP_ROOT}/bootstrap/cache"
export VIEWS_DIR="${STORAGE_DIR}/framework/views"
export SESSIONS_DIR="${STORAGE_DIR}/framework/sessions"
export FRAMEWORK_CACHE_DIR="${STORAGE_DIR}/framework/cache"

# PostgreSQL
export DB_USER="arush"
export DB_PASS="R2705mr2"
export DB_NAME="app_arush"
export PG_VER="16"
export PG_CLUSTER="main"
export PG_CONF_DIR="/etc/postgresql/${PG_VER}/${PG_CLUSTER}"

# Otros
export DATE_TAG="$(date +%F_%H%M%S)"
EOF

source /etc/arush/env.sh

# Hacer persistentes las variables
echo "source /etc/arush/env.sh" > /etc/profile.d/arush-env.sh
chmod +x /etc/profile.d/arush-env.sh

print_success "Variables de entorno configuradas"

###############################################################################
# 2. CONFIGURACIÓN INICIAL DEL SISTEMA
###############################################################################

print_step "2. Configuración inicial del sistema..."

# Actualizar sistema
apt update && apt upgrade -y

# Configurar zona horaria
timedatectl set-timezone ${TIMEZONE}
print_success "Zona horaria configurada: ${TIMEZONE}"

# Configurar hostname
hostnamectl set-hostname ${HOSTNAME}
print_success "Hostname configurado: ${HOSTNAME}"

# Actualizar /etc/hosts
cat >> /etc/hosts <<EOF

# Configuración local Arush
${SRV_IP} ${APP_HOST}
${SRV_IP} ${FRONT_HOST}
${SRV_IP} ${BLOG_HOST}
EOF
print_success "Archivo /etc/hosts actualizado"

# Instalar paquetes esenciales
apt install -y curl wget git unzip software-properties-common \
    build-essential apt-transport-https ca-certificates gnupg lsb-release

# Crear usuario de desarrollo
if ! id "${DEV_USER}" &>/dev/null; then
    useradd -m -s /bin/bash ${DEV_USER}
    usermod -aG sudo ${DEV_USER}
    print_success "Usuario ${DEV_USER} creado"
else
    print_warning "Usuario ${DEV_USER} ya existe"
fi

###############################################################################
# 3. CONFIGURACIÓN DE SSH
###############################################################################

print_step "3. Configurando SSH..."

# Backup
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.${DATE_TAG}

cat > /etc/ssh/sshd_config.d/99-arush-security.conf <<'EOF'
# Configuración de seguridad SSH - Arush Local
Port 22
AddressFamily inet
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
MaxAuthTries 3
MaxSessions 5
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive yes
AllowUsers suburbak
X11Forwarding no
AllowTcpForwarding yes
AllowStreamLocalForwarding no
PrintMotd no
PrintLastLog yes
EOF

systemctl restart sshd
print_success "SSH configurado"

###############################################################################
# 4. CONFIGURACIÓN DE FIREWALL UFW
###############################################################################

print_step "4. Configurando firewall UFW..."

apt install -y ufw

# Configurar reglas
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from ${LAN_CIDR} to any port 22 proto tcp comment 'SSH desde LAN'
ufw allow from ${LAN_CIDR} to any port 80 proto tcp comment 'HTTP desde LAN'
ufw allow from ${LAN_CIDR} to any port 443 proto tcp comment 'HTTPS desde LAN'
ufw allow from ${LAN_CIDR} to any port 5432 proto tcp comment 'PostgreSQL desde LAN'
ufw allow from ${LAN_CIDR} to any port 5050 proto tcp comment 'pgAdmin desde LAN'

ufw logging medium
ufw --force enable

print_success "UFW configurado y habilitado"

###############################################################################
# 5. INSTALACIÓN DE NGINX
###############################################################################

print_step "5. Instalando Nginx..."

apt install -y nginx

# Configurar Nginx
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.${DATE_TAG}

cat > /etc/nginx/nginx.conf <<'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 2048;
    multi_accept on;
    use epoll;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    client_max_body_size 100M;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';

    access_log /var/log/nginx/access.log;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml font/truetype font/opentype 
               application/vnd.ms-fontobject image/svg+xml;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

mkdir -p /etc/nginx/snippets
rm -f /etc/nginx/sites-enabled/default

systemctl enable nginx
systemctl restart nginx

print_success "Nginx instalado y configurado"

###############################################################################
# 6. INSTALACIÓN DE PHP 8.3
###############################################################################

print_step "6. Instalando PHP 8.3..."

add-apt-repository -y ppa:ondrej/php
apt update

apt install -y php8.3 php8.3-fpm php8.3-cli php8.3-common \
    php8.3-pgsql php8.3-zip php8.3-gd php8.3-mbstring php8.3-curl \
    php8.3-xml php8.3-bcmath php8.3-intl php8.3-redis php8.3-opcache \
    php8.3-readline php8.3-tokenizer

# Configurar PHP
cp /etc/php/8.3/fpm/php.ini /etc/php/8.3/fpm/php.ini.backup.${DATE_TAG}

sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.3/fpm/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php/8.3/fpm/php.ini
sed -i 's/post_max_size = .*/post_max_size = 100M/' /etc/php/8.3/fpm/php.ini
sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/8.3/fpm/php.ini
sed -i 's/;date.timezone =.*/date.timezone = America\/Mexico_City/' /etc/php/8.3/fpm/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.3/fpm/php.ini

# Configurar pool PHP-FPM
cp /etc/php/8.3/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/www.conf.backup.${DATE_TAG}

cat > /etc/php/8.3/fpm/pool.d/www.conf <<'EOF'
[www]
user = www-data
group = www-data
listen = /run/php/php8.3-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500

php_admin_value[error_log] = /var/log/php8.3-fpm.log
php_admin_flag[log_errors] = on
EOF

systemctl enable php8.3-fpm
systemctl restart php8.3-fpm

print_success "PHP 8.3 instalado: $(php -v | head -n 1)"

###############################################################################
# 7. INSTALACIÓN DE POSTGRESQL
###############################################################################

print_step "7. Instalando PostgreSQL 16..."

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | tee /etc/apt/trusted.gpg.d/pgdg.asc

apt update
apt install -y postgresql-${PG_VER} postgresql-contrib-${PG_VER}

# Configurar PostgreSQL
cp ${PG_CONF_DIR}/pg_hba.conf ${PG_CONF_DIR}/pg_hba.conf.backup.${DATE_TAG}

cat >> ${PG_CONF_DIR}/pg_hba.conf <<EOF

# Configuración Arush Local
host    all             all             ${LAN_CIDR}            scram-sha-256
EOF

cp ${PG_CONF_DIR}/postgresql.conf ${PG_CONF_DIR}/postgresql.conf.backup.${DATE_TAG}
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" ${PG_CONF_DIR}/postgresql.conf

# Crear usuario y base de datos
sudo -u postgres psql <<EOF
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';
CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
\q
EOF

systemctl enable postgresql
systemctl restart postgresql

print_success "PostgreSQL 16 instalado y configurado"

###############################################################################
# 8. INSTALACIÓN DE PGADMIN 4
###############################################################################

print_step "8. Instalando pgAdmin 4..."

curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'

apt update
apt install -y pgadmin4-web

# Configurar pgAdmin
/usr/pgadmin4/bin/setup-web.sh <<EOF
admin@arush.local
${DB_PASS}
${DB_PASS}
y
EOF

# Configurar Nginx para pgAdmin
cat > /etc/nginx/sites-available/pgadmin <<'EOF'
server {
    listen 5050;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:80/pgadmin4;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_redirect off;
    }
}
EOF

ln -sf /etc/nginx/sites-available/pgadmin /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

print_success "pgAdmin 4 instalado (http://${SRV_IP}:5050/pgadmin4)"

###############################################################################
# 9. CREACIÓN DE CERTIFICADOS SSL
###############################################################################

print_step "9. Generando certificados SSL autofirmados (válidos 10 años)..."

# Crear estructura CA
mkdir -p ${CA_DIR}/{certs,crl,newcerts,private}
chmod 700 ${CA_DIR}/private
touch ${CA_DIR}/index.txt
echo 1000 > ${CA_DIR}/serial

# Configuración OpenSSL CA
cat > ${CA_DIR}/openssl-ca.cnf <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = ${CA_DIR}
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

private_key       = \$dir/private/ca.key
certificate       = \$dir/certs/ca.crt

default_md        = sha256
default_days      = 3650
preserve          = no
policy            = policy_loose

[ policy_loose ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF

# Generar CA
openssl genrsa -out ${CA_DIR}/private/ca.key 4096
chmod 400 ${CA_DIR}/private/ca.key

openssl req -config ${CA_DIR}/openssl-ca.cnf \
    -key ${CA_DIR}/private/ca.key \
    -new -x509 -days 3650 -sha256 -extensions v3_ca \
    -out ${CA_DIR}/certs/ca.crt \
    -subj "/C=MX/ST=Estado/L=Ciudad/O=Arush/OU=IT/CN=Arush Local CA"

print_success "CA generada"

# Configuración SAN
cat > ${CA_DIR}/openssl-san.cnf <<EOF
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = v3_req
prompt             = no

[ req_distinguished_name ]
C  = MX
ST = Estado
L  = Ciudad
O  = Arush
OU = Development
CN = ${DOMAIN}

[ v3_req ]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${DOMAIN}
DNS.2 = *.${DOMAIN}
DNS.3 = ${APP_HOST}
DNS.4 = ${FRONT_HOST}
DNS.5 = ${BLOG_HOST}
IP.1  = ${SRV_IP}
IP.2  = 127.0.0.1
EOF

# Generar certificado servidor
openssl genrsa -out ${KEY_FILE} 2048
chmod 600 ${KEY_FILE}

openssl req -new \
    -key ${KEY_FILE} \
    -out ${CA_DIR}/${CERT_NAME}.csr \
    -config ${CA_DIR}/openssl-san.cnf

openssl x509 -req \
    -in ${CA_DIR}/${CERT_NAME}.csr \
    -CA ${CA_DIR}/certs/ca.crt \
    -CAkey ${CA_DIR}/private/ca.key \
    -CAcreateserial \
    -out ${CRT_FILE} \
    -days 3650 \
    -sha256 \
    -extensions v3_req \
    -extfile ${CA_DIR}/openssl-san.cnf

# Crear fullchain
cat ${CRT_FILE} ${CA_DIR}/certs/ca.crt > ${FULLCHAIN}

# Generar DH params
openssl dhparam -out ${DH_PARAM} 2048

print_success "Certificado SSL generado (válido 10 años)"

# Crear snippets Nginx
cat > ${TLS_SNIPPET} <<EOF
ssl_certificate ${FULLCHAIN};
ssl_certificate_key ${KEY_FILE};
ssl_dhparam ${DH_PARAM};
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;
ssl_stapling off;
ssl_stapling_verify off;
EOF

cat > ${HDRS_SNIPPET} <<'EOF'
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
EOF

###############################################################################
# 10. CONFIGURACIÓN DE VIRTUAL HOSTS
###############################################################################

print_step "10. Configurando Virtual Hosts..."

# Crear directorios
mkdir -p ${APP_ROOT} ${FRONT_ROOT} ${BLOG_ROOT}
chown -R ${WEB_USER}:${WEB_USER} /var/www
chmod -R 755 /var/www

# VHost app.arush.local
cat > /etc/nginx/sites-available/${APP_HOST} <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${APP_HOST};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${APP_HOST};

    root ${APP_ROOT}/public;
    index index.php index.html;

    include ${TLS_SNIPPET};
    include ${HDRS_SNIPPET};

    access_log /var/log/nginx/${APP_HOST}-access.log;
    error_log /var/log/nginx/${APP_HOST}-error.log;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\. {
        deny all;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# VHost front.arush.local
cat > /etc/nginx/sites-available/${FRONT_HOST} <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${FRONT_HOST};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${FRONT_HOST};

    root ${FRONT_ROOT}/dist;
    index index.html;

    include ${TLS_SNIPPET};
    include ${HDRS_SNIPPET};

    access_log /var/log/nginx/${FRONT_HOST}-access.log;
    error_log /var/log/nginx/${FRONT_HOST}-error.log;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location = /index.html {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }
}
EOF

# VHost blog.arush.local
cat > /etc/nginx/sites-available/${BLOG_HOST} <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${BLOG_HOST};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${BLOG_HOST};

    root ${BLOG_ROOT}/dist;
    index index.html;

    include ${TLS_SNIPPET};
    include ${HDRS_SNIPPET};

    access_log /var/log/nginx/${BLOG_HOST}-access.log;
    error_log /var/log/nginx/${BLOG_HOST}-error.log;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location = /index.html {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }
}
EOF

# Habilitar vhosts
ln -sf /etc/nginx/sites-available/${APP_HOST} /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/${FRONT_HOST} /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/${BLOG_HOST} /etc/nginx/sites-enabled/

nginx -t && systemctl reload nginx

print_success "Virtual Hosts configurados"

###############################################################################
# 11. INSTALACIÓN DE COMPOSER
###############################################################################

print_step "11. Instalando Composer..."

cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

print_success "Composer instalado: $(composer --version)"

###############################################################################
# 12. INSTALACIÓN DE NODE.JS Y NPM
###############################################################################

print_step "12. Instalando Node.js y NPM..."

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

npm install -g yarn pnpm @vue/cli vite

print_success "Node.js instalado: $(node --version)"
print_success "NPM instalado: $(npm --version)"

###############################################################################
# 13. DESPLIEGUE DE LARAVEL 11
###############################################################################

print_step "13. Desplegando Laravel 11..."

cd /var/www

# Verificar si ya existe el proyecto
if [ ! -d "${APP_ROOT}/artisan" ]; then
    composer create-project laravel/laravel:^11.0 app --prefer-dist
    print_success "Laravel 11 creado"
else
    print_warning "Laravel ya existe en ${APP_ROOT}"
fi

# Configurar permisos
chown -R ${WEB_USER}:${WEB_USER} ${APP_ROOT}
chmod -R 755 ${APP_ROOT}
chmod -R 775 ${APP_ROOT}/storage
chmod -R 775 ${APP_ROOT}/bootstrap/cache

usermod -aG ${WEB_USER} ${DEV_USER}

# Configurar .env
cat > ${APP_ROOT}/.env <<EOF
APP_NAME=Arush
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_TIMEZONE=${TIMEZONE}
APP_URL=https://${APP_HOST}

APP_LOCALE=es
APP_FALLBACK_LOCALE=es
APP_FAKER_LOCALE=es_MX

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
CACHE_STORE=file
SESSION_DRIVER=database
SESSION_LIFETIME=120

MAIL_MAILER=log
MAIL_FROM_ADDRESS="noreply@arush.local"
MAIL_FROM_NAME="\${APP_NAME}"

VITE_APP_NAME="\${APP_NAME}"
EOF

chmod 640 ${APP_ROOT}/.env

# Generar APP_KEY
cd ${APP_ROOT}
sudo -u ${WEB_USER} php artisan key:generate

# Ejecutar migraciones
sudo -u ${WEB_USER} php artisan migrate --force

# Optimizar para producción
sudo -u ${WEB_USER} php artisan config:cache
sudo -u ${WEB_USER} php artisan route:cache
sudo -u ${WEB_USER} php artisan view:cache
sudo -u ${WEB_USER} composer install --optimize-autoloader --no-dev

print_success "Laravel 11 desplegado en ${APP_HOST}"

###############################################################################
# 14. DESPLIEGUE DE VUE.JS
###############################################################################

print_step "14. Desplegando proyectos Vue.js..."

# Frontend Vue.js
cd /var/www
if [ ! -d "${FRONT_ROOT}/package.json" ]; then
    sudo -u ${WEB_USER} vue create front -d
    
    cat > ${FRONT_ROOT}/vue.config.js <<'EOF'
const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  publicPath: '/',
  outputDir: 'dist',
  assetsDir: 'assets',
  productionSourceMap: false,
  
  devServer: {
    port: 8080,
    proxy: {
      '/api': {
        target: 'https://app.arush.local',
        changeOrigin: true,
        secure: false
      }
    }
  }
})
EOF

    chown -R ${WEB_USER}:${WEB_USER} ${FRONT_ROOT}
    cd ${FRONT_ROOT}
    sudo -u ${WEB_USER} npm install
    sudo -u ${WEB_USER} npm run build
    
    print_success "Frontend Vue.js desplegado en ${FRONT_HOST}"
else
    print_warning "Frontend Vue.js ya existe en ${FRONT_ROOT}"
fi

# Blog Vue.js
cd /var/www
if [ ! -d "${BLOG_ROOT}/package.json" ]; then
    sudo -u ${WEB_USER} npm create vite@latest blog -- --template vue
    
    cat > ${BLOG_ROOT}/vite.config.js <<'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: '/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'terser'
  }
})
EOF

    chown -R ${WEB_USER}:${WEB_USER} ${BLOG_ROOT}
    cd ${BLOG_ROOT}
    sudo -u ${WEB_USER} npm install
    sudo -u ${WEB_USER} npm run build
    
    print_success "Blog Vue.js desplegado en ${BLOG_HOST}"
else
    print_warning "Blog Vue.js ya existe en ${BLOG_ROOT}"
fi

###############################################################################
# 15. VERIFICACIÓN FINAL
###############################################################################

print_step "15. Verificación final del sistema..."

echo ""
echo "=== Estado de Servicios ==="
systemctl status nginx --no-pager | grep -E 'Active|Loaded' || true
systemctl status php8.3-fpm --no-pager | grep -E 'Active|Loaded' || true
systemctl status postgresql --no-pager | grep -E 'Active|Loaded' || true

echo ""
echo "=== Versiones Instaladas ==="
nginx -v 2>&1
php -v | head -n 1
psql --version
composer --version | head -n 1
node --version
npm --version

echo ""
echo "=== Puertos en Escucha ==="
ss -tlnp | grep -E '(80|443|5432|5050)' || true

echo ""
echo "=== Verificación SSL ==="
openssl x509 -in ${CRT_FILE} -text -noout | grep -E '(Not Before|Not After)' || true

echo ""
print_success "¡Instalación completada exitosamente!"

echo ""
echo -e "${GREEN}=== URLs de Acceso ===${NC}"
echo -e "  • Laravel Backend:   ${BLUE}https://${APP_HOST}${NC}"
echo -e "  • Vue.js Frontend:   ${BLUE}https://${FRONT_HOST}${NC}"
echo -e "  • Blog Vue.js:       ${BLUE}https://${BLOG_HOST}${NC}"
echo -e "  • pgAdmin 4:         ${BLUE}http://${SRV_IP}:5050/pgadmin4${NC}"
echo ""
echo -e "${YELLOW}Nota: Debes agregar las siguientes líneas a /etc/hosts en tu máquina cliente:${NC}"
echo -e "  ${SRV_IP} ${APP_HOST}"
echo -e "  ${SRV_IP} ${FRONT_HOST}"
echo -e "  ${SRV_IP} ${BLOG_HOST}"
echo ""
echo -e "${YELLOW}Para evitar advertencias SSL, importa el certificado CA:${NC}"
echo -e "  ${CA_DIR}/certs/ca.crt"
echo ""

###############################################################################
# SCRIPT DE BACKUP AUTOMATIZADO
###############################################################################

cat > /usr/local/bin/backup-arush.sh <<'BACKUP_EOF'
#!/bin/bash
source /etc/arush/env.sh

BACKUP_DIR="/backup/arush"
mkdir -p ${BACKUP_DIR}

# Backup base de datos
PGPASSWORD=${DB_PASS} pg_dump -h 127.0.0.1 -U ${DB_USER} ${DB_NAME} > ${BACKUP_DIR}/db_${DATE_TAG}.sql

# Backup archivos
tar -czf ${BACKUP_DIR}/app_${DATE_TAG}.tar.gz ${APP_ROOT}
tar -czf ${BACKUP_DIR}/front_${DATE_TAG}.tar.gz ${FRONT_ROOT}
tar -czf ${BACKUP_DIR}/blog_${DATE_TAG}.tar.gz ${BLOG_ROOT}

# Limpiar backups antiguos
find ${BACKUP_DIR} -name "*.sql" -mtime +30 -delete
find ${BACKUP_DIR} -name "*.tar.gz" -mtime +30 -delete

echo "Backup completado: ${DATE_TAG}"
BACKUP_EOF

chmod +x /usr/local/bin/backup-arush.sh

print_success "Script de backup creado en /usr/local/bin/backup-arush.sh"

echo ""
echo -e "${GREEN}¡Instalación del servidor completada!${NC}"
echo -e "${BLUE}Documentación completa en: /workspace/PROCEDIMIENTO_INSTALACION_SERVIDOR.md${NC}"
