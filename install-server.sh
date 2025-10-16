#!/bin/bash

###############################################################################
# Script de Instalación Automatizada - Servidor Web Ubuntu 24.04 LTS
# Stack: Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js
# Autor: DevOps Senior
# Fecha: 2025-10-16
# Versión: 2.0 (Corregida y Probada)
###############################################################################

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funciones de utilidad
print_header() {
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}$1${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
}

print_step() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ADVERTENCIA: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Verificar que se ejecuta como root o con sudo
if [[ $EUID -ne 0 ]]; then
   print_error "Este script debe ejecutarse como root o con sudo"
   exit 1
fi

print_header "Instalación Automatizada - Stack Web Completo"
print_info "Ubuntu 24.04 LTS + Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js"
print_info "Tiempo estimado: 20-30 minutos"
echo ""

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
print_info "Actualizando sistema operativo..."
apt update && apt upgrade -y

# Configurar zona horaria
timedatectl set-timezone ${TIMEZONE}
print_success "Zona horaria configurada: ${TIMEZONE}"

# Configurar hostname
hostnamectl set-hostname ${HOSTNAME}
print_success "Hostname configurado: ${HOSTNAME}"

# Actualizar /etc/hosts
if ! grep -q "# Configuración local Arush" /etc/hosts; then
    cat >> /etc/hosts <<EOF

# Configuración local Arush
${SRV_IP} ${APP_HOST}
${SRV_IP} ${FRONT_HOST}
${SRV_IP} ${BLOG_HOST}
EOF
    print_success "Archivo /etc/hosts actualizado"
else
    print_warning "Entrada en /etc/hosts ya existe"
fi

# Instalar paquetes esenciales
print_info "Instalando paquetes esenciales..."
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

print_success "Sistema configurado correctamente"

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

# Reiniciar SSH (en Ubuntu es 'ssh' no 'sshd')
systemctl restart ssh
print_success "SSH configurado y asegurado"

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

ufw logging medium
ufw --force enable

print_success "UFW configurado y habilitado (solo red local: ${LAN_CIDR})"

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

print_info "Instalando PHP 8.3 y extensiones requeridas..."
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
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | tee /etc/apt/trusted.gpg.d/pgdg.asc > /dev/null

apt update
print_info "Instalando PostgreSQL 16..."
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
print_info "Creando usuario y base de datos..."
sudo -u postgres psql <<EOF
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';
CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
\q
EOF

systemctl enable postgresql
systemctl restart postgresql

print_success "PostgreSQL 16 instalado y configurado"
print_info "Usuario: ${DB_USER} | Base de datos: ${DB_NAME}"

###############################################################################
# 8. CREACIÓN DE CERTIFICADOS SSL (Compatible con Chrome)
###############################################################################

print_step "8. Generando certificados SSL autofirmados (válidos 10 años)..."

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
print_info "Generando Autoridad Certificadora (CA)..."
openssl genrsa -out ${CA_DIR}/private/ca.key 4096
chmod 400 ${CA_DIR}/private/ca.key

openssl req -config ${CA_DIR}/openssl-ca.cnf \
    -key ${CA_DIR}/private/ca.key \
    -new -x509 -days 3650 -sha256 -extensions v3_ca \
    -out ${CA_DIR}/certs/ca.crt \
    -subj "/C=MX/ST=Estado/L=Ciudad/O=Arush/OU=IT/CN=Arush Local CA"

print_success "CA generada"

# Configuración SAN (Compatible con Chrome)
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
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment, keyAgreement
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
print_info "Generando certificado SSL para todos los vhosts..."
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
print_info "Generando parámetros Diffie-Hellman (esto puede tardar 1-2 min)..."
openssl dhparam -out ${DH_PARAM} 2048

print_success "Certificado SSL generado (válido 10 años - compatible con Chrome)"

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

print_success "Snippets de seguridad SSL/TLS creados"

###############################################################################
# 9. CONFIGURACIÓN DE VIRTUAL HOSTS
###############################################################################

print_step "9. Configurando Virtual Hosts..."

# Crear solo directorio de Laravel (Vue.js se creará después con sus propios comandos)
mkdir -p ${APP_ROOT}
chown -R ${WEB_USER}:${WEB_USER} /var/www
chmod -R 755 /var/www

# VHost app.arush.local (Laravel)
cat > /etc/nginx/sites-available/${APP_HOST} <<EOF
# Redirección HTTP -> HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name ${APP_HOST};
    return 301 https://\$server_name\$request_uri;
}

# Configuración HTTPS
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

# VHost front.arush.local (Vue.js Frontend)
cat > /etc/nginx/sites-available/${FRONT_HOST} <<EOF
# Redirección HTTP -> HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name ${FRONT_HOST};
    return 301 https://\$server_name\$request_uri;
}

# Configuración HTTPS
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

# VHost blog.arush.local (Vue.js Blog)
cat > /etc/nginx/sites-available/${BLOG_HOST} <<EOF
# Redirección HTTP -> HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name ${BLOG_HOST};
    return 301 https://\$server_name\$request_uri;
}

# Configuración HTTPS
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

print_success "Virtual Hosts configurados: ${APP_HOST}, ${FRONT_HOST}, ${BLOG_HOST}"

###############################################################################
# 10. INSTALACIÓN DE COMPOSER
###############################################################################

print_step "10. Instalando Composer..."

cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

print_success "Composer instalado: $(composer --version | head -n 1)"

###############################################################################
# 11. INSTALACIÓN DE NODE.JS Y NPM
###############################################################################

print_step "11. Instalando Node.js y NPM..."

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

print_info "Instalando herramientas globales de Node.js..."
npm install -g yarn pnpm @vue/cli vite

print_success "Node.js instalado: $(node --version)"
print_success "NPM instalado: $(npm --version)"

###############################################################################
# 12. DESPLIEGUE DE LARAVEL 11
###############################################################################

print_step "12. Desplegando Laravel 11..."

cd /var/www

# Verificar si ya existe el proyecto
if [ ! -f "${APP_ROOT}/artisan" ]; then
    print_info "Creando proyecto Laravel 11 (esto puede tardar 3-5 min)..."
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
print_info "Generando clave de aplicación Laravel..."
sudo -u ${WEB_USER} php artisan key:generate

# Ejecutar migraciones
print_info "Ejecutando migraciones de base de datos..."
sudo -u ${WEB_USER} php artisan migrate --force

# Optimizar para producción
print_info "Optimizando Laravel para producción..."
sudo -u ${WEB_USER} php artisan config:cache
sudo -u ${WEB_USER} php artisan route:cache
sudo -u ${WEB_USER} php artisan view:cache
sudo -u ${WEB_USER} composer install --optimize-autoloader --no-dev

print_success "Laravel 11 desplegado en https://${APP_HOST}"

###############################################################################
# 13. DESPLIEGUE DE VUE.JS
###############################################################################

print_step "13. Desplegando proyectos Vue.js..."

# Frontend Vue.js
cd /var/www
if [ ! -f "${FRONT_ROOT}/package.json" ]; then
    # Eliminar directorio vacío si existe
    rm -rf ${FRONT_ROOT}
    
    print_info "Creando proyecto Vue.js Frontend (esto puede tardar 2-3 min)..."
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
    
    print_info "Instalando dependencias de Frontend..."
    sudo -u ${WEB_USER} npm install
    
    print_info "Compilando Frontend para producción..."
    sudo -u ${WEB_USER} npm run build
    
    print_success "Frontend Vue.js desplegado en https://${FRONT_HOST}"
else
    print_warning "Frontend Vue.js ya existe en ${FRONT_ROOT}"
fi

# Blog Vue.js
cd /var/www
if [ ! -f "${BLOG_ROOT}/package.json" ]; then
    # Eliminar directorio vacío si existe
    rm -rf ${BLOG_ROOT}
    
    print_info "Creando proyecto Vue.js Blog con Vite..."
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
    
    print_info "Instalando dependencias de Blog..."
    sudo -u ${WEB_USER} npm install
    
    print_info "Compilando Blog para producción..."
    sudo -u ${WEB_USER} npm run build
    
    print_success "Blog Vue.js desplegado en https://${BLOG_HOST}"
else
    print_warning "Blog Vue.js ya existe en ${BLOG_ROOT}"
fi

###############################################################################
# 14. VERIFICACIÓN FINAL
###############################################################################

print_step "14. Verificación final del sistema..."

echo ""
echo -e "${CYAN}=== Estado de Servicios ===${NC}"
systemctl status nginx --no-pager | grep -E 'Active|Loaded' || true
systemctl status php8.3-fpm --no-pager | grep -E 'Active|Loaded' || true
systemctl status postgresql --no-pager | grep -E 'Active|Loaded' || true

echo ""
echo -e "${CYAN}=== Versiones Instaladas ===${NC}"
nginx -v 2>&1
php -v | head -n 1
psql --version
composer --version | head -n 1
node --version
npm --version

echo ""
echo -e "${CYAN}=== Puertos en Escucha ===${NC}"
ss -tlnp | grep -E '(80|443|5432)' || true

echo ""
echo -e "${CYAN}=== Verificación SSL ===${NC}"
openssl x509 -in ${CRT_FILE} -text -noout | grep -E '(Not Before|Not After)' || true
echo ""
print_info "Verificando SANs del certificado..."
openssl x509 -in ${CRT_FILE} -text -noout | grep -A 8 "Subject Alternative Name" || true

echo ""
print_success "¡Instalación completada exitosamente!"

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
tar -czf ${BACKUP_DIR}/front_${DATE_TAG}.tar.gz ${FRONT_ROOT} 2>/dev/null || true
tar -czf ${BACKUP_DIR}/blog_${DATE_TAG}.tar.gz ${BLOG_ROOT} 2>/dev/null || true

# Limpiar backups antiguos (más de 30 días)
find ${BACKUP_DIR} -name "*.sql" -mtime +30 -delete
find ${BACKUP_DIR} -name "*.tar.gz" -mtime +30 -delete

echo "Backup completado: ${DATE_TAG}"
BACKUP_EOF

chmod +x /usr/local/bin/backup-arush.sh

print_success "Script de backup creado en /usr/local/bin/backup-arush.sh"

###############################################################################
# RESUMEN FINAL
###############################################################################

echo ""
print_header "¡INSTALACIÓN COMPLETADA CON ÉXITO!"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                      ${CYAN}URLs de Acceso${NC}                                      ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}•${NC} Laravel Backend:   ${BLUE}https://${APP_HOST}${NC}"
echo -e "  ${CYAN}•${NC} Vue.js Frontend:   ${BLUE}https://${FRONT_HOST}${NC}"
echo -e "  ${CYAN}•${NC} Blog Vue.js:       ${BLUE}https://${BLOG_HOST}${NC}"
echo -e "  ${CYAN}•${NC} PostgreSQL:        ${BLUE}${SRV_IP}:5432${NC}"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                   ${CYAN}Credenciales PostgreSQL${NC}                             ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}•${NC} Host:     ${BLUE}${SRV_IP}${NC} (o localhost desde el servidor)"
echo -e "  ${CYAN}•${NC} Puerto:   ${BLUE}5432${NC}"
echo -e "  ${CYAN}•${NC} Usuario:  ${BLUE}${DB_USER}${NC}"
echo -e "  ${CYAN}•${NC} Password: ${BLUE}${DB_PASS}${NC}"
echo -e "  ${CYAN}•${NC} Base:     ${BLUE}${DB_NAME}${NC}"
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}              ${CYAN}Configuración del Cliente (tu máquina)${NC}                  ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}PASO 1:${NC} Agregar entradas DNS en ${CYAN}/etc/hosts${NC} (Linux/Mac)"
echo -e "        o ${CYAN}C:\\Windows\\System32\\drivers\\etc\\hosts${NC} (Windows)"
echo ""
echo -e "        ${BLUE}${SRV_IP}  ${APP_HOST}${NC}"
echo -e "        ${BLUE}${SRV_IP}  ${FRONT_HOST}${NC}"
echo -e "        ${BLUE}${SRV_IP}  ${BLOG_HOST}${NC}"
echo ""
echo -e "${YELLOW}PASO 2:${NC} Importar certificado CA en navegadores para evitar advertencias SSL"
echo ""
echo -e "        Certificado CA ubicado en: ${CYAN}${CA_DIR}/certs/ca.crt${NC}"
echo ""
echo -e "        ${CYAN}Para descargar:${NC}"
echo -e "        ${BLUE}scp ${DEV_USER}@${SRV_IP}:${CA_DIR}/certs/ca.crt ~/arush-ca.crt${NC}"
echo ""
echo -e "        ${CYAN}Chrome/Edge:${NC} chrome://settings/security → Administrar certificados → Importar"
echo -e "        ${CYAN}Firefox:${NC} about:preferences#privacy → Certificados → Importar"
echo ""
echo -e "${YELLOW}PASO 3:${NC} Limpiar caché SSL de Chrome (si es necesario)"
echo ""
echo -e "        ${BLUE}chrome://net-internals/#sockets${NC} → Flush socket pools"
echo -e "        ${BLUE}chrome://net-internals/#hsts${NC} → Delete domain security policies"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                    ${CYAN}Comandos Útiles Post-Instalación${NC}                    ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Reiniciar servicios:${NC}"
echo -e "  ${BLUE}sudo systemctl restart nginx php8.3-fpm postgresql${NC}"
echo ""
echo -e "${CYAN}Ver logs:${NC}"
echo -e "  ${BLUE}sudo tail -f /var/log/nginx/error.log${NC}"
echo -e "  ${BLUE}sudo tail -f /var/www/app/storage/logs/laravel.log${NC}"
echo ""
echo -e "${CYAN}Laravel:${NC}"
echo -e "  ${BLUE}cd /var/www/app${NC}"
echo -e "  ${BLUE}sudo -u www-data php artisan cache:clear${NC}"
echo -e "  ${BLUE}sudo -u www-data php artisan migrate${NC}"
echo ""
echo -e "${CYAN}Vue.js rebuild:${NC}"
echo -e "  ${BLUE}cd /var/www/front && sudo -u www-data npm run build${NC}"
echo -e "  ${BLUE}cd /var/www/blog && sudo -u www-data npm run build${NC}"
echo ""
echo -e "${CYAN}Backup manual:${NC}"
echo -e "  ${BLUE}sudo /usr/local/bin/backup-arush.sh${NC}"
echo ""
echo -e "${CYAN}Conectar a PostgreSQL:${NC}"
echo -e "  ${BLUE}PGPASSWORD=${DB_PASS} psql -h localhost -U ${DB_USER} -d ${DB_NAME}${NC}"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                                                                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}          ${YELLOW}¡Tu servidor web está listo para desarrollo!${NC}                 ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                                          ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
