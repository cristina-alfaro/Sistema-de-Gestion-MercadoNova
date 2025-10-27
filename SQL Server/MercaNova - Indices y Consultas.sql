USE MercaNovaDB;
GO

-- INDICES

-- INDICE 1: Para busqueda rapida de productos por nombre
CREATE INDEX IX_Producto_Nombre ON Producto(nombre);
PRINT 'Indice 1 creado: IX_Producto_Nombre (Busqueda por nombre de producto)';
GO

-- INDICE 2: Para consultas de ventas por fecha
CREATE INDEX IX_Venta_Fecha ON Venta(fecha_venta);
PRINT 'Indice 2 creado: IX_Venta_Fecha (Busqueda de ventas por fecha)';
GO

-- INDICE 3: Para consultas de inventario por sucursal y producto
CREATE INDEX IX_Inventario_SucursalProducto ON Inventario(id_sucursal, id_producto);
PRINT 'Indice 3 creado: IX_Inventario_SucursalProducto (Busqueda de inventario)';
GO

-- INDICE 4: Para consultas de clientes por apellido
CREATE INDEX IX_Cliente_Apellido ON Cliente(apellido);
PRINT 'Indice 4 creado: IX_Cliente_Apellido (Busqueda de clientes por apellido)';
GO

-- DEMOSTRACION DE USO CON CONSULTAS SIMPLES

-- CONSULTA 1: Busqueda de productos por nombre (uso de IX_Producto_Nombre)
PRINT '1. Buscando productos que contengan "Leche":';
SELECT nombre, precio_unitario, descripcion 
FROM Producto 
WHERE nombre LIKE '%Leche%';
PRINT 'Se ha usado el indice: IX_Producto_Nombre';
GO

-- CONSULTA 2: Ventas de los ultimos 7 dias (uso de IX_Venta_Fecha)
PRINT '2. Ventas de los ultimos 7 dias:';
SELECT COUNT(*) as Total_Ventas, SUM(total) as Ingresos_Totales
FROM Venta 
WHERE fecha_venta >= DATEADD(DAY, -7, GETDATE());
PRINT 'Se ha usado el indice: IX_Venta_Fecha';
GO

-- CONSULTA 3: Stock de productos en sucursal 1 (uso de IX_Inventario_SucursalProducto)
PRINT '3. Inventario de la sucursal 1:';
SELECT p.nombre, i.stock_actual, i.stock_minimo
FROM Inventario i
JOIN Producto p ON i.id_producto = p.id_producto
WHERE i.id_sucursal = 1
ORDER BY p.nombre;
PRINT 'Se ha usado el indice: IX_Inventario_SucursalProducto';
GO

-- CONSULTA 4: Busqueda de clientes por apellido (uso de IX_Cliente_Apellido)
PRINT '4. Clientes con apellido "Guzman":';
SELECT nombre, apellido, telefono, correo
FROM Cliente 
WHERE apellido = 'Guzman';
PRINT 'Se ha usado el indice: IX_Cliente_Apellido';
GO

USE MercaNovaDBprueba16;
GO

-- CONSULTAS CON JOIN Y FUNCIONES DE AGREGACION

-- CONSULTA 5: Total de ventas por sucursal
SELECT 
    s.nombre AS Sucursal,
    COUNT(v.id_venta) AS Numero_Ventas,
    SUM(v.total) AS Total_Vendido
FROM Venta v
INNER JOIN Sucursal s ON v.id_sucursal = s.id_sucursal
GROUP BY s.nombre
ORDER BY Total_Vendido DESC;
GO

 -- CONSULTA 6: Stock total y promedio por categor�a de producto
SELECT 
    c.nombre AS Categoria,
    SUM(i.stock_actual) AS Stock_Total,
    AVG(i.stock_actual) AS Promedio_Stock
FROM Inventario i
INNER JOIN Producto p ON i.id_producto = p.id_producto
INNER JOIN Categoria c ON p.id_categoria = c.id_categoria
GROUP BY c.nombre
ORDER BY Stock_Total DESC;
GO

-- CONSULTA 7: Ventas realizadas por cada empleado
SELECT 
    e.nombre + ' ' + e.apellido AS Empleado,
    COUNT(v.id_venta) AS Numero_Ventas,
    SUM(v.total) AS Total_Generado,
    AVG(v.total) AS Promedio_Venta
FROM Empleado e
INNER JOIN Venta v ON e.id_empleado = v.id_empleado
GROUP BY e.nombre, e.apellido
ORDER BY Total_Generado DESC;
GO
