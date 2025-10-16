# 🚀 Instalación Servidor Web - Ubuntu 24.04 LTS

## ¡Bienvenido al Paquete de Instalación Completo!

---

## 📦 ¿Qué Contiene Este Paquete?

**Un sistema completo de instalación automatizada para:**

### Stack Tecnológico
- 🌐 **Nginx** - Servidor web con HTTP/2 y SSL/TLS
- 🐘 **PHP 8.3** - Con 15 extensiones + PHP-FPM
- 🐘 **PostgreSQL 16** - Base de datos relacional
- 🔧 **pgAdmin 4** - Administrador web de PostgreSQL
- 🎨 **Laravel 11** - Framework backend PHP
- ⚡ **Vue.js 3** - Framework frontend (2 proyectos)

### Herramientas
- 📦 **Composer** - Gestión de paquetes PHP
- 📦 **Node.js 20 LTS + NPM** - Runtime JavaScript
- 🔐 **Certificados SSL** - Autofirmados válidos 10 años
- 🛡️ **Firewall UFW** - Configurado para red local
- 🔒 **SSH Hardening** - Configuración segura
- 💾 **Backup Automático** - Script incluido

---

## 📚 6 Documentos Incluidos

### 🎯 Para Empezar Rápido (Leer Primero)

#### 1. **INDICE_DOCUMENTACION.md** ⭐ EMPIEZA AQUÍ
   > Índice completo de toda la documentación
   
   📄 15 KB | Navegación entre documentos

---

#### 2. **install-server.sh** 🚀 EJECUTA ESTO
   > Script de instalación automatizada
   
   📄 27 KB | ✅ Instalación en 1 comando (15-20 min)
   
   **Uso:**
   ```bash
   sudo bash install-server.sh
   ```

---

#### 3. **CHECKLIST_INSTALACION.md** ✅ SIGUE ESTO
   > Lista de verificación completa paso a paso
   
   📄 17 KB | 737 líneas | 9 fases | ~150 checks
   
   **Fases:**
   1. ✅ Preparación (10 min)
   2. ✅ Transferir archivos (2 min)
   3. ✅ Instalación automatizada (15-20 min)
   4. ✅ Verificación servidor (5 min)
   5. ✅ Configuración cliente (5 min)
   6. ✅ Pruebas cliente (5 min)
   7. ✅ Verificación final (5 min)
   8. ✅ Documentación y backup (5 min)
   9. ✅ Notas post-instalación

---

### 📖 Para Consulta y Referencia

#### 4. **RESUMEN_INSTALACION.md**
   > Resumen ejecutivo completo
   
   📄 13 KB | 500 líneas
   
   **Incluye:**
   - Inicio rápido en 3 pasos
   - Stack completo
   - Variables de configuración
   - URLs y credenciales
   - Estructura de archivos
   - Comandos de verificación

---

#### 5. **README_INSTALACION.md**
   > Manual de usuario y guía de uso
   
   📄 9.6 KB | 434 líneas
   
   **Incluye:**
   - Pre-requisitos
   - Instrucciones de instalación
   - Configuración del cliente
   - Comandos útiles
   - Troubleshooting
   - Backup automático

---

#### 6. **PROCEDIMIENTO_INSTALACION_SERVIDOR.md**
   > Procedimiento técnico COMPLETO
   
   📄 36 KB | 1,568 líneas | 15 secciones
   
   **Para instalación manual paso a paso**
   
   **Secciones:**
   1. Variables de Entorno
   2. Configuración Inicial
   3. SSH
   4. Firewall UFW
   5. Nginx
   6. PHP 8.3
   7. PostgreSQL
   8. pgAdmin 4
   9. Certificados SSL
   10. Virtual Hosts
   11. Composer
   12. Node.js
   13. Laravel 11
   14. Vue.js
   15. Verificación

---

## 📊 Estadísticas del Paquete

| Métrica | Valor |
|---------|-------|
| **Archivos** | 6 documentos + 1 script |
| **Líneas totales** | 4,795+ líneas |
| **Tamaño total** | ~132 KB |
| **Componentes** | 15+ servicios |
| **Tiempo instalación** | ~20 min (automatizada) |
| **Checks incluidos** | 150+ verificaciones |
| **Comandos** | 200+ comandos |

---

## 🚀 INICIO RÁPIDO - 4 Pasos

### Paso 1: Transferir Archivos al Servidor
```bash
scp -r /workspace/*.{md,sh} usuario@192.168.1.13:/tmp/arush-install/
```

### Paso 2: Conectar al Servidor
```bash
ssh usuario@192.168.1.13
```

### Paso 3: Ejecutar Instalación Automatizada
```bash
cd /tmp/arush-install
sudo bash install-server.sh
```

### Paso 4: Seguir Checklist de Verificación
```bash
cat CHECKLIST_INSTALACION.md
# Marcar cada punto ✅
```

---

## ⏱️ Tiempo Estimado

| Fase | Tiempo |
|------|--------|
| Preparación | 5 min |
| Instalación automática | 15-20 min |
| Configuración cliente | 5 min |
| Verificación | 5 min |
| **TOTAL** | **~35-40 min** |

---

## 🌐 URLs de Acceso (Post-Instalación)

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Laravel** | https://app.arush.local | Backend API |
| **Frontend** | https://front.arush.local | Vue.js SPA |
| **Blog** | https://blog.arush.local | Vue.js estático |
| **pgAdmin** | http://192.168.1.13:5050/pgadmin4 | Admin PostgreSQL |

### 🔑 Credenciales por Defecto

| Servicio | Usuario | Contraseña |
|----------|---------|------------|
| **pgAdmin** | admin@arush.local | R2705mr2 |
| **PostgreSQL** | arush | R2705mr2 |

⚠️ **Cambiar en producción**

---

## ✅ Lo Que Se Instalará

### Sistema Base
- [x] Ubuntu Server 24.04 LTS configurado
- [x] Zona horaria: America/Mexico_City
- [x] Hostname: app.arush.local
- [x] SSH hardening aplicado
- [x] Firewall UFW (red local 192.168.1.0/24)

### Servicios Web
- [x] **Nginx** con HTTP/2 y SSL/TLS
- [x] **PHP 8.3** + FPM + 15 extensiones
- [x] **PostgreSQL 16** + usuario/BD
- [x] **pgAdmin 4** en modo web

### Aplicaciones
- [x] **Laravel 11** en `/var/www/app` (app.arush.local)
- [x] **Vue.js Frontend** en `/var/www/front` (front.arush.local)
- [x] **Vue.js Blog** en `/var/www/blog` (blog.arush.local)

### Herramientas Dev
- [x] **Composer** 2.x
- [x] **Node.js** 20.x LTS
- [x] **NPM** + Yarn + PNPM
- [x] **Vue CLI** + Vite

### Seguridad
- [x] **CA privada** para desarrollo
- [x] **Certificados SSL** (10 años de validez)
- [x] **Redirección HTTP → HTTPS** automática
- [x] **Headers de seguridad** configurados
- [x] **Firewall UFW** activo

### Extras
- [x] **3 Virtual Hosts** configurados
- [x] **Script de backup** automático
- [x] **Documentación completa**

---

## 🎯 Orden de Lectura Recomendado

### Antes de Instalar

1. **LEER:** `00_INICIO_AQUI.md` (este archivo)
   - Vista general del paquete

2. **LEER:** `RESUMEN_INSTALACION.md`
   - Entender qué se instalará
   - Revisar variables

3. **EJECUTAR:** `install-server.sh`
   - Instalación automatizada

4. **SEGUIR:** `CHECKLIST_INSTALACION.md`
   - Verificar cada paso

### Después de Instalar

5. **CONSULTAR:** `README_INSTALACION.md`
   - Configurar cliente
   - Comandos útiles
   - Troubleshooting

6. **REFERENCIA:** `PROCEDIMIENTO_INSTALACION_SERVIDOR.md`
   - Detalles técnicos
   - Instalación manual

7. **ÍNDICE:** `INDICE_DOCUMENTACION.md`
   - Navegación rápida

---

## 🔧 Variables de Configuración

**Ubicación en servidor:** `/etc/arush/env.sh`

### Red y Dominio
```bash
TIMEZONE="America/Mexico_City"
LAN_CIDR="192.168.1.0/24"
SRV_IP="192.168.1.13"
DOMAIN="arush.local"
```

### Virtual Hosts
```bash
APP_HOST="app.arush.local"      # Laravel
FRONT_HOST="front.arush.local"  # Vue.js Frontend  
BLOG_HOST="blog.arush.local"    # Vue.js Blog
```

### Directorios
```bash
APP_ROOT="/var/www/app"
FRONT_ROOT="/var/www/front"
BLOG_ROOT="/var/www/blog"
```

### Base de Datos
```bash
DB_USER="arush"
DB_PASS="R2705mr2"              # ⚠️ CAMBIAR EN PRODUCCIÓN
DB_NAME="app_arush"
PG_VER="16"
```

⚠️ **Modificar en `install-server.sh` antes de ejecutar si se requieren valores diferentes**

---

## 📋 Pre-Requisitos

Antes de comenzar, verifica que tienes:

### Hardware Mínimo
- [x] CPU: 2+ cores
- [x] RAM: 2+ GB
- [x] Disco: 20+ GB libre
- [x] Red: 100 Mbps

### Software
- [x] Ubuntu Server 24.04 LTS instalado
- [x] SSH funcionando
- [x] Usuario con sudo
- [x] Acceso a Internet

### Red
- [x] IP configurada: 192.168.1.13
- [x] Rango de red: 192.168.1.0/24
- [x] Gateway accesible
- [x] DNS resolviendo

---

## 🛡️ Seguridad Incluida

### SSH Hardening
- ✅ Root login deshabilitado
- ✅ Max 3 intentos de autenticación
- ✅ Timeout de sesión: 5 min
- ✅ Solo usuario `suburbak` permitido

### Firewall UFW
- ✅ Puerto 22 (SSH) - Solo LAN
- ✅ Puerto 80 (HTTP) - Solo LAN
- ✅ Puerto 443 (HTTPS) - Solo LAN
- ✅ Puerto 5432 (PostgreSQL) - Solo LAN
- ✅ Puerto 5050 (pgAdmin) - Solo LAN
- ✅ Política por defecto: DENY incoming

### SSL/TLS
- ✅ Certificados autofirmados (10 años)
- ✅ Protocolos: TLSv1.2, TLSv1.3
- ✅ Cifrados fuertes
- ✅ HSTS habilitado
- ✅ Headers de seguridad

---

## 📚 Documentos del Paquete

### Archivo Principal
- **📄 00_INICIO_AQUI.md** (este archivo)

### Instalación
- **🚀 install-server.sh** - Script automatizado
- **✅ CHECKLIST_INSTALACION.md** - Verificación paso a paso

### Documentación
- **📊 RESUMEN_INSTALACION.md** - Resumen ejecutivo
- **📖 README_INSTALACION.md** - Manual de usuario
- **📋 PROCEDIMIENTO_INSTALACION_SERVIDOR.md** - Procedimiento completo
- **📚 INDICE_DOCUMENTACION.md** - Índice general

---

## 🐛 Troubleshooting Rápido

### Error 502 Bad Gateway
```bash
sudo systemctl restart php8.3-fpm
sudo tail -f /var/log/php8.3-fpm.log
```

### Permission Denied Laravel
```bash
cd /var/www/app
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### No conecta PostgreSQL
```bash
sudo systemctl restart postgresql
sudo tail -f /var/log/postgresql/postgresql-16-main.log
```

### Nginx no inicia
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

**📖 Más soluciones en:** `README_INSTALACION.md` → Troubleshooting

---

## 💡 Tips Importantes

### ✅ Para Principiantes
1. Usar instalación automatizada (`install-server.sh`)
2. Seguir `CHECKLIST_INSTALACION.md` paso a paso
3. Consultar `README_INSTALACION.md` para dudas

### ✅ Para Expertos
1. Revisar `PROCEDIMIENTO_INSTALACION_SERVIDOR.md`
2. Modificar variables según necesidades
3. Personalizar configuraciones

### ⚠️ Para Producción
1. **CAMBIAR** todas las contraseñas
2. **USAR** certificados SSL válidos (Let's Encrypt)
3. **HABILITAR** autenticación SSH por llaves
4. **CONFIGURAR** backups externos
5. **IMPLEMENTAR** monitoring
6. **HABILITAR** Fail2ban
7. **REVISAR** y ajustar firewall

---

## 📞 Soporte

### Orden de Resolución

1. **Consultar:**
   - `README_INSTALACION.md` → Troubleshooting
   - `CHECKLIST_INSTALACION.md` → Verificación

2. **Revisar logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   sudo tail -f /var/log/php8.3-fpm.log
   ```

3. **Verificar servicios:**
   ```bash
   sudo systemctl status nginx php8.3-fpm postgresql
   ```

---

## 🎉 ¡Comienza Ahora!

### Instalación en 3 Comandos

```bash
# 1. Transferir archivos
scp -r /workspace/* usuario@192.168.1.13:/tmp/arush-install/

# 2. Ejecutar instalación
ssh usuario@192.168.1.13 "cd /tmp/arush-install && sudo bash install-server.sh"

# 3. Configurar cliente (en tu máquina)
echo "192.168.1.13  app.arush.local front.arush.local blog.arush.local" | sudo tee -a /etc/hosts
```

### Verificar Instalación

```bash
# Abrir en navegador
https://app.arush.local
https://front.arush.local
https://blog.arush.local
http://192.168.1.13:5050/pgadmin4
```

---

## 🏆 Resumen Final

**Con este paquete obtienes:**

✅ **15+ componentes** instalados y configurados  
✅ **3 aplicaciones web** desplegadas  
✅ **Seguridad completa** (SSL, Firewall, SSH)  
✅ **6 documentos** de soporte  
✅ **150+ verificaciones** incluidas  
✅ **Backup automático** configurado  
✅ **Listo en ~40 minutos**  

---

## 📝 Siguiente Paso

### 👉 Leer: `RESUMEN_INSTALACION.md`
### 👉 Ejecutar: `install-server.sh`
### 👉 Verificar: `CHECKLIST_INSTALACION.md`

---

**¡Tu servidor web completo te espera!** 🚀

---

**Creado por:** DevOps Senior  
**Stack:** Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js  
**Fecha:** 2025-10-16  
**Versión:** 1.0

---

## 📂 Archivos del Paquete

```
/workspace/
├── 00_INICIO_AQUI.md                      ⭐ ESTE ARCHIVO
├── INDICE_DOCUMENTACION.md                📚 Índice general
├── install-server.sh                      🚀 Script de instalación
├── CHECKLIST_INSTALACION.md               ✅ Verificación
├── RESUMEN_INSTALACION.md                 📊 Resumen ejecutivo
├── README_INSTALACION.md                  📖 Manual de usuario
└── PROCEDIMIENTO_INSTALACION_SERVIDOR.md  📋 Procedimiento completo
```

**Total:** 7 archivos | ~4,795 líneas | ~140 KB

---

### 🎯 ¡Comienza tu instalación ahora!

```bash
sudo bash install-server.sh
```
