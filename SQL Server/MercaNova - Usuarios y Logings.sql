USE MercaNovaDB;
GO

-- CREACION DE ROLES 

-- Encargado de la sucursal: Puede gestionar ventas, compras, inventario, proveedores, y auditar cambios
CREATE ROLE rol_gerente_sucursal;

-- Cajero o vendedor: Solo puede registrar ventas y consultar inventario, sin modificar nada m�s
CREATE ROLE rol_empleado_ventas;
GO

-- GERENTE SUCURSAL
CREATE LOGIN gerente_sucursal WITH PASSWORD = 'Gerente@123';
CREATE USER gerente_sucursal FOR LOGIN gerente_sucursal;
EXEC sp_addrolemember 'rol_gerente_sucursal', 'gerente_sucursal';

-- Ventas
GRANT SELECT, INSERT, UPDATE, DELETE ON Venta TO rol_gerente_sucursal;
GRANT SELECT, INSERT, UPDATE, DELETE ON DetalleVenta TO rol_gerente_sucursal;

-- Compras
GRANT SELECT, INSERT, UPDATE, DELETE ON Compra TO rol_gerente_sucursal;
GRANT SELECT, INSERT, UPDATE, DELETE ON DetalleCompra TO rol_gerente_sucursal;

-- Inventario y auditor�a
GRANT SELECT, INSERT, UPDATE, DELETE ON Inventario TO rol_gerente_sucursal;
GRANT SELECT, INSERT, UPDATE, DELETE ON AuditoriaInventario TO rol_gerente_sucursal;

-- Proveedores
GRANT SELECT, INSERT, UPDATE, DELETE ON Proveedor TO rol_gerente_sucursal;

-- Productos y Categor�as (solo lectura, para control)
GRANT SELECT ON Producto TO rol_gerente_sucursal;
GRANT SELECT ON Categoria TO rol_gerente_sucursal;

-- Clientes (solo lectura, no puede editar datos de clientes)
GRANT SELECT ON Cliente TO rol_gerente_sucursal;

-- Empleados (solo lectura, para conocer qui�n vende)
GRANT SELECT ON Empleado TO rol_gerente_sucursal;

-- Sucursal (solo lectura, no puede modificar datos institucionales)
GRANT SELECT ON Sucursal TO rol_gerente_sucursal;
GO

-- EMPLEADO VENTAS
CREATE LOGIN empleado_ventas WITH PASSWORD = 'Ventas@123';
CREATE USER empleado_ventas FOR LOGIN empleado_ventas;
EXEC sp_addrolemember 'rol_empleado_ventas', 'empleado_ventas';
GO

-- Permisos de ventas
GRANT SELECT, INSERT ON Venta TO rol_empleado_ventas;
GRANT SELECT, INSERT ON DetalleVenta TO rol_empleado_ventas;

-- Clientes: puede registrar nuevos y verlos
GRANT SELECT, INSERT ON Cliente TO rol_empleado_ventas;

-- Inventario: solo lectura (para saber si hay productos)
GRANT SELECT ON Inventario TO rol_empleado_ventas;

-- Productos y categor�as: solo lectura (para ver precios y descripciones)
GRANT SELECT ON Producto TO rol_empleado_ventas;
GRANT SELECT ON Categoria TO rol_empleado_ventas;

-- Sucursal y empleado (solo lectura)
GRANT SELECT ON Sucursal TO rol_empleado_ventas;
GRANT SELECT ON Empleado TO rol_empleado_ventas;
GO

-- VERIFICAR PERMISOS
-- Conectarte como gerente
EXECUTE AS LOGIN = 'gerente_sucursal';
SELECT USER_NAME();
-- probar insertar o actualizar en Inventario
REVERT;

-- Conectarte como empleado
EXECUTE AS LOGIN = 'empleado_ventas';
SELECT USER_NAME();
-- intentar eliminar una venta (debe fallar)
DELETE FROM Venta WHERE id_venta = 1;
REVERT;
