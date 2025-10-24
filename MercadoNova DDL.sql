CREATE DATABASE MercaNovaDB;
GO

USE MercaNovaDB;
GO

-- 1. Sucursales
CREATE TABLE Sucursal (
    id_sucursal INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    direccion NVARCHAR(150),
    ciudad NVARCHAR(100),
    departamento NVARCHAR(100),
    telefono NVARCHAR(20),
    gerente NVARCHAR(100)
);

-- 2. Empleados
CREATE TABLE Empleado (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    cargo NVARCHAR(100),
    fecha_contratacion DATE,
    salario DECIMAL(10,2),
    id_sucursal INT NOT NULL,
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

-- 3. Clientes
CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100),
    dui NVARCHAR(10) UNIQUE,
    telefono NVARCHAR(20),
    correo NVARCHAR(100),
    direccion NVARCHAR(150),
	fecha_registro DATE DEFAULT GETDATE()
);

-- 4. Categorías
CREATE TABLE Categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(200)
);

-- 5. Proveedores
CREATE TABLE Proveedor (
    id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    contacto NVARCHAR(100),
    telefono NVARCHAR(20),
    correo NVARCHAR(100),
    direccion NVARCHAR(150),
    pais NVARCHAR(100)
);

-- 6. Productos
CREATE TABLE Producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(200),
    precio_unitario DECIMAL(10,2) NOT NULL,
    estado BIT DEFAULT 1,
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
);

-- 7. Inventario (por sucursal)
CREATE TABLE Inventario (
    id_inventario INT IDENTITY(1,1) PRIMARY KEY,
    id_sucursal INT NOT NULL,
    id_producto INT NOT NULL,
    stock_actual INT NOT NULL,
    stock_minimo INT DEFAULT 10,
    stock_maximo INT DEFAULT 100,
    ultima_actualizacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    CONSTRAINT UQ_Inventario UNIQUE (id_sucursal, id_producto)
);

-- 8. Ventas
CREATE TABLE Venta (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    fecha_venta DATETIME DEFAULT GETDATE(),
    total DECIMAL(10,2),
    metodo_pago NVARCHAR(50),
    id_empleado INT NOT NULL,
    id_cliente INT NULL,
    id_sucursal INT NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

-- 9. Detalle de Ventas
CREATE TABLE DetalleVenta (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

-- 10. Compras
CREATE TABLE Compra (
    id_compra INT IDENTITY(1,1) PRIMARY KEY,
    fecha_compra DATETIME DEFAULT GETDATE(),
    total DECIMAL(10,2),
    id_proveedor INT NOT NULL,
    id_empleado INT NOT NULL,
    id_sucursal INT NOT NULL,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

-- 11. Detalle de Compras
CREATE TABLE DetalleCompra (
    id_detalle_compra INT IDENTITY(1,1) PRIMARY KEY,
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    costo_unitario DECIMAL(10,2),
    subtotal AS (cantidad * costo_unitario) PERSISTED,
    FOREIGN KEY (id_compra) REFERENCES Compra(id_compra),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

-- 12. Auditoría de Inventario
CREATE TABLE AuditoriaInventario (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha DATETIME DEFAULT GETDATE(),
    accion NVARCHAR(50),
    cantidad INT,
    stock_anterior INT,
    stock_nuevo INT,
    usuario_responsable NVARCHAR(100),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

-- Constraints adicionales
ALTER TABLE Producto 
ADD CONSTRAINT CHK_Precio_Positivo CHECK (precio_unitario > 0);

ALTER TABLE Inventario 
ADD CONSTRAINT CHK_Stock_Min_Max CHECK (stock_minimo <= stock_maximo);

ALTER TABLE DetalleVenta 
ADD CONSTRAINT CHK_Cantidad_Positiva CHECK (cantidad > 0);

