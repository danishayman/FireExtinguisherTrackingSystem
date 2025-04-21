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
-- First drop the default constraint
DECLARE @constraintName NVARCHAR(128)
SELECT @constraintName = name 
FROM sys.default_constraints 
WHERE parent_object_id = OBJECT_ID('ServiceReminders')
AND parent_column_id = (
    SELECT column_id 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('ServiceReminders')
    AND name = 'DateCreated'
)

IF @constraintName IS NOT NULL
    EXEC('ALTER TABLE ServiceReminders DROP CONSTRAINT ' + @constraintName)

-- Then drop the column
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

//AREACODE
ALTER TABLE FireExtinguishers
ADD AreaCode varchar(20);

-- Create ActivityLogs table for tracking user activities
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivityLogs]'))
BEGIN
    CREATE TABLE [dbo].[ActivityLogs] (
        [LogID] INT IDENTITY(1,1) PRIMARY KEY,
        [UserID] INT NOT NULL,
        [Action] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [EntityType] NVARCHAR(50) NULL, -- Type of entity acted upon (e.g., FireExtinguisher, User, Plant)
        [EntityID] NVARCHAR(50) NULL,   -- ID of the entity acted upon
        [IPAddress] NVARCHAR(50) NULL,
        [Timestamp] DATETIME DEFAULT GETDATE(),
        FOREIGN KEY ([UserID]) REFERENCES [Users]([UserID])
    );
END
GO

-- Create index for efficient querying of activity logs
CREATE INDEX IX_ActivityLogs_UserID ON ActivityLogs(UserID);
CREATE INDEX IX_ActivityLogs_Timestamp ON ActivityLogs(Timestamp);
CREATE INDEX IX_ActivityLogs_EntityType_EntityID ON ActivityLogs(EntityType, EntityID);
GO