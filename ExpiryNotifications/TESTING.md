# Testing the Fire Extinguisher Expiry Notification System

This guide explains how to test the notification system without waiting for actual days to pass.

## Quick Start

1. Build the solution in Visual Studio
2. Open a command prompt in the ExpiryNotifications folder
3. Run one of the following commands:

```
RunTests.bat all         # Test all scenarios
RunTests.bat two-months  # Test 1-2 month notifications
RunTests.bat one-month   # Test <1 month notifications
RunTests.bat critical    # Test notifications for critical cases (expiring within a week)
```

## What Happens During Testing

When running in test mode:

1. The application generates mock fire extinguisher data instead of querying the database
2. Email notifications are sent regardless of the day of week (normally weekly emails would only be sent on Mondays)
3. Subject lines are prefixed with "[TEST]" to distinguish test emails
4. The console window will display detailed information and stay open until you press a key

## Test Scenarios Explained

### Two-Months Scenario
- Tests fire extinguishers expiring in 31-60 days
- In normal operation, these would trigger weekly notifications (on Mondays)
- The test generates several mock fire extinguishers with expiry dates in this range

### One-Month Scenario
- Tests fire extinguishers expiring in 1-30 days
- In normal operation, these would trigger daily notifications
- The test generates several mock fire extinguishers with expiry dates in this range

### Critical Scenario
- Tests fire extinguishers expiring very soon (within 7 days)
- These are highest priority and would trigger daily notifications with urgent styling
- The test generates mock fire extinguishers with expiry dates in the next week

### All Scenarios
- Tests all of the above scenarios together
- Useful for verifying the complete notification system at once

## Verifying Test Results

After running a test:

1. Check your email inbox for the test notifications
2. Verify that the email content is formatted correctly
3. For the "critical" scenario, check that items expiring within 7 days are highlighted in red
4. For the "one-month" scenario, check that items expiring within 30 days are highlighted in orange

## Troubleshooting Test Issues

If you don't receive test emails:

1. Check that your SMTP settings in Web.config are correct
2. Verify that the email address in the code is correct
3. Check your spam/junk folder
4. Look at the console output for any error messages
