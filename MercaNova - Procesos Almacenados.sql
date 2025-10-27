USE MercaNovaDB;
GO

-- PROCESOS ALMACENADOS

--- 1. SP - RealizarVenta
CREATE sp_RealizarVenta
    @id_empleado INT,
    @id_cliente INT = NULL,
    @metodo_pago NVARCHAR(50),
    @productos_json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_venta INT;
    DECLARE @nombre_empleado NVARCHAR(201);
    DECLARE @id_sucursal INT;  -- Nueva variable

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar empleado y obtener su sucursal
        SELECT 
            @nombre_empleado = e.nombre + ' ' + e.apellido,
            @id_sucursal = e.id_sucursal  -- Obtenemos la sucursal
        FROM Empleado e
        WHERE e.id_empleado = @id_empleado;

        IF @nombre_empleado IS NULL
        BEGIN
            RAISERROR('Error: El empleado con ID %d no existe', 16, 1, @id_empleado);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el empleado tiene sucursal asignada
        IF @id_sucursal IS NULL
        BEGIN
            RAISERROR('Error: El empleado %s no tiene una sucursal asignada', 16, 1, @nombre_empleado);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @id_cliente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente = @id_cliente)
        BEGIN
            RAISERROR('Error: El cliente con ID %d no existe', 16, 1, @id_cliente);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar JSON
        IF @productos_json IS NULL OR LTRIM(RTRIM(@productos_json)) = '' OR @productos_json = '[]'
        BEGIN
            RAISERROR('Error: No hay productos en la venta', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Crear tabla temporal
        CREATE TABLE #TempVentas (
            id_producto INT,
            cantidad INT,
            precio_unitario DECIMAL(10,2),
            subtotal DECIMAL(10,2)
        );

        -- Insertar productos con precios desde tabla Producto
        INSERT INTO #TempVentas (id_producto, cantidad, precio_unitario, subtotal)
        SELECT 
            CAST(JSON_VALUE(producto.value, '$.id') AS INT),
            CAST(JSON_VALUE(producto.value, '$.cantidad') AS INT),
            p.precio_unitario,
            CAST(JSON_VALUE(producto.value, '$.cantidad') AS INT) * p.precio_unitario
        FROM OPENJSON(@productos_json) AS producto
        INNER JOIN Producto p ON CAST(JSON_VALUE(producto.value, '$.id') AS INT) = p.id_producto;

        -- Validar productos
        IF NOT EXISTS (SELECT 1 FROM #TempVentas)
        BEGIN
            RAISERROR('Error: Formato de productos inv�lido', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que productos existen y est�n activos
        IF EXISTS (SELECT 1 FROM #TempVentas tv LEFT JOIN Producto p ON tv.id_producto = p.id_producto WHERE p.id_producto IS NULL OR p.estado = 0)
        BEGIN
            RAISERROR('Error: Uno o m�s productos no existen o est�n inactivos', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar stock
        IF EXISTS (
            SELECT 1 
            FROM #TempVentas tv
            INNER JOIN Inventario i ON tv.id_producto = i.id_producto AND i.id_sucursal = @id_sucursal
            WHERE i.stock_actual < tv.cantidad
        )
        BEGIN
            RAISERROR('Error: Stock insuficiente para algunos productos', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar cantidades positivas
        IF EXISTS (SELECT 1 FROM #TempVentas WHERE cantidad <= 0)
        BEGIN
            RAISERROR('Error: Las cantidades deben ser mayores a cero', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obtener nombre del empleado
        SELECT @nombre_empleado = nombre + ' ' + apellido 
        FROM Empleado 
        WHERE id_empleado = @id_empleado;

        -- INSERTAR VENTA (el trigger TR_CalcularTotalVenta calcular� el total autom�ticamente)
        INSERT INTO Venta (fecha_venta, total, metodo_pago, id_empleado, id_cliente, id_sucursal)
        VALUES (GETDATE(), 0, @metodo_pago, @id_empleado, @id_cliente, @id_sucursal); -- Total = 0 temporal

        SET @id_venta = SCOPE_IDENTITY();

        -- INSERTAR DETALLES (los triggers se encargan del resto)
        INSERT INTO DetalleVenta (id_venta, id_producto, cantidad, precio_unitario)
        SELECT @id_venta, id_producto, cantidad, precio_unitario
        FROM #TempVentas;

        -- Auditor�a manual (el trigger de stock negativo har� auditor�a si es necesario)
        INSERT INTO AuditoriaInventario (
            id_producto, id_sucursal, fecha, accion, 
            cantidad, stock_anterior, stock_nuevo, usuario_responsable
        )
        SELECT 
            tv.id_producto,
            @id_sucursal,
            GETDATE(),
            'Salida',
            tv.cantidad,
            i.stock_actual,
            i.stock_actual - tv.cantidad,
            @nombre_empleado
        FROM #TempVentas tv
        INNER JOIN Inventario i ON tv.id_producto = i.id_producto AND i.id_sucursal = @id_sucursal;

        COMMIT TRANSACTION;

        -- Retornar resultados
        SELECT 
            @id_venta AS id_venta_creada,
            (SELECT SUM(subtotal) FROM #TempVentas) AS total_venta,
            @nombre_empleado AS empleado,
            (SELECT COUNT(*) FROM #TempVentas) AS cantidad_productos,
            (SELECT SUM(cantidad) FROM #TempVentas) AS total_unidades;

        -- Detalle de productos
        SELECT 
            p.id_producto,
            p.nombre AS producto,
            tv.cantidad,
            tv.precio_unitario,
            tv.subtotal
        FROM #TempVentas tv
        INNER JOIN Producto p ON tv.id_producto = p.id_producto;

        DROP TABLE #TempVentas;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        IF OBJECT_ID('tempdb..#TempVentas') IS NOT NULL
            DROP TABLE #TempVentas;
        
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en RealizarVenta: %s', 16, 1, @ErrorMsg);
    END CATCH;
END;
GO

--- 2. SP - InsertarCliente
CREATE PROCEDURE sp_InsertarCliente
    @nombre NVARCHAR(100) = NULL,
    @apellido NVARCHAR(100),
    @dui NVARCHAR(10),
    @telefono NVARCHAR(20),
    @correo NVARCHAR(100),
    @direccion NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar campos obligatorios
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('Error: El nombre es obligatorio', 16, 1);
        RETURN;
    END

    -- Para que el dui no se repita
    IF EXISTS (SELECT 1 FROM Cliente WHERE dui = @dui)
    BEGIN
        RAISERROR('Error: Ya existe un cliente registrado con este n�mero de DUI.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        -- Insertar nuevo cliente
        INSERT INTO Cliente (nombre, apellido, dui, telefono, correo, direccion)
        VALUES (@nombre, @apellido, @dui, @telefono, @correo, @direccion);

        DECLARE @nuevo_id INT = SCOPE_IDENTITY();
        
        SELECT @nuevo_id AS id_cliente;
    END TRY
    BEGIN CATCH
        -- Manejar errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error al insertar cliente: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
END;
GO

--- 3. SP - BuscarProducto
CREATE OR ALTER PROCEDURE sp_BuscarProductos
    @nombre NVARCHAR(100) = NULL,
    @id_categoria INT = NULL,
    @id_proveedor INT = NULL,
    @precio_min DECIMAL(10,2) = NULL,
    @precio_max DECIMAL(10,2) = NULL,
    @estado BIT = NULL
AS
BEGIN
    -- Solo validaci�n cr�tica
    IF @precio_min IS NOT NULL AND @precio_max IS NOT NULL AND @precio_min > @precio_max
    BEGIN
        RAISERROR('Error: El precio m�nimo no puede ser mayor al precio m�ximo', 16, 1);
        RETURN;
    END

    SELECT
        p.id_producto AS IDProducto,
        p.nombre AS NombreProducto,
        p.descripcion AS DescripcionProducto,
        p.precio_unitario AS PrecioUnidad,
        c.nombre AS NombreCategoria,
        pr.nombre AS NombreProveedor,
        p.estado AS Estado
    FROM
        Producto p
    INNER JOIN Categoria c ON p.id_categoria = c.id_categoria
    INNER JOIN Proveedor pr ON p.id_proveedor = pr.id_proveedor
    WHERE 
        (@nombre IS NULL OR p.nombre LIKE '%' + @nombre + '%')
        AND (@id_categoria IS NULL OR p.id_categoria = @id_categoria)
        AND (@id_proveedor IS NULL OR p.id_proveedor = @id_proveedor)
        AND (@precio_min IS NULL OR p.precio_unitario >= @precio_min)
        AND (@precio_max IS NULL OR p.precio_unitario <= @precio_max)
        AND (@estado IS NULL OR p.estado = @estado)
    ORDER BY p.nombre;
END;
GO

-- 4. SP - RealizarCompraStock
CREATE OR ALTER PROCEDURE sp_RealizarCompraStock
    @id_empleado_gerente INT,
    @productos_json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @total_compra DECIMAL(10,2) = 0;
    DECLARE @nombre_gerente NVARCHAR(201);
    DECLARE @cargo_empleado NVARCHAR(100);
    DECLARE @id_sucursal_empleado INT;  -- Nueva variable para la sucursal del empleado

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el empleado existe y obtener su sucursal
        SELECT 
            @cargo_empleado = e.cargo,
            @nombre_gerente = e.nombre + ' ' + e.apellido,
            @id_sucursal_empleado = e.id_sucursal  -- Obtenemos la sucursal del empleado
        FROM Empleado e
        WHERE e.id_empleado = @id_empleado_gerente;

        IF @nombre_gerente IS NULL
        BEGIN
            RAISERROR('Error: El empleado con ID %d no existe', 16, 1, @id_empleado_gerente);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el empleado tiene permisos de gerente
        IF @cargo_empleado NOT LIKE '%gerente%' AND @cargo_empleado NOT LIKE '%Gerente%'
        BEGIN
            RAISERROR('Error: El empleado %s no tiene permisos de gerente para realizar compras', 16, 1, @nombre_gerente);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el empleado tiene una sucursal asignada
        IF @id_sucursal_empleado IS NULL
        BEGIN
            RAISERROR('Error: El empleado %s no tiene una sucursal asignada', 16, 1, @nombre_gerente);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que la sucursal del empleado existe
        IF NOT EXISTS (SELECT 1 FROM Sucursal WHERE id_sucursal = @id_sucursal_empleado)
        BEGIN
            RAISERROR('Error: La sucursal asignada al empleado (ID %d) no existe', 16, 1, @id_sucursal_empleado);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- El resto del procedimiento se mantiene igual, pero usando @id_sucursal_empleado
        -- Validar que el JSON de productos no est� vac�o
        IF @productos_json IS NULL OR LTRIM(RTRIM(@productos_json)) = '' OR @productos_json = '[]'
        BEGIN
            RAISERROR('Error: No hay productos en la compra', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Crear tabla temporal para los productos
        CREATE TABLE #TempCompras (
            id_producto INT,
            cantidad INT,
            costo_unitario DECIMAL(10,2),
            id_proveedor INT,
            subtotal DECIMAL(10,2),
            nombre_producto NVARCHAR(100),
            nombre_proveedor NVARCHAR(100)
        );

        -- Insertar productos desde JSON
        INSERT INTO #TempCompras (id_producto, cantidad, costo_unitario, id_proveedor, subtotal, nombre_producto, nombre_proveedor)
        SELECT 
            CAST(JSON_VALUE(producto.value, '$.id') AS INT) AS id_producto,
            CAST(JSON_VALUE(producto.value, '$.cantidad') AS INT) AS cantidad,
            CAST(JSON_VALUE(producto.value, '$.costo') AS DECIMAL(10,2)) AS costo_unitario,
            CAST(JSON_VALUE(producto.value, '$.id_proveedor') AS INT) AS id_proveedor,
            CAST(JSON_VALUE(producto.value, '$.cantidad') AS INT) * CAST(JSON_VALUE(producto.value, '$.costo') AS DECIMAL(10,2)) AS subtotal,
            p.nombre AS nombre_producto,
            pr.nombre AS nombre_proveedor
        FROM OPENJSON(@productos_json) AS producto
        INNER JOIN Producto p ON CAST(JSON_VALUE(producto.value, '$.id') AS INT) = p.id_producto
        INNER JOIN Proveedor pr ON CAST(JSON_VALUE(producto.value, '$.id_proveedor') AS INT) = pr.id_proveedor;

        -- Validar que se insertaron productos
        IF NOT EXISTS (SELECT 1 FROM #TempCompras)
        BEGIN
            RAISERROR('Error: Formato de productos inv�lido', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que todos los productos existen en la tabla Producto
        IF EXISTS (
            SELECT 1 
            FROM #TempCompras tc
            LEFT JOIN Producto p ON tc.id_producto = p.id_producto
            WHERE p.id_producto IS NULL
        )
        BEGIN
            DECLARE @productos_inexistentes NVARCHAR(1000);
            
            SELECT @productos_inexistentes = STRING_AGG(tc.id_producto, ', ')
            FROM #TempCompras tc
            LEFT JOIN Producto p ON tc.id_producto = p.id_producto
            WHERE p.id_producto IS NULL;
            
            RAISERROR('Error: Los siguientes productos no existen: %s', 16, 1, @productos_inexistentes);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que todos los productos est�n activos
        IF EXISTS (
            SELECT 1 
            FROM #TempCompras tc
            INNER JOIN Producto p ON tc.id_producto = p.id_producto
            WHERE p.estado = 0
        )
        BEGIN
            DECLARE @productos_inactivos NVARCHAR(1000);
            
            SELECT @productos_inactivos = STRING_AGG(tc.id_producto, ', ')
            FROM #TempCompras tc
            INNER JOIN Producto p ON tc.id_producto = p.id_producto
            WHERE p.estado = 0;
            
            RAISERROR('Error: Los siguientes productos est�n inactivos: %s', 16, 1, @productos_inactivos);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que todos los proveedores existen
        IF EXISTS (
            SELECT 1 
            FROM #TempCompras tc
            LEFT JOIN Proveedor pr ON tc.id_proveedor = pr.id_proveedor
            WHERE pr.id_proveedor IS NULL
        )
        BEGIN
            RAISERROR('Error: Uno o m�s proveedores no existen', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que los productos pertenecen a los proveedores especificados
        IF EXISTS (
            SELECT 1 
            FROM #TempCompras tc
            INNER JOIN Producto p ON tc.id_producto = p.id_producto
            WHERE p.id_proveedor != tc.id_proveedor
        )
        BEGIN
            RAISERROR('Error: Uno o m�s productos no pertenecen al proveedor especificado', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar cantidades y costos positivos
        IF EXISTS (SELECT 1 FROM #TempCompras WHERE cantidad <= 0 OR costo_unitario <= 0)
        BEGIN
            RAISERROR('Error: Las cantidades y costos deben ser mayores a cero', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Calcular el total de la compra
        SELECT @total_compra = SUM(subtotal) FROM #TempCompras;

        -- Validar que el total sea positivo
        IF @total_compra <= 0
        BEGIN
            RAISERROR('Error: El total de la compra debe ser mayor a cero', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Crear tabla temporal para agrupar por proveedor
        CREATE TABLE #ComprasPorProveedor (
            id_proveedor INT,
            total_proveedor DECIMAL(10,2),
            id_compra INT,
            nombre_proveedor NVARCHAR(100)
        );

        -- Agrupar productos por proveedor y calcular totales
        INSERT INTO #ComprasPorProveedor (id_proveedor, total_proveedor, nombre_proveedor)
        SELECT 
            id_proveedor,
            SUM(subtotal) as total_proveedor,
            MAX(nombre_proveedor) as nombre_proveedor
        FROM #TempCompras
        GROUP BY id_proveedor;

        -- Insertar compras por cada proveedor
        DECLARE @id_proveedor_actual INT, @total_proveedor_actual DECIMAL(10,2), @nombre_proveedor_actual NVARCHAR(100);

        DECLARE proveedor_cursor CURSOR FOR
        SELECT id_proveedor, total_proveedor, nombre_proveedor FROM #ComprasPorProveedor;

        OPEN proveedor_cursor;
        FETCH NEXT FROM proveedor_cursor INTO @id_proveedor_actual, @total_proveedor_actual, @nombre_proveedor_actual;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @id_compra_actual INT;

            -- Insertar cabecera de la compra para este proveedor (usando @id_sucursal_empleado)
            INSERT INTO Compra (
                fecha_compra, 
                total, 
                id_proveedor, 
                id_empleado, 
                id_sucursal
            )
            VALUES (
                GETDATE(), 
                @total_proveedor_actual, 
                @id_proveedor_actual, 
                @id_empleado_gerente, 
                @id_sucursal_empleado  -- Usamos la sucursal del empleado
            );

            SET @id_compra_actual = SCOPE_IDENTITY();

            -- Actualizar la tabla temporal con el id_compra
            UPDATE #ComprasPorProveedor 
            SET id_compra = @id_compra_actual 
            WHERE id_proveedor = @id_proveedor_actual;

            -- Insertar detalles de compra para los productos de este proveedor
            INSERT INTO DetalleCompra (
                id_compra, 
                id_producto, 
                cantidad, 
                costo_unitario
            )
            SELECT 
                @id_compra_actual, 
                tc.id_producto, 
                tc.cantidad, 
                tc.costo_unitario
            FROM #TempCompras tc
            WHERE tc.id_proveedor = @id_proveedor_actual;

            FETCH NEXT FROM proveedor_cursor INTO @id_proveedor_actual, @total_proveedor_actual, @nombre_proveedor_actual;
        END

        CLOSE proveedor_cursor;
        DEALLOCATE proveedor_cursor;

        -- Actualizar inventario (usando @id_sucursal_empleado)
        MERGE Inventario AS target
        USING (
            SELECT 
                @id_sucursal_empleado as id_sucursal,  -- Usamos la sucursal del empleado
                tc.id_producto,
                tc.cantidad
            FROM #TempCompras tc
        ) AS source
        ON target.id_sucursal = source.id_sucursal 
           AND target.id_producto = source.id_producto
        WHEN MATCHED THEN
            UPDATE SET 
                stock_actual = target.stock_actual + source.cantidad,
                ultima_actualizacion = GETDATE()
        WHEN NOT MATCHED THEN
            INSERT (id_sucursal, id_producto, stock_actual, stock_minimo, stock_maximo, ultima_actualizacion)
            VALUES (source.id_sucursal, source.id_producto, source.cantidad, 10, 100, GETDATE());

        -- Registrar en auditor�a de inventario (usando @id_sucursal_empleado)
        INSERT INTO AuditoriaInventario (
            id_producto, 
            id_sucursal, 
            fecha, 
            accion, 
            cantidad, 
            stock_anterior, 
            stock_nuevo, 
            usuario_responsable
        )
        SELECT 
            tc.id_producto,
            @id_sucursal_empleado,  -- Usamos la sucursal del empleado
            GETDATE(),
            'Entrada',
            tc.cantidad,
            ISNULL(i.stock_actual, 0),
            ISNULL(i.stock_actual, 0) + tc.cantidad,
            @nombre_gerente
        FROM #TempCompras tc
        LEFT JOIN Inventario i ON tc.id_producto = i.id_producto 
                              AND i.id_sucursal = @id_sucursal_empleado;  -- Usamos la sucursal del empleado

        COMMIT TRANSACTION;

        -- Retornar resumen general de la compra (incluyendo la sucursal autom�tica)
        SELECT 
            @total_compra AS total_compra_general,
            @nombre_gerente AS gerente_responsable,
            @id_sucursal_empleado AS id_sucursal,  -- Informamos qu� sucursal se us�
            (SELECT nombre FROM Sucursal WHERE id_sucursal = @id_sucursal_empleado) AS nombre_sucursal,
            (SELECT COUNT(*) FROM #TempCompras) AS cantidad_productos,
            (SELECT SUM(cantidad) FROM #TempCompras) AS total_unidades,
            (SELECT COUNT(DISTINCT id_proveedor) FROM #TempCompras) AS cantidad_proveedores;

        -- Retornar resumen por proveedor
        SELECT 
            cpp.id_proveedor,
            cpp.nombre_proveedor,
            cpp.total_proveedor,
            cpp.id_compra,
            (SELECT COUNT(*) FROM #TempCompras tc WHERE tc.id_proveedor = cpp.id_proveedor) AS cantidad_productos
        FROM #ComprasPorProveedor cpp;

        -- Retornar detalle de productos comprados
        SELECT 
            tc.id_producto,
            tc.nombre_producto,
            tc.nombre_proveedor,
            tc.cantidad,
            tc.costo_unitario,
            tc.subtotal,
            cpp.id_compra,
            (ISNULL(i.stock_actual, 0) + tc.cantidad) AS nuevo_stock
        FROM #TempCompras tc
        INNER JOIN #ComprasPorProveedor cpp ON tc.id_proveedor = cpp.id_proveedor
        LEFT JOIN Inventario i ON tc.id_producto = i.id_producto 
                              AND i.id_sucursal = @id_sucursal_empleado  -- Usamos la sucursal del empleado
        ORDER BY tc.nombre_proveedor, tc.nombre_producto;

        -- Limpiar tablas temporales
        DROP TABLE #TempCompras;
        DROP TABLE #ComprasPorProveedor;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        IF OBJECT_ID('tempdb..#TempCompras') IS NOT NULL
            DROP TABLE #TempCompras;
        IF OBJECT_ID('tempdb..#ComprasPorProveedor') IS NOT NULL
            DROP TABLE #ComprasPorProveedor;
        
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Error en RealizarCompraStock: %s', @ErrorSeverity, @ErrorState, @ErrorMsg);
        RETURN;
    END CATCH;
END;
GO

-- EJEMPLOS DE USO DE LOS SP

USE MercaNovaDB;
GO

-- 1. EJEMPLOS PARA sp_RealizarVenta

-- Ejemplo 1: Venta con 3 productos diferentes
EXEC sp_RealizarVenta 
    @id_empleado = 10,
    @id_cliente = 1,
    @metodo_pago = 'EFECTIVO',
    @productos_json = '[
        {"id":1, "cantidad":2},
        {"id":2, "cantidad":1},
        {"id":3, "cantidad":3}
    ]';
GO

-- Ejemplo 2: Venta sin cliente, solo un producto
EXEC sp_RealizarVenta 
    @id_empleado = 2,
    @id_cliente = NULL,
    @metodo_pago = 'TARJETA',
    @productos_json = '[
        {"id":4, "cantidad":5}
    ]';
GO

-- 2. EJEMPLOS PARA sp_InsertarCliente

-- Ejemplo 1: Cliente con todos los datos
EXEC sp_InsertarCliente 
    @nombre = 'María',
    @apellido = 'Gonzalez',
    @dui = '12345678-9',
    @telefono = '2222-3333',
    @correo = 'maria.gonzalez@email.com',
    @direccion = 'Calle Principal #123, San Salvador';
GO

-- Ejemplo 2: Cliente con datos mínimos
EXEC sp_InsertarCliente 
    @nombre = 'Carlos',
    @apellido = 'López',
    @dui = '98765432-1',
    @telefono = '7777-8888',
    @correo = NULL,
    @direccion = NULL;
GO

-- 3. EJEMPLOS PARA sp_BuscarProductos

-- Ejemplo 1: Búsqueda por categoría y rango de precios
EXEC sp_BuscarProductos 
    @id_categoria = 7,
    @precio_min = 2.00,
    @precio_max = 50.00,
    @estado = 1;
GO

-- Ejemplo 2: Búsqueda por nombre y proveedor
EXEC sp_BuscarProductos 
    @nombre = 'Pollo entero',
    @id_proveedor = 5,
    @estado = 1;
GO

-- 4. EJEMPLOS PARA sp_RealizarCompraStock

-- Ejemplo 1: Compra de productos de 3 proveedores diferentes
EXEC sp_RealizarCompraStock 
    @id_empleado_gerente = 5,
	-- En el campo “costo” se debe registrar el costo unitario del producto pagado al proveedor.
	-- Este valor debe ser menor que el precio registrado en la tabla “Producto”, ya que dicho precio corresponde al valor de venta al público.
    @productos_json = '[
        {"id":1, "cantidad":20, "costo":1.00, "id_proveedor":1}, 
        {"id":2, "cantidad":15, "costo":1.15, "id_proveedor":2},
        {"id":3, "cantidad":30, "costo":0.75, "id_proveedor":3},
    ]';
GO


-- Ejemplo 2: Compra de un solo proveedor
EXEC sp_RealizarCompraStock 
    @id_empleado_gerente = 5,
    @productos_json = '[
        {"id":1, "cantidad":50, "costo":1.00, "id_proveedor":1},
        {"id":11, "cantidad":30, "costo":1.10, "id_proveedor":1}
    ]';
GO