# 🎯 Guía de Configuración de Cursor IDE para Laravel

## ✅ Archivos Creados

He creado dos archivos esenciales en tu proyecto:

1. **`.cursorrules`** - Define reglas y contexto específico para tu proyecto Laravel
2. **`.cursorignore`** - Optimiza el rendimiento ignorando archivos innecesarios

## ⚙️ Configuraciones Recomendadas en la Interfaz

### Settings que VES en tu captura:

| Opción | Estado Recomendado | Motivo |
|--------|-------------------|--------|
| **Include Full-Folder Context** | ❌ OFF | Evita saturar el contexto en proyectos grandes Laravel |
| **Web Search Tool** | ✅ ON | Útil para documentación actualizada de Laravel/PHP |
| **Auto-Accept Web Search** | ✅ ON | Acelera el flujo de trabajo (pruébalo) |
| **Hierarchical Cursor Ignore** | ✅ ON | Respeta `.cursorignore` en subdirectorios |
| **Backspace Removes Context** | ✅ ON | Mayor control sobre el contexto |

### Configuraciones Adicionales Importantes

#### En Settings (Ctrl/Cmd + ,):

**General:**
- **Models**: Selecciona `claude-sonnet-4` para mejor rendimiento con PHP/Laravel
- **Temperature**: 0.3-0.5 para código más determinista
- **Max Tokens**: 4000-8000 (suficiente para la mayoría de casos)

**Features:**
- **Tab Autocomplete**: ✅ Activado (muy útil para código repetitivo)
- **Cursor Tab**: ✅ Activado (sugerencias inline)
- **Partial Accepts**: ✅ Activado (aceptar sugerencias palabra por palabra)

**Chat:**
- **Always Search**: ❌ OFF (usa búsqueda solo cuando la necesites con @Web)
- **Privacy Mode**: Configurar según tu preferencia (si trabajas con datos sensibles)

**Performance:**
- **Index Timeout**: 60000ms (1 minuto, para proyectos Laravel medianos)
- **Max File Size**: 1MB (evita procesar archivos muy grandes)

## 🚀 Cómo Usar Cursor Efectivamente en Laravel

### 1. Uso de @ Symbols (Menciones)

```
@workspace - Incluye todo el proyecto (usa con moderación)
@folder - Incluye una carpeta específica (ej: @app/Models)
@file - Incluye un archivo específico
@code - Incluye un símbolo específico (clase, método)
@docs - Busca en documentación (Laravel, PHP, etc.)
@web - Busca en internet
@git - Contexto de cambios git
```

### 2. Comandos Útiles en el Chat

**Para generar código:**
```
"Crea un UserController con CRUD completo"
"Genera una migración para tabla posts con título, contenido y user_id"
"Crea un Form Request para validar registro de usuario"
```

**Para debugging:**
```
"Encuentra el problema en @file:app/Http/Controllers/UserController.php"
"¿Por qué este código genera N+1 queries?"
```

**Para refactoring:**
```
"Refactoriza este método para usar Service Pattern @code"
"Optimiza estas queries agregando eager loading"
```

### 3. Composer (Ctrl/Cmd + I)

El Composer es ideal para:
- Generar múltiples archivos relacionados (Controller + Request + Resource)
- Hacer cambios en varios archivos a la vez
- Crear features completas (CRUD + tests)

**Ejemplo:**
```
"Crea un sistema de autenticación con:
- RegisterController
- LoginController  
- RegisterRequest con validación
- UserResource para API
- Tests para ambos endpoints"
```

### 4. Shortcuts Esenciales

- **Ctrl/Cmd + K**: Inline edit (editar selección)
- **Ctrl/Cmd + L**: Abrir chat
- **Ctrl/Cmd + I**: Abrir composer (edición multi-archivo)
- **Tab**: Aceptar sugerencia completa
- **Ctrl/Cmd + →**: Aceptar sugerencia palabra por palabra
- **Ctrl/Cmd + Shift + P**: Command palette

## 💡 Tips Pro para Laravel en Cursor

### 1. Contexto Inteligente
Cuando pidas algo relacionado con un modelo, incluye el contexto:
```
"Actualiza @file:app/Models/User.php para incluir una relación 
con posts, y actualiza @file:app/Models/Post.php también"
```

### 2. Testing
Pide tests junto con el código:
```
"Crea un endpoint POST /api/users con su controller, 
request validation, y feature test completo"
```

### 3. Usa .cursorrules a tu favor
El archivo `.cursorrules` ahora contiene el contexto de tu proyecto.
Cursor lo leerá automáticamente, así que el AI sabrá:
- Qué versión de Laravel usas
- Tus convenciones de código
- Estructura del proyecto
- Best practices que sigues

### 4. Iteración Rápida
Si el código generado no es perfecto:
```
"El método anterior tiene un problema con X, corrígelo"
"Simplifica este código usando Laravel Collection methods"
```

### 5. Documentación on-the-fly
```
"@docs Laravel 12 middleware, ¿cómo crear uno personalizado?"
"@web Tailwind CSS 4.0 nuevas features"
```

## 🎯 Workflows Recomendados

### Crear un CRUD Completo
1. **Paso 1**: "Crea una migración para [recurso]"
2. **Paso 2**: "Crea el modelo [Nombre] con fillable y relationships"
3. **Paso 3**: "Crea un [Nombre]Controller con Resource methods"
4. **Paso 4**: "Crea [Nombre]Request para validación"
5. **Paso 5**: "Crea [Nombre]Resource para API response"
6. **Paso 6**: "Agrega las rutas a api.php"
7. **Paso 7**: "Crea Feature tests para todos los endpoints"

O hazlo todo en un Composer (Ctrl/Cmd + I):
```
"Crea un CRUD completo para Posts con título, contenido, 
user_id, incluyendo migración, modelo, controller, requests, 
resource, rutas API y tests"
```

### Debugging
1. Selecciona el código problemático
2. Ctrl/Cmd + K
3. "Encuentra el bug y corrígelo explicando qué estaba mal"

### Refactoring
1. Incluye el archivo: `@file:path/to/file.php`
2. "Refactoriza siguiendo [patrón/principio]"
3. Revisa cambios y acepta

## 📊 Métricas para Evaluar si Vale la Pena Pro

Durante tu prueba, evalúa:

✅ **Ahorro de tiempo:**
- ¿Cuánto más rápido creas CRUDs?
- ¿Te ayuda a evitar bugs?
- ¿Acelera tu aprendizaje de Laravel?

✅ **Calidad del código:**
- ¿Genera código que sigue best practices?
- ¿Reduce errores comunes?
- ¿Mejora la consistencia del código?

✅ **Productividad:**
- ¿Reduces context switching (buscar docs)?
- ¿Escribes tests más fácilmente?
- ¿Refactorizas más seguido?

### Features Pro que Valen la Pena:
- **Requests ilimitados** (vs limitados en free)
- **Claude Sonnet 4** (mejor que GPT-4 para código)
- **Privacy mode** (tu código no entrena el modelo)
- **Prioridad en responses**

## 🔒 Consideraciones de Privacidad

⚠️ **NUNCA incluyas en el contexto:**
- Archivos `.env` (ya está en .cursorignore)
- Claves API o secretos
- Datos de producción
- Información sensible de clientes

✅ **Es seguro incluir:**
- Código de la aplicación
- Tests
- Configuraciones (sin secretos)
- Documentación

## 🚦 Próximos Pasos

1. ✅ **Reinicia Cursor** para que cargue las nuevas configuraciones
2. ✅ **Activa "Hierarchical Cursor Ignore"** en settings
3. ✅ **Prueba crear un CRUD completo** usando Composer
4. ✅ **Experimenta con @symbols** para controlar el contexto
5. ✅ **Pide que genere tests** para tu código existente

## 📚 Recursos Adicionales

- [Documentación Cursor](https://cursor.sh/docs)
- [Laravel 12 Docs](https://laravel.com/docs/12.x)
- [Cursor Discord](https://discord.gg/cursor) - Comunidad activa
- [Cursor Forum](https://forum.cursor.sh) - Tips y trucos

---

## 💬 Comandos de Ejemplo para Probar AHORA

Abre el Composer (Ctrl/Cmd + I) y prueba estos:

```
1. "Analiza la estructura actual del proyecto y dame sugerencias de mejora"

2. "Crea un middleware de logging que registre todas las requests API"

3. "Genera un Seeder para User con 50 usuarios fake usando factories"

4. "Crea un endpoint GET /api/users/{id} con su Resource y test"

5. "Revisa @file:app/Http/Controllers/UserController.php y optimízalo"
```

---

**¡Disfruta usando Cursor! 🚀**

Si tienes dudas sobre alguna configuración específica, pregunta en el chat.
