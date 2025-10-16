# Procedimiento de Instalación - Servidor Web Ubuntu 24.04 LTS
## Stack: Nginx + PHP 8.3 + PostgreSQL + Laravel 11 + Vue.js

**Fecha:** 2025-10-16  
**Autor:** DevOps Senior  
**Sistema Operativo:** Ubuntu Server 24.04 LTS  
**Dominio:** arush.local  

---

## 📋 Tabla de Contenidos
1. [Variables de Entorno](#1-variables-de-entorno)
2. [Configuración Inicial del Sistema](#2-configuración-inicial-del-sistema)
3. [Configuración de SSH](#3-configuración-de-ssh)
4. [Configuración de Firewall UFW](#4-configuración-de-firewall-ufw)
5. [Instalación de Nginx](#5-instalación-de-nginx)
6. [Instalación de PHP 8.3](#6-instalación-de-php-83)
7. [Instalación de PostgreSQL](#7-instalación-de-postgresql)
8. [Instalación de pgAdmin 4](#8-instalación-de-pgadmin-4)
9. [Creación de Certificados SSL](#9-creación-de-certificados-ssl)
10. [Configuración de Virtual Hosts](#10-configuración-de-virtual-hosts)
11. [Instalación de Composer](#11-instalación-de-composer)
12. [Instalación de Node.js y NPM](#12-instalación-de-nodejs-y-npm)
13. [Despliegue de Laravel 11](#13-despliegue-de-laravel-11)
14. [Despliegue de Vue.js](#14-despliegue-de-vuejs)
15. [Verificación Final](#15-verificación-final)

---

## 1. Variables de Entorno

### 1.1 Crear archivo de variables de entorno

```bash
sudo mkdir -p /etc/arush
sudo tee /etc/arush/env.sh > /dev/null <<'EOF'
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
```

### 1.2 Cargar variables de entorno

```bash
source /etc/arush/env.sh
```

### 1.3 Hacer persistentes las variables (opcional)

```bash
echo "source /etc/arush/env.sh" | sudo tee -a /etc/profile.d/arush-env.sh
sudo chmod +x /etc/profile.d/arush-env.sh
```

---

## 2. Configuración Inicial del Sistema

### 2.1 Actualizar el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

### 2.2 Configurar zona horaria

```bash
sudo timedatectl set-timezone ${TIMEZONE}
timedatectl status
```

### 2.3 Configurar hostname

```bash
sudo hostnamectl set-hostname ${HOSTNAME}
```

### 2.4 Actualizar archivo hosts

```bash
sudo tee -a /etc/hosts > /dev/null <<EOF

# Configuración local Arush
${SRV_IP} ${APP_HOST}
${SRV_IP} ${FRONT_HOST}
${SRV_IP} ${BLOG_HOST}
EOF
```

### 2.5 Instalar paquetes esenciales

```bash
sudo apt install -y curl wget git unzip software-properties-common \
    build-essential apt-transport-https ca-certificates gnupg lsb-release
```

### 2.6 Crear usuario de desarrollo (si no existe)

```bash
sudo useradd -m -s /bin/bash ${DEV_USER} || echo "Usuario ${DEV_USER} ya existe"
sudo usermod -aG sudo ${DEV_USER}
```

---

## 3. Configuración de SSH

### 3.1 Realizar backup de configuración SSH

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.${DATE_TAG}
```

### 3.2 Configurar SSH de forma segura

```bash
sudo tee /etc/ssh/sshd_config.d/99-arush-security.conf > /dev/null <<'EOF'
# Configuración de seguridad SSH - Arush Local

# Configuración básica
Port 22
AddressFamily inet

# Autenticación
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Seguridad adicional
MaxAuthTries 3
MaxSessions 5
LoginGraceTime 30

# Configuración de sesión
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive yes

# Restricciones de acceso
AllowUsers suburbak

# X11 y forwarding
X11Forwarding no
AllowTcpForwarding yes
AllowStreamLocalForwarding no

# Banner y mensajes
PrintMotd no
PrintLastLog yes
EOF
```

### 3.3 Reiniciar servicio SSH

```bash
sudo systemctl restart sshd
sudo systemctl status sshd --no-pager
```

---

## 4. Configuración de Firewall UFW

### 4.1 Instalar UFW (si no está instalado)

```bash
sudo apt install -y ufw
```

### 4.2 Configurar reglas de firewall para red local

```bash
# Denegar todo por defecto
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH desde la red local
sudo ufw allow from ${LAN_CIDR} to any port 22 proto tcp comment 'SSH desde LAN'

# Permitir HTTP y HTTPS desde la red local
sudo ufw allow from ${LAN_CIDR} to any port 80 proto tcp comment 'HTTP desde LAN'
sudo ufw allow from ${LAN_CIDR} to any port 443 proto tcp comment 'HTTPS desde LAN'

# Permitir PostgreSQL desde la red local (opcional, solo si se necesita acceso remoto)
sudo ufw allow from ${LAN_CIDR} to any port 5432 proto tcp comment 'PostgreSQL desde LAN'

# Permitir pgAdmin desde la red local
sudo ufw allow from ${LAN_CIDR} to any port 5050 proto tcp comment 'pgAdmin desde LAN'
```

### 4.3 Habilitar UFW

```bash
# Habilitar UFW
sudo ufw --force enable

# Verificar estado
sudo ufw status verbose
```

### 4.4 Configurar logging

```bash
sudo ufw logging medium
```

---

## 5. Instalación de Nginx

### 5.1 Instalar Nginx

```bash
sudo apt install -y nginx
```

### 5.2 Verificar instalación

```bash
nginx -v
sudo systemctl status nginx --no-pager
```

### 5.3 Configurar Nginx

```bash
# Backup de configuración original
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.${DATE_TAG}

# Configuración optimizada
sudo tee /etc/nginx/nginx.conf > /dev/null <<'EOF'
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
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    client_max_body_size 100M;

    # MIME
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';

    # Logging Settings
    access_log /var/log/nginx/access.log;

    # Gzip Settings
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml font/truetype font/opentype 
               application/vnd.ms-fontobject image/svg+xml;

    # Virtual Host Configs
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
```

### 5.4 Crear directorios de snippets

```bash
sudo mkdir -p /etc/nginx/snippets
```

### 5.5 Deshabilitar sitio por defecto

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

---

## 6. Instalación de PHP 8.3

### 6.1 Agregar repositorio de PHP

```bash
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
```

### 6.2 Instalar PHP 8.3 y extensiones necesarias

```bash
sudo apt install -y php8.3 php8.3-fpm php8.3-cli php8.3-common \
    php8.3-pgsql php8.3-zip php8.3-gd php8.3-mbstring php8.3-curl \
    php8.3-xml php8.3-bcmath php8.3-intl php8.3-redis php8.3-opcache \
    php8.3-readline php8.3-tokenizer
```

### 6.3 Verificar instalación

```bash
php -v
php -m
```

### 6.4 Configurar PHP-FPM

```bash
# Backup de configuración
sudo cp /etc/php/8.3/fpm/php.ini /etc/php/8.3/fpm/php.ini.backup.${DATE_TAG}

# Configurar PHP para producción
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.3/fpm/php.ini
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php/8.3/fpm/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 100M/' /etc/php/8.3/fpm/php.ini
sudo sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/8.3/fpm/php.ini
sudo sed -i 's/;date.timezone =.*/date.timezone = America\/Mexico_City/' /etc/php/8.3/fpm/php.ini
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.3/fpm/php.ini

# Configurar pool de PHP-FPM
sudo cp /etc/php/8.3/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/www.conf.backup.${DATE_TAG}

sudo tee /etc/php/8.3/fpm/pool.d/www.conf > /dev/null <<'EOF'
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
```

### 6.5 Reiniciar PHP-FPM

```bash
sudo systemctl restart php8.3-fpm
sudo systemctl enable php8.3-fpm
sudo systemctl status php8.3-fpm --no-pager
```

---

## 7. Instalación de PostgreSQL

### 7.1 Instalar PostgreSQL 16

```bash
# Agregar repositorio oficial de PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc

sudo apt update
sudo apt install -y postgresql-${PG_VER} postgresql-contrib-${PG_VER}
```

### 7.2 Verificar instalación

```bash
sudo systemctl status postgresql --no-pager
psql --version
```

### 7.3 Configurar PostgreSQL

```bash
# Configurar autenticación para red local
sudo cp ${PG_CONF_DIR}/pg_hba.conf ${PG_CONF_DIR}/pg_hba.conf.backup.${DATE_TAG}

sudo tee -a ${PG_CONF_DIR}/pg_hba.conf > /dev/null <<EOF

# Configuración Arush Local
host    all             all             ${LAN_CIDR}            scram-sha-256
EOF

# Configurar para escuchar en todas las interfaces (si se necesita acceso remoto)
sudo cp ${PG_CONF_DIR}/postgresql.conf ${PG_CONF_DIR}/postgresql.conf.backup.${DATE_TAG}

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" ${PG_CONF_DIR}/postgresql.conf
```

### 7.4 Crear usuario y base de datos

```bash
# Crear usuario de base de datos
sudo -u postgres psql <<EOF
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';
CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
\q
EOF

# Verificar
sudo -u postgres psql -c "\l" | grep ${DB_NAME}
sudo -u postgres psql -c "\du" | grep ${DB_USER}
```

### 7.5 Reiniciar PostgreSQL

```bash
sudo systemctl restart postgresql
sudo systemctl enable postgresql
```

---

## 8. Instalación de pgAdmin 4

### 8.1 Agregar repositorio de pgAdmin

```bash
# Instalar el repositorio
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'

sudo apt update
```

### 8.2 Instalar pgAdmin 4 (modo web)

```bash
sudo apt install -y pgadmin4-web
```

### 8.3 Configurar pgAdmin 4

```bash
# Configurar pgAdmin (establecer email y contraseña)
sudo /usr/pgadmin4/bin/setup-web.sh <<EOF
admin@arush.local
${DB_PASS}
${DB_PASS}
y
EOF
```

### 8.4 Configurar Nginx para pgAdmin

```bash
sudo tee /etc/nginx/sites-available/pgadmin > /dev/null <<'EOF'
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

sudo ln -sf /etc/nginx/sites-available/pgadmin /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

---

## 9. Creación de Certificados SSL

### 9.1 Crear estructura de directorios para CA

```bash
sudo mkdir -p ${CA_DIR}/{certs,crl,newcerts,private}
sudo chmod 700 ${CA_DIR}/private
sudo touch ${CA_DIR}/index.txt
echo 1000 | sudo tee ${CA_DIR}/serial
```

### 9.2 Crear configuración OpenSSL para CA

```bash
sudo tee ${CA_DIR}/openssl-ca.cnf > /dev/null <<EOF
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

crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/ca.crl
crl_extensions    = crl_ext
default_crl_days  = 30

default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
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

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
authorityKeyIdentifier=keyid:always

[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
EOF
```

### 9.3 Generar Autoridad Certificadora (CA) privada

```bash
# Generar clave privada de CA (sin contraseña para automatización)
sudo openssl genrsa -out ${CA_DIR}/private/ca.key 4096
sudo chmod 400 ${CA_DIR}/private/ca.key

# Generar certificado raíz de CA (válido 10 años)
sudo openssl req -config ${CA_DIR}/openssl-ca.cnf \
    -key ${CA_DIR}/private/ca.key \
    -new -x509 -days 3650 -sha256 -extensions v3_ca \
    -out ${CA_DIR}/certs/ca.crt \
    -subj "/C=MX/ST=Estado/L=Ciudad/O=Arush/OU=IT/CN=Arush Local CA"
```

### 9.4 Crear configuración para certificado SAN (Subject Alternative Name)

```bash
sudo tee ${CA_DIR}/openssl-san.cnf > /dev/null <<EOF
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
```

### 9.5 Generar certificado SAN (válido 10 años)

```bash
# Generar clave privada del servidor
sudo openssl genrsa -out ${KEY_FILE} 2048
sudo chmod 600 ${KEY_FILE}

# Generar CSR (Certificate Signing Request)
sudo openssl req -new \
    -key ${KEY_FILE} \
    -out ${CA_DIR}/${CERT_NAME}.csr \
    -config ${CA_DIR}/openssl-san.cnf

# Firmar certificado con CA (válido 10 años = 3650 días)
sudo openssl x509 -req \
    -in ${CA_DIR}/${CERT_NAME}.csr \
    -CA ${CA_DIR}/certs/ca.crt \
    -CAkey ${CA_DIR}/private/ca.key \
    -CAcreateserial \
    -out ${CRT_FILE} \
    -days 3650 \
    -sha256 \
    -extensions v3_req \
    -extfile ${CA_DIR}/openssl-san.cnf

# Crear fullchain (certificado + CA)
sudo cat ${CRT_FILE} ${CA_DIR}/certs/ca.crt | sudo tee ${FULLCHAIN} > /dev/null

# Verificar certificado
sudo openssl x509 -in ${CRT_FILE} -text -noout | grep -A 5 "Subject Alternative Name"
```

### 9.6 Generar parámetros Diffie-Hellman

```bash
sudo openssl dhparam -out ${DH_PARAM} 2048
```

### 9.7 Crear snippet de configuración TLS para Nginx

```bash
sudo tee ${TLS_SNIPPET} > /dev/null <<EOF
# Certificados SSL
ssl_certificate ${FULLCHAIN};
ssl_certificate_key ${KEY_FILE};

# Parámetros Diffie-Hellman
ssl_dhparam ${DH_PARAM};

# Protocolos y cifrados
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;

# Optimizaciones SSL
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;

# OCSP Stapling
ssl_stapling off;
ssl_stapling_verify off;
EOF
```

### 9.8 Crear snippet de headers de seguridad

```bash
sudo tee ${HDRS_SNIPPET} > /dev/null <<'EOF'
# Headers de seguridad
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Content Security Policy (ajustar según necesidades)
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

# Permissions Policy
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
EOF
```

---

## 10. Configuración de Virtual Hosts

### 10.1 Crear directorios de proyectos

```bash
sudo mkdir -p ${APP_ROOT} ${FRONT_ROOT} ${BLOG_ROOT}
sudo chown -R ${WEB_USER}:${WEB_USER} /var/www
sudo chmod -R 755 /var/www
```

### 10.2 Configurar Virtual Host - app.arush.local (Laravel)

```bash
sudo tee /etc/nginx/sites-available/${APP_HOST} > /dev/null <<EOF
# Redirección HTTP a HTTPS
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
    index index.php index.html index.htm;

    # Incluir configuración TLS
    include ${TLS_SNIPPET};

    # Incluir headers de seguridad
    include ${HDRS_SNIPPET};

    # Logs
    access_log /var/log/nginx/${APP_HOST}-access.log;
    error_log /var/log/nginx/${APP_HOST}-error.log;

    # Laravel routes
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # PHP-FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    # Denegar acceso a archivos ocultos
    location ~ /\. {
        deny all;
    }

    # Cache para assets estáticos
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF
```

### 10.3 Configurar Virtual Host - front.arush.local (Vue.js)

```bash
sudo tee /etc/nginx/sites-available/${FRONT_HOST} > /dev/null <<EOF
# Redirección HTTP a HTTPS
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

    # Incluir configuración TLS
    include ${TLS_SNIPPET};

    # Incluir headers de seguridad
    include ${HDRS_SNIPPET};

    # Logs
    access_log /var/log/nginx/${FRONT_HOST}-access.log;
    error_log /var/log/nginx/${FRONT_HOST}-error.log;

    # Vue.js SPA configuration
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Cache para assets estáticos
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # No cache para index.html
    location = /index.html {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }
}
EOF
```

### 10.4 Configurar Virtual Host - blog.arush.local (Vue.js estático)

```bash
sudo tee /etc/nginx/sites-available/${BLOG_HOST} > /dev/null <<EOF
# Redirección HTTP a HTTPS
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

    # Incluir configuración TLS
    include ${TLS_SNIPPET};

    # Incluir headers de seguridad
    include ${HDRS_SNIPPET};

    # Logs
    access_log /var/log/nginx/${BLOG_HOST}-access.log;
    error_log /var/log/nginx/${BLOG_HOST}-error.log;

    # Vue.js SPA configuration
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Cache para assets estáticos
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # No cache para index.html
    location = /index.html {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }
}
EOF
```

### 10.5 Habilitar virtual hosts

```bash
sudo ln -sf /etc/nginx/sites-available/${APP_HOST} /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/${FRONT_HOST} /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/${BLOG_HOST} /etc/nginx/sites-enabled/
```

### 10.6 Verificar y recargar Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 11. Instalación de Composer

### 11.1 Descargar e instalar Composer

```bash
cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php

# Verificar instalador (opcional, usar hash del sitio oficial)
HASH="$(curl -sS https://composer.github.io/installer.sig)"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

# Instalar Composer globalmente
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php
```

### 11.2 Verificar instalación

```bash
composer --version
```

---

## 12. Instalación de Node.js y NPM

### 12.1 Instalar Node.js 20.x LTS

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### 12.2 Verificar instalación

```bash
node --version
npm --version
```

### 12.3 Instalar herramientas globales

```bash
sudo npm install -g yarn pnpm @vue/cli vite
```

---

## 13. Despliegue de Laravel 11

### 13.1 Crear proyecto Laravel 11 (si no existe)

```bash
cd /var/www
sudo composer create-project laravel/laravel:^11.0 app --prefer-dist
```

### 13.2 Configurar permisos de Laravel

```bash
# Cambiar propietario
sudo chown -R ${WEB_USER}:${WEB_USER} ${APP_ROOT}

# Permisos específicos de Laravel
sudo chmod -R 755 ${APP_ROOT}
sudo chmod -R 775 ${APP_ROOT}/storage
sudo chmod -R 775 ${APP_ROOT}/bootstrap/cache

# Agregar usuario de desarrollo al grupo www-data
sudo usermod -aG ${WEB_USER} ${DEV_USER}
```

### 13.3 Configurar archivo .env de Laravel

```bash
sudo tee ${APP_ROOT}/.env > /dev/null <<EOF
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
LOG_DEPRECATIONS_CHANNEL=null
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
SESSION_ENCRYPT=false

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="noreply@arush.local"
MAIL_FROM_NAME="\${APP_NAME}"

VITE_APP_NAME="\${APP_NAME}"
EOF

# Ajustar permisos del .env
sudo chmod 640 ${APP_ROOT}/.env
```

### 13.4 Generar APP_KEY

```bash
cd ${APP_ROOT}
sudo -u ${WEB_USER} php artisan key:generate
```

### 13.5 Ejecutar migraciones

```bash
cd ${APP_ROOT}
sudo -u ${WEB_USER} php artisan migrate --force
```

### 13.6 Optimizar Laravel para producción

```bash
cd ${APP_ROOT}

# Cache de configuración
sudo -u ${WEB_USER} php artisan config:cache

# Cache de rutas
sudo -u ${WEB_USER} php artisan route:cache

# Cache de vistas
sudo -u ${WEB_USER} php artisan view:cache

# Optimizar autoload de Composer
sudo -u ${WEB_USER} composer install --optimize-autoloader --no-dev
```

### 13.7 Instalar dependencias de frontend (si aplica)

```bash
cd ${APP_ROOT}
sudo -u ${WEB_USER} npm install
sudo -u ${WEB_USER} npm run build
```

---

## 14. Despliegue de Vue.js

### 14.1 Crear proyecto Vue.js para frontend (front.arush.local)

```bash
cd /var/www

# Crear proyecto con Vue CLI
sudo -u ${WEB_USER} vue create front <<EOF
3
n
3.x
n
Babel
n
n
npm
EOF
```

### 14.2 Configurar proyecto frontend

```bash
# Crear archivo de configuración de build
sudo tee ${FRONT_ROOT}/vue.config.js > /dev/null <<'EOF'
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

# Ajustar permisos
sudo chown -R ${WEB_USER}:${WEB_USER} ${FRONT_ROOT}
```

### 14.3 Construir proyecto frontend

```bash
cd ${FRONT_ROOT}
sudo -u ${WEB_USER} npm install
sudo -u ${WEB_USER} npm run build
```

### 14.4 Crear proyecto Vue.js para blog (blog.arush.local)

```bash
cd /var/www

# Crear proyecto con Vite
sudo -u ${WEB_USER} npm create vite@latest blog -- --template vue

cd ${BLOG_ROOT}
sudo -u ${WEB_USER} npm install
```

### 14.5 Configurar proyecto blog

```bash
# Crear archivo de configuración de Vite
sudo tee ${BLOG_ROOT}/vite.config.js > /dev/null <<'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: '/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'terser',
    chunkSizeWarningLimit: 1000
  }
})
EOF

sudo chown -R ${WEB_USER}:${WEB_USER} ${BLOG_ROOT}
```

### 14.6 Construir proyecto blog

```bash
cd ${BLOG_ROOT}
sudo -u ${WEB_USER} npm run build
```

---

## 15. Verificación Final

### 15.1 Verificar servicios

```bash
echo "=== Estado de Servicios ==="
sudo systemctl status nginx --no-pager | grep -E 'Active|Loaded'
sudo systemctl status php8.3-fpm --no-pager | grep -E 'Active|Loaded'
sudo systemctl status postgresql --no-pager | grep -E 'Active|Loaded'

echo ""
echo "=== Versiones Instaladas ==="
nginx -v
php -v | head -n 1
psql --version
composer --version
node --version
npm --version
```

### 15.2 Verificar configuración de Nginx

```bash
sudo nginx -t
```

### 15.3 Verificar puertos en escucha

```bash
sudo ss -tlnp | grep -E '(80|443|5432|5050)'
```

### 15.4 Verificar firewall

```bash
sudo ufw status verbose
```

### 15.5 Verificar certificados SSL

```bash
echo "=== Verificación de Certificado SSL ==="
sudo openssl x509 -in ${CRT_FILE} -text -noout | grep -E '(Issuer|Subject|Not Before|Not After|DNS:)'
```

### 15.6 Verificar conectividad a base de datos

```bash
PGPASSWORD=${DB_PASS} psql -h 127.0.0.1 -U ${DB_USER} -d ${DB_NAME} -c "SELECT version();"
```

### 15.7 Probar sitios web (desde el servidor)

```bash
echo "=== Prueba de Sitios Web ==="

# Probar redirección HTTP a HTTPS
echo "1. Probando ${APP_HOST} (HTTP -> HTTPS):"
curl -I http://${APP_HOST} 2>/dev/null | grep -E '(HTTP|Location)'

echo ""
echo "2. Probando ${APP_HOST} (HTTPS):"
curl -I -k https://${APP_HOST} 2>/dev/null | grep -E '(HTTP|Server)'

echo ""
echo "3. Probando ${FRONT_HOST} (HTTPS):"
curl -I -k https://${FRONT_HOST} 2>/dev/null | grep -E '(HTTP|Server)'

echo ""
echo "4. Probando ${BLOG_HOST} (HTTPS):"
curl -I -k https://${BLOG_HOST} 2>/dev/null | grep -E '(HTTP|Server)'
```

### 15.8 Verificar permisos de Laravel

```bash
echo "=== Verificación de Permisos Laravel ==="
ls -la ${APP_ROOT} | head -n 10
ls -la ${APP_ROOT}/storage
ls -la ${APP_ROOT}/bootstrap/cache
```

---

## 🔧 Comandos Útiles Post-Instalación

### Reiniciar todos los servicios

```bash
sudo systemctl restart nginx php8.3-fpm postgresql
```

### Ver logs en tiempo real

```bash
# Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/${APP_HOST}-access.log

# PHP-FPM
sudo tail -f /var/log/php8.3-fpm.log

# PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-${PG_VER}-main.log

# Laravel
sudo tail -f ${APP_ROOT}/storage/logs/laravel.log
```

### Limpiar cache de Laravel

```bash
cd ${APP_ROOT}
sudo -u ${WEB_USER} php artisan cache:clear
sudo -u ${WEB_USER} php artisan config:clear
sudo -u ${WEB_USER} php artisan route:clear
sudo -u ${WEB_USER} php artisan view:clear
```

### Reconstruir cache de Laravel

```bash
cd ${APP_ROOT}
sudo -u ${WEB_USER} php artisan config:cache
sudo -u ${WEB_USER} php artisan route:cache
sudo -u ${WEB_USER} php artisan view:cache
```

### Actualizar composer de Laravel

```bash
cd ${APP_ROOT}
sudo -u ${WEB_USER} composer update
```

### Reconstruir frontend Vue.js

```bash
# Frontend
cd ${FRONT_ROOT}
sudo -u ${WEB_USER} npm run build

# Blog
cd ${BLOG_ROOT}
sudo -u ${WEB_USER} npm run build
```

---

## 📝 Notas Importantes

### Configuración DNS Local

Para acceder desde otras máquinas en la red local, agregar a `/etc/hosts` o configurar DNS:

```
192.168.1.13  app.arush.local
192.168.1.13  front.arush.local
192.168.1.13  blog.arush.local
```

### Importar Certificado CA en Navegadores

Para evitar advertencias de seguridad en navegadores:

1. **Firefox:**
   - Preferencias → Privacidad y Seguridad → Certificados → Ver Certificados
   - Importar `${CA_DIR}/certs/ca.crt`

2. **Chrome/Edge:**
   - Configuración → Privacidad y seguridad → Seguridad → Administrar certificados
   - Autoridades → Importar `${CA_DIR}/certs/ca.crt`

3. **Sistema Linux:**
   ```bash
   sudo cp ${CA_DIR}/certs/ca.crt /usr/local/share/ca-certificates/arush-local-ca.crt
   sudo update-ca-certificates
   ```

### Backup Recomendado

```bash
# Crear script de backup
sudo tee /usr/local/bin/backup-arush.sh > /dev/null <<'EOF'
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

# Limpiar backups antiguos (más de 30 días)
find ${BACKUP_DIR} -name "*.sql" -mtime +30 -delete
find ${BACKUP_DIR} -name "*.tar.gz" -mtime +30 -delete

echo "Backup completado: ${DATE_TAG}"
EOF

sudo chmod +x /usr/local/bin/backup-arush.sh

# Programar backup diario (crontab)
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-arush.sh") | crontab -
```

### Seguridad Adicional

```bash
# Fail2ban para protección contra fuerza bruta (opcional)
sudo apt install -y fail2ban

sudo tee /etc/fail2ban/jail.local > /dev/null <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-noscript]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## ✅ Checklist de Verificación Final

- [ ] Sistema actualizado y zona horaria configurada
- [ ] SSH configurado y asegurado
- [ ] UFW habilitado con reglas de red local
- [ ] Nginx instalado y funcionando
- [ ] PHP 8.3 con todas las extensiones instalado
- [ ] PostgreSQL 16 instalado y usuario/BD creados
- [ ] pgAdmin 4 accesible en puerto 5050
- [ ] Certificado SSL autofirmado creado (válido 10 años)
- [ ] Virtual hosts configurados con redirección HTTPS
- [ ] Composer instalado globalmente
- [ ] Node.js y NPM instalados
- [ ] Laravel 11 desplegado en app.arush.local
- [ ] Vue.js frontend desplegado en front.arush.local
- [ ] Vue.js blog desplegado en blog.arush.local
- [ ] Todos los servicios iniciados y habilitados
- [ ] Permisos de archivos correctamente configurados
- [ ] Firewall configurado correctamente

---

## 🔗 URLs de Acceso

- **Laravel Backend:** https://app.arush.local
- **Vue.js Frontend:** https://front.arush.local
- **Blog Vue.js:** https://blog.arush.local
- **pgAdmin 4:** http://192.168.1.13:5050/pgadmin4

---

## 📞 Soporte y Troubleshooting

### Error: "502 Bad Gateway" en Laravel

```bash
# Verificar PHP-FPM
sudo systemctl status php8.3-fpm
sudo tail -f /var/log/php8.3-fpm.log

# Verificar permisos
sudo chown -R www-data:www-data ${APP_ROOT}/storage
sudo chmod -R 775 ${APP_ROOT}/storage
```

### Error: "Permission denied" en Laravel

```bash
# Corregir permisos
cd ${APP_ROOT}
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### Error: No se puede conectar a PostgreSQL

```bash
# Verificar servicio
sudo systemctl status postgresql

# Verificar conectividad
PGPASSWORD=${DB_PASS} psql -h 127.0.0.1 -U ${DB_USER} -d ${DB_NAME} -c "\l"

# Revisar logs
sudo tail -f /var/log/postgresql/postgresql-16-main.log
```

### Regenerar certificados SSL

```bash
# Eliminar certificados antiguos
sudo rm -f ${CRT_FILE} ${KEY_FILE} ${FULLCHAIN}

# Regenerar (seguir pasos 9.5 y 9.6 del procedimiento)
```

---

**Procedimiento completado.** Documentación generada por DevOps Senior - Arush Local Development Stack.
