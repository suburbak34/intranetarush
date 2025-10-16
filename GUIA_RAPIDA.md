# ⚡ Guía Rápida - install-server.sh v2.0

## 🎯 Instalación en 4 Pasos

---

## 📥 PASO 1: Copiar al Servidor

```bash
scp /workspace/install-server.sh suburbak@192.168.1.13:~/
```

---

## 🚀 PASO 2: Ejecutar

```bash
ssh suburbak@192.168.1.13
chmod +x ~/install-server.sh
sudo bash ~/install-server.sh
```

⏱️ **Espera 25 minutos**

---

## 🌐 PASO 3: Configurar DNS (en tu PC)

**Linux/Mac:**
```bash
sudo nano /etc/hosts
```

**Windows:**
```
notepad C:\Windows\System32\drivers\etc\hosts
```

**Agregar:**
```
192.168.1.13  app.arush.local
192.168.1.13  front.arush.local
192.168.1.13  blog.arush.local
```

---

## ✅ PASO 4: Acceder

Abrir en navegador:

- **Laravel:** https://app.arush.local
- **Frontend:** https://front.arush.local
- **Blog:** https://blog.arush.local

---

## 🔐 Importar CA (Evitar Advertencia SSL)

```bash
# Descargar
scp suburbak@192.168.1.13:/etc/ssl/localCA/certs/ca.crt ~/arush-ca.crt

# Importar en Chrome:
chrome://settings/security → Certificados → Importar

# Importar en Firefox:
about:preferences#privacy → Certificados → Importar
```

---

## 🔑 Credenciales

**PostgreSQL:**
- Host: 192.168.1.13
- Usuario: arush
- Password: R2705mr2
- BD: app_arush

---

## 🎉 ¡Listo!

**Tu servidor web completo estará funcionando en ~30 minutos.**

Stack: Nginx + PHP 8.3 + PostgreSQL 16 + Laravel 11 + Vue.js 3
