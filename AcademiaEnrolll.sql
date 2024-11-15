-- Crear la base de datos si no existe
IF DB_ID('AcademiEnroll') IS NULL
    CREATE DATABASE AcademiEnroll;
GO

-- Usar la base de datos
USE AcademiEnroll;
GO

-- Crear la tabla Usuarios si no existe
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE name = 'Usuarios' AND type = 'U'
)
BEGIN
    CREATE TABLE Usuarios (
        IdUsuario INT PRIMARY KEY IDENTITY,
        Nombre NVARCHAR(100) NOT NULL,    
        Correo NVARCHAR(100) NOT NULL UNIQUE,
        Clave NVARCHAR(50) NOT NULL,
        Rol NVARCHAR(20) NOT NULL CHECK (Rol IN ('Estudiante', 'Docente', 'Administrador'))
    );

    -- Insertar un administrador por defecto
    INSERT INTO Usuarios (Correo, Nombre, Clave, Rol) 
    VALUES ('admin@academienroll.com', 'Juan', 'admin123', 'Administrador');
END;
GO

-- Crear la tabla Estudiantes si no existe
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE name = 'Estudiantes' AND type = 'U'
)
BEGIN
    CREATE TABLE Estudiantes (
        IdEstudiante INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,    
        Correo NVARCHAR(100) NOT NULL UNIQUE,
        IdUsuario INT NOT NULL,
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
    );
END;
GO

-- Crear la tabla Docentes si no existe
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE name = 'Docentes' AND type = 'U'
)
BEGIN
    CREATE TABLE Docentes (
        IdDocente INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,
        Correo NVARCHAR(100) NOT NULL UNIQUE,
        IdUsuario INT NOT NULL,
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
    );
END;
GO

-- Crear la tabla Administradores si no existe
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE name = 'Administradores' AND type = 'U'
)
BEGIN
    CREATE TABLE Administradores (
        IdAdministrador INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,
        Correo NVARCHAR(100) NOT NULL UNIQUE,
        IdUsuario INT NOT NULL,
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
    );
END;
GO

-- Crear la tabla Inscripciones si no existe
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE name = 'Inscripciones' AND type = 'U'
)
BEGIN
    CREATE TABLE Inscripciones (
        CodInscripcion INT IDENTITY(1,1) PRIMARY KEY,
        IdEstudiante INT NOT NULL,
        NombreMateria NVARCHAR(50) NOT NULL,
        Horario NVARCHAR(50) NOT NULL,
        FOREIGN KEY (IdEstudiante) REFERENCES Estudiantes(IdEstudiante)
    );
END;
GO

-- Crear la tabla Asignaturas si no existe
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE name = 'Asignaturas' AND type = 'U'
)
BEGIN
    CREATE TABLE Asignaturas (
        IdAsignatura INT IDENTITY(1,1) PRIMARY KEY,
        Asignatura NVARCHAR(100) NOT NULL,
        Descripcion NVARCHAR(255) NOT NULL
    );
END;
GO

-- Crear la tabla Notas si no existe
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE name = 'Notas' AND type = 'U'
)
BEGIN
    CREATE TABLE Notas (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        NombreEstudiante NVARCHAR(100) NOT NULL,
        NombreAsignatura NVARCHAR(100) NOT NULL,
        Calificacion DECIMAL(5,2) NOT NULL
    );
END;
GO

-- Crear o actualizar el trigger InsertarAsignaturaDesdeInscripcion
CREATE OR ALTER TRIGGER InsertarAsignaturaDesdeInscripcion
ON Inscripciones
AFTER INSERT
AS
BEGIN
    INSERT INTO Asignaturas (Asignatura, Descripcion)
    SELECT NombreMateria, Horario
    FROM inserted;
END;
GO

-- Crear o actualizar el trigger trg_ValidarNota
CREATE OR ALTER TRIGGER trg_ValidarNota
ON Notas
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    -- Validar que las calificaciones estén entre 0 y 10
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE Calificacion < 0 OR Calificacion > 10
    )
    BEGIN
        RAISERROR('La calificación debe estar entre 0 y 10.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Realizar la inserción o actualización usando MERGE
    MERGE Notas AS target
    USING inserted AS source
    ON target.Id = source.Id
    WHEN MATCHED THEN
        UPDATE SET 
            target.NombreEstudiante = source.NombreEstudiante,
            target.NombreAsignatura = source.NombreAsignatura,
            target.Calificacion = source.Calificacion
    WHEN NOT MATCHED THEN
        INSERT (NombreEstudiante, NombreAsignatura, Calificacion)
        VALUES (source.NombreEstudiante, source.NombreAsignatura, source.Calificacion);
END;
GO

-- Crear o actualizar el procedimiento almacenado sp_AgregarNota
CREATE OR ALTER PROCEDURE sp_AgregarNota
    @NombreEstudiante NVARCHAR(100),
    @NombreAsignatura NVARCHAR(100),
    @Calificacion DECIMAL(5,2)
AS
BEGIN
    IF @Calificacion < 0 OR @Calificacion > 10
    BEGIN
        RAISERROR('La calificación debe estar entre 0 y 10.', 16, 1);
        RETURN;
    END
    INSERT INTO Notas (NombreEstudiante, NombreAsignatura, Calificacion)
    VALUES (@NombreEstudiante, @NombreAsignatura, @Calificacion);
END;
GO

-- Crear o actualizar el procedimiento almacenado SP_ActualizarNota
CREATE OR ALTER PROCEDURE SP_ActualizarNota
    @Id INT,
    @Calificacion DECIMAL(5,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar calificación
        IF @Calificacion < 0 OR @Calificacion > 10
        BEGIN
            RAISERROR('La calificación debe estar entre 0 y 10.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Verificar existencia del registro
        IF NOT EXISTS (SELECT 1 FROM Notas WHERE Id = @Id)
        BEGIN
            RAISERROR('No se encontró un registro con el Id proporcionado.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar la nota
        UPDATE Notas
        SET Calificacion = @Calificacion
        WHERE Id = @Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- Consultar registros de las tablas
SELECT * FROM Usuarios;
SELECT * FROM Estudiantes;
SELECT * FROM Docentes;
SELECT * FROM Administradores;
SELECT * FROM Notas;
GO
 