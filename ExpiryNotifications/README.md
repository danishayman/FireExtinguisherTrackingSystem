# Fire Extinguisher Expiry Notification System

This console application checks for fire extinguishers that are nearing their expiry dates and sends email notifications based on the following schedule:

- **Two months before expiry**: Send one email per week (on Mondays)
- **One month before expiry**: Send one email every day

## Setup Instructions

### 1. Build the Application

1. Open the solution in Visual Studio
2. Right-click on the ExpiryNotifications project and select "Build"
3. The compiled executable will be in the `bin\Debug` or `bin\Release` folder

### 2. Configure Windows Task Scheduler

To run the application automatically every day:

1. Open Windows Task Scheduler (search for "Task Scheduler" in the Start menu)
2. Click "Create Basic Task..."
3. Enter a name (e.g., "Fire Extinguisher Expiry Check") and description
4. Select "Daily" for the trigger
5. Choose a start time (recommended: early morning, e.g., 7:00 AM)
6. Select "Start a program" for the action
7. Browse to the location of the compiled executable (`ExpiryNotifications.exe`)
8. Complete the wizard

### 3. Configuration Settings

Before running the application, you need to configure the following settings in the `App.config` file:

1. **Database Connection String**: Update the `FETSConnection` connection string with your SQL Server details
   ```xml
   <connectionStrings>
     <add name="FETSConnection" connectionString="Data Source=localhost\SQLEXPRESS;Initial Catalog=FireExtinguisherTrackingSystem;Integrated Security=True" providerName="System.Data.SqlClient" />
   </connectionStrings>
   ```

2. **Email Settings**: Update the SMTP settings with your email provider details
   ```xml
   <system.net>
     <mailSettings>
       <smtp from="fireextinguisher@example.com">
         <network host="smtp.gmail.com" port="587" userName="your-email@gmail.com" password="your-app-password" enableSsl="true" />
       </smtp>
     </mailSettings>
   </system.net>
   ```

3. **Email Recipient**: Update the email recipient in the appSettings section
   ```xml
   <appSettings>
     <add key="EmailRecipient" value="your-email@example.com" />
   </appSettings>
   ```

## Testing the Application

The application includes a test mode that allows you to simulate different expiry scenarios without waiting for actual days to pass. Use the following command-line arguments:

```
ExpiryNotifications.exe --test [--scenario SCENARIO_NAME]
```

Available test scenarios:

- `two-months`: Tests notifications for fire extinguishers expiring in 1-2 months
- `one-month`: Tests notifications for fire extinguishers expiring within a month
- `critical`: Tests notifications for fire extinguishers expiring within a week
- If no scenario is specified, it will test all scenarios

Examples:

```
# Test all scenarios
ExpiryNotifications.exe --test

# Test only the two-months scenario
ExpiryNotifications.exe --test --scenario two-months

# Test only the critical scenario
ExpiryNotifications.exe --test --scenario critical
```

When running in test mode:
- The application uses mock data instead of querying the database
- Email notifications are sent regardless of the day of week
- Subject lines are prefixed with "[TEST]" to distinguish test emails
- The console window will stay open until you press a key

## Troubleshooting

If you encounter issues with the notification system:

1. Check the Windows Event Viewer for any error logs
2. Verify that the SMTP settings in App.config are correct
3. Ensure the application has access to the database
4. Check that the fire extinguisher data in the database is up to date

## Dependencies

- .NET Framework 4.8
- MailKit 4.11.0 (for email functionality)
- MimeKit 4.11.0
- SQL Server database connection

## Security Notes

- Updated MimeKit from 3.1.0 to 4.11.0 to address a known high severity vulnerability (GHSA-gmc6-fwg3-75m5)
- Updated MailKit to 4.11.0 for compatibility with the newer MimeKit version
- Last security update: March 20, 2025
