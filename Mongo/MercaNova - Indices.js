// Primero nos conectamos a la base de datos merchanovadb
use merchanovadb;

// INDICE 1: Para consultas de analytics por sucursal y fecha
db.analytics_ventas_tiempo_real.createIndex(
  { 
    "sucursal_id": 1, 
    "timestamp": -1 
  },
  { 
    name: "idx_analytics_sucursal_timestamp",
    background: true
  }
);

// INDICE 2: Para consultas de comportamiento de inventario
db.logs_comportamiento_inventario.createIndex(
  { 
    "producto_id": 1, 
    "sucursal_id": 1,
    "criticidad": 1,
    "timestamp": -1
  },
  { 
    name: "idx_inventario_producto_sucursal",
    background: true
  }
);

// Verificamos indices creados
db.analytics_ventas_tiempo_real.getIndexes();
db.logs_comportamiento_inventario.getIndexes();