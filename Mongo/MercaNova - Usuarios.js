// Conectarse como administrador
use admin;

// USUARIO 1: Usuario de solo lectura para reportes
db.createUser({
  user: "reportes_user",
  pwd: "Reportes2024!",
  roles: [
    {
      role: "read",
      db: "merchanovadb"
    }
  ],
  customData: {
    descripcion: "Usuario para consultas de reportes y analytics",
    creadoPor: "Administrador",
    fechaCreacion: new Date()
  }
});

// USUARIO 2: Usuario con permisos de lectura/escritura para la aplicación
db.createUser({
  user: "app_merchanova",
  pwd: "AppMerca2024!",
  roles: [
    {
      role: "readWrite",
      db: "merchanovadb"
    }
  ],
  customData: {
    descripcion: "Usuario para la aplicación principal de MercaNova",
    creadoPor: "Administrador", 
    fechaCreacion: new Date()
  }
});

// Verificar usuarios creados
db.getUsers();