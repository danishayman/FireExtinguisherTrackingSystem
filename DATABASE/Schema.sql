-- Create the database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'FETS')
BEGIN
    CREATE DATABASE FETS;
END
GO

USE FETS;
GO

-- Drop existing tables if they exist
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FireExtinguishers]'))
    DROP TABLE [dbo].[FireExtinguishers];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MapImages]'))
    DROP TABLE [dbo].[MapImages];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Levels]'))
    DROP TABLE [dbo].[Levels];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Plants]'))
    DROP TABLE [dbo].[Plants];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Status]'))
    DROP TABLE [dbo].[Status];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FireExtinguisherTypes]'))
    DROP TABLE [dbo].[FireExtinguisherTypes];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]'))
    DROP TABLE [dbo].[Users];
GO

-- Create Users table
CREATE TABLE [dbo].[Users] (
    [UserID] INT IDENTITY(1,1) PRIMARY KEY,
    [Username] NVARCHAR(50) NOT NULL UNIQUE,
    [PasswordHash] VARBINARY(256) NOT NULL,
    [Role] NVARCHAR(20) NOT NULL
);
GO

-- Create Plants table
CREATE TABLE [dbo].[Plants] (
    [PlantID] INT IDENTITY(1,1) PRIMARY KEY,
    [PlantName] NVARCHAR(100) NOT NULL
);
GO

-- Create Levels table
CREATE TABLE [dbo].[Levels] (
    [LevelID] INT IDENTITY(1,1) PRIMARY KEY,
    [PlantID] INT NOT NULL,
    [LevelName] NVARCHAR(50) NOT NULL,
    FOREIGN KEY ([PlantID]) REFERENCES [Plants]([PlantID])
);
GO

-- Create Status table
CREATE TABLE [dbo].[Status] (
    [StatusID] INT IDENTITY(1,1) PRIMARY KEY,
    [StatusName] NVARCHAR(50) NOT NULL,
    [ColorCode] NVARCHAR(7) NOT NULL -- Hex color code
);
GO

-- Create FireExtinguisherTypes table
CREATE TABLE [dbo].[FireExtinguisherTypes] (
    [TypeID] INT IDENTITY(1,1) PRIMARY KEY,
    [TypeName] NVARCHAR(50) NOT NULL
);
GO

-- Create FireExtinguishers table
CREATE TABLE [dbo].[FireExtinguishers] (
    [FEID] INT IDENTITY(1,1) PRIMARY KEY,
    [SerialNumber] NVARCHAR(50) NOT NULL UNIQUE,
    [PlantID] INT NOT NULL,
    [LevelID] INT NOT NULL,
    [Location] NVARCHAR(200) NOT NULL,
    [TypeID] INT NOT NULL,
    [DateExpired] DATE NOT NULL,
    [Remarks] NVARCHAR(500),
    [StatusID] INT NOT NULL,
    FOREIGN KEY ([PlantID]) REFERENCES [Plants]([PlantID]),
    FOREIGN KEY ([LevelID]) REFERENCES [Levels]([LevelID]),
    FOREIGN KEY ([TypeID]) REFERENCES [FireExtinguisherTypes]([TypeID]),
    FOREIGN KEY ([StatusID]) REFERENCES [Status]([StatusID])
);
GO

-- Create MapImages table
CREATE TABLE [dbo].[MapImages] (
    [MapID] INT IDENTITY(1,1) PRIMARY KEY,
    [PlantID] INT NOT NULL,
    [LevelID] INT NOT NULL,
    [ImagePath] NVARCHAR(500) NOT NULL,
    [UploadDate] DATETIME DEFAULT GETDATE(),
    FOREIGN KEY ([PlantID]) REFERENCES [Plants]([PlantID]),
    FOREIGN KEY ([LevelID]) REFERENCES [Levels]([LevelID])
);
GO

-- Insert default admin user (password: admin123)
INSERT INTO [Users] ([Username], [PasswordHash], [Role])
VALUES (N'admin', HASHBYTES('SHA2_256', N'admin123'), N'Administrator');
GO

-- Insert all required statuses
INSERT INTO [Status] ([StatusName], [ColorCode])
VALUES 
    (N'Active', N'#28a745'),      -- Green for active
    (N'Expiring Soon', N'#ffc107'), -- Yellow for expiring soon
    (N'Expired', N'#dc3545'),     -- Red for expired
    (N'Under Service', N'#17a2b8'); -- Blue for under service
GO

-- Insert default fire extinguisher types
INSERT INTO [FireExtinguisherTypes] ([TypeName])
VALUES
    (N'ABC'),
    (N'CO2');
GO

-- Insert sample plants
INSERT INTO [Plants] ([PlantName])
VALUES
    (N'Plant 1'),
    (N'Plant 3'),
    (N'Plant 5'),
    (N'Plant 13'),
    (N'Plant 21'),
    (N'Plant 34'),
    (N'Plant 55');
GO

-- Insert sample levels for each plant
INSERT INTO [Levels] ([PlantID], [LevelName])
SELECT p.PlantID, n.LevelName
FROM [Plants] p
CROSS APPLY (
    VALUES 
        (N'Level 1'),
        (N'Level 2'),
        (N'Level 3')
) n(LevelName)
WHERE p.PlantName IN (N'Plant 1', N'Plant 3', N'Plant 5', N'Plant 13')
UNION ALL
SELECT p.PlantID, n.LevelName
FROM [Plants] p
CROSS APPLY (
    VALUES 
        (N'Level 1'),
        (N'Level 2')
) n(LevelName)
WHERE p.PlantName = N'Plant 21'
UNION ALL
SELECT p.PlantID, n.LevelName
FROM [Plants] p
CROSS APPLY (
    VALUES 
        (N'Level 1'),
        (N'Level 2'),
        (N'Level 3'),
        (N'Level 4'),
        (N'Level 5'),
        (N'Level 6'),
        (N'Level 7')
) n(LevelName)
WHERE p.PlantName = N'Plant 34'
UNION ALL
SELECT p.PlantID, n.LevelName
FROM [Plants] p
CROSS APPLY (
    VALUES 
        (N'Level 1'),
        (N'Level 2'),
        (N'Level 3'),
        (N'Level 4'),
        (N'Level 5')
) n(LevelName)
WHERE p.PlantName = N'Plant 55';
GO 









ALTER TABLE [FETS].[dbo].[FireExtinguishers] ADD Replacement NVARCHAR(50)