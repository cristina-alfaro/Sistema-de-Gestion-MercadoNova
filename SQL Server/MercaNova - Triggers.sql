USE MercaNovaDB;
GO

-- DISPARADORES

-- Nota: Ejecutar los disparadores 1 por 1 desde: Create Trigger: (nombre del trigger) hasta: end; Go (estas son las ultimas dos lineas que tiene cada disparador)
-- Disparador: TR_RegistrarNuevosProductos
-- Objetivo: Registrar automaticamente en auditoria cuando se crean nuevos productos
CREATE TRIGGER TR_RegistrarNuevosProductos
ON Producto
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Registramos automaticamente en auditoria cuando se agrega un nuevo producto
        INSERT INTO AuditoriaInventario (
            id_producto,
			id_sucursal,
            accion, 
            cantidad, 
            stock_anterior, 
            stock_nuevo, 
            usuario_responsable
        )
        SELECT 
            i.id_producto,
            1, -- dejamos la sucursal principal por defecto
            'PRODUCTO_CREADO',
            0,
            0,
            0,
            SYSTEM_USER
        FROM inserted i;
        
        COMMIT TRANSACTION;  -- confirmamos la transaccion con Commit
        PRINT 'Nuevo producto registrado en auditoria correctamente.';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;  -- Cancelamos la transaccion en caso de error
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- Segundo Disparador (TR_CalcularTotalVenta).
-- Objetivo: Calcular automaticamente el total de las ventas cuando se modifican los detalles.
CREATE TRIGGER TR_CalcularTotalVenta
ON DetalleVenta
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Aqui obtenemos todas las ventas afectadas
        DECLARE @VentasAfectadas TABLE (id_venta INT);
        
        INSERT INTO @VentasAfectadas (id_venta)
        SELECT id_venta FROM inserted
        UNION
        SELECT id_venta FROM deleted;
        
        -- Verificamos con una condicional IF si no hay ventas afectadas en inserted/deleted, salir
        IF NOT EXISTS (SELECT 1 FROM @VentasAfectadas)
        BEGIN
            COMMIT TRANSACTION;
            RETURN;
        END;
        
        -- Recalculamos el total para cada venta afectada
        UPDATE Venta
        SET total = (
            SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
            FROM DetalleVenta
            WHERE id_venta = Venta.id_venta
        )
        WHERE id_venta IN (SELECT id_venta FROM @VentasAfectadas);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- Tercer Disparador (TR_ControlStockMinimo)
-- Objetivo: Generar alertas cuando los productos alcanzan niveles bajos de stock
CREATE TRIGGER TR_ControlStockMinimo
ON Inventario
AFTER UPDATE, INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificamos productos que han alcanzado o estan por debajo del stock minimo
        DECLARE @ProductosBajoStock TABLE (
            id_sucursal INT,
            id_producto INT,
            nombre_producto NVARCHAR(100),
            nombre_sucursal NVARCHAR(100),
            stock_actual INT,
            stock_minimo INT,
            diferencia INT
        );
        
        INSERT INTO @ProductosBajoStock
        SELECT 
            i.id_sucursal,
            i.id_producto,
            p.nombre as nombre_producto,
            s.nombre as nombre_sucursal,
            i.stock_actual,
            i.stock_minimo,
            (i.stock_actual - i.stock_minimo) as diferencia
        FROM inserted i
        INNER JOIN Producto p ON i.id_producto = p.id_producto
        INNER JOIN Sucursal s ON i.id_sucursal = s.id_sucursal
        WHERE i.stock_actual <= i.stock_minimo + 5; -- Aqui alertamos cuando este cerca del minimo
        
        -- Insertamos alertas en la auditoria para productos con stock bajo
        IF EXISTS (SELECT 1 FROM @ProductosBajoStock WHERE diferencia <= 0)
        BEGIN
            INSERT INTO AuditoriaInventario (
                id_producto, id_sucursal, accion, cantidad,
                stock_anterior, stock_nuevo, usuario_responsable
            )
            SELECT 
                id_producto,
                id_sucursal,
                'ALERTA_STOCK_BAJO',
                ABS(diferencia),
                stock_minimo,
                stock_actual,
                SYSTEM_USER
            FROM @ProductosBajoStock
            WHERE diferencia <= 0;
            
            -- Este espacio lo cree con la finalidad de que algun dia se podria integrar con un sistema de notificaciones por email
            PRINT 'ALERTA: Productos con stock por debajo del minimo detectados. Verificar tabla AuditoriaInventario.';
        END;
        
        -- Alerta para productos cerca del minimo (dentro de 5 unidades)
        IF EXISTS (SELECT 1 FROM @ProductosBajoStock WHERE diferencia > 0 AND diferencia <= 5)
        BEGIN
            PRINT 'ADVERTENCIA: Productos cerca del stock minimo. Considerar reabastecimiento.';
        END;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- ===========================================================
-- DEMOSTRACION 1: TR_RegistrarNuevosProductos con Transacciones
-- ===========================================================
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 1. Ver estado inicial de la auditoria
PRINT '=== ESTADO INICIAL DE AUDITORIA ===';
SELECT 
    COUNT(*) as total_registros_auditoria
FROM AuditoriaInventario 
WHERE accion = 'PRODUCTO_CREADO';

-- 2. Prueba 1: Para esta prueba insertare un producto exitosamente
PRINT '=== PRUEBA 1: INSERCION EXITOSA ===';
BEGIN TRY
    INSERT INTO Producto (nombre, descripcion, precio_unitario, estado, id_categoria, id_proveedor)
    VALUES ('Queso Fresco 250g', 'Queso fresco tipo panela', 3.25, 1, 1, 1);
    
    DECLARE @producto_exitoso_id INT = SCOPE_IDENTITY();
    PRINT 'Producto creado exitosamente. ID: ' + CAST(@producto_exitoso_id AS NVARCHAR);
    
    -- Verificamos que se haya creado el registro en auditoria
    SELECT 
        id_auditoria,
        id_producto,
        accion,
        fecha,
        usuario_responsable
    FROM AuditoriaInventario 
    WHERE id_producto = @producto_exitoso_id;
    
END TRY
BEGIN CATCH
    PRINT 'Error inesperado: ' + ERROR_MESSAGE();
END CATCH;
-- ===================
-- Hasta el END CATCH
-- ===================
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 3. Prueba 2: Simularemos un error forzado para probar el ROLLBACK que usamos en el trigger
PRINT '=== PRUEBA 2: SIMULAR ERROR PARA PROBAR ROLLBACK ===';

-- Creamos una tabla temporal para simular un problema
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Probamos en insertar un producto valido
    INSERT INTO Producto (nombre, descripcion, precio_unitario, estado, id_categoria, id_proveedor)
    VALUES ('Aceite Vegetal 1L', 'Aceite de cocina', 4.50, 1, 8, 8);
    
    DECLARE @producto_error_id INT = SCOPE_IDENTITY();
    PRINT 'Producto insertado temporalmente. ID: ' + CAST(@producto_error_id AS NVARCHAR);
    
    -- Forzamos un error (intentaremos insertar en una tabla que no existe)
    INSERT INTO TablaQueNoExiste (columna) VALUES (1);
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    PRINT 'Error capturado (ROLLBACK automatico): ' + ERROR_MESSAGE();
    
    -- Verificamos que el producto NO se mantuvo por el ROLLBACK
    IF NOT EXISTS (SELECT 1 FROM Producto WHERE id_producto = @producto_error_id)
    BEGIN
        PRINT 'ROLLBACK funciono :D: El producto fue eliminado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'ROLLBACK fallo :c: El producto permanecio en la base de datos.';
    END
END CATCH;
-- ===================
-- Hasta el END CATCH
-- ===================
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 4. Prueba 3: Insertaremos multiples productos (transaccion implicita)
PRINT '=== PRUEBA 3: INSERCION MULTIPLE ===';
BEGIN TRY
    INSERT INTO Producto (nombre, descripcion, precio_unitario, estado, id_categoria, id_proveedor)
    VALUES 
        ('Cereal Integral 500g', 'Cereal de trigo integral', 3.75, 1, 3, 3),
        ('Shampoo Anticaspa 400ml', 'Shampoo para cuidado capilar', 5.25, 1, 4, 4),
        ('Salm�n Fresco 500g', 'Filete de salm�n fresco', 12.50, 1, 5, 5);
    
    PRINT 'M�ltiples productos insertados exitosamente.';
    
    -- Verificamos que todos tienen registro en auditoria
    SELECT 
        p.id_producto,
        p.nombre,
        ai.accion,
        ai.fecha
    FROM Producto p
    INNER JOIN AuditoriaInventario ai ON p.id_producto = ai.id_producto
    WHERE p.nombre IN ('Cereal Integral 500g', 'Shampoo Anticaspa 400ml', 'Salm�n Fresco 500g')
    ORDER BY ai.fecha DESC;
    
END TRY
BEGIN CATCH
    PRINT 'Error en insercion multiple: ' + ERROR_MESSAGE();
END CATCH;
-- ===================
-- Hasta el END CATCH
-- ===================
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 5. Prueba 4: Insertamos un producto con datos invalidos
PRINT '=== PRUEBA 4: DATOS INVALIDOS (para probar la integridad referencial) ===';
BEGIN TRY
    -- Intentaremos una categoria que no existe, la categoria 999
    INSERT INTO Producto (nombre, descripcion, precio_unitario, estado, id_categoria, id_proveedor)
    VALUES ('Producto Invalido', 'Producto con categoria inexistente', 10.00, 1, 999, 1);
    
END TRY
BEGIN CATCH
    PRINT 'Error esperado (violacion de FK): ' + ERROR_MESSAGE();
    
    -- Verificamo que NO se creo el registro en auditoria para este producto
    IF NOT EXISTS (
        SELECT 1 FROM AuditoriaInventario ai
        INNER JOIN Producto p ON ai.id_producto = p.id_producto
        WHERE p.nombre = 'Producto Invalido'
    )
    BEGIN
        PRINT 'Transaccion funciono: No hay registro en auditoria para producto invalido.';
    END
END CATCH;
-- ===================
-- Hasta el END CATCH
-- ===================
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 6. Resumen final
PRINT '=== RESUMEN FINAL ===';
SELECT 
    accion,
    COUNT(*) as total_registros,
    MIN(fecha) as fecha_minima,
    MAX(fecha) as fecha_maxima
FROM AuditoriaInventario
WHERE accion = 'PRODUCTO_CREADO'
GROUP BY accion;
-- ==========
-- Hasta aqui
-- ==========
-- ===================
-- Ejecutar desde aqui
-- ===================
-- Mostramos todos los productos que fueron creados durante la demostracion
-- Usamos la fecha de auditoria
SELECT 
    p.id_producto,
    p.nombre,
    p.precio_unitario,
    c.nombre as categoria,
    ai.fecha as fecha_registro_auditoria
FROM Producto p
INNER JOIN Categoria c ON p.id_categoria = c.id_categoria
INNER JOIN AuditoriaInventario ai ON p.id_producto = ai.id_producto
WHERE ai.accion = 'PRODUCTO_CREADO'
AND ai.fecha >= DATEADD(HOUR, -1, GETDATE())  -- Productos de la ultima hora
ORDER BY ai.fecha DESC;
-- ==========
-- Hasta aqui
-- ==========

-- =====================================
-- DEMOSTRACI�N 2: TR_CalcularTotalVenta
-- =====================================
-- ===================
-- Ejecutar desde aqui
-- =================== 
PRINT '=== DEMOSTRACION 3: TR_CalcularTotalVenta ===';
-- 1. Creamos una venta nueva
BEGIN TRY
    BEGIN TRANSACTION;
    
    PRINT '1. Creando venta de prueba...';
    INSERT INTO Venta (fecha_venta, total, metodo_pago, id_empleado, id_cliente, id_sucursal)
    VALUES (GETDATE(), 0, 'Mixto', 3, 3, 2);
    
    DECLARE @venta_calculo INT = SCOPE_IDENTITY();
    
    -- 2. Agregamos primer detalle
    PRINT '2. Agregando primer producto...';
    INSERT INTO DetalleVenta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@venta_calculo, 4, 2, 2.5);  -- 2 Detergentes
    
    SELECT 'Despues del primer producto:' as Info;
    SELECT id_venta, total FROM Venta WHERE id_venta = @venta_calculo;
    
    -- 3. Agregamos segundo detalle
    PRINT '3. Agregando segundo producto...';
    INSERT INTO DetalleVenta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@venta_calculo, 5, 1, 5.0);  -- 1 Pollo Entero
    
    SELECT 'Despues del segundo producto:' as Info;
    SELECT id_venta, total FROM Venta WHERE id_venta = @venta_calculo;
    
    -- 4. Actualizamos la cantidad de un producto
    PRINT '4. Actualizando cantidad...';
    UPDATE DetalleVenta 
    SET cantidad = 3 
    WHERE id_venta = @venta_calculo AND id_producto = 4;
    
    SELECT 'Despues de actualizar cantidad:' as Info;
    SELECT id_venta, total FROM Venta WHERE id_venta = @venta_calculo;
    
    -- 5. Eliminamos un producto
    PRINT '5. Eliminando un producto...';
    DELETE FROM DetalleVenta 
    WHERE id_venta = @venta_calculo AND id_producto = 5;
    
    SELECT 'Despues de eliminar producto:' as Info;
    SELECT id_venta, total FROM Venta WHERE id_venta = @venta_calculo;
    
    COMMIT TRANSACTION;
    
    -- 6. Mostramos detalles finales
    SELECT '6. Detalles finales de la venta:' as Info;
    SELECT 
        p.nombre as Producto,
        dv.cantidad,
        dv.precio_unitario as Precio,
        dv.subtotal
    FROM DetalleVenta dv
    INNER JOIN Producto p ON dv.id_producto = p.id_producto
    WHERE dv.id_venta = @venta_calculo;
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;
GO
-- ==========
-- Hasta aqui
-- ========== 
-- =====================================
-- DEMOSTRACI�N 3: TR_ControlStockMinimo
-- =====================================
-- ===================
-- Ejecutar desde aqui
-- ===================
PRINT '=== DEMOSTRACION 4: TR_ControlStockMinimo ===';
-- 1. Estado actual de productos cercanos al stock minimo
SELECT '1. Productos cercanos al stock minimo:' as Info;
SELECT 
    p.nombre as Producto,
    s.nombre as Sucursal,
    i.stock_actual,
    i.stock_minimo,
    (i.stock_actual - i.stock_minimo) as Diferencia,
    CASE 
        WHEN i.stock_actual <= i.stock_minimo THEN 'URGENTE'
        WHEN i.stock_actual <= i.stock_minimo + 5 THEN 'ALERTA'
        ELSE 'NORMAL'
    END as Estado
FROM Inventario i
INNER JOIN Producto p ON i.id_producto = p.id_producto
INNER JOIN Sucursal s ON i.id_sucursal = s.id_sucursal
WHERE i.stock_actual <= i.stock_minimo + 10  -- Mostrar los mas criticos
ORDER BY Diferencia ASC;
-- ==========
-- Hasta aqui
-- ==========
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 2. Probamos las alertas de stock bajo
PRINT '2. Simulando situaciones de stock bajo...';
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Producto 7 en sucursal 1 (Manzanas) - Stock actual: 26, Minimo: 10
    -- Reducir a 8 (por debajo del m�nimo)
    UPDATE Inventario 
    SET stock_actual = 8,
        ultima_actualizacion = GETDATE()
    WHERE id_sucursal = 1 AND id_producto = 7;
    
    PRINT '   Producto 7 actualizado a stock critico';
    
    -- Producto 2 en sucursal 1 (Jugo de Naranja) - Stock actual: 34, Minimo: 10  
    -- Reducir a 12 (cerca del minimo)
    UPDATE Inventario 
    SET stock_actual = 12,
        ultima_actualizacion = GETDATE()
    WHERE id_sucursal = 1 AND id_producto = 2;
    
    PRINT '    Producto 2 actualizado a stock bajo';
    
    -- Producto 5 en sucursal 3 (Pollo) - Stock actual: 90, Minimo: 10
    -- Reducir a 5 (muy por debajo del m�nimo)
    UPDATE Inventario 
    SET stock_actual = 5,
        ultima_actualizacion = GETDATE()
    WHERE id_sucursal = 3 AND id_producto = 5;
    
    PRINT '   Producto 5 actualizado a stock critico';
    
    COMMIT TRANSACTION;
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;
-- ==========
-- Hasta aqui
-- ==========
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 3. Verificamos las alertas generadas en auditoria
SELECT '3. Alertas generadas automaticamente:' as Info;
SELECT 
    p.nombre as Producto,
    s.nombre as Sucursal,
    ai.accion,
    ai.stock_anterior as Stock_M�nimo,
    ai.stock_nuevo as Stock_Actual,
    ai.cantidad as Diferencia,
    ai.fecha,
    ai.usuario_responsable
FROM AuditoriaInventario ai
INNER JOIN Producto p ON ai.id_producto = p.id_producto
INNER JOIN Sucursal s ON ai.id_sucursal = s.id_sucursal
WHERE ai.accion = 'ALERTA_STOCK_BAJO'
AND ai.fecha >= DATEADD(MINUTE, -5, GETDATE())
ORDER BY ai.fecha DESC;
-- ==========
-- Hasta aqui
-- ==========
-- ===================
-- Ejecutar desde aqui
-- ===================
-- 4. Resumen de productos que necesitan atencion
SELECT '4. Resumen - Productos que necesitan reabastecimiento:' as Info;
SELECT 
    p.nombre as Producto,
    s.nombre as Sucursal,
    i.stock_actual,
    i.stock_minimo,
    CASE 
        WHEN i.stock_actual <= i.stock_minimo THEN 'URGENTE'
        WHEN i.stock_actual <= i.stock_minimo + 5 THEN 'ALERTA' 
        ELSE 'NORMAL'
    END as Prioridad,
    CASE 
        WHEN i.stock_actual <= i.stock_minimo THEN i.stock_minimo - i.stock_actual + 20
        WHEN i.stock_actual <= i.stock_minimo + 5 THEN (i.stock_minimo + 10) - i.stock_actual
        ELSE 0
    END as 'Cantidad a Comprar'
FROM Inventario i
INNER JOIN Producto p ON i.id_producto = p.id_producto
INNER JOIN Sucursal s ON i.id_sucursal = s.id_sucursal
WHERE i.stock_actual <= i.stock_minimo + 5
ORDER BY Prioridad, i.stock_actual ASC;
GO
-- ==========
-- Hasta aqui
-- ==========
-- ==============================
-- FIN DEL BLOQUE DE DISPARADORES
-- ==============================
