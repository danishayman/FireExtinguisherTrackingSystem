# Fire Extinguisher Tracking System - Service Reminder Feature

## New Feature: Service Follow-up Reminders

This update adds functionality to send reminder emails 7 days after a fire extinguisher has been serviced. This ensures proper follow-up with vendors regarding service quality and documentation.

## Installation Steps

### 1. Database Updates

Run the database update script to add the required tables and columns:

```
setup_service_reminders.bat
```

This script will:
- Add a `DateServiced` column to the `FireExtinguishers` table
- Create a new `ServiceReminders` table
- Add necessary indexes for performance

### 2. Application Files

The following files have been updated or added:

- `Pages/ViewSection/ViewSection.aspx.cs` - Updated to record service dates and create reminders
- `ExpiryNotifications/Program.cs` - Added service reminder functionality
- `ExpiryNotifications/EmailTemplates/ServiceReminderTemplate.html` - Template for reminder emails

### 3. Testing the New Feature

To test the service reminder functionality:

1. Complete a service for a fire extinguisher in the system 
   (Set a new expiry date for a fire extinguisher under service)

2. Run the notification service in test mode:
   ```
   ExpiryNotifications.exe --test --scenario service
   ```

3. Check that you receive a service reminder email

### 4. Scheduling the Service

Ensure the ExpiryNotifications service is scheduled to run daily using Windows Task Scheduler.

## Documentation

For more detailed information, see the following files:

- `ServiceReminderImplementation.md` - Technical details of the implementation
- `ExpiryNotifications/README.md` - Complete guide to the notification service
- `DB_Updates.sql` - SQL statements used to update the database

## Support

If you encounter any issues with this new feature, please contact the system administrator. 