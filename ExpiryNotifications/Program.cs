using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using MimeKit;
using MailKit.Net.Smtp;
using MailKit.Security;
using System.Web;

namespace FETS.ExpiryNotifications
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("Fire Extinguisher Expiry Notification System");
            Console.WriteLine("===========================================");
            Console.WriteLine($"Starting check at {DateTime.Now}");

            // enter test mode
            bool testMode = args.Contains("--test");
            string testScenario = null;
            
            if (testMode)
            {
                Console.WriteLine("RUNNING IN TEST MODE");
                
                int scenarioIndex = Array.IndexOf(args, "--scenario");
                if (scenarioIndex >= 0 && scenarioIndex < args.Length - 1)
                {
                    testScenario = args[scenarioIndex + 1];
                    Console.WriteLine($"Test scenario: {testScenario}");
                }
                else
                {
                    Console.WriteLine("No specific test scenario specified. Will test all scenarios.");
                }
            }

            try
            {
                
                string connectionString;
                try {
                    connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                }
                catch (Exception ex) {
                    Console.WriteLine($"ERROR: Connection string 'FETSConnection' not found in App.config: {ex.Message}");
                    Console.WriteLine("Attempting to use hardcoded connection string as fallback...");
                    
                    // Fallback connection string - should match the one in App.config
                    //log will show that fallback connection is used
                    connectionString = "Data Source=localhost;Initial Catalog=FETS;User ID=danishaiman;Password=12345;Connection Timeout=30";
                    Console.WriteLine("Using fallback connection string. Please verify App.config is properly configured.");
                }

                // TEST
                if (testMode && testScenario?.ToLower() == "service") 
                {
                    Console.WriteLine("Testing service reminder feature...");
                    await SendServiceReminders(connectionString, true);
                    Console.WriteLine("Service reminder test completed");
                    return;
                }

                // Check for pending service reminders
                Console.WriteLine("Checking for service follow-up reminders...");
                await SendServiceReminders(connectionString, testMode);

                // Check for fire extinguishers nearing expiry
                List<FireExtinguisher> expiringExtinguishers;
                
                if (testMode)
                {
                    // Use test data instead of database query
                    expiringExtinguishers = GetTestFireExtinguishers(testScenario);
                }
                else
                {
                    expiringExtinguishers = GetExpiringFireExtinguishers(connectionString);
                }
                
                Console.WriteLine($"Found {expiringExtinguishers.Count} fire extinguishers nearing expiry");

                
                if (testMode)
                {
                    
                    await SendTestExpiryNotifications(expiringExtinguishers, testScenario);
                }
                else
                {
                    await SendExpiryNotifications(expiringExtinguishers);
                }

                Console.WriteLine("Expiry notification process completed successfully");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR: {ex.Message}");
                Console.WriteLine(ex.StackTrace);
            }
            
            if (testMode)
            {
                Console.WriteLine("\nPress any key to exit...");
                Console.ReadKey();
            }
        }

        private static List<FireExtinguisher> GetTestFireExtinguishers(string scenario)
        {
            List<FireExtinguisher> testExtinguishers = new List<FireExtinguisher>();
            
            switch (scenario?.ToLower())
            {
                case "service":
                    
                    Console.WriteLine("Service reminder scenario selected - will test service reminder functionality");
                    return new List<FireExtinguisher>();
                
                case "two-months":
                    // Test fire extinguishers expiring in 1-2 months
                    for (int i = 31; i <= 60; i += 10)
                    {
                        testExtinguishers.Add(new FireExtinguisher
                        {
                            FEID = 1000 + i,
                            SerialNumber = $"TEST-{i}",
                            PlantName = "Test Plant",
                            LevelName = "Test Level",
                            Location = $"Test Location {i}",
                            TypeName = "Test Type",
                            DateExpired = DateTime.Now.AddDays(i),
                            StatusName = "Active",
                            DaysUntilExpiry = i
                        });
                    }
                    break;
                    
                case "one-month":
                    // Test fire extinguishers expiring in less than a month
                    for (int i = 1; i <= 30; i += 5)
                    {
                        testExtinguishers.Add(new FireExtinguisher
                        {
                            FEID = 2000 + i,
                            SerialNumber = $"TEST-{i}",
                            PlantName = "Test Plant",
                            LevelName = "Test Level",
                            Location = $"Test Location {i}",
                            TypeName = "Test Type",
                            DateExpired = DateTime.Now.AddDays(i),
                            StatusName = "Active",
                            DaysUntilExpiry = i
                        });
                    }
                    break;
                    
                case "critical":
                    // Test fire extinguishers expiring very soon (within a week)
                    for (int i = 1; i <= 7; i++)
                    {
                        testExtinguishers.Add(new FireExtinguisher
                        {
                            FEID = 3000 + i,
                            SerialNumber = $"TEST-CRITICAL-{i}",
                            PlantName = "Test Plant",
                            LevelName = "Test Level",
                            Location = $"Critical Location {i}",
                            TypeName = "Test Type",
                            DateExpired = DateTime.Now.AddDays(i),
                            StatusName = "Active",
                            DaysUntilExpiry = i
                        });
                    }
                    break;
                    
                default:
                    // Default: ALL
                    for (int i = 45; i <= 60; i += 15)
                    {
                        testExtinguishers.Add(new FireExtinguisher
                        {
                            FEID = 1000 + i,
                            SerialNumber = $"TEST-2M-{i}",
                            PlantName = "Test Plant",
                            LevelName = "Test Level",
                            Location = $"Test Location {i}",
                            TypeName = "Test Type",
                            DateExpired = DateTime.Now.AddDays(i),
                            StatusName = "Active",
                            DaysUntilExpiry = i
                        });
                    }
                
                    for (int i = 15; i <= 30; i += 15)
                    {
                        testExtinguishers.Add(new FireExtinguisher
                        {
                            FEID = 2000 + i,
                            SerialNumber = $"TEST-1M-{i}",
                            PlantName = "Test Plant",
                            LevelName = "Test Level",
                            Location = $"Test Location {i}",
                            TypeName = "Test Type",
                            DateExpired = DateTime.Now.AddDays(i),
                            StatusName = "Active",
                            DaysUntilExpiry = i
                        });
                    }
                    
                    for (int i = 1; i <= 7; i += 2)
                    {
                        testExtinguishers.Add(new FireExtinguisher
                        {
                            FEID = 3000 + i,
                            SerialNumber = $"TEST-CRIT-{i}",
                            PlantName = "Test Plant",
                            LevelName = "Test Level",
                            Location = $"Critical Location {i}",
                            TypeName = "Test Type",
                            DateExpired = DateTime.Now.AddDays(i),
                            StatusName = "Active",
                            DaysUntilExpiry = i
                        });
                    }
                    break;
            }
            
            return testExtinguishers;
        }

        private static List<FireExtinguisher> GetExpiringFireExtinguishers(string connectionString)
        {
            List<FireExtinguisher> expiringExtinguishers = new List<FireExtinguisher>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        fe.FEID, 
                        fe.SerialNumber, 
                        p.PlantName, 
                        l.LevelName, 
                        fe.Location, 
                        t.TypeName, 
                        fe.DateExpired, 
                        s.StatusName,
                        DATEDIFF(day, GETDATE(), fe.DateExpired) AS DaysUntilExpiry
                    FROM FireExtinguishers fe
                    INNER JOIN Plants p ON fe.PlantID = p.PlantID
                    INNER JOIN Levels l ON fe.LevelID = l.LevelID
                    INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                    INNER JOIN Status s ON fe.StatusID = s.StatusID
                    WHERE 
                        (s.StatusName = 'Active' OR s.StatusName = 'Expiring Soon') AND
                        fe.DateExpired >= GETDATE() AND
                        fe.DateExpired <= DATEADD(day, 60, GETDATE())
                    ORDER BY DaysUntilExpiry ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            expiringExtinguishers.Add(new FireExtinguisher
                            {
                                FEID = Convert.ToInt32(reader["FEID"]),
                                SerialNumber = reader["SerialNumber"].ToString(),
                                PlantName = reader["PlantName"].ToString(),
                                LevelName = reader["LevelName"].ToString(),
                                Location = reader["Location"].ToString(),
                                TypeName = reader["TypeName"].ToString(),
                                DateExpired = Convert.ToDateTime(reader["DateExpired"]),
                                StatusName = reader["StatusName"].ToString(),
                                DaysUntilExpiry = Convert.ToInt32(reader["DaysUntilExpiry"])
                            });
                        }
                    }
                }
            }

            return expiringExtinguishers;
        }

        private static async Task SendTestExpiryNotifications(List<FireExtinguisher> expiringExtinguishers, string scenario)
        {
            if (expiringExtinguishers.Count == 0)
            {
                Console.WriteLine("No fire extinguishers to test notifications for");
                return;
            }

            
            var twoMonthsNotifications = expiringExtinguishers.Where(fe => fe.DaysUntilExpiry > 30 && fe.DaysUntilExpiry <= 60).ToList();
            var oneMonthNotifications = expiringExtinguishers.Where(fe => fe.DaysUntilExpiry > 0 && fe.DaysUntilExpiry <= 30).ToList();

            // In test mode, NO day check
            if ((twoMonthsNotifications.Any() && (scenario == null || scenario.ToLower() == "two-months" || scenario.ToLower() == "all")))
            {
                Console.WriteLine("Testing two-month notification scenario...");
                await SendEmailNotification(twoMonthsNotifications, "[TEST] Fire Extinguishers Expiring in Two Months");
                Console.WriteLine($"Sent test notification for {twoMonthsNotifications.Count} fire extinguishers expiring in 1-2 months");
            }

            if ((oneMonthNotifications.Any() && (scenario == null || scenario.ToLower() == "one-month" || scenario.ToLower() == "critical" || scenario.ToLower() == "all")))
            {
                Console.WriteLine("Testing one-month notification scenario...");
                await SendEmailNotification(oneMonthNotifications, "[TEST] URGENT: Fire Extinguishers Expiring Soon");
                Console.WriteLine($"Sent test notification for {oneMonthNotifications.Count} fire extinguishers expiring in less than a month");
            }
        }

        private static async Task SendExpiryNotifications(List<FireExtinguisher> expiringExtinguishers)
        {
            if (expiringExtinguishers.Count == 0)
            {
                Console.WriteLine("No fire extinguishers need notification at this time");
                return;
            }

            
            var twoMonthsNotifications = expiringExtinguishers.Where(fe => fe.DaysUntilExpiry > 30 && fe.DaysUntilExpiry <= 60).ToList();
            var oneMonthNotifications = expiringExtinguishers.Where(fe => fe.DaysUntilExpiry > 0 && fe.DaysUntilExpiry <= 30).ToList();

            // Send notifications for two months (send once a week)
            if (twoMonthsNotifications.Any() && DateTime.Now.DayOfWeek == DayOfWeek.Monday)
            {
                await SendEmailNotification(twoMonthsNotifications, "Fire Extinguishers Expiring in Two Months");
                Console.WriteLine($"Sent weekly notification for {twoMonthsNotifications.Count} fire extinguishers expiring in 1-2 months");
            }

            // Send notifications for one month (send daily)
            if (oneMonthNotifications.Any())
            {
                await SendEmailNotification(oneMonthNotifications, "URGENT: Fire Extinguishers Expiring Soon");
                Console.WriteLine($"Sent daily notification for {oneMonthNotifications.Count} fire extinguishers expiring in less than a month");
            }
        }

        private static async Task SendEmailNotification(List<FireExtinguisher> fireExtinguishers, string subject)
        {
            try
            {
                var connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                var smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as System.Net.Configuration.SmtpSection;
                if (smtpSection == null)
                {
                    throw new ConfigurationErrorsException("SMTP configuration not found in App.config");
                }

                var message = new MimeMessage();
                message.From.Add(new MailboxAddress("Fire Extinguisher Tracking System", smtpSection.From));
                
                // Get recipients from the db
                List<EmailRecipient> recipients = GetEmailRecipients(connectionString, "Expiry", "All");
                
                if (recipients.Count == 0)
                {
                    Console.WriteLine("No active recipients found for email notifications. Using fallback recipient.");
                    message.To.Add(new MailboxAddress("", "danishaiman3b@gmail.com")); // Fallback recipient
                }
                else
                {
                    foreach (var recipient in recipients)
                    {
                        message.To.Add(new MailboxAddress(recipient.RecipientName, recipient.EmailAddress));
                    }
                }
                
                message.Subject = subject;

                List<FireExtinguisherExpiryInfo> expiryInfoList = fireExtinguishers.Select(fe => new FireExtinguisherExpiryInfo
                {
                    SerialNumber = fe.SerialNumber,
                    Plant = fe.PlantName,
                    Level = fe.LevelName,
                    Location = fe.Location,
                    ExpiryDate = fe.DateExpired,
                    Remarks = fe.StatusName
                }).ToList();

                string body;
                if (expiryInfoList.Count == 1)
                {
                    var fe = expiryInfoList[0];
                    body = GenerateExpiryEmailTemplate(
                        fe.SerialNumber,
                        fe.Plant,
                        fe.Level,
                        fe.Location,
                        fe.ExpiryDate,
                        fe.Remarks,
                        subject
                    );
                }
                else
                {
                    body = GenerateMultipleExpiryEmailTemplate(expiryInfoList);
                }

                var bodyBuilder = new BodyBuilder { HtmlBody = body };
                message.Body = bodyBuilder.ToMessageBody();

                using (var client = new SmtpClient())
                {
                    await client.ConnectAsync(smtpSection.Network.Host, smtpSection.Network.Port,
                        smtpSection.Network.EnableSsl ? SecureSocketOptions.StartTls : SecureSocketOptions.Auto);

                    if (!string.IsNullOrEmpty(smtpSection.Network.UserName))
                    {
                        await client.AuthenticateAsync(smtpSection.Network.UserName, smtpSection.Network.Password);
                    }

                    await client.SendAsync(message);
                    await client.DisconnectAsync(true);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to send email notification: {ex.Message}");
                throw;
            }
        }

        //FETCH EMAIL TEMPLATE
        private static string GenerateExpiryEmailTemplate(
            string serialNumber,
            string plant,
            string level,
            string location,
            DateTime expiryDate,
            string remarks = null,
            string notificationType = "Expiry Notification")
        {
            
            string templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EmailTemplates", "ExpiryEmailTemplate.html");
            
            
            string template = File.ReadAllText(templatePath);
            
            
            TimeSpan timeUntilExpiry = expiryDate - DateTime.Now;
            int daysUntilExpiry = (int)timeUntilExpiry.TotalDays;
            
            
            string severityClass = "info";
            string expiryStatus = "will expire soon";
            
            if (daysUntilExpiry <= 0)
            {
                severityClass = "critical";
                expiryStatus = "has expired";
                daysUntilExpiry = 0; 
            }
            else if (daysUntilExpiry <= 30)
            {
                severityClass = "warning";
                expiryStatus = "will expire within 30 days";
            }
            else
            {
                expiryStatus = $"will expire in {daysUntilExpiry} days";
            }
            
            
            string remarksRow = string.IsNullOrEmpty(remarks) 
                ? string.Empty 
                : $@"<tr>
                        <th>Remarks</th>
                        <td>{remarks}</td>
                    </tr>";
            
            
            template = template.Replace("{SerialNumber}", serialNumber)
                               .Replace("{Plant}", plant)
                               .Replace("{Level}", level)
                               .Replace("{Location}", location)
                               .Replace("{ExpiryDate}", expiryDate.ToString("MMMM dd, yyyy"))
                               .Replace("{DaysUntilExpiry}", daysUntilExpiry.ToString())
                               .Replace("{SeverityClass}", severityClass)
                               .Replace("{ExpiryStatus}", expiryStatus)
                               .Replace("{RemarksRow}", remarksRow)
                               .Replace("{NotificationType}", notificationType)
                               .Replace("{SystemUrl}", "https://yourcompany.com/FETS")
                               .Replace("{CurrentYear}", DateTime.Now.Year.ToString())
                               .Replace("{CompanyName}", "INARI AMERTRON BHD.");
            
            return template;
        }

        private static string GenerateMultipleExpiryEmailTemplate(List<FireExtinguisherExpiryInfo> extinguishers)
        {
            
            string templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EmailTemplates", "ExpiryEmailTemplate.html");
            
            
            string template = File.ReadAllText(templatePath);
            
            int minDaysUntilExpiry = int.MaxValue;
            foreach (var extinguisher in extinguishers)
            {
                TimeSpan timeUntilExpiry = extinguisher.ExpiryDate - DateTime.Now;
                int daysUntilExpiry = (int)timeUntilExpiry.TotalDays;
                if (daysUntilExpiry < minDaysUntilExpiry)
                {
                    minDaysUntilExpiry = daysUntilExpiry;
                }
            }
            
            string notificationType = "Multiple Extinguishers Expiry Alert";
            if (minDaysUntilExpiry <= 0)
            {
                notificationType = "CRITICAL: Expired Extinguishers";
            }
            else if (minDaysUntilExpiry <= 30)
            {
                notificationType = "URGENT: Extinguishers Expiring Soon";
            }
            
            System.Text.StringBuilder tableContent = new System.Text.StringBuilder();
            tableContent.Append(@"
                <table>
                    <thead>
                        <tr>
                            <th>Serial Number</th>
                            <th>Plant</th>
                            <th>Level</th>
                            <th>Location</th>
                            <th>Expiry Date</th>
                            <th>Days Left</th>
                        </tr>
                    </thead>
                    <tbody>");
            
            foreach (var extinguisher in extinguishers)
            {
                TimeSpan timeUntilExpiry = extinguisher.ExpiryDate - DateTime.Now;
                int daysUntilExpiry = (int)timeUntilExpiry.TotalDays;
                if (daysUntilExpiry < 0) daysUntilExpiry = 0; // Don't show negative days
                
                string rowClass = "info";
                if (daysUntilExpiry <= 0)
                {
                    rowClass = "critical";
                }
                else if (daysUntilExpiry <= 30)
                {
                    rowClass = "warning";
                }
                
                tableContent.Append($@"
                        <tr class='{rowClass}'>
                            <td>{extinguisher.SerialNumber}</td>
                            <td>{extinguisher.Plant}</td>
                            <td>{extinguisher.Level}</td>
                            <td>{extinguisher.Location}</td>
                            <td>{extinguisher.ExpiryDate.ToString("MMM dd, yyyy")}</td>
                            <td>{daysUntilExpiry}</td>
                        </tr>");
            }
            
            tableContent.Append(@"
                    </tbody>
                </table>");
            
            string modifiedTemplate = template
                .Replace(@"<div class=""countdown"">
                <span class=""countdown-number"">{DaysUntilExpiry}</span>
                <span>days until expiry</span>
            </div>", "")
                .Replace(@"<h2>Fire Extinguisher Details:</h2>
            
            <table>
                <tr>
                    <th>Serial Number</th>
                    <td>{SerialNumber}</td>
                </tr>
                <tr>
                    <th>Plant</th>
                    <td>{Plant}</td>
                </tr>
                <tr>
                    <th>Level</th>
                    <td>{Level}</td>
                </tr>
                <tr>
                    <th>Location</th>
                    <td>{Location}</td>
                </tr>
                <tr>
                    <th>Expiry Date</th>
                    <td class=""{SeverityClass}"">{ExpiryDate}</td>
                </tr>
                {RemarksRow}
            </table>", $"<h2>Fire Extinguishers Expiry Details:</h2>\n{tableContent}")
                .Replace("<p>This is an <strong>important notification</strong> regarding a fire extinguisher that {ExpiryStatus}. Please take immediate action to ensure continued fire safety compliance.</p>", 
                         $"<p>This is an <strong>important notification</strong> regarding {extinguishers.Count} fire extinguishers that require attention. Please take immediate action to ensure continued fire safety compliance.</p>")
                .Replace("{NotificationType}", notificationType)
                .Replace("{SystemUrl}", "https://yourcompany.com/FETS")
                .Replace("{CurrentYear}", DateTime.Now.Year.ToString())
                .Replace("{CompanyName}", "INARI AMERTRON BHD.");
            
            return modifiedTemplate;
        }

        private static async Task SendServiceReminders(string connectionString, bool testMode)
        {
            try
            {

                List<ServiceReminderInfo> serviceReminders = GetPendingServiceReminders(connectionString, testMode);
                
                if (serviceReminders.Count == 0)
                {
                    Console.WriteLine("No service follow-up reminders are due today.");
                    return;
                }
                
                Console.WriteLine($"Found {serviceReminders.Count} fire extinguisher(s) that need service follow-up reminders");
                
                await SendServiceReminderEmail(serviceReminders);
                
                UpdateReminderStatus(connectionString, serviceReminders);
                
                Console.WriteLine("Service reminder emails have been sent");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending service reminders: {ex.Message}");
                throw;
            }
        }
        
        // Gets a list of fire extinguishers that need service follow-up reminders
        private static List<ServiceReminderInfo> GetPendingServiceReminders(string connectionString, bool testMode)
        {
            List<ServiceReminderInfo> reminders = new List<ServiceReminderInfo>();
            
            // For test mode, create test data
            if (testMode)
            {
                // Create 2 test reminders
                reminders.Add(new ServiceReminderInfo
                {
                    FEID = 1001,
                    SerialNumber = "TEST-SR-001",
                    Plant = "Test Plant",
                    Level = "Test Level",
                    Location = "Test Location 1",
                    ServiceDate = DateTime.Now.AddDays(-7),
                    ExpiryDate = DateTime.Now.AddYears(1),
                    ReminderID = 1
                });
                
                reminders.Add(new ServiceReminderInfo
                {
                    FEID = 1002,
                    SerialNumber = "TEST-SR-002",
                    Plant = "Test Plant",
                    Level = "Test Level",
                    Location = "Test Location 2",
                    ServiceDate = DateTime.Now.AddDays(-7),
                    ExpiryDate = DateTime.Now.AddYears(1),
                    ReminderID = 2
                });
                
                return reminders;
            }
            
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                try
                {
                    foreach (var reminder in reminders.Where(r => r.ReminderID > 0))
                    {
                        string updateQuery = "UPDATE ServiceReminders SET ReminderSent = 1 WHERE ReminderID = @ReminderID";
                        
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@ReminderID", reminder.ReminderID);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                catch (SqlException)
                {

                    Console.WriteLine("Note: Could not update ServiceReminders table status. This is expected if using the fallback method.");
                }
                
                try
                {
                    string query = @"
                        SELECT 
                            sr.ReminderID,
                            sr.FEID, 
                            fe.SerialNumber,
                            p.PlantName,
                            l.LevelName,
                            fe.Location,
                            sr.DateServiced,
                            fe.DateExpired
                        FROM ServiceReminders sr
                        INNER JOIN FireExtinguishers fe ON sr.FEID = fe.FEID
                        INNER JOIN Plants p ON fe.PlantID = p.PlantID
                        INNER JOIN Levels l ON fe.LevelID = l.LevelID
                        WHERE 
                            sr.ReminderDate <= GETDATE() AND
                            sr.ReminderSent = 0
                        ORDER BY sr.DateServiced ASC";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                reminders.Add(new ServiceReminderInfo
                                {
                                    ReminderID = reader.GetInt32(reader.GetOrdinal("ReminderID")),
                                    FEID = reader.GetInt32(reader.GetOrdinal("FEID")),
                                    SerialNumber = reader.GetString(reader.GetOrdinal("SerialNumber")),
                                    Plant = reader.GetString(reader.GetOrdinal("PlantName")),
                                    Level = reader.GetString(reader.GetOrdinal("LevelName")),
                                    Location = reader.GetString(reader.GetOrdinal("Location")),
                                    ServiceDate = reader.GetDateTime(reader.GetOrdinal("DateServiced")),
                                    ExpiryDate = reader.GetDateTime(reader.GetOrdinal("DateExpired"))
                                });
                            }
                        }
                    }
                }
                catch (SqlException)
                {
                    // If the ServiceReminders table doesn't exist or other SQL error, fall back to directly checking DateServiced
                    Console.WriteLine("ServiceReminders table query failed. Falling back to direct DateServiced check.");
                    
                    string fallbackQuery = @"
                        SELECT 
                            fe.FEID,
                            fe.SerialNumber,
                            p.PlantName,
                            l.LevelName,
                            fe.Location,
                            fe.DateServiced,
                            fe.DateExpired
                        FROM FireExtinguishers fe
                        INNER JOIN Plants p ON fe.PlantID = p.PlantID
                        INNER JOIN Levels l ON fe.LevelID = l.LevelID
                        WHERE 
                            fe.DateServiced IS NOT NULL AND
                            DATEDIFF(day, fe.DateServiced, GETDATE()) = 7
                        ORDER BY fe.DateServiced ASC";
                    
                    using (SqlCommand cmd = new SqlCommand(fallbackQuery, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                reminders.Add(new ServiceReminderInfo
                                {
                                    FEID = reader.GetInt32(reader.GetOrdinal("FEID")),
                                    SerialNumber = reader.GetString(reader.GetOrdinal("SerialNumber")),
                                    Plant = reader.GetString(reader.GetOrdinal("PlantName")),
                                    Level = reader.GetString(reader.GetOrdinal("LevelName")),
                                    Location = reader.GetString(reader.GetOrdinal("Location")),
                                    ServiceDate = reader.GetDateTime(reader.GetOrdinal("DateServiced")),
                                    ExpiryDate = reader.GetDateTime(reader.GetOrdinal("DateExpired"))
                                });
                            }
                        }
                    }
                }
            }
            
            return reminders;
        }
        
        private static void UpdateReminderStatus(string connectionString, List<ServiceReminderInfo> reminders)
        {
            if (reminders.Count == 0) return;
            
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                try
                {
                    foreach (var reminder in reminders.Where(r => r.ReminderID > 0))
                    {
                        string updateQuery = "UPDATE ServiceReminders SET ReminderSent = 1 WHERE ReminderID = @ReminderID";
                        
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@ReminderID", reminder.ReminderID);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                catch (SqlException)
                {
                    Console.WriteLine("Note: Could not update ServiceReminders table status. This is expected if using the fallback method.");
                }
            }
        }
        
        // Sends a reminder email for fire extinguishers that were serviced 7 days ago
        private static async Task SendServiceReminderEmail(List<ServiceReminderInfo> reminders)
        {
            if (reminders.Count == 0) return;
            
            try
            {
                var connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                var smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as System.Net.Configuration.SmtpSection;
                if (smtpSection == null)
                {
                    throw new ConfigurationErrorsException("SMTP configuration not found in App.config");
                }
                
                var message = new MimeMessage();
                message.From.Add(new MailboxAddress("Fire Extinguisher Tracking System", smtpSection.From));
                
                List<EmailRecipient> recipients = GetEmailRecipients(connectionString, "Service", "All");
                
                if (recipients.Count == 0)
                {
                    Console.WriteLine("No active recipients found for service reminders. Using fallback recipient.");
                    message.To.Add(new MailboxAddress("", "danishaiman3b@gmail.com")); // Fallback recipient
                }
                else
                {
                    foreach (var recipient in recipients)
                    {
                        message.To.Add(new MailboxAddress(recipient.RecipientName, recipient.EmailAddress));
                    }
                }
                
                message.Subject = "Fire Extinguisher Service Follow-up Reminder";
                
                string body;
                if (reminders.Count == 1)
                {
                    body = GenerateServiceReminderEmail(reminders[0]);
                }
                else
                {
                    body = GenerateMultipleServiceReminderEmail(reminders);
                }
                
                var bodyBuilder = new BodyBuilder { HtmlBody = body };
                message.Body = bodyBuilder.ToMessageBody();
                
                using (var client = new SmtpClient())
                {
                    await client.ConnectAsync(smtpSection.Network.Host, smtpSection.Network.Port,
                        smtpSection.Network.EnableSsl ? SecureSocketOptions.StartTls : SecureSocketOptions.Auto);
                    
                    if (!string.IsNullOrEmpty(smtpSection.Network.UserName))
                    {
                        await client.AuthenticateAsync(smtpSection.Network.UserName, smtpSection.Network.Password);
                    }
                    
                    await client.SendAsync(message);
                    await client.DisconnectAsync(true);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to send service reminder email: {ex.Message}");
                throw;
            }
        }
        
        // Generates an HTML email body for a single extinguisher service reminder
        private static string GenerateServiceReminderEmail(ServiceReminderInfo reminder)
        {
            try
            {
                string templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EmailTemplates", "ServiceReminderTemplate.html");
                
                if (!File.Exists(templatePath))
                {
                    Console.WriteLine($"Warning: Service reminder template not found at {templatePath}");
                    return CreateFallbackServiceReminderEmail(reminder);
                }
                
                string template = File.ReadAllText(templatePath);
                
                template = template.Replace("{{SerialNumber}}", reminder.SerialNumber);
                template = template.Replace("{{Plant}}", reminder.Plant);
                template = template.Replace("{{Level}}", reminder.Level);
                template = template.Replace("{{Location}}", reminder.Location);
                template = template.Replace("{{ServiceDate}}", reminder.ServiceDate.ToString("MMM dd, yyyy"));
                template = template.Replace("{{ExpiryDate}}", reminder.ExpiryDate.ToString("MMM dd, yyyy"));
                template = template.Replace("{{GenerationDate}}", DateTime.Now.ToString("MMM dd, yyyy HH:mm"));
                
                template = template.Replace("data-display=\"{{TableStyle}}\"", "style=\"display: none;\"");
                template = template.Replace("{{TableRows}}", ""); // Empty as we're not showing the table
                
                return template;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error generating service reminder email: {ex.Message}");
                return CreateFallbackServiceReminderEmail(reminder);
            }
        }
        
        
        // FALLBACK TEMPLATE IF TEMPLATE IS NOT AVAILABLE/ACCESSIBLE
        
        private static string CreateFallbackServiceReminderEmail(ServiceReminderInfo reminder)
        {
            return $@"
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        h2 {{ color: #e74c3c; }}
                        .details {{ background-color: #f9f9f9; padding: 15px; margin: 15px 0; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <h2>Fire Extinguisher Service Follow-up Reminder</h2>
                        <p>This is a reminder to follow up with your vendor regarding the recently serviced fire extinguisher.</p>
                        
                        <div class='details'>
                            <p><strong>Serial Number:</strong> {reminder.SerialNumber}</p>
                            <p><strong>Location:</strong> {reminder.Plant}, {reminder.Level}, {reminder.Location}</p>
                            <p><strong>Service Date:</strong> {reminder.ServiceDate.ToString("MMM dd, yyyy")}</p>
                            <p><strong>New Expiry Date:</strong> {reminder.ExpiryDate.ToString("MMM dd, yyyy")}</p>
                        </div>
                        
                        <p>Please ensure that the service was performed correctly and all documentation has been received.</p>
                        
                        <p>Generated on {DateTime.Now.ToString("MMM dd, yyyy HH:mm")}</p>
                    </div>
                </body>
                </html>";
        }
        
        private static string GenerateMultipleServiceReminderEmail(List<ServiceReminderInfo> reminders)
        {
            try 
            {
                string templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EmailTemplates", "ServiceReminderTemplate.html");
                
                if (!File.Exists(templatePath))
                {
                    Console.WriteLine($"Warning: Service reminder template not found at {templatePath}");
                    return CreateFallbackMultipleServiceReminderEmail(reminders);
                }
                
                string template = File.ReadAllText(templatePath);
                
                template = template.Replace("<div class=\"extinguisher-details\">", "<div class=\"extinguisher-details\" style=\"display: none;\">");
                
                template = template.Replace("data-display=\"{{TableStyle}}\"", "style=\"\"");
                
                string tableRows = "";
                foreach (var reminder in reminders)
                {
                    tableRows += $@"
                        <tr>
                            <td>{reminder.SerialNumber}</td>
                            <td>{reminder.Plant}, {reminder.Level}, {reminder.Location}</td>
                            <td>{reminder.ServiceDate.ToString("MMM dd, yyyy")}</td>
                            <td>{reminder.ExpiryDate.ToString("MMM dd, yyyy")}</td>
                        </tr>";
                }
                
                template = template.Replace("{{TableRows}}", tableRows);
                template = template.Replace("{{GenerationDate}}", DateTime.Now.ToString("MMM dd, yyyy HH:mm"));
                
                template = template.Replace("{{SerialNumber}}", "");
                template = template.Replace("{{Plant}}", "");
                template = template.Replace("{{Level}}", "");
                template = template.Replace("{{Location}}", "");
                template = template.Replace("{{ServiceDate}}", "");
                template = template.Replace("{{ExpiryDate}}", "");
                
                return template;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error generating multiple service reminder email: {ex.Message}");
                return CreateFallbackMultipleServiceReminderEmail(reminders);
            }
        }
        
        //NO TEMPLATE++MULTIPLE
        private static string CreateFallbackMultipleServiceReminderEmail(List<ServiceReminderInfo> reminders)
        {
            string tableRows = "";
            foreach (var reminder in reminders)
            {
                tableRows += $@"
                    <tr>
                        <td>{reminder.SerialNumber}</td>
                        <td>{reminder.Plant}, {reminder.Level}, {reminder.Location}</td>
                        <td>{reminder.ServiceDate.ToString("MMM dd, yyyy")}</td>
                        <td>{reminder.ExpiryDate.ToString("MMM dd, yyyy")}</td>
                    </tr>";
            }
            
            return $@"
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        h2 {{ color: #e74c3c; }}
                        table {{ width: 100%; border-collapse: collapse; margin: 20px 0; }}
                        table, th, td {{ border: 1px solid #ddd; }}
                        th, td {{ padding: 10px; text-align: left; }}
                        th {{ background-color: #f2f2f2; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <h2>Fire Extinguisher Service Follow-up Reminders</h2>
                        <p>This is a reminder to follow up with your vendor regarding recently serviced fire extinguishers.</p>
                        
                        <table>
                            <thead>
                                <tr>
                                    <th>Serial Number</th>
                                    <th>Location</th>
                                    <th>Service Date</th>
                                    <th>New Expiry Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                {tableRows}
                            </tbody>
                        </table>
                        
                        <p>Please ensure that the service was performed correctly and all documentation has been received.</p>
                        
                        <p>Generated on {DateTime.Now.ToString("MMM dd, yyyy HH:mm")}</p>
                    </div>
                </body>
                </html>";
        }

        private static List<EmailRecipient> GetEmailRecipients(string connectionString, string notificationType, string fallbackType = null)
        {
            List<EmailRecipient> recipients = new List<EmailRecipient>();
            
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    
                    bool tableExists = false;
                    string checkTableQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EmailRecipients'";
                    using (SqlCommand checkCmd = new SqlCommand(checkTableQuery, conn))
                    {
                        int tableCount = (int)checkCmd.ExecuteScalar();
                        tableExists = (tableCount > 0);
                    }
                    
                    if (!tableExists)
                    {
                        Console.WriteLine("EmailRecipients table does not exist. Using fallback recipient.");
                        return recipients; 
                    }
                    
                    string query = @"
                        SELECT EmailAddress, RecipientName, NotificationType 
                        FROM EmailRecipients 
                        WHERE IsActive = 1 AND (NotificationType = @NotificationType OR NotificationType = 'All'";
                    
                    if (!string.IsNullOrEmpty(fallbackType) && fallbackType != notificationType)
                    {
                        query += " OR NotificationType = @FallbackType";
                    }
                    
                    query += ") ORDER BY RecipientName";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@NotificationType", notificationType);
                        if (!string.IsNullOrEmpty(fallbackType) && fallbackType != notificationType)
                        {
                            cmd.Parameters.AddWithValue("@FallbackType", fallbackType);
                        }
                        
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                recipients.Add(new EmailRecipient
                                {
                                    EmailAddress = reader["EmailAddress"].ToString(),
                                    RecipientName = reader["RecipientName"].ToString(),
                                    NotificationType = reader["NotificationType"].ToString()
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error retrieving email recipients: {ex.Message}");
            }
            
            return recipients;
        }
    }

    public class FireExtinguisher
    {
        public int FEID { get; set; }
        public string SerialNumber { get; set; }
        public string PlantName { get; set; }
        public string LevelName { get; set; }
        public string Location { get; set; }
        public string TypeName { get; set; }
        public DateTime DateExpired { get; set; }
        public string StatusName { get; set; }
        public int DaysUntilExpiry { get; set; }
    }

    public class FireExtinguisherExpiryInfo
    {
        public string SerialNumber { get; set; }
        public string Plant { get; set; }
        public string Level { get; set; }
        public string Location { get; set; }
        public DateTime ExpiryDate { get; set; }
        public string Remarks { get; set; }
    }

    public class ServiceReminderInfo
    {
        public int FEID { get; set; }
        public string SerialNumber { get; set; }
        public string Plant { get; set; }
        public string Level { get; set; }
        public string Location { get; set; }
        public DateTime ServiceDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public int ReminderID { get; set; }
    }

    public class EmailRecipient
    {
        public string EmailAddress { get; set; }
        public string RecipientName { get; set; }
        public string NotificationType { get; set; }
    }
}
