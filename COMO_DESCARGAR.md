# 📥 Cómo Descargar install-server.sh

## ✅ El archivo está en: `/workspace/install-server.sh`

---

## 🎯 MÉTODO 1: DESCARGAR DESDE CURSOR (Interfaz Gráfica)

### Paso 1: Abrir el Explorador de Archivos

```
1. Mira el PANEL IZQUIERDO de Cursor
2. Busca el ícono de "Explorador de Archivos" (📁)
   - Generalmente es el primer ícono en la barra lateral izquierda
   - O presiona: Ctrl+Shift+E (Windows/Linux) o Cmd+Shift+E (Mac)
```

### Paso 2: Navegar a /workspace/

```
3. En el explorador de archivos, verás una estructura de carpetas
4. Busca la carpeta "workspace" 
5. Haz clic en "workspace" para expandirla
6. Verás el archivo: install-server.sh
```

### Paso 3: Descargar el Archivo

```
7. CLICK DERECHO sobre "install-server.sh"
8. Busca en el menú contextual una opción que diga:
   - "Download..." (Descargar)
   - "Save As..." (Guardar como)
   - "Download File" (Descargar archivo)
   
9. Si no aparece, intenta:
   - Click derecho → "Reveal in File Explorer" (Windows)
   - Click derecho → "Reveal in Finder" (Mac)
   - Luego copia el archivo desde ahí
```

### Alternativa Visual:

```
Si ves el archivo en el explorador:
1. Haz clic en el archivo para abrirlo
2. Arriba a la derecha del editor, busca:
   - Ícono de "más opciones" (⋮ o ...)
   - O menú "File" → "Save As"
3. Guarda el archivo en tu computadora
```

---

## 🚀 MÉTODO 2: COPIAR CONTENIDO Y CREAR ARCHIVO (100% Seguro)

Este método SIEMPRE funciona:

### Opción A: Ver el contenido completo

1. **En esta conversación, te voy a mostrar el contenido del script**
2. **Copia TODO el texto** (desde `#!/bin/bash` hasta el final)
3. **Crea el archivo en tu computadora:**

**En Linux/Mac:**
```bash
# Abrir terminal y crear el archivo
nano ~/install-server.sh

# Pegar el contenido (Ctrl+Shift+V)
# Guardar: Ctrl+O, Enter, Ctrl+X

# Dar permisos
chmod +x ~/install-server.sh
```

**En Windows (PowerShell):**
```powershell
# Crear archivo
notepad install-server.sh

# Pegar el contenido
# Guardar: File → Save
```

---

## 💻 MÉTODO 3: COPIAR DIRECTAMENTE AL SERVIDOR (Más Rápido)

**Si tienes acceso SSH desde donde estás:**

### Paso 1: Abrir terminal en tu computadora

### Paso 2: Usar SCP para copiar

```bash
# Si /workspace está en tu máquina local
scp /workspace/install-server.sh suburbak@192.168.1.13:~/

# O desde donde lo descargaste
scp ~/Downloads/install-server.sh suburbak@192.168.1.13:~/
```

---

## 📋 MÉTODO 4: CREAR EL ARCHIVO DIRECTAMENTE EN EL SERVIDOR

**La forma más simple de todas:**

### Paso 1: Conectar al servidor

```bash
ssh suburbak@192.168.1.13
```

### Paso 2: Crear el archivo en el servidor

```bash
nano ~/install-server.sh
```

### Paso 3: Pegar el contenido

**Aquí abajo te voy a poner el contenido COMPLETO del script.**

1. Copia TODO desde la línea `#!/bin/bash` hasta el final
2. En el nano del servidor: Pega con **Shift+Insert** o **Click derecho → Paste**
3. Guarda: **Ctrl+O**, **Enter**, **Ctrl+X**

### Paso 4: Dar permisos

```bash
chmod +x ~/install-server.sh
```

### Paso 5: Ejecutar

```bash
sudo bash ~/install-server.sh
```

---

## 🔍 SI TODAVÍA NO PUEDES DESCARGARLO

### Dime qué ves en Cursor:

**Opción 1:** ¿Ves el explorador de archivos en el panel izquierdo?
- ✅ SÍ → Ve al MÉTODO 1
- ❌ NO → Presiona `Ctrl+Shift+E` para abrirlo

**Opción 2:** ¿Puedes abrir una terminal en Cursor?
- ✅ SÍ → Ve al MÉTODO 3
- ❌ NO → Ve al MÉTODO 4

**Opción 3:** ¿Prefieres que te muestre el contenido completo?
- ✅ SÍ → Ve más abajo (CONTENIDO DEL SCRIPT)

---

## 📝 UBICACIÓN DEL ARCHIVO

```
Ruta completa: /workspace/install-server.sh
Tamaño: 27 KB
Líneas: 979
```

---

## 🆘 AYUDA RÁPIDA

**Si nada funciona, usa este método 100% efectivo:**

1. **Pídeme que te muestre el contenido del script**
2. **Copialo**
3. **Créalo directamente en el servidor:**
   ```bash
   ssh suburbak@192.168.1.13
   nano ~/install-server.sh
   # Pegar contenido
   # Ctrl+O, Enter, Ctrl+X
   chmod +x ~/install-server.sh
   sudo bash ~/install-server.sh
   ```

---

## 🎯 RECOMENDACIÓN

**La forma MÁS FÁCIL es el MÉTODO 4:**
- No necesitas descargar nada
- Creas el archivo directamente en el servidor
- Solo necesitas copiar y pegar el contenido

**¿Quieres que te muestre el contenido completo del script para copiarlo?**

Responde "SÍ" y te lo muestro en el siguiente mensaje.

---

**Creado por:** DevOps Senior  
**Fecha:** 2025-10-16
