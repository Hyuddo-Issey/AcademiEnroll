create database AcademiEnroll

use AcademiEnroll

CREATE TABLE Usuarios (
    IdUsuario INT PRIMARY KEY IDENTITY,
	Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) NOT NULL,
    Clave NVARCHAR(100) NOT NULL,
    Rol NVARCHAR(50) NOT NULL
);

-- Insertar un administrador por defecto
INSERT INTO Usuarios (Correo,Nombre, Clave, Rol) 
VALUES ('admin@academienroll.com', 'Juan','admin123', 'Administrador');

CREATE TABLE Estudiantes (
    IdEstudiante INT PRIMARY KEY IDENTITY,
    Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) NOT NULL,
    IdUsuario INT FOREIGN KEY REFERENCES Usuarios(IdUsuario)
);


CREATE TABLE Docentes (
    IdDocente INT PRIMARY KEY IDENTITY,
    Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) NOT NULL,
    IdUsuario INT FOREIGN KEY REFERENCES Usuarios(IdUsuario)
);

SELECT * FROM Usuarios
SELECT * FROM Estudiantes