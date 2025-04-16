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

-- Rename DateServiced columns to new names
-- 1. First create new columns
ALTER TABLE FireExtinguishers
ADD DateSentService DATETIME NULL;

-- 2. Copy data from old columns to new ones
UPDATE FireExtinguishers
SET DateSentService = DateServiced;

-- 3. Drop old columns
ALTER TABLE FireExtinguishers
DROP COLUMN DateServiced;

-- 1. For ServiceReminders, rename the column and add a new one
-- First add new column
ALTER TABLE ServiceReminders
ADD DateCompleteService DATETIME NULL;

-- 2. Copy data from old column to new one
UPDATE ServiceReminders
SET DateCompleteService = DateServiced;

-- 3. Drop old DateServiced column
ALTER TABLE ServiceReminders
DROP COLUMN DateServiced;

-- 4. Update index
DROP INDEX IX_ServiceReminders_ReminderDate ON ServiceReminders;

CREATE INDEX IX_ServiceReminders_ReminderDate 
ON ServiceReminders(ReminderDate, ReminderSent);