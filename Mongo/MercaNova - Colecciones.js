// Crear base de datos MercaNova
use MercaNova

// Crear colección analisis_ventas_tiempo
db.createCollection("analisis_ventas_tiempo", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["timestamp", "sucursal_id", "ventas_totales", "transacciones"],
            properties: {
                _id: {
                    bsonType: "objectId"
                },
                cantidad_mas_vendido: {
                    bsonType: "int"
                },
                categoria_mas_vendida: {
                    bsonType: "string"
                },
                efectivo: {
                    bsonType: "int"
                },
                hora_pico: {
                    bsonType: "bool"
                },
                mixto: {
                    bsonType: "int"
                },
                periodo: {
                    bsonType: "string"
                },
                producto_mas_vendido: {
                    bsonType: "string"
                },
                productos_vendidos: {
                    bsonType: "int"
                },
                sucursal_id: {
                    bsonType: "int"
                },
                sucursal_nombre: {
                    bsonType: "string"
                },
                tarjeta: {
                    bsonType: "int"
                },
                tendencia: {
                    bsonType: "string"
                },
                ticket_promedio: {
                    bsonType: "double"
                },
                timestamp: {
                    bsonType: "date"
                },
                transacciones: {
                    bsonType: "int"
                },
                ventas_totales: {
                    bsonType: "double"
                }
            }
        }
    }
})

// Crear colección historial_comportamiento_clientes
db.createCollection("historial_comportamiento_clientes", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["cliente_id", "nombre_completo", "segmento"],
            properties: {
                _id: {
                    bsonType: "objectId"
                },
                categoria_principal: {
                    bsonType: "string"
                },
                cliente_id: {
                    bsonType: "int"
                },
                frecuencia_recompra: {
                    bsonType: "double"
                },
                frecuencia_visita: {
                    bsonType: "string"
                },
                horario_visita: {
                    bsonType: "string"
                },
                items_promedio: {
                    bsonType: "int"
                },
                metodo_pago_principal: {
                    bsonType: "string"
                },
                monto_promedio: {
                    bsonType: "double"
                },
                monto_total_vida: {
                    bsonType: ["double", "int", "string"]
                },
                nombre_completo: {
                    bsonType: "string"
                },
                producto_favorito: {
                    bsonType: "string"
                },
                producto_recurrente: {
                    bsonType: "string"
                },
                segmento: {
                    bsonType: "string"
                },
                sensibilidad_precio: {
                    bsonType: "string"
                },
                sucursal_preferida_id: {
                    bsonType: "int"
                },
                sucursal_preferida_nombre: {
                    bsonType: "string"
                },
                ticket_promedio: {
                    bsonType: "double"
                },
                timestamp_ultima_visita: {
                    bsonType: "date"
                },
                total_compras: {
                    bsonType: "int"
                }
            }
        }
    }
})

// Crear colección logs_comportamiento_inventario
db.createCollection("logs_comportamiento_inventario", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["producto_id", "sucursal_id", "timestamp", "tipo_evento"],
            properties: {
                _id: {
                    bsonType: "objectId"
                },
                criticidad: {
                    bsonType: "string"
                },
                dias_stock_actual: {
                    bsonType: ["int", "double", "string"]
                },
                patron_principal: {
                    bsonType: "string"
                },
                producto_id: {
                    bsonType: "int"
                },
                producto_nombre: {
                    bsonType: "string"
                },
                recomendacion_stock: {
                    bsonType: "string"
                },
                stock_actual: {
                    bsonType: "int"
                },
                stock_maximo: {
                    bsonType: "int"
                },
                stock_minimo: {
                    bsonType: "int"
                },
                sucursal_id: {
                    bsonType: "int"
                },
                sucursal_nombre: {
                    bsonType: "string"
                },
                tendencia: {
                    bsonType: "string"
                },
                timestamp: {
                    bsonType: "date"
                },
                tipo_evento: {
                    bsonType: "string"
                },
                velocidad_rotacion: {
                    bsonType: ["double", "int", "string"]
                },
                ventas_dia_anterior: {
                    bsonType: "int"
                },
                ventas_ultima_semana: {
                    bsonType: "int"
                }
            }
        }
    }
})