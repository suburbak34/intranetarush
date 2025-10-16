# 🚀 Instalación Automatizada de Servidor Web - Ubuntu 24.04 LTS

## 📦 Stack Tecnológico

- **Sistema Operativo:** Ubuntu Server 24.04 LTS
- **Servidor Web:** Nginx
- **Lenguaje:** PHP 8.3
- **Base de Datos:** PostgreSQL 16
- **Administrador BD:** pgAdmin 4
- **Backend Framework:** Laravel 11
- **Frontend Framework:** Vue.js 3
- **Gestión de Paquetes:** Composer, NPM

## 🎯 Características

✅ Configuración completa de seguridad SSH  
✅ Firewall UFW con reglas para red local  
✅ Certificados SSL autofirmados (válidos 10 años)  
✅ Redirección automática HTTP → HTTPS  
✅ 3 Virtual Hosts configurados:
   - `app.arush.local` - Laravel 11
   - `front.arush.local` - Vue.js (SPA)
   - `blog.arush.local` - Vue.js (contenido estático)

## 📋 Pre-requisitos

- Ubuntu Server 24.04 LTS instalado
- Acceso root o sudo
- Conexión a Internet
- Mínimo 2GB RAM
- Mínimo 20GB de espacio en disco

## 🔧 Instalación

### Opción 1: Instalación Automatizada (Recomendada)

```bash
# 1. Clonar o descargar los archivos
cd /tmp
git clone <repositorio> arush-server
cd arush-server

# 2. Ejecutar el script de instalación
sudo bash install-server.sh
```

El script instalará y configurará todo automáticamente en aproximadamente **15-20 minutos**.

### Opción 2: Instalación Manual

Si prefieres instalar paso a paso, sigue el documento:

```bash
# Ver procedimiento detallado
cat PROCEDIMIENTO_INSTALACION_SERVIDOR.md
```

## 🔑 Variables de Configuración

Las variables de configuración se encuentran en `/etc/arush/env.sh`:

```bash
# Variables principales
TIMEZONE="America/Mexico_City"
LAN_CIDR="192.168.1.0/24"
SRV_IP="192.168.1.13"
DOMAIN="arush.local"

# Hosts virtuales
APP_HOST="app.arush.local"
FRONT_HOST="front.arush.local"
BLOG_HOST="blog.arush.local"

# Base de datos
DB_USER="arush"
DB_PASS="R2705mr2"
DB_NAME="app_arush"
```

**⚠️ IMPORTANTE:** Modifica estas variables ANTES de ejecutar el script si necesitas configuraciones diferentes.

## 🌐 Configuración del Cliente

### 1. Agregar entradas DNS locales

En tu máquina cliente (Windows, Linux, Mac), edita el archivo hosts:

**Linux/Mac:** `/etc/hosts`  
**Windows:** `C:\Windows\System32\drivers\etc\hosts`

Agrega las siguientes líneas:

```
192.168.1.13  app.arush.local
192.168.1.13  front.arush.local
192.168.1.13  blog.arush.local
```

### 2. Importar Certificado CA (Opcional)

Para evitar advertencias de seguridad SSL en navegadores:

**Ubicación del certificado en el servidor:**
```
/etc/ssl/localCA/certs/ca.crt
```

**Importar en navegadores:**

- **Firefox:**
  1. Preferencias → Privacidad y Seguridad
  2. Certificados → Ver Certificados
  3. Autoridades → Importar `ca.crt`

- **Chrome/Edge:**
  1. Configuración → Privacidad y seguridad
  2. Seguridad → Administrar certificados
  3. Autoridades → Importar `ca.crt`

- **Sistema Linux:**
  ```bash
  sudo cp /etc/ssl/localCA/certs/ca.crt /usr/local/share/ca-certificates/arush-ca.crt
  sudo update-ca-certificates
  ```

## 🔗 URLs de Acceso

Después de la instalación, accede a los servicios:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Laravel Backend** | https://app.arush.local | API y backend Laravel 11 |
| **Frontend Vue.js** | https://front.arush.local | Aplicación frontend SPA |
| **Blog Vue.js** | https://blog.arush.local | Blog estático |
| **pgAdmin 4** | http://192.168.1.13:5050/pgadmin4 | Administrador de PostgreSQL |

### Credenciales pgAdmin 4

- **Email:** `admin@arush.local`
- **Password:** `R2705mr2` (definido en DB_PASS)

### Credenciales PostgreSQL

- **Usuario:** `arush`
- **Password:** `R2705mr2`
- **Base de datos:** `app_arush`
- **Host:** `192.168.1.13` (o `localhost` desde el servidor)
- **Puerto:** `5432`

## ✅ Verificación Post-Instalación

### 1. Verificar servicios

```bash
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
sudo systemctl status postgresql
```

### 2. Verificar puertos

```bash
sudo ss -tlnp | grep -E '(80|443|5432|5050)'
```

### 3. Verificar certificados SSL

```bash
sudo openssl x509 -in /etc/ssl/certs/arush-local-san.crt -text -noout | grep -E 'Not After'
```

### 4. Probar sitios web

```bash
# Desde el servidor
curl -I -k https://app.arush.local
curl -I -k https://front.arush.local
curl -I -k https://blog.arush.local
```

### 5. Verificar firewall

```bash
sudo ufw status verbose
```

## 🛠️ Comandos Útiles

### Gestión de Servicios

```bash
# Reiniciar todos los servicios
sudo systemctl restart nginx php8.3-fpm postgresql

# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/app.arush.local-access.log

# Ver logs de Laravel
sudo tail -f /var/www/app/storage/logs/laravel.log

# Ver logs de PHP-FPM
sudo tail -f /var/log/php8.3-fpm.log
```

### Laravel

```bash
cd /var/www/app

# Limpiar cache
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan route:clear
sudo -u www-data php artisan view:clear

# Reconstruir cache
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache

# Ejecutar migraciones
sudo -u www-data php artisan migrate

# Ver rutas
sudo -u www-data php artisan route:list
```

### Vue.js

```bash
# Reconstruir frontend
cd /var/www/front
sudo -u www-data npm run build

# Reconstruir blog
cd /var/www/blog
sudo -u www-data npm run build
```

### PostgreSQL

```bash
# Conectar a base de datos
sudo -u postgres psql

# O con usuario específico
PGPASSWORD=R2705mr2 psql -h localhost -U arush -d app_arush

# Listar bases de datos
sudo -u postgres psql -c "\l"

# Listar usuarios
sudo -u postgres psql -c "\du"

# Backup de base de datos
PGPASSWORD=R2705mr2 pg_dump -h localhost -U arush app_arush > backup.sql

# Restaurar base de datos
PGPASSWORD=R2705mr2 psql -h localhost -U arush app_arush < backup.sql
```

## 💾 Backup Automatizado

El script crea un comando de backup en `/usr/local/bin/backup-arush.sh`

### Ejecutar backup manual

```bash
sudo /usr/local/bin/backup-arush.sh
```

### Programar backup automático (crontab)

```bash
# Backup diario a las 2:00 AM
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-arush.sh") | crontab -
```

Los backups se guardan en: `/backup/arush/`

## 🔒 Seguridad

### Firewall UFW

El firewall está configurado para permitir acceso SOLO desde la red local:

- SSH (22) - Solo desde 192.168.1.0/24
- HTTP (80) - Solo desde 192.168.1.0/24
- HTTPS (443) - Solo desde 192.168.1.0/24
- PostgreSQL (5432) - Solo desde 192.168.1.0/24
- pgAdmin (5050) - Solo desde 192.168.1.0/24

### SSH Hardening

- Root login deshabilitado
- Máximo 3 intentos de autenticación
- Timeout de sesión: 5 minutos
- Solo usuario `suburbak` permitido

### SSL/TLS

- Certificados válidos por 10 años
- Protocolos: TLSv1.2 y TLSv1.3
- Cifrados fuertes configurados
- HSTS habilitado
- Headers de seguridad configurados

## 🐛 Troubleshooting

### Error: "502 Bad Gateway"

```bash
# Verificar PHP-FPM
sudo systemctl status php8.3-fpm
sudo tail -f /var/log/php8.3-fpm.log

# Reiniciar PHP-FPM
sudo systemctl restart php8.3-fpm
```

### Error: "Permission denied" en Laravel

```bash
cd /var/www/app
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### Error: No se puede conectar a PostgreSQL

```bash
# Verificar servicio
sudo systemctl status postgresql

# Verificar logs
sudo tail -f /var/log/postgresql/postgresql-16-main.log

# Reiniciar servicio
sudo systemctl restart postgresql
```

### Error: Nginx no inicia

```bash
# Verificar configuración
sudo nginx -t

# Ver logs de error
sudo tail -f /var/log/nginx/error.log

# Revisar puertos en uso
sudo ss -tlnp | grep -E '(80|443)'
```

### Regenerar certificados SSL

```bash
# Cargar variables
source /etc/arush/env.sh

# Eliminar certificados
sudo rm -f ${CRT_FILE} ${KEY_FILE} ${FULLCHAIN}

# Regenerar (seguir paso 9 del procedimiento)
```

## 📁 Estructura de Directorios

```
/var/www/
├── app/              # Laravel 11
│   ├── app/
│   ├── public/
│   ├── storage/
│   └── ...
├── front/            # Vue.js Frontend
│   ├── dist/
│   ├── src/
│   └── ...
└── blog/             # Vue.js Blog
    ├── dist/
    ├── src/
    └── ...

/etc/nginx/
├── sites-available/
│   ├── app.arush.local
│   ├── front.arush.local
│   ├── blog.arush.local
│   └── pgadmin
└── snippets/
    ├── tls-arush.conf
    └── headers-arush.conf

/etc/ssl/
├── localCA/
│   ├── certs/
│   │   └── ca.crt
│   └── private/
│       └── ca.key
├── certs/
│   └── arush-local-san.crt
└── private/
    └── arush-local-san.key
```

## 📚 Documentación Adicional

- **Procedimiento completo:** `PROCEDIMIENTO_INSTALACION_SERVIDOR.md`
- **Variables de entorno:** `/etc/arush/env.sh`
- **Script de instalación:** `install-server.sh`
- **Script de backup:** `/usr/local/bin/backup-arush.sh`

## 🤝 Soporte

Para soporte o consultas sobre la instalación:

1. Revisa el archivo `PROCEDIMIENTO_INSTALACION_SERVIDOR.md`
2. Verifica los logs de cada servicio
3. Consulta la sección de Troubleshooting

## 📝 Notas Finales

- ⚠️ Este stack está optimizado para **desarrollo y entornos locales**
- 🔐 Para producción, cambia las contraseñas y configura certificados SSL válidos
- 💡 Los certificados autofirmados son válidos por 10 años
- 🔄 Se recomienda configurar backups automáticos

---

**Instalación completada por:** DevOps Senior  
**Stack:** Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js  
**Fecha:** 2025-10-16
