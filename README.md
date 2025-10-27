# 🛒  Sistema-de-Gestion-MercadoNova

**¿Qué es  el Sistema-de-Gestion-MercadoNova?**  
Es un sistema de base de datos completo diseñado para gestionar todas las operaciones de un supermercado (MercaNova): ventas, inventario, compras, clientes y empleados.

---

## 🗂️ ANÁLISIS DETALLADO DE CADA ARCHIVO

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

#### ✅ **Resultado esperado:**
- Base de datos `MercaNovaDB` creada
- 12 tablas creadas sin errores
- Mensaje: "Comando(s) completado(s) correctamente."

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

#### 🔍 **Ejemplo de datos insertados:**
```sql
-- Productos reales con precios
('Leche Entera 1L', 'Leche pasteurizada entera 1 litro', 1.1, 1, 1, 1)
('Pollo Entero', 'Pollo fresco entero', 5, 1, 5, 5)

-- Sucursales en diferentes departamentos
('Sucursal Centro', 'Colonia San Benito...', 'San Salvador')
('Sucursal Occidente', 'Colonia Santa Lucia...', 'Santa Ana')
```

#### 📝 **Cómo ejecutar:**
1. **Asegúrate** de que el Paso 1 se ejecutó sin errores
2. Abre el archivo en SSMS
3. **Cambia a la base de datos correcta** (debe decir "MercaNovaDB" en la barra de herramientas)
4. **Ejecuta COMPLETO** (F5)
5. **Espera** unos segundos mientras inserta 100+ registros

#### ✅ **Resultado esperado:**
- Mensajes de "(1 fila afectada)" múltiples veces
- Al final: "Comando(s) completado(s) correctamente."
- **NO** deben aparecer errores de claves foráneas

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

#### ✅ **Resultado esperado:**
- Mensajes de creación de roles y usuarios
- Al final: permisos asignados correctamente
- Pueden aparecer advertencias (son normales)

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

#### ✅ **Resultado esperado:**
- Mensajes: "Indice 1 creado", "Indice 2 creado", etc.
- Consultas que muestran datos reales
- Resultados en formato de tabla

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

#### 🧪 **Incluye demostraciones completas** que muestran:
- Cómo funcionan los triggers en escenarios reales
- Cómo manejan errores (transacciones con ROLLBACK)
- Cómo generan alertas automáticas

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

#### ✅ **Resultado esperado:**
- Mensajes: "Trigger creado"
- Demostraciones que muestran productos insertados
- Alertas de stock bajo generadas automáticamente

---

### **📄 ARCHIVO 6: `MercaNova - Procesos Almacenados.sql`**

#### 🎯 **¿Qué hace este archivo?**
**Crea las operaciones principales del negocio** como procedimientos reutilizables.

#### 🛠️ **Procedimientos implementados:**

**1. `sp_RealizarVenta`** - **El corazón del sistema**
```sql
-- Ejemplo de uso:
EXEC sp_RealizarVenta 
    @id_empleado = 10,
    @id_cliente = 1, 
    @metodo_pago = 'EFECTIVO',
    @productos_json = '[{"id":1, "cantidad":2}, {"id":2, "cantidad":1}]';
```
**Qué hace internamente**:
- Valida que el empleado existe
- Verifica stock disponible
- Calcula totales automáticamente
- Registra en auditoría
- Maneja errores con transacciones

**2. `sp_InsertarCliente`** - Registro seguro de clientes
**3. `sp_BuscarProductos`** - Búsqueda flexible con múltiples filtros  
**4. `sp_RealizarCompraStock`** - Gestión de compras a proveedores (solo gerentes)

#### 📝 **CÓMO EJECUTAR:**
1. **Ejecuta por partes** Cada proceso desde el princio hasta GO
2. **Luego** ejecuta también por partes los ejemplos al final del archivo (desde EXEC hasta GO)

#### ✅ **Resultado esperado:**
- Mensajes de creación de procedimientos
- Ejemplos que muestran ventas realizadas correctamente
- Resultados de búsquedas de productos

---

## 🚀 **RESUMEN EJECUTIVO DEL FLUJO**

### **Fase 1: Construcción** 🏗️
1. **Base de datos** - Crear el "terreno"
2. **Tablas** - Construir las "habitaciones"

### **Fase 2: Población** 🎨  
3. **Datos** - Rellenar con información real

### **Fase 3: Seguridad** 🔒
4. **Usuarios y roles** - Definir quién puede hacer qué

### **Fase 4: Optimización** ⚡
5. **Índices** - Hacer búsquedas rápidas

### **Fase 5: Automatización** 🤖
6. **Triggers** - Asistentes automáticos

### **Fase 6: Operaciones** 🛒
7. **Procedimientos** - Funcionalidades listas para usar

---

## ✅ **AL FINALIZAR TENDREMOS:**

Un sistema de supermercado **completamente funcional** que puede:
- ✅ Registrar ventas con validaciones automáticas
- ✅ Gestionar inventario con alertas de stock bajo  
- ✅ Realizar compras a proveedores con control de permisos
- ✅ Consultar reportes de ventas y rendimiento
- ✅ Mantener auditoría completa de todos los movimientos
- ✅ Operar con diferentes niveles de seguridad

