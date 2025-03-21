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