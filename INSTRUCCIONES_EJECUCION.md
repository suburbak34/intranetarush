# 🚀 Instrucciones de Ejecución - Script de Instalación

## Procedimiento para Ejecutar install-server.sh en Ubuntu Server

---

## 📋 Pre-requisitos

Antes de comenzar, asegúrate de tener:

- ✅ Servidor Ubuntu 24.04 LTS instalado
- ✅ Usuario `suburbak` creado con privilegios sudo
- ✅ Conexión SSH funcionando
- ✅ Acceso a Internet desde el servidor
- ✅ Archivo `install-server.sh` descargado en tu máquina local

---

## 📥 Paso 1: Transferir el Script al Servidor

### Opción A: Usando SCP (Desde tu máquina local)

```bash
# Transferir el script a la raíz del usuario suburbak
scp /workspace/install-server.sh suburbak@192.168.1.13:~/
```

### Opción B: Usando SFTP

```bash
# Conectar por SFTP
sftp suburbak@192.168.1.13

# Subir el archivo
put /workspace/install-server.sh

# Salir
exit
```

### Opción C: Copiar y pegar manualmente

```bash
# 1. Conectar al servidor
ssh suburbak@192.168.1.13

# 2. Crear el archivo
nano ~/install-server.sh

# 3. Copiar y pegar el contenido del script
# 4. Guardar: Ctrl+O, Enter, Ctrl+X
```

---

## 🔧 Paso 2: Verificar el Archivo en el Servidor

```bash
# Conectar al servidor (si aún no estás conectado)
ssh suburbak@192.168.1.13

# Verificar que el archivo existe
ls -lh ~/install-server.sh

# Deberías ver algo como:
# -rw-r--r-- 1 suburbak suburbak 27K Oct 16 15:00 /home/suburbak/install-server.sh
```

---

## ✅ Paso 3: Dar Permisos de Ejecución

```bash
# Hacer el script ejecutable
chmod +x ~/install-server.sh

# Verificar permisos
ls -lh ~/install-server.sh

# Ahora deberías ver:
# -rwxr-xr-x 1 suburbak suburbak 27K Oct 16 15:00 /home/suburbak/install-server.sh
#  ^^^
#  Nota la 'x' que indica que es ejecutable
```

---

## 🚀 Paso 4: Ejecutar el Script

### ⚠️ IMPORTANTE: El script DEBE ejecutarse como root o con sudo

```bash
# Ejecutar el script con sudo
sudo bash ~/install-server.sh
```

### Alternativa: Ejecutar como root

```bash
# Cambiar a root
sudo su -

# Ejecutar el script
bash /home/suburbak/install-server.sh

# Salir de root al terminar
exit
```

---

## 📊 Paso 5: Monitorear la Instalación

Durante la ejecución verás:

```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║          Script de Instalación Automatizada                             ║
║          Stack: Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js   ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

==> 1. Configurando variables de entorno...
✓ Variables de entorno configuradas

==> 2. Configuración inicial del sistema...
...
```

### Tiempos Esperados:

- **Actualización del sistema:** 3-5 minutos
- **Instalación de Nginx + PHP:** 2-3 minutos  
- **Instalación de PostgreSQL:** 2-3 minutos
- **Instalación de pgAdmin:** 1-2 minutos
- **Generación de certificados SSL:** 2-3 minutos
- **Instalación de Composer + Node.js:** 2-3 minutos
- **Despliegue de Laravel:** 3-5 minutos
- **Despliegue de Vue.js:** 2-3 minutos

**Tiempo total estimado: 15-25 minutos**

---

## 📝 Paso 6: Guardar Log de Instalación (Opcional)

Para guardar un registro de la instalación:

```bash
# Ejecutar con redirección de salida a archivo log
sudo bash ~/install-server.sh 2>&1 | tee ~/instalacion-$(date +%Y%m%d-%H%M%S).log
```

Esto creará un archivo log como: `instalacion-20251016-150530.log`

---

## ✅ Paso 7: Verificar la Instalación

Después de que el script termine, verás un resumen:

```
=== Estado de Servicios ===
nginx.service - A high performance web server
     Active: active (running) since...

php8.3-fpm.service - The PHP 8.3 FastCGI Process Manager
     Active: active (running) since...

postgresql.service - PostgreSQL RDBMS
     Active: active (running) since...

=== Versiones Instaladas ===
nginx version: nginx/1.24.0
PHP 8.3.x (cli)
psql (PostgreSQL) 16.x
Composer version 2.x.x
v20.x.x
10.x.x

¡Instalación completada exitosamente!

=== URLs de Acceso ===
  • Laravel Backend:   https://app.arush.local
  • Vue.js Frontend:   https://front.arush.local
  • Blog Vue.js:       https://blog.arush.local
  • pgAdmin 4:         http://192.168.1.13:5050/pgadmin4
```

### Verificación Manual:

```bash
# 1. Verificar servicios
sudo systemctl status nginx php8.3-fpm postgresql

# 2. Verificar puertos
sudo ss -tlnp | grep -E '(80|443|5432|5050)'

# 3. Verificar firewall
sudo ufw status verbose

# 4. Verificar certificados
sudo openssl x509 -in /etc/ssl/certs/arush-local-san.crt -text -noout | grep -E 'Not After'

# 5. Probar sitios web (desde el servidor)
curl -I -k https://app.arush.local
curl -I -k https://front.arush.local
curl -I -k https://blog.arush.local
```

---

## 🖥️ Paso 8: Configurar tu Máquina Cliente

### 8.1 Agregar Entradas DNS en tu Máquina Local

**En Linux/Mac:**

```bash
sudo nano /etc/hosts
```

**En Windows:**

```cmd
notepad C:\Windows\System32\drivers\etc\hosts
```

**Agregar estas líneas:**

```
192.168.1.13  app.arush.local
192.168.1.13  front.arush.local
192.168.1.13  blog.arush.local
```

Guardar y cerrar.

### 8.2 Verificar desde el Cliente

```bash
# Verificar resolución DNS
ping app.arush.local
```

### 8.3 Abrir en Navegador

Ahora puedes acceder a:

- 🌐 **Laravel:** https://app.arush.local
- 🌐 **Frontend Vue.js:** https://front.arush.local
- 🌐 **Blog:** https://blog.arush.local
- 🔧 **pgAdmin:** http://192.168.1.13:5050/pgadmin4

---

## 🔐 Paso 9: Importar Certificado CA (Opcional)

Para evitar advertencias SSL en navegadores:

### 9.1 Descargar Certificado CA

```bash
# Desde tu máquina local
scp suburbak@192.168.1.13:/etc/ssl/localCA/certs/ca.crt ~/arush-ca.crt
```

### 9.2 Importar en Navegador

**Firefox:**
1. Preferencias → Privacidad y Seguridad
2. Certificados → Ver Certificados
3. Pestaña "Autoridades"
4. Importar → Seleccionar `arush-ca.crt`
5. Marcar "Confiar en esta CA para identificar sitios web"

**Chrome/Edge:**
1. Configuración → Privacidad y seguridad
2. Seguridad → Administrar certificados
3. Pestaña "Autoridades de certificación raíz de confianza"
4. Importar → Seleccionar `arush-ca.crt`

**Sistema Linux:**
```bash
sudo cp ~/arush-ca.crt /usr/local/share/ca-certificates/arush-local-ca.crt
sudo update-ca-certificates
```

---

## 🔑 Credenciales de Acceso

### pgAdmin 4
- **URL:** http://192.168.1.13:5050/pgadmin4
- **Email:** admin@arush.local
- **Password:** R2705mr2

### PostgreSQL
- **Host:** 192.168.1.13 (o localhost desde el servidor)
- **Puerto:** 5432
- **Usuario:** arush
- **Password:** R2705mr2
- **Base de datos:** app_arush

### SSH
- **Usuario:** suburbak
- **Puerto:** 22
- **IP:** 192.168.1.13

⚠️ **IMPORTANTE:** Cambia estas contraseñas en ambientes de producción

---

## 🐛 Solución de Problemas

### Error: "Permission denied"

```bash
# Asegurarse de ejecutar con sudo
sudo bash ~/install-server.sh
```

### Error: "Script not found"

```bash
# Verificar que el archivo existe
ls -lh ~/install-server.sh

# Verificar la ruta completa
pwd
# Debería mostrar: /home/suburbak
```

### Error: "No space left on device"

```bash
# Verificar espacio en disco
df -h

# Se requieren al menos 20GB libres
```

### Error durante instalación de paquetes

```bash
# Actualizar repositorios
sudo apt update

# Reintentar instalación
sudo bash ~/install-server.sh
```

### El script se detiene o falla

```bash
# Ver logs detallados
sudo bash -x ~/install-server.sh 2>&1 | tee ~/debug.log

# Revisar el log
less ~/debug.log
```

### Verificar variables de entorno

```bash
# Después de la instalación
source /etc/arush/env.sh
echo $DOMAIN
# Debería mostrar: arush.local
```

---

## 🔄 Reinstalación o Limpieza

Si necesitas reinstalar desde cero:

### Opción 1: Limpiar componentes manualmente

```bash
# Detener servicios
sudo systemctl stop nginx php8.3-fpm postgresql

# Eliminar paquetes (CUIDADO: esto borra todo)
sudo apt purge -y nginx php8.3* postgresql* pgadmin4*

# Limpiar directorios
sudo rm -rf /var/www/app /var/www/front /var/www/blog
sudo rm -rf /etc/nginx/sites-*
sudo rm -rf /etc/ssl/localCA
sudo rm -rf /etc/arush

# Limpiar autoremove
sudo apt autoremove -y
sudo apt autoclean

# Luego ejecutar el script nuevamente
sudo bash ~/install-server.sh
```

### Opción 2: Reinstalar Ubuntu (más limpio)

Reinstala Ubuntu 24.04 LTS desde cero y ejecuta el script.

---

## 📋 Checklist de Ejecución

Usa esta lista para verificar cada paso:

- [ ] **1. Pre-requisitos verificados**
  - [ ] Ubuntu 24.04 LTS instalado
  - [ ] Usuario suburbak con sudo
  - [ ] Conexión SSH funcionando
  - [ ] Internet disponible

- [ ] **2. Archivo transferido**
  - [ ] Script copiado a /home/suburbak/install-server.sh
  - [ ] Permisos de ejecución aplicados (chmod +x)

- [ ] **3. Ejecución del script**
  - [ ] Script ejecutado con sudo
  - [ ] Sin errores durante la instalación
  - [ ] Mensaje de finalización mostrado

- [ ] **4. Verificación en servidor**
  - [ ] Nginx corriendo
  - [ ] PHP-FPM corriendo
  - [ ] PostgreSQL corriendo
  - [ ] Puertos 80, 443, 5432, 5050 escuchando
  - [ ] UFW activo

- [ ] **5. Configuración cliente**
  - [ ] Archivo /etc/hosts actualizado
  - [ ] DNS resolviendo correctamente

- [ ] **6. Pruebas de acceso**
  - [ ] https://app.arush.local carga
  - [ ] https://front.arush.local carga
  - [ ] https://blog.arush.local carga
  - [ ] http://192.168.1.13:5050/pgadmin4 carga

- [ ] **7. Certificado CA (opcional)**
  - [ ] CA descargado
  - [ ] Importado en navegador

- [ ] **8. Credenciales probadas**
  - [ ] pgAdmin login exitoso
  - [ ] PostgreSQL conexión exitosa

---

## 📞 Comandos de Referencia Rápida

### Gestión de Servicios

```bash
# Reiniciar todos los servicios
sudo systemctl restart nginx php8.3-fpm postgresql

# Ver estado
sudo systemctl status nginx php8.3-fpm postgresql

# Ver logs
sudo journalctl -u nginx -f
sudo journalctl -u php8.3-fpm -f
sudo journalctl -u postgresql -f
```

### Laravel

```bash
cd /var/www/app

# Limpiar cache
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan config:clear

# Reconstruir cache
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
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

### Backup Manual

```bash
# Ejecutar backup
sudo /usr/local/bin/backup-arush.sh

# Ver backups
ls -lh /backup/arush/
```

---

## 🎯 Resumen del Procedimiento

### Comando Completo de Instalación:

```bash
# En una sola línea (desde tu máquina local):
scp /workspace/install-server.sh suburbak@192.168.1.13:~/ && \
ssh suburbak@192.168.1.13 "chmod +x ~/install-server.sh && sudo bash ~/install-server.sh"
```

### O paso a paso:

```bash
# 1. Transferir
scp /workspace/install-server.sh suburbak@192.168.1.13:~/

# 2. Conectar
ssh suburbak@192.168.1.13

# 3. Ejecutar
chmod +x ~/install-server.sh
sudo bash ~/install-server.sh
```

---

## ✅ Instalación Exitosa

Si todo salió bien, verás:

```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║              ¡Instalación del servidor completada!                       ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

¡Todo listo para comenzar a desarrollar! 🚀
```

---

**Creado por:** DevOps Senior  
**Fecha:** 2025-10-16  
**Stack:** Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js  

---

## 📚 Documentación Adicional

- **PROCEDIMIENTO_INSTALACION_SERVIDOR.md** - Procedimiento completo paso a paso
- **CHECKLIST_INSTALACION.md** - Lista de verificación detallada
- **README_INSTALACION.md** - Manual de usuario
- **RESUMEN_INSTALACION.md** - Resumen ejecutivo

---

**¡Tu servidor web está listo para producción!** 🎉
