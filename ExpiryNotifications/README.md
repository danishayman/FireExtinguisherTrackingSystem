# Fire Extinguisher Tracking System - Notification Service

This console application sends automated email notifications for fire extinguishers that are expiring soon and service follow-up reminders.

## Features

1. **Expiry Notifications**:
   - Sends notifications for extinguishers expiring in 31-60 days (weekly on Mondays)
   - Sends notifications for extinguishers expiring in 0-30 days (daily)

2. **Service Follow-up Reminders**:
   - Sends reminders 7 days after a fire extinguisher has been serviced
   - Prompts PIC to verify proper service completion with the vendor

## Configuration

Configuration is stored in the `App.config` file:

```xml
<configuration>
  <appSettings>
    <add key="EmailRecipient" value="irfandanishnoorazlin@gmail.com" />
  </appSettings>
  <connectionStrings>
    <add name="FETSConnection" connectionString="Data Source=localhost;Initial Catalog=FETS;User ID=irfandanish;Password=1234;Connection Timeout=30" providerName="System.Data.SqlClient" />
  </connectionStrings>
  <system.net>
    <mailSettings>
      <smtp from="sender@example.com">
        <network host="smtp.gmail.com" port="587" userName="youremail@gmail.com" password="your-app-password" enableSsl="true" />
      </smtp>
    </mailSettings>
  </system.net>
</configuration>
```

## Usage

### Running Manually

```
ExpiryNotifications.exe
```

### Testing Mode

Run with test data instead of accessing the database:

```
ExpiryNotifications.exe --test
```

Test specific scenarios:

```
ExpiryNotifications.exe --test --scenario two-months
ExpiryNotifications.exe --test --scenario one-month
ExpiryNotifications.exe --test --scenario critical
```

## Scheduling as a Task

### Windows Task Scheduler Setup

1. Open Task Scheduler
2. Click "Create Basic Task"
3. Name: "Fire Extinguisher Notifications"
4. Description: "Sends notifications for expiring fire extinguishers and service follow-ups"
5. Trigger: Daily at 8:00 AM
6. Action: Start a Program
7. Program/script: Browse to the ExpiryNotifications.exe location
8. Finish

### Best Practices

- Ensure the application can access the database from the scheduled task context
- Verify email settings are correctly configured
- Run the task manually with --test flag to verify it works before scheduling

## Database Changes

The application looks for a `ServiceReminders` table to track reminders:

```sql
CREATE TABLE ServiceReminders (
    ReminderID INT IDENTITY(1,1) PRIMARY KEY,
    FEID INT NOT NULL,
    DateServiced DATETIME NOT NULL,
    ReminderDate DATETIME NOT NULL,
    ReminderSent BIT DEFAULT 0,
    DateCreated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FEID) REFERENCES FireExtinguishers(FEID)
);
```

If this table is not found, the application will fall back to using the `DateServiced` column in the `FireExtinguishers` table.

## Service Follow-up Process

1. When a fire extinguisher service is completed, the PIC enters a new expiry date
2. The system records the service date and schedules a reminder for 7 days later
3. After 7 days, the notification service sends a follow-up email
4. The PIC should verify with the vendor that service was properly completed
5. Any issues found should be reported to the vendor immediately

## Dependencies

- .NET Framework 4.8
- MailKit 4.11.0 (for email functionality)
- MimeKit 4.11.0
- SQL Server database connection

## Security Notes

- Updated MimeKit from 3.1.0 to 4.11.0 to address a known high severity vulnerability (GHSA-gmc6-fwg3-75m5)
- Updated MailKit to 4.11.0 for compatibility with the newer MimeKit version
- Last security update: March 20, 2025
