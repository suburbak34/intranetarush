# ⚡ Ejecución Rápida - install-server.sh

## 🎯 Procedimiento Resumido para Consola Ubuntu

---

## 📥 PASO 1: Copiar Script al Servidor

### Desde tu máquina local:

```bash
scp /workspace/install-server.sh suburbak@192.168.1.13:~/
```

---

## 🔐 PASO 2: Conectar al Servidor

```bash
ssh suburbak@192.168.1.13
```

---

## ✅ PASO 3: Verificar y Dar Permisos

```bash
# Verificar que el archivo existe
ls -lh ~/install-server.sh

# Dar permisos de ejecución
chmod +x ~/install-server.sh

# Verificar permisos (debe mostrar -rwxr-xr-x)
ls -lh ~/install-server.sh
```

---

## 🚀 PASO 4: Ejecutar el Script

### Opción A: Ejecución Normal

```bash
sudo bash ~/install-server.sh
```

### Opción B: Con Log de Salida

```bash
sudo bash ~/install-server.sh 2>&1 | tee ~/instalacion-$(date +%Y%m%d-%H%M%S).log
```

---

## ⏱️ TIEMPO DE ESPERA

**Duración:** 15-25 minutos

Durante la ejecución verás el progreso:

```
==> 1. Configurando variables de entorno...
✓ Variables de entorno configuradas

==> 2. Configuración inicial del sistema...
✓ Sistema actualizado

==> 3. Configurando SSH...
✓ SSH configurado

... (continúa hasta el paso 14)
```

---

## ✅ PASO 5: Verificar Instalación

```bash
# Ver estado de servicios
sudo systemctl status nginx php8.3-fpm postgresql

# Ver puertos activos
sudo ss -tlnp | grep -E '(80|443|5432|5050)'

# Ver firewall
sudo ufw status verbose
```

---

## 🌐 PASO 6: Configurar Cliente

### En tu máquina local (Linux/Mac):

```bash
sudo bash -c 'cat >> /etc/hosts <<EOF
192.168.1.13  app.arush.local
192.168.1.13  front.arush.local
192.168.1.13  blog.arush.local
EOF'
```

### En Windows:

```cmd
notepad C:\Windows\System32\drivers\etc\hosts
```

Agregar:
```
192.168.1.13  app.arush.local
192.168.1.13  front.arush.local
192.168.1.13  blog.arush.local
```

---

## 🎉 PASO 7: Acceder a las Aplicaciones

### Abrir en navegador:

- **Laravel:** https://app.arush.local
- **Frontend:** https://front.arush.local
- **Blog:** https://blog.arush.local
- **pgAdmin:** http://192.168.1.13:5050/pgadmin4

### Credenciales pgAdmin:
- Email: `admin@arush.local`
- Password: `R2705mr2`

---

## 🔑 COMANDOS DE UNA LÍNEA

### Instalación Completa (desde tu máquina local):

```bash
scp /workspace/install-server.sh suburbak@192.168.1.13:~/ && \
ssh -t suburbak@192.168.1.13 "chmod +x ~/install-server.sh && sudo bash ~/install-server.sh"
```

### Solo Ejecutar (si ya está en el servidor):

```bash
ssh -t suburbak@192.168.1.13 "sudo bash ~/install-server.sh"
```

---

## 🐛 Solución Rápida de Problemas

### Script no encontrado:
```bash
ls -lh ~/install-server.sh
pwd  # Debe mostrar: /home/suburbak
```

### Sin permisos:
```bash
chmod +x ~/install-server.sh
sudo bash ~/install-server.sh
```

### Error de paquetes:
```bash
sudo apt update
sudo bash ~/install-server.sh
```

### Ver log detallado:
```bash
sudo bash -x ~/install-server.sh 2>&1 | tee ~/debug.log
```

---

## 📋 Checklist Rápido

- [ ] Script copiado a `/home/suburbak/install-server.sh`
- [ ] Permisos +x aplicados
- [ ] Ejecutado con `sudo bash`
- [ ] Instalación completada sin errores
- [ ] Servicios corriendo (nginx, php, postgresql)
- [ ] `/etc/hosts` actualizado en cliente
- [ ] URLs accesibles en navegador

---

## 🔄 Comandos Post-Instalación

### Reiniciar servicios:
```bash
sudo systemctl restart nginx php8.3-fpm postgresql
```

### Ver logs:
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/php8.3-fpm.log
```

### Laravel:
```bash
cd /var/www/app
sudo -u www-data php artisan cache:clear
```

### Backup:
```bash
sudo /usr/local/bin/backup-arush.sh
```

---

## ✅ Finalización Exitosa

Cuando veas este mensaje, la instalación está completa:

```
╔══════════════════════════════════════════════════════════════════════════╗
║              ¡Instalación del servidor completada!                       ║
╚══════════════════════════════════════════════════════════════════════════╝

=== URLs de Acceso ===
  • Laravel Backend:   https://app.arush.local
  • Vue.js Frontend:   https://front.arush.local
  • Blog Vue.js:       https://blog.arush.local
  • pgAdmin 4:         http://192.168.1.13:5050/pgadmin4
```

---

**🚀 ¡Tu servidor está listo para usar!**
