-- Crea la base de datos del proyecto si aún no existe.
USE [master];
GO

IF DB_ID(N'Aethel_Capital_Bank') IS NULL
BEGIN
    CREATE DATABASE [Aethel_Capital_Bank];
END;
GO