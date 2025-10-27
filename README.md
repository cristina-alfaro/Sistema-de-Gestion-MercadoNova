# 🛒  Sistema-de-Gestion-MercadoNova

**¿Qué es  el Sistema-de-Gestion-MercadoNova?**  
Es un sistema de base de datos hibrido diseñado para gestionar todas las operaciones de un supermercado (MercaNova): ventas, inventario, compras, clientes y empleados.

```md
## 📁 ESTRUCTURA DEL PROYECTO

La carpeta del proyecto está organizada para separar las implementaciones de **SQL Server** y **MongoDB**, junto con sus datasets y scripts correspondientes.

```

Sistema-de-Gestion-MercadoNova/
│
├── 📂 Mongo/
│   ├── 📂 DataSet Sintetico/
│   │   ├── analisis_ventas_tiempo_real.json
│   │   ├── historial_comportamiento_clientes.json
│   │   └── logs_comportamiento_inventario.json
│   │
│   ├── MercaNova - Colecciones.js          # Creación de colecciones y relaciones
│   ├── MercaNova - DataSet.json            # Datos iniciales de prueba para MongoDB
│   ├── MercaNova - Indices.js              # Índices y consultas optimizadas
│   └── MercaNova - Usuarios.js             # Gestión de roles y usuarios en Mongo
│
├── 📂 SQL Server/
│   ├── 📂 DataSet Sintetico/
│   │   ├── AuditoriaInventario.csv
│   │   ├── Categoria.csv
│   │   ├── Cliente.csv
│   │   ├── Compra.csv
│   │   ├── DetalleCompra.csv
│   │   ├── DetalleVenta.csv
│   │   ├── Empleado.csv
│   │   ├── Inventario.csv
│   │   ├── Producto.csv
│   │   ├── Proveedor.csv
│   │   └── Sucursal.csv
│   │
│   ├── MercaNova - Base de datos.sql        # Creación de BD y tablas principales
│   ├── MercaNova - DataSet SQL.sql          # Inserción de datos iniciales
│   ├── MercaNova - Indices y Consultas.sql  # Índices y consultas analíticas
│   ├── MercaNova - Procesos Almacenados.sql # Procedimientos principales
│   ├── MercaNova - Triggers.sql             # Automatización con triggers
│   └── MercaNova - Usuarios y Logings.sql   # Gestión de usuarios y roles
│
└── 📝 README.md                                # Documentación del proyecto

```

---

### 🧠 Descripción general

- **📂 Mongo/** → Contiene la parte **NoSQL** del sistema: análisis, movimientos de inventario y comportamiento de clientes, con datos en formato JSON y scripts en JavaScript para crear colecciones, índices y usuarios.
- **📂 SQL Server/** → Implementa la parte **relacional** del sistema con toda la estructura principal (tablas, procedimientos, triggers, etc.) y un conjunto de datos sintéticos en formato CSV para pruebas.

---

## 🗂️ ANÁLISIS DETALLADO DE CADA ARCHIVO (SQL Server)

### **📄 ARCHIVO 1: `MercaNova - Base de datos.sql`**

#### 🎯 **¿Qué hace este archivo?**
Es el **cimientos** de todo el sistema. Crea la base de datos completa con todas las tablas necesarias.

#### 🔧 **Componentes que crea:**
- **La base de datos** (`MercaNovaDB`)
- **12 tablas principales** -
  - `Sucursal` - Información de cada tienda
  - `Empleado` - Datos de los trabajadores
  - `Cliente` - Información de clientes
  - `Producto` - Catálogo de productos
  - `Inventario` - Stock por sucursal
  - `Venta` y `DetalleVenta` - Registro de ventas
  - `Compra` y `DetalleCompra` - Registro de compras a proveedores
  - `AuditoriaInventario` - Historial de cambios

#### 📝 **Cómo ejecutar:**
1. Abre SQL Server Management Studio
2. Conéctate a tu servidor de base de datos
3. **Abre el archivo** en SSMS
4. **Ejecuta COMPLETO** (presiona F5 o haz clic en "Ejecutar")
5. **Verifica** que no hay errores en la pestaña "Mensajes"

---

### **📄 ARCHIVO 2: `MercaNova - DataSet.sql`**

#### 🎯 **¿Qué hace este archivo?**
**Pobla la base de datos con información real**. Inserta todos los datos de prueba: sucursales, productos, empleados, clientes, etc.

#### 🏪 **Datos que incluye:**
- **5 sucursales** en diferentes ciudades de El Salvador
- **8 categorías** de productos (Lácteos, Bebidas, Snacks, etc.)
- **10 proveedores** con información de contacto real
- **11 productos** con precios y descripciones
- **10 empleados** con diferentes cargos y salarios
- **10 clientes** con DUI, teléfonos y direcciones
- **50 registros de inventario** (stock en cada sucursal)
- **Ventas y compras de ejemplo** para probar el sistema

#### 📝 **Cómo ejecutar:**
1. **Asegúrate** de que el Paso 1 se ejecutó sin errores
2. Abre el archivo en SSMS
3. **Cambia a la base de datos correcta** (debe decir "MercaNovaDB" en la barra de herramientas)
4. **Ejecuta COMPLETO** (F5)
5. **Espera** unos segundos mientras inserta 100+ registros

---

### **📄 ARCHIVO 3: `MercaNova - Usuarios y Logings.sql`**

#### 🎯 **¿Qué hace este archivo?**
**Implementa la seguridad del sistema**. Crea usuarios y roles de seguridad para el sistema.

#### 👥 **Roles creados:**

**1. Gerente de Sucursal** (`rol_gerente_sucursal`)
- **Puede**: Gestionar ventas, compras, inventario, proveedores
- **No puede**: Modificar datos de clientes o información institucional
- **Como en la vida real**: Un gerente que supervisa toda la operación

**2. Empleado de Ventas** (`rol_empleado_ventas`) 
- **Puede**: Registrar ventas, consultar productos, agregar clientes nuevos
- **No puede**: Hacer compras, modificar inventario, eliminar ventas
- **Como en la vida real**: Un cajero que solo procesa ventas

#### 🔐 **Credenciales:**
```
Gerente: usuario='gerente_sucursal', contraseña='Gerente@123'
Empleado: usuario='empleado_ventas', contraseña='Ventas@123'
```

#### 📝 **Cómo ejecutar:**
1. **Verifica** que los pasos 1 y 2 se completaron
2. Abre el archivo en SSMS
3. **Ejecuta COMPLETO** (F5)
4. **Ignora** mensajes como "El usuario ya existe" (es normal)

---

### **📄 ARCHIVO 4: `MercaNova - Indices y Consultas.sql`**

#### 🎯 **¿Qué hace este archivo?**
**Optimiza el rendimiento** y proporciona consultas útiles para el negocio.

#### ⚡ **Índices creados:**
1. `IX_Producto_Nombre` - Búsqueda rápida de productos
2. `IX_Venta_Fecha` - Consultas rápidas por fecha de venta  
3. `IX_Inventario_SucursalProducto` - Búsqueda eficiente de stock
4. `IX_Cliente_Apellido` - Búsqueda rápida de clientes

#### 📊 **Consultas de negocio incluidas:**
- **Ventas por sucursal** - ¿Qué tienda vende más?
- **Stock por categoría** - ¿Qué categorías tienen más inventario?
- **Rendimiento de empleados** - ¿Quién vende más?

#### 📝 **Cómo ejecutar:**
1. Abre el archivo en SSMS
2. **Ejecuta COMPLETO** (F5)
3. **Observa** los resultados en la pestaña "Resultados"

---

### **📄 ARCHIVO 5: `MercaNova - Triggers.sql`**

#### 🎯 **¿Qué hace este archivo?**
**Automatiza procesos** importantes. Los triggers son como "asistentes automáticos" que actúan cuando suceden ciertos eventos.

#### 🤖 **Triggers implementados:**

**1. `TR_RegistrarNuevosProductos`**
- **Cuándo se activa**: Cuando se agrega un nuevo producto
- **Qué hace**: Registra automáticamente en la auditoría
- **Ejemplo práctico**: Cuando agregas un nuevo producto al sistema, queda automáticamente auditado

**2. `TR_CalcularTotalVenta`** 
- **Cuándo se activa**: Cuando se modifica el detalle de una venta
- **Qué hace**: Recalcula automáticamente el total
- **Ejemplo práctico**: Si agregas/eliminas productos de una venta, el total se actualiza solo

**3. `TR_ControlStockMinimo`**
- **Cuándo se activa**: Cuando el inventario cambia
- **Qué hace**: Genera alertas cuando el stock está bajo
- **Ejemplo práctico**: Si el stock de leche baja a 8 unidades (mínimo es 10), genera una alerta

#### 📝 **CÓMO EJECUTAR (POR PARTES):**

**PARTE 5.1 - Crear los Triggers:**
```sql
-- EJECUTAR ESTOS TRES BLOQUES UNO POR UNO:

-- Bloque 1: Ejecutar desde línea 11 hasta línea 48 (primer CREATE TRIGGER... hasta END; GO)
-- Bloque 2: Ejecutar desde línea 51 hasta línea 89 (segundo CREATE TRIGGER... hasta END; GO)  
-- Bloque 3: Ejecutar desde línea 92 hasta línea 147 (tercer CREATE TRIGGER... hasta END; GO)
```

**PARTE 5.2 - Demostraciones:**
```sql
-- EJECUTAR CADA BLOQUE COMPLETO:

-- Bloque DEMOSTRACIÓN 1: Líneas 149-248
-- Bloque DEMOSTRACIÓN 2: Líneas 250-320
-- Bloque DEMOSTRACIÓN 3: Líneas 322-460
```

---

### **📄 ARCHIVO 6: `MercaNova - Procesos Almacenados.sql`**

#### 🎯 **¿Qué hace este archivo?**
**Crea las operaciones principales del negocio** como procedimientos reutilizables.

#### 🛠️ **Procedimientos implementados:**

**1. `sp_RealizarVenta`** - Permite a los empleados realizar ventas más facilmente
**2. `sp_InsertarCliente`** - Registro seguro de clientes
**3. `sp_BuscarProductos`** - Búsqueda flexible con múltiples filtros  
**4. `sp_RealizarCompraStock`** - Gestión de compras a proveedores (solo gerentes)

#### 📝 **CÓMO EJECUTAR:**
1. **Ejecuta por partes** Cada proceso desde el principio hasta GO
2. **Luego** ejecuta también por partes los ejemplos al final del archivo (desde EXEC hasta GO)

---

## 🗂️ ANÁLISIS DETALLADO DE CADA ARCHIVO (Mongo DB)

### **📄 ARCHIVO 1: `MercaNova - Colecciones.js`**

#### 🎯 **¿Qué hace este archivo?**
Crea la **estructura analítica** del sistema. En MongoDB, no tenemos tablas rígidas como en SQL, sino **colecciones flexibles** con documentos JSON.

#### 🔧 **Las 3 colecciones de análisis:**

**1. `analisis_ventas_tiempo`** - El "termómetro" del negocio
**¿Qué analiza?**: Patrones horarios, productos estrella, métodos de pago

**2. `historial_comportamiento_clientes`** - El "perfilador" de clientes
**¿Qué analiza?**: Segmentación, preferencias, valor de vida del cliente

**3. `logs_comportamiento_inventario`** - El "médico" del stock
**¿Qué analiza?**: Rotación, días de stock, alertas automáticas

---

### **📄 ARCHIVO 2: `MercaNova - DataSet.json`**

#### 🎯 **¿Qué hace este archivo?**
**Pobla el sistema con datos de análisis realistas**. Estos son datos importantes para el negocio.

#### 📊 **Datos de análisis incluidos:**

**1. Ventas por hora** - 17 documentos de análisis horario
```javascript
// Patrón de ventas en Sucursal Centro
8:00 AM → 28 transacciones → $850.25 → Hora normal
9:00 AM → 45 transacciones → $1500.75 → HORA PICO ✅
12:00 PM → 52 transacciones → $1800.90 → HORA PICO ✅
```
**Insight**: Identifica claramente las horas pico para optimizar personal

**2. Comportamiento de 16 clientes** - Historial completo
```javascript
// Segmentación automática:
"Carlos Lemus" → "frecuente" → Visita semanal → $25.5 promedio
"Ana Guzman" → "valor_alto" → Visita quincenal → $42.3 promedio  
"Jorge Morales" → "frecuente" → Visita DIARIA → $8.5 promedio
```
**Insight**: Permite campañas de marketing segmentadas

**3. 18 análisis de inventario** - Alertas inteligentes
```javascript
// Ejemplos de criticidad:
"Leche Entera 1L" → Stock: 8 → "CRÍTICA" → "reabastecimiento_emergencia"
"Detergente 1kg" → Stock: 75 → "BAJA" → "reducir_pedido"
"Manzanas 1kg" → Stock: 7 → "CRÍTICA" → "reabastecimiento_urgente"
```
**Insight**: Sistema de alertas proactivo para inventario

---

### **📄 ARCHIVO 3: `MercaNova - Indices.js`**

#### 🎯 **¿Qué hace este archivo?**
**Optimiza las consultas analíticas** para que los reportes sean ultra-rápidos.

#### ⚡ **Índices creados:**

**1. `idx_analytics_sucursal_timestamp`**
```javascript
{
  "sucursal_id": 1,      // Primero por sucursal
  "timestamp": -1        // Luego por fecha (más reciente primero)
}
```
**Para consultas como**: "¿Cuáles fueron las ventas de la sucursal 1 en la última semana?"

**2. `idx_inventario_producto_sucursal`** 
```javascript
{
  "producto_id": 1,      // Por producto
  "sucursal_id": 1,      // Por sucursal  
  "criticidad": 1,       // Por nivel de alerta
  "timestamp": -1        // Más reciente primero
}
```
**Para consultas como**: "¿Qué productos están en estado crítico en la sucursal 2?"

#### 💡 **Parámetro `background: true`**
```javascript
{ background: true }  // Se crea en segundo plano sin bloquear la base de datos
```
**Ventaja**: Puedes seguir usando la base de datos mientras se crean los índices.

---

### **📄 ARCHIVO 4: `MercaNova - Usuarios.js`**

#### 🎯 **¿Qué hace este archivo?**
**Configura la seguridad y acceso** con roles específicos para diferentes tipos de usuarios.

#### 👥 **Usuarios creados:**

**1. `reportes_user` - Solo Lectura**
**Para**: Equipos de analytics, gerentes, dashboards
**Puede**: Consultar todos los datos, generar reportes
**No puede**: Modificar, insertar o eliminar datos

**2. `app_merchanova` - Lectura/Escritura**  
**Para**: La aplicación principal que alimenta los datos
**Puede**: Insertar nuevos análisis, actualizar datos
**No puede**: Administrar la base de datos

---

## 🚀 **GUÍA DE EJECUCIÓN PASO A PASO**

### **PRERREQUISITOS**
- ✅ MongoDB instalado (versión 4.2+)
- ✅ MongoDB Compass o línea de comandos
- ✅ Acceso de administrador a la instancia

---

### **PASO 1: Ejecutar Colecciones** 🏗️
**Archivo**: `MercaNova - Colecciones.js`
```bash
# En MongoDB Shell:
mongo "MercaNova - Colecciones.js"
```
**Verificación**:
```javascript
use MercaNova
show collections
// Debe mostrar: analisis_ventas_tiempo, historial_comportamiento_clientes, logs_comportamiento_inventario
```

### **PASO 2: Insertar Datos de Análisis** 📊
**Archivo**: `MercaNova - DataSet.json`
```bash
# En MongoDB Shell, ejecutar por partes:
// Copiar y pegar cada insertMany por separado
```
**Verificación**:
```javascript
db.analisis_ventas_tiempo.countDocuments() // Debe ser 17
db.historial_comportamiento_clientes.countDocuments() // Debe ser 16  
db.logs_comportamiento_inventario.countDocuments() // Debe ser 18
```

### **PASO 3: Crear Índices** ⚡
**Archivo**: `MercaNova - Indices.js`
```bash
mongo "MercaNova - Indices.js"
```
**Verificación**:
```javascript
db.analisis_ventas_tiempo.getIndexes() // Debe mostrar 2 índices
db.logs_comportamiento_inventario.getIndexes() // Debe mostrar 2 índices
```

### **PASO 4: Configurar Usuarios** 🔐
**Archivo**: `MercaNova - Usuarios.js`
```bash
# Conectarse como admin primero:
mongo admin "MercaNova - Usuarios.js"
```
**Verificación**:
```javascript
use admin
db.getUsers() // Debe mostrar los 2 usuarios creados
```

---

## 🎉 **RESULTADO FINAL**

Al completar ambos sistemas tendrás:

### **🚀 SISTEMA HÍBRIDO COMPLETO**
- ✅ **Operaciones en tiempo real** + **Análisis predictivo**
- ✅ **Gestión transaccional** + **Business intelligence**
- ✅ **Base relacional** + **Base NoSQL optimizada**
- ✅ **Sistema listo para producción** y **escalable**