USE MercaNovaDB;
GO

--INSERCIONES

INSERT INTO Sucursal (nombre, direccion, ciudad, departamento, telefono, gerente) VALUES
('Sucursal Centro', 'Colonia San Benito, Avenida Espa�a #123', 'San Salvador', 'San Salvador', '2222-1111', 'Maria Lopez'),
('Sucursal Occidente', 'Colonia Santa Lucia, Calle Libertad #45', 'Santa Ana', 'Santa Ana', '2444-2233', 'Carlos Gomez'),
('Sucursal Oriente', 'Colonia Ciudad Pacifica, Avenida Roosevelt #89', 'San Miguel', 'San Miguel', '2666-3344', 'Julia Martinez'),
('Sucursal Costera', 'Colonia El Carmen, 4a Calle Poniente #56', 'Santa Tecla', 'La Libertad', '2456-7788', 'Oscar Ramirez'),
('Sucursal Norte�a', 'Colonia El angel, Calle Central #32', 'La Palma', 'Chalatenango', '2300-9911', 'Ana Torres');

INSERT INTO Categoria (nombre, descripcion) VALUES
('Lacteos', 'Productos derivados de la leche'),
('Bebidas', 'Refrescos, jugos y agua'),
('Snacks', 'Botanas y galletas'),
('Limpieza', 'Productos para limpieza del hogar'),
('Carnes', 'Pollo, res y cerdo'),
('Verduras', 'Hortalizas y vegetales frescos'),
('Frutas', 'Frutas nacionales e importadas'),
('Granos Basicos', 'Arroz, frijoles, maiz y mas');

INSERT INTO Proveedor (nombre, contacto, telefono, correo, direccion, pais) VALUES
('Lacteos El Salvador', 'Pedro Ramos', '2221-1111', 'contacto@lacteosv.com', 'Km 5 Carretera a Santa Ana, Distrito Santa Ana Centro, Santa Ana', 'El Salvador'),
('Bebidas Tropical', 'Maria Fuentes', '2233-2222', 'ventas@bebidastropical.com', 'Zona Industrial #45, Distrito Soyapango, San Salvador', 'El Salvador'),
('Snacks del Valle', 'Carlos Reyes', '2244-3333', 'info@snacksvalle.com', 'Avenida Roosevelt #89, Distrito San Miguel Centro, San Miguel', 'El Salvador'),
('Aseo Total', 'Lucia Martinez', '2255-4444', 'lucia@aseototal.com', 'Calle Chiltiupan #12, Distrito Santa Tecla, La Libertad', 'El Salvador'),
('Carnes Premium', 'Jose Portillo', '2266-5555', 'ventas@carnespremium.com', 'Barrio San Juan #34, Distrito Santa Ana Centro, Santa Ana', 'El Salvador'),
('Agrofrut', 'Marta Ortiz', '2277-6666', 'contacto@agrofrut.com', 'Calle Central #22, Distrito San Vicente, San Vicente', 'El Salvador'),
('Verduras Selectas', 'Andres Rivas', '2288-7777', 'info@verdurasselectas.com', 'Calle Dr. Araujo #18, Distrito San Salvador Centro, San Salvador', 'El Salvador'),
('Distribuidora Basicos', 'Rafael Arevalo', '2299-8888', 'basicos@distri.com', 'Bo El Calvario #9, Distrito Usulutan Centro, Usulutan', 'El Salvador'),
('Agua Pura SV', 'Gloria Jimenez', '2300-9999', 'ventas@aguapura.com', 'Final 3a Calle Poniente #17, Distrito San Miguel, San Miguel', 'El Salvador'),
('Finca Natural', 'Eduardo Perez', '2311-0000', 'info@fincanatural.com', 'Canton El Zapote #5, Distrito Chalatenango, Chalatenango', 'El Salvador');

INSERT INTO Producto (nombre, descripcion, precio_unitario, estado, id_categoria, id_proveedor) VALUES
('Leche Entera 1L', 'Leche pasteurizada entera 1 litro', 1.1, 1, 1, 1),
('Jugo de Naranja 1L', 'Jugo natural de naranja sin azucar', 1.5, 1, 2, 2),
('Papas Fritas 100g', 'Bolsa de papas fritas clasicas', 0.9, 1, 3, 3),
('Detergente 1kg', 'Detergente en polvo multiusos', 2.5, 1, 4, 4),
('Pollo Entero', 'Pollo fresco entero', 5, 1, 5, 5),
('Tomates 1kg', 'Tomates frescos rojos', 1.2, 1, 6, 7),
('Manzanas 1kg', 'Manzanas importadas rojas', 2.3, 1, 7, 6),
('Frijoles Negros 1kg', 'Frijoles negros de alta calidad', 1.1, 1, 8, 8),
('Agua Pura 600ml', 'Botella de agua purificada', 0.5, 1, 2, 9),
('Mango 1kg', 'Mango fresco de temporada', 1.8, 1, 7, 10),
('Queso Fresco 1lb', 'Queso fresco delicioso', 1.5, 1, 1, 1);

INSERT INTO Empleado (nombre, apellido, cargo, fecha_contratacion, salario, id_sucursal) VALUES
('Jose', 'Hernandez', 'Cajero', '2021-05-12', 450, 1),
('Luisa', 'Morales', 'Vendedora', '2022-01-20', 400, 1),
('Mario', 'Garcia', 'Supervisor', '2020-03-11', 600, 2),
('Sofia', 'Campos', 'Cajera', '2023-02-18', 420, 2),
('Rafael', 'Torres', 'Gerente', '2019-11-10', 900, 3),
('Patricia', 'Navarro', 'Bodeguera', '2022-08-25', 380, 3),
('Juan', 'Lopez', 'Vendedor', '2020-12-03', 410, 4),
('Carmen', 'Flores', 'Cajera', '2021-09-15', 430, 4),
('Andres', 'Molina', 'Gerente', '2018-04-01', 950, 5),
('Laura', 'Perez', 'Vendedora', '2022-07-09', 400, 5);

INSERT INTO Cliente (nombre, apellido, dui, telefono, correo, direccion) VALUES
('Carlos', 'Lemus', '01234567-8', '7012-1111', 'carlos.lemus@gmail.com', 'Colonia San Benito, Avenida Espa�a #25, Distrito San Salvador Centro, San Salvador'),
('Ana', 'Guzman', '02345678-9', '7013-2222', 'ana.guzman@outlook.com', 'Colonia San Benito, Calle La Mascota #12, Distrito San Salvador Centro, San Salvador'),
('Ricardo', 'Flores', '03456789-0', '7014-3333', 'ricardo.flores@yahoo.com', 'Colonia Centro, Avenida Independencia #34, Distrito Santa Ana Centro, Santa Ana'),
('Sonia', 'Mendoza', '04567890-1', '7015-4444', 'sonia.mendoza@gmail.com', 'Colonia Ciudad Jardin, Calle Los Laureles #8, Distrito San Miguel Centro, San Miguel'),
('Jorge', 'Morales', '05678901-2', '7016-5555', 'jorge.morales@protonmail.com', 'Colonia El Calvario, Calle Principal #5, Distrito Chalatenango Centro, Chalatenango'),
('Maria', 'Vasquez', '06789012-3', '7017-6666', 'maria.vasquez@hotmail.com', 'Colonia Santa Marta, 2a Avenida Norte #22, Distrito Sonsonate Centro, Sonsonate'),
('Luis', 'Campos', '07890123-4', '7018-7777', 'luis.campos@gmail.com', 'Colonia Quezaltepeque, Calle San Antonio #14, Distrito Santa Tecla, La Libertad'),
('Diana', 'Rojas', '08901234-5', '7019-8888', 'diana.rojas@icloud.com', 'Colonia San Francisco, 4a Calle Oriente #3, Distrito San Vicente, San Vicente'),
('Julio', 'Ramirez', '09012345-6', '7020-9999', 'julio.ramirez@outlook.com', 'Colonia Miramonte, Calle Los Olmos #11, Distrito San Salvador Centro, San Salvador'),
('Gabriela', 'Martinez', '10123456-7', '7021-0000', 'gabriela.martinez@gmail.com', 'Colonia El Calvario, 1a Calle Poniente #7, Distrito Usulutan Centro, Usulutan');

INSERT INTO Inventario (id_sucursal, id_producto, stock_actual, stock_minimo, stock_maximo, ultima_actualizacion) VALUES
(1, 1, 63, 10, 100, '2025-10-20 08:00:00'),
(1, 2, 34, 10, 100, '2025-10-20 08:00:00'),
(1, 3, 43, 10, 100, '2025-10-20 08:00:00'),
(1, 4, 89, 10, 100, '2025-10-20 08:00:00'),
(1, 5, 29, 10, 100, '2025-10-20 08:00:00'),
(1, 6, 89, 10, 100, '2025-10-20 08:00:00'),
(1, 7, 26, 10, 100, '2025-10-20 08:00:00'),
(1, 8, 86, 10, 100, '2025-10-20 08:00:00'),
(1, 9, 50, 10, 100, '2025-10-20 08:00:00'),
(1, 10, 78, 10, 100, '2025-10-20 08:00:00'),
(2, 1, 22, 10, 100, '2025-10-20 08:00:00'),
(2, 2, 20, 10, 100, '2025-10-20 08:00:00'),
(2, 3, 92, 10, 100, '2025-10-20 08:00:00'),
(2, 4, 80, 10, 100, '2025-10-20 08:00:00'),
(2, 5, 65, 10, 100, '2025-10-20 08:00:00'),
(2, 6, 53, 10, 100, '2025-10-20 08:00:00'),
(2, 7, 78, 10, 100, '2025-10-20 08:00:00'),
(2, 8, 39, 10, 100, '2025-10-20 08:00:00'),
(2, 9, 88, 10, 100, '2025-10-20 08:00:00'),
(2, 10, 48, 10, 100, '2025-10-20 08:00:00'),
(3, 1, 36, 10, 100, '2025-10-20 08:00:00'),
(3, 2, 47, 10, 100, '2025-10-20 08:00:00'),
(3, 3, 99, 10, 100, '2025-10-20 08:00:00'),
(3, 4, 45, 10, 100, '2025-10-20 08:00:00'),
(3, 5, 90, 10, 100, '2025-10-20 08:00:00'),
(3, 6, 44, 10, 100, '2025-10-20 08:00:00'),
(3, 7, 34, 10, 100, '2025-10-20 08:00:00'),
(3, 8, 96, 10, 100, '2025-10-20 08:00:00'),
(3, 9, 35, 10, 100, '2025-10-20 08:00:00'),
(3, 10, 82, 10, 100, '2025-10-20 08:00:00'),
(4, 1, 73, 10, 100, '2025-10-20 08:00:00'),
(4, 2, 37, 10, 100, '2025-10-20 08:00:00'),
(4, 3, 89, 10, 100, '2025-10-20 08:00:00'),
(4, 4, 58, 10, 100, '2025-10-20 08:00:00'),
(4, 5, 38, 10, 100, '2025-10-20 08:00:00'),
(4, 6, 44, 10, 100, '2025-10-20 08:00:00'),
(4, 7, 89, 10, 100, '2025-10-20 08:00:00'),
(4, 8, 35, 10, 100, '2025-10-20 08:00:00'),
(4, 9, 40, 10, 100, '2025-10-20 08:00:00'),
(4, 10, 67, 10, 100, '2025-10-20 08:00:00'),
(5, 1, 97, 10, 100, '2025-10-20 08:00:00'),
(5, 2, 33, 10, 100, '2025-10-20 08:00:00'),
(5, 3, 93, 10, 100, '2025-10-20 08:00:00'),
(5, 4, 31, 10, 100, '2025-10-20 08:00:00'),
(5, 5, 72, 10, 100, '2025-10-20 08:00:00'),
(5, 6, 54, 10, 100, '2025-10-20 08:00:00'),
(5, 7, 24, 10, 100, '2025-10-20 08:00:00'),
(5, 8, 45, 10, 100, '2025-10-20 08:00:00'),
(5, 9, 35, 10, 100, '2025-10-20 08:00:00'),
(5, 10, 50, 10, 100, '2025-10-20 08:00:00');

INSERT INTO Compra (fecha_compra, total, id_proveedor, id_empleado, id_sucursal) VALUES
('2025-09-10 10:00:00', 200, 1, 1, 1),
('2025-09-11 11:00:00', 150, 2, 2, 1),
('2025-09-12 12:00:00', 300, 3, 3, 2),
('2025-09-13 13:00:00', 250, 4, 4, 2),
('2025-09-14 14:00:00', 180, 5, 5, 3),
('2025-09-15 15:00:00', 220, 6, 6, 3),
('2025-09-16 16:00:00', 210, 7, 7, 4),
('2025-09-17 17:00:00', 190, 8, 8, 4),
('2025-09-18 18:00:00', 170, 9, 9, 5),
('2025-09-19 19:00:00', 160, 10, 10, 5);

INSERT INTO DetalleCompra (id_compra, id_producto, cantidad, costo_unitario) VALUES
(1, 1, 100, 0.9),
(2, 2, 80, 1.2),
(3, 3, 120, 0.7),
(4, 4, 50, 2),
(5, 5, 60, 4.5),
(6, 6, 70, 1),
(7, 7, 90, 2),
(8, 8, 110, 0.9),
(9, 9, 200, 0.4),
(10, 10, 150, 1.5);

INSERT INTO Venta (fecha_venta, total, metodo_pago, id_empleado, id_cliente, id_sucursal) VALUES
('2025-10-10 14:30:00', 3.1, 'Efectivo', 1, 1, 1),
('2025-10-11 10:15:00', 1, 'Tarjeta', 2, 2, 1),
('2025-10-12 17:40:00', 9.6, 'Efectivo', 3, 3, 2),
('2025-10-13 09:30:00', 2.5, 'Tarjeta', 4, 4, 2),
('2025-10-14 11:45:00', 4.2, 'Efectivo', 5, 5, 3),
('2025-10-15 13:20:00', 3.3, 'Efectivo', 6, 6, 3),
('2025-10-16 16:10:00', 1.8, 'Tarjeta', 7, 7, 4),
('2025-10-17 19:50:00', 1.5, 'Efectivo', 8, 8, 4),
('2025-10-18 15:10:00', 10, 'Efectivo', 9, 9, 5),
('2025-10-19 12:00:00', 3.1, 'Tarjeta', 10, 10, 5);

INSERT INTO DetalleVenta (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 2, 1.1),
(1, 3, 1, 0.9),
(2, 9, 2, 0.5),
(3, 5, 1, 5),
(3, 7, 2, 2.3),
(4, 4, 1, 2.5),
(5, 2, 2, 1.5),
(5, 6, 1, 1.2),
(6, 8, 3, 1.1),
(7, 10, 1, 1.8),
(8, 9, 3, 0.5),
(9, 5, 2, 5),
(10, 3, 1, 0.9),
(10, 1, 2, 1.1);

INSERT INTO AuditoriaInventario (id_producto, id_sucursal, fecha, accion, cantidad, stock_anterior, stock_nuevo, usuario_responsable) VALUES
(1, 1, '2025-10-20 09:00:00', 'Entrada', 10, 50, 60, 'Jose Hernandez'),
(2, 2, '2025-10-21 09:00:00', 'Salida', 5, 40, 35, 'Luisa Morales'),
(3, 3, '2025-10-22 09:00:00', 'Entrada', 20, 30, 50, 'Mario Garcia'),
(4, 4, '2025-10-23 09:00:00', 'Salida', 8, 70, 62, 'Sofia Campos'),
(5, 5, '2025-10-24 09:00:00', 'Ajuste', 3, 100, 103, 'Rafael Torres'),
(6, 3, '2025-10-24 10:00:00', 'Entrada', 15, 25, 40, 'Patricia Navarro'),
(7, 4, '2025-10-24 11:00:00', 'Salida', 10, 50, 40, 'Juan Lopez'),
(8, 2, '2025-10-24 12:00:00', 'Ajuste', 5, 30, 35, 'Carmen Flores'),
(9, 1, '2025-10-24 13:00:00', 'Entrada', 12, 60, 72, 'Andres Molina'),
(10, 5, '2025-10-24 14:00:00', 'Salida', 7, 80, 73, 'Laura Perez');