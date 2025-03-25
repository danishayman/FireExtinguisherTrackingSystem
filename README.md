# 🧯 Fire Extinguisher Tracking System (FETS)

## 📖 About
The Fire Extinguisher Tracking System (FETS) is a comprehensive web-based solution designed to manage and monitor fire extinguishers across facilities. This system helps organizations maintain safety compliance by tracking inspections, services, and sending timely notifications.

## ✨ Features & Modules

### Core Features
- 🔍 Fire Extinguisher Management
  - Track location and status
  - Monitor expiry dates

- 📅 Service Management
  - Schedule maintenance
  - Track service dates
  - Vendor management
  - Service quality follow-ups

- 📧 Automated Notifications
  - Expiry reminders
  - Service follow-up reminders (7 days post-service)
  - Email notifications to person in charge
  - Custom email templates


## 🛠️ Technology Stack
- **Framework**: ASP.NET Web Forms (.NET Framework 4.8)
- **Database**: Microsoft SQL Server
- **Email Service**: MailKit 4.11.0
- **Security**: BouncyCastle Cryptography 2.5.1
- **Frontend**: HTML, CSS, JavaScript
- **Additional Libraries**:
  - MimeKit 4.11.0
  - System.Memory 4.6.2
  - System.Threading.Tasks.Extensions 4.6.2

## 📋 Requirements
- Windows Server/Windows 10
- .NET Framework 4.8
- SQL Server 2019 or later
- IIS 7.0 or later
- SMTP server access for email notifications

## 🚀 Installation & Setup

### 1. Database Setup
```batch
# Run the database setup script
setup_service_reminders.bat
```

### 2. Environment Configuration
Create a `.env` file with the following configurations:
```env
# Database Configuration
DB_SERVER=your_server
DB_NAME=FETS
DB_USERNAME=your_username
DB_PASSWORD=your_password

# Email Configuration
SMTP_HOST=your_smtp_host
SMTP_PORT=587
SMTP_USERNAME=your_email
SMTP_PASSWORD=your_password
SMTP_ENABLE_SSL=true
```

### 3. Application Setup
1. Clone the repository
2. Open `FireExtinguisherTrackingSystem.sln` in Visual Studio
3. Restore NuGet packages
4. Build the solution
5. Deploy to IIS

### 4. Service Configuration
- Configure Windows Task Scheduler for daily notifications
- Set up the ExpiryNotifications service
- Configure email templates in `EmailTemplates` directory

## 🧪 Testing
1. Complete a service entry for a fire extinguisher
2. Run test notification:
```batch
ExpiryNotifications.exe --test --scenario service
```
3. Verify email notifications

## 📁 Project Structure
```
📦 FireExtinguisherTrackingSystem

├─ App_Code
│  └─ EmailTemplateManager.cs
├─ Assets
│  └─ css
│     └─ styles.css
├─ DB_Updates.sql
Default.aspx
├─ Default.aspx.cs
├─ Default.aspx.designer.cs
EmailTemplates
│  ├─ ExpiryEmailTemplate.html
│  └─ ServiceEmailTemplate.html
├─ ExpiryNotifications
│  ├─ App.config
EmailTemplates
│  │  ├─ ExpiryEmailTemplate.html
│  │  └─ ServiceReminderTemplate.html
│  ├─ ExpiryNotifications.csproj
│  ├─ Program.c
│  ├─ README.md
│  ├─ RunTests.bat
SetupScheduledTask.bat
│  ├─ TESTING.md
│  └─ packages.config
├─ FETS.csproj
FETS.csproj.user
FireExtinguisherTrackingSystem.sln
Pages
│  ├─ Dashboard
│  │  ├─ Dashboard.aspx
Dashboard.aspx.cs
│  │  └─ Dashboard.aspx.designer.cs
│  ├─ DataEntry
│  │  ├─ DataEntry.aspx
DataEntry.aspx.cs
│  │  └─ DataEntry.aspx.designer.cs
│  ├─ MapLayout
│  │  ├─ MapLayout.aspx
MapLayout.aspx.cs
MapLayout.aspx.designer.cs
ViewMap.aspx
ViewMap.aspx.cs
│  │  └─ ViewMap.aspx.designer.cs
│  ├─ Profile
│  │  ├─ Profile.aspx
Profile.aspx.cs
│  │  └─ Profile.aspx.designer.cs
│  └─ ViewSection
│     ├─ ViewSection.aspx
│     ├─ ViewSection.aspx.cs
│     └─ ViewSection.aspx.designer.│ 
├─ README.md
├─ ServiceReminderImplementation.md
├─ Site.Master
├─ Site.Master.cs
├─ Site.Master.designer.cs
├─ Uploads
│  └─ misc
│     ├─ front-gate.jpg
│     ├─ logo.jpeg
│     └─ warning.png
├─ Web.config
├─ packages.config
├─ packages
└─ setup_service_reminders.bat
```


## 🤝 Support
For technical support or feature requests, please contact the system administrator or create an issue in the project repository.