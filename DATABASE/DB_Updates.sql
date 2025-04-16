-- Add DateServiced column to FireExtinguishers table
ALTER TABLE FireExtinguishers
ADD DateServiced DATETIME NULL;

-- Create ServiceReminders table
CREATE TABLE ServiceReminders (
    ReminderID INT IDENTITY(1,1) PRIMARY KEY,
    FEID INT NOT NULL,
    DateServiced DATETIME NOT NULL,
    ReminderDate DATETIME NOT NULL,
    ReminderSent BIT DEFAULT 0,
    DateCreated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FEID) REFERENCES FireExtinguishers(FEID)
);

-- Create index for efficient querying
CREATE INDEX IX_ServiceReminders_ReminderDate 
ON ServiceReminders(ReminderDate, ReminderSent);

-- Drop the DateCreated column from ServiceReminders table
ALTER TABLE ServiceReminders
DROP COLUMN DateCreated;

-- First drop the Users table if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]'))
    DROP TABLE [dbo].[Users];
GO

-- Create Plants table first
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Plants]'))
BEGIN
    CREATE TABLE [dbo].[Plants] (
        [PlantID] INT IDENTITY(1,1) PRIMARY KEY,
        [PlantName] NVARCHAR(100) NOT NULL
    );
END
GO

-- Then create Users table with foreign key reference
CREATE TABLE [dbo].[Users] (
    [UserID] INT IDENTITY(1,1) PRIMARY KEY,
    [Username] NVARCHAR(50) NOT NULL UNIQUE,
    [PasswordHash] VARBINARY(256) NOT NULL,
    [Role] NVARCHAR(20) NOT NULL,
    [PlantID] INT NULL,
    FOREIGN KEY ([PlantID]) REFERENCES [Plants]([PlantID])
);
GO


INSERT INTO Users (Username, PasswordHash, Role, PlantID)
VALUES ('admin', HASHBYTES('SHA2_256', CONVERT(NVARCHAR(50), 'admin123')), 'Administrator', NULL);