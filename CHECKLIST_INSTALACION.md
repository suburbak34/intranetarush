# ✅ Checklist de Instalación - Servidor Web Ubuntu 24.04 LTS

## 📋 Lista de Verificación Completa

### 🔧 Fase 1: Preparación (10 min)

- [ ] **1.1** Servidor Ubuntu 24.04 LTS instalado y accesible
- [ ] **1.2** Conexión SSH funcionando
- [ ] **1.3** Usuario con privilegios sudo creado
- [ ] **1.4** Acceso a Internet verificado
- [ ] **1.5** Requisitos mínimos verificados:
  - [ ] CPU: 2+ cores
  - [ ] RAM: 2+ GB
  - [ ] Disco: 20+ GB libre
  - [ ] Red: Configurada en 192.168.1.0/24

**Comandos de verificación:**
```bash
# Verificar versión Ubuntu
lsb_release -a

# Verificar recursos
free -h
df -h
nproc

# Verificar conectividad
ping -c 3 google.com
```

---

### 📥 Fase 2: Transferir Archivos (2 min)

- [ ] **2.1** Archivos descargados/clonados
- [ ] **2.2** Archivos transferidos al servidor:
  - [ ] `PROCEDIMIENTO_INSTALACION_SERVIDOR.md`
  - [ ] `install-server.sh`
  - [ ] `README_INSTALACION.md`
  - [ ] `RESUMEN_INSTALACION.md`
  - [ ] `CHECKLIST_INSTALACION.md`

**Comandos:**
```bash
# Desde tu máquina local
scp -r /workspace/* usuario@192.168.1.13:/tmp/arush-install/

# Verificar en el servidor
ssh usuario@192.168.1.13
ls -la /tmp/arush-install/
```

---

### 🚀 Fase 3: Ejecutar Instalación Automatizada (15-20 min)

- [ ] **3.1** Variables de entorno revisadas en `/etc/arush/env.sh`
- [ ] **3.2** Script de instalación ejecutado
- [ ] **3.3** Instalación completada sin errores
- [ ] **3.4** Log de instalación guardado

**Comandos:**
```bash
cd /tmp/arush-install

# Revisar variables (opcional - modificar si es necesario)
nano install-server.sh

# Ejecutar instalación
sudo bash install-server.sh 2>&1 | tee instalacion.log

# El script instalará automáticamente todos los componentes
```

**Componentes que se instalarán:**
- [⏳] Configuración del sistema
- [⏳] SSH hardening
- [⏳] Firewall UFW
- [⏳] Nginx
- [⏳] PHP 8.3
- [⏳] PostgreSQL 16
- [⏳] pgAdmin 4
- [⏳] Certificados SSL
- [⏳] Virtual Hosts
- [⏳] Composer
- [⏳] Node.js y NPM
- [⏳] Laravel 11
- [⏳] Vue.js (Frontend)
- [⏳] Vue.js (Blog)
- [⏳] Backup script

---

### ✅ Fase 4: Verificación en Servidor (5 min)

#### 4.1 Servicios

- [ ] **Nginx** está corriendo
  ```bash
  sudo systemctl status nginx
  ```

- [ ] **PHP-FPM 8.3** está corriendo
  ```bash
  sudo systemctl status php8.3-fpm
  ```

- [ ] **PostgreSQL 16** está corriendo
  ```bash
  sudo systemctl status postgresql
  ```

- [ ] **Todos los servicios** habilitados para inicio automático
  ```bash
  sudo systemctl is-enabled nginx php8.3-fpm postgresql
  ```

#### 4.2 Versiones

- [ ] **Nginx** instalado
  ```bash
  nginx -v
  # Esperado: nginx version: nginx/1.x.x
  ```

- [ ] **PHP 8.3** instalado
  ```bash
  php -v
  # Esperado: PHP 8.3.x
  ```

- [ ] **PostgreSQL 16** instalado
  ```bash
  psql --version
  # Esperado: psql (PostgreSQL) 16.x
  ```

- [ ] **Composer** instalado
  ```bash
  composer --version
  # Esperado: Composer version 2.x.x
  ```

- [ ] **Node.js 20.x** instalado
  ```bash
  node --version
  # Esperado: v20.x.x
  ```

- [ ] **NPM** instalado
  ```bash
  npm --version
  # Esperado: 10.x.x
  ```

#### 4.3 Puertos

- [ ] **Puerto 80** (HTTP) escuchando
- [ ] **Puerto 443** (HTTPS) escuchando
- [ ] **Puerto 5432** (PostgreSQL) escuchando
- [ ] **Puerto 5050** (pgAdmin) escuchando

```bash
sudo ss -tlnp | grep -E '(80|443|5432|5050)'

# Esperado:
# *:80    LISTEN  nginx
# *:443   LISTEN  nginx
# *:5432  LISTEN  postgres
# *:5050  LISTEN  nginx
```

#### 4.4 Firewall

- [ ] **UFW** habilitado y activo
- [ ] **Reglas** configuradas correctamente

```bash
sudo ufw status verbose

# Esperado:
# Status: active
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW       192.168.1.0/24
# 80/tcp                     ALLOW       192.168.1.0/24
# 443/tcp                    ALLOW       192.168.1.0/24
# 5432/tcp                   ALLOW       192.168.1.0/24
# 5050/tcp                   ALLOW       192.168.1.0/24
```

#### 4.5 Certificados SSL

- [ ] **CA creada** en `/etc/ssl/localCA/certs/ca.crt`
- [ ] **Certificado servidor** en `/etc/ssl/certs/arush-local-san.crt`
- [ ] **Clave privada** en `/etc/ssl/private/arush-local-san.key`
- [ ] **Certificado válido** por 10 años

```bash
# Verificar existencia
ls -la /etc/ssl/localCA/certs/ca.crt
ls -la /etc/ssl/certs/arush-local-san.crt

# Verificar validez (10 años)
sudo openssl x509 -in /etc/ssl/certs/arush-local-san.crt -text -noout | grep -E '(Not Before|Not After)'

# Verificar SANs
sudo openssl x509 -in /etc/ssl/certs/arush-local-san.crt -text -noout | grep -A 5 "Subject Alternative"
# Esperado: DNS:app.arush.local, DNS:front.arush.local, DNS:blog.arush.local
```

#### 4.6 Base de Datos

- [ ] **Usuario** `arush` creado
- [ ] **Base de datos** `app_arush` creada
- [ ] **Conexión** funcionando

```bash
# Listar bases de datos
sudo -u postgres psql -c "\l" | grep app_arush

# Listar usuarios
sudo -u postgres psql -c "\du" | grep arush

# Probar conexión
PGPASSWORD=R2705mr2 psql -h localhost -U arush -d app_arush -c "SELECT version();"
```

#### 4.7 Virtual Hosts

- [ ] **app.arush.local** configurado
- [ ] **front.arush.local** configurado
- [ ] **blog.arush.local** configurado
- [ ] **Todos** habilitados en sites-enabled

```bash
# Verificar archivos de configuración
ls -la /etc/nginx/sites-available/ | grep arush

# Verificar enlaces simbólicos
ls -la /etc/nginx/sites-enabled/ | grep arush

# Probar configuración Nginx
sudo nginx -t
```

#### 4.8 Aplicaciones

- [ ] **Laravel** instalado en `/var/www/app`
- [ ] **Vue Frontend** instalado en `/var/www/front`
- [ ] **Vue Blog** instalado en `/var/www/blog`
- [ ] **Permisos** correctos configurados

```bash
# Verificar directorios
ls -la /var/www/

# Verificar Laravel
ls -la /var/www/app/ | grep artisan
cat /var/www/app/.env | grep APP_KEY

# Verificar Vue projects
ls -la /var/www/front/dist/
ls -la /var/www/blog/dist/

# Verificar permisos
ls -la /var/www/app/storage
ls -la /var/www/app/bootstrap/cache
```

#### 4.9 Pruebas Locales (desde servidor)

- [ ] **app.arush.local** responde HTTP 301 (redirección)
  ```bash
  curl -I http://app.arush.local
  # Esperado: HTTP/1.1 301 Moved Permanently
  ```

- [ ] **app.arush.local** responde HTTPS 200
  ```bash
  curl -I -k https://app.arush.local
  # Esperado: HTTP/2 200
  ```

- [ ] **front.arush.local** responde HTTPS 200
  ```bash
  curl -I -k https://front.arush.local
  # Esperado: HTTP/2 200
  ```

- [ ] **blog.arush.local** responde HTTPS 200
  ```bash
  curl -I -k https://blog.arush.local
  # Esperado: HTTP/2 200
  ```

---

### 💻 Fase 5: Configuración del Cliente (5 min)

#### 5.1 Archivo Hosts

**En tu máquina local (no el servidor):**

- [ ] **Linux/Mac:** Editar `/etc/hosts`
  ```bash
  sudo nano /etc/hosts
  ```

- [ ] **Windows:** Editar `C:\Windows\System32\drivers\etc\hosts`
  ```cmd
  notepad C:\Windows\System32\drivers\etc\hosts
  ```

- [ ] **Agregar líneas:**
  ```
  192.168.1.13  app.arush.local
  192.168.1.13  front.arush.local
  192.168.1.13  blog.arush.local
  ```

- [ ] **Verificar resolución DNS:**
  ```bash
  # Linux/Mac
  ping -c 2 app.arush.local
  
  # Windows
  ping app.arush.local
  ```

#### 5.2 Certificado CA (Opcional)

- [ ] **Descargar** certificado CA del servidor
  ```bash
  scp usuario@192.168.1.13:/etc/ssl/localCA/certs/ca.crt ~/arush-ca.crt
  ```

- [ ] **Importar en navegador:**
  
  **Firefox:**
  - [ ] Abrir Preferencias/Settings
  - [ ] Ir a Privacidad y Seguridad
  - [ ] Certificados → Ver Certificados
  - [ ] Pestaña "Autoridades"
  - [ ] Importar `arush-ca.crt`
  - [ ] Marcar "Confiar en esta CA para identificar sitios web"
  
  **Chrome/Edge:**
  - [ ] Abrir Configuración
  - [ ] Buscar "Certificados"
  - [ ] Administrar certificados
  - [ ] Pestaña "Autoridades de certificación raíz de confianza"
  - [ ] Importar → Seleccionar `arush-ca.crt`
  
  **Sistema Linux:**
  ```bash
  sudo cp ~/arush-ca.crt /usr/local/share/ca-certificates/arush-local-ca.crt
  sudo update-ca-certificates
  ```

---

### 🌐 Fase 6: Pruebas desde Cliente (5 min)

#### 6.1 Acceso Web

**Abrir en navegador:**

- [ ] **Laravel Backend**
  ```
  https://app.arush.local
  ```
  - [ ] Página carga correctamente
  - [ ] Sin errores SSL (si CA importada)
  - [ ] Laravel welcome page visible

- [ ] **Frontend Vue.js**
  ```
  https://front.arush.local
  ```
  - [ ] Página carga correctamente
  - [ ] Sin errores SSL (si CA importada)
  - [ ] Vue.js app visible

- [ ] **Blog Vue.js**
  ```
  https://blog.arush.local
  ```
  - [ ] Página carga correctamente
  - [ ] Sin errores SSL (si CA importada)
  - [ ] Blog visible

#### 6.2 pgAdmin 4

- [ ] **Acceder a pgAdmin**
  ```
  http://192.168.1.13:5050/pgadmin4
  ```

- [ ] **Iniciar sesión:**
  - Email: `admin@arush.local`
  - Password: `R2705mr2`

- [ ] **Agregar servidor PostgreSQL:**
  - [ ] Click derecho en "Servers" → Create → Server
  - [ ] General → Name: `Arush Local`
  - [ ] Connection:
    - Host: `192.168.1.13` o `localhost`
    - Port: `5432`
    - Database: `app_arush`
    - Username: `arush`
    - Password: `R2705mr2`
  - [ ] Save

- [ ] **Verificar base de datos:**
  - [ ] Expandir: Servers → Arush Local → Databases → app_arush
  - [ ] Ver tablas de Laravel (migrations, users, etc.)

#### 6.3 Redirección HTTP → HTTPS

- [ ] **Verificar redirección automática:**
  
  Abrir en navegador (HTTP):
  ```
  http://app.arush.local
  ```
  - [ ] Debe redirigir automáticamente a `https://app.arush.local`
  
  ```
  http://front.arush.local
  ```
  - [ ] Debe redirigir automáticamente a `https://front.arush.local`
  
  ```
  http://blog.arush.local
  ```
  - [ ] Debe redirigir automáticamente a `https://blog.arush.local`

#### 6.4 Headers de Seguridad

- [ ] **Verificar headers** (F12 → Network → Seleccionar recurso → Headers)

  Debe incluir:
  - [ ] `Strict-Transport-Security: max-age=31536000`
  - [ ] `X-Frame-Options: SAMEORIGIN`
  - [ ] `X-Content-Type-Options: nosniff`
  - [ ] `X-XSS-Protection: 1; mode=block`
  - [ ] `Content-Security-Policy: ...`

---

### 📊 Fase 7: Verificación Final (5 min)

#### 7.1 Resumen de Componentes

**Verificar que TODO esté instalado:**

| Componente | Versión Esperada | Comando Verificación | Estado |
|------------|------------------|----------------------|--------|
| Ubuntu | 24.04 LTS | `lsb_release -a` | [ ] ✅ |
| Nginx | 1.24+ | `nginx -v` | [ ] ✅ |
| PHP | 8.3.x | `php -v` | [ ] ✅ |
| PostgreSQL | 16.x | `psql --version` | [ ] ✅ |
| pgAdmin | 4.x | Browser: puerto 5050 | [ ] ✅ |
| Composer | 2.x | `composer --version` | [ ] ✅ |
| Node.js | 20.x | `node --version` | [ ] ✅ |
| NPM | 10.x | `npm --version` | [ ] ✅ |
| Laravel | 11.x | `/var/www/app/artisan --version` | [ ] ✅ |
| Vue.js | 3.x | `/var/www/front/package.json` | [ ] ✅ |

#### 7.2 Servicios Activos

- [ ] **3/3 servicios** principales corriendo:
  ```bash
  sudo systemctl is-active nginx php8.3-fpm postgresql
  # Esperado: active, active, active
  ```

#### 7.3 Acceso a URLs

- [ ] **4/4 URLs** accesibles:
  - [ ] ✅ https://app.arush.local
  - [ ] ✅ https://front.arush.local
  - [ ] ✅ https://blog.arush.local
  - [ ] ✅ http://192.168.1.13:5050/pgadmin4

#### 7.4 Seguridad

- [ ] **Firewall** activo y configurado
- [ ] **SSH** hardening aplicado
- [ ] **SSL/TLS** funcionando (TLSv1.2/1.3)
- [ ] **Headers** de seguridad presentes
- [ ] **Permisos** de archivos correctos

#### 7.5 Base de Datos

- [ ] **PostgreSQL** accesible remotamente desde LAN
- [ ] **pgAdmin** conectado exitosamente
- [ ] **Migraciones Laravel** ejecutadas

---

### 🎯 Fase 8: Documentación y Backup (5 min)

#### 8.1 Archivos de Documentación

- [ ] **Procedimiento completo** disponible:
  ```
  /workspace/PROCEDIMIENTO_INSTALACION_SERVIDOR.md
  ```

- [ ] **README** disponible:
  ```
  /workspace/README_INSTALACION.md
  ```

- [ ] **Resumen** disponible:
  ```
  /workspace/RESUMEN_INSTALACION.md
  ```

- [ ] **Checklist** (este archivo) disponible:
  ```
  /workspace/CHECKLIST_INSTALACION.md
  ```

#### 8.2 Script de Backup

- [ ] **Script creado** en `/usr/local/bin/backup-arush.sh`
- [ ] **Script ejecutable:**
  ```bash
  sudo chmod +x /usr/local/bin/backup-arush.sh
  ```

- [ ] **Probar backup manual:**
  ```bash
  sudo /usr/local/bin/backup-arush.sh
  ```

- [ ] **Verificar archivos de backup:**
  ```bash
  ls -lh /backup/arush/
  ```

- [ ] **Programar backup automático** (opcional):
  ```bash
  (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-arush.sh") | crontab -
  crontab -l
  ```

#### 8.3 Variables de Entorno

- [ ] **Archivo de variables** creado:
  ```bash
  cat /etc/arush/env.sh
  ```

- [ ] **Variables cargadas** automáticamente:
  ```bash
  source /etc/arush/env.sh
  echo $DOMAIN
  # Esperado: arush.local
  ```

---

### 📝 Fase 9: Notas Post-Instalación

#### 9.1 Credenciales por Defecto

**Anota y guarda estas credenciales de forma segura:**

| Servicio | Usuario | Contraseña | Ubicación |
|----------|---------|------------|-----------|
| pgAdmin | admin@arush.local | R2705mr2 | http://IP:5050/pgadmin4 |
| PostgreSQL | arush | R2705mr2 | localhost:5432 |
| SSH | suburbak | (tu contraseña) | puerto 22 |
| Sistema | suburbak | (tu contraseña) | - |

⚠️ **IMPORTANTE:** Cambia estas contraseñas para producción

#### 9.2 Comandos Útiles Frecuentes

**Guardar estos comandos:**

```bash
# Reiniciar servicios
sudo systemctl restart nginx php8.3-fpm postgresql

# Ver logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/www/app/storage/logs/laravel.log

# Laravel artisan
cd /var/www/app
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan migrate

# Rebuild Vue.js
cd /var/www/front && sudo -u www-data npm run build
cd /var/www/blog && sudo -u www-data npm run build

# Ver estado UFW
sudo ufw status verbose

# Backup manual
sudo /usr/local/bin/backup-arush.sh
```

#### 9.3 Próximos Pasos

**Para Desarrollo:**
- [ ] Clonar repositorios de código
- [ ] Configurar Git en el servidor
- [ ] Crear seeders para datos de prueba
- [ ] Desarrollar APIs en Laravel
- [ ] Desarrollar componentes Vue.js

**Para Producción:**
- [ ] Cambiar TODAS las contraseñas
- [ ] Obtener certificados SSL válidos (Let's Encrypt)
- [ ] Habilitar autenticación SSH por llaves
- [ ] Configurar monitoring (Prometheus/Grafana)
- [ ] Implementar CI/CD
- [ ] Habilitar Fail2ban
- [ ] Configurar rate limiting
- [ ] Backups externos automáticos

---

## 🎉 ¡INSTALACIÓN COMPLETADA!

### ✅ Resumen Final

Si has marcado TODAS las casillas anteriores, tu instalación está **100% completa y funcional**.

**Has instalado exitosamente:**

✅ **Sistema Base:**
- Ubuntu Server 24.04 LTS configurado
- Zona horaria: America/Mexico_City
- SSH hardening aplicado
- Firewall UFW activo

✅ **Stack Web:**
- Nginx (servidor web)
- PHP 8.3 + FPM
- PostgreSQL 16
- pgAdmin 4

✅ **Frameworks:**
- Laravel 11 (Backend)
- Vue.js 3 (Frontend x2)

✅ **Herramientas:**
- Composer
- Node.js 20 LTS + NPM
- Vue CLI, Vite

✅ **Seguridad:**
- Certificados SSL (10 años)
- Firewall configurado
- HTTPS obligatorio
- Headers de seguridad

✅ **Extras:**
- 3 Virtual Hosts
- Script de backup automático
- Documentación completa

### 🚀 Comienza a Desarrollar

**Tu servidor está listo. Accede a:**

```
🌐 Laravel:  https://app.arush.local
🌐 Frontend: https://front.arush.local
🌐 Blog:     https://blog.arush.local
🔧 pgAdmin:  http://192.168.1.13:5050/pgadmin4
```

**SSH al servidor:**
```bash
ssh suburbak@192.168.1.13
cd /var/www/app
php artisan about
```

---

### 📚 Referencias Rápidas

- **Procedimiento completo:** `PROCEDIMIENTO_INSTALACION_SERVIDOR.md`
- **Manual de uso:** `README_INSTALACION.md`
- **Resumen ejecutivo:** `RESUMEN_INSTALACION.md`
- **Este checklist:** `CHECKLIST_INSTALACION.md`

---

### 📞 Soporte

**Si algo no funciona:**

1. ✅ Revisa este checklist punto por punto
2. 📖 Consulta el `PROCEDIMIENTO_INSTALACION_SERVIDOR.md`
3. 🔍 Revisa los logs de servicios
4. 🐛 Consulta sección "Troubleshooting" en `README_INSTALACION.md`

---

**Instalación completada por:** DevOps Senior  
**Stack:** Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js  
**Fecha:** 2025-10-16  
**Versión:** 1.0

---

## 📊 Estadísticas de Instalación

**Tiempo total estimado:** ~50 minutos

| Fase | Tiempo | Descripción |
|------|--------|-------------|
| 1. Preparación | 10 min | Verificar requisitos |
| 2. Transferir archivos | 2 min | SCP al servidor |
| 3. Instalación | 15-20 min | Script automatizado |
| 4. Verificación servidor | 5 min | Comandos de check |
| 5. Config cliente | 5 min | Hosts y certificado |
| 6. Pruebas cliente | 5 min | Navegador |
| 7. Verificación final | 5 min | Resumen completo |
| 8. Documentación | 5 min | Backup y notas |

**Total:** ✅ Servidor completo en ~1 hora

---

¡Felicitaciones! 🎊 Tu servidor web está completamente operativo. 🚀
