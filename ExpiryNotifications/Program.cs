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

            // Parse command line arguments for test mode
            bool testMode = args.Contains("--test");
            string testScenario = null;
            
            if (testMode)
            {
                Console.WriteLine("RUNNING IN TEST MODE");
                
                // Check for specific test scenario
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
                // Get connection string with better error handling
                string connectionString;
                try {
                    connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                }
                catch (Exception ex) {
                    Console.WriteLine($"ERROR: Connection string 'FETSConnection' not found in App.config: {ex.Message}");
                    Console.WriteLine("Attempting to use hardcoded connection string as fallback...");
                    
                    // Fallback connection string - should match the one in App.config
                    connectionString = "Data Source=localhost;Initial Catalog=FETS;User ID=irfandanish;Password=1234;Connection Timeout=30";
                    
                    // Log that we're using the fallback
                    Console.WriteLine("Using fallback connection string. Please verify App.config is properly configured.");
                }

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

                // Send notifications based on expiry timeline
                if (testMode)
                {
                    // In test mode, override day of week checks to ensure emails are sent
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
            
            // Create test data based on scenario
            switch (scenario?.ToLower())
            {
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
                    // Default: create a mix of all scenarios
                    // Two months range
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
                    
                    // One month range
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
                    
                    // Critical range (less than a week)
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
                        s.StatusName = 'Active' AND
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

            // Group fire extinguishers by notification frequency
            var twoMonthsNotifications = expiringExtinguishers.Where(fe => fe.DaysUntilExpiry > 30 && fe.DaysUntilExpiry <= 60).ToList();
            var oneMonthNotifications = expiringExtinguishers.Where(fe => fe.DaysUntilExpiry > 0 && fe.DaysUntilExpiry <= 30).ToList();

            // In test mode, we'll send emails regardless of the day of week
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

            // Group fire extinguishers by notification frequency
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
                message.To.Add(new MailboxAddress("", "irfandanishnoorazlin@gmail.com")); // Replace with actual recipient
                message.Subject = subject;

                // Convert to FireExtinguisherExpiryInfo objects for the template
                List<FireExtinguisherExpiryInfo> expiryInfoList = fireExtinguishers.Select(fe => new FireExtinguisherExpiryInfo
                {
                    SerialNumber = fe.SerialNumber,
                    Plant = fe.PlantName,
                    Level = fe.LevelName,
                    Location = fe.Location,
                    ExpiryDate = fe.DateExpired,
                    Remarks = fe.StatusName
                }).ToList();

                // Use the template manager to generate the email body
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

        /// <summary>
        /// Gets the expiry notification email template with placeholders replaced with actual data
        /// </summary>
        private static string GenerateExpiryEmailTemplate(
            string serialNumber,
            string plant,
            string level,
            string location,
            DateTime expiryDate,
            string remarks = null,
            string notificationType = "Expiry Notification")
        {
            // Path to the template file
            string templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EmailTemplates", "ExpiryEmailTemplate.html");
            
            // Read the template
            string template = File.ReadAllText(templatePath);
            
            // Calculate days until expiry
            TimeSpan timeUntilExpiry = expiryDate - DateTime.Now;
            int daysUntilExpiry = (int)timeUntilExpiry.TotalDays;
            
            // Determine severity class and expiry status text
            string severityClass = "info";
            string expiryStatus = "will expire soon";
            
            if (daysUntilExpiry <= 0)
            {
                severityClass = "critical";
                expiryStatus = "has expired";
                daysUntilExpiry = 0; // Don't show negative days
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
            
            // Generate remarks row if remarks exist
            string remarksRow = string.IsNullOrEmpty(remarks) 
                ? string.Empty 
                : $@"<tr>
                        <th>Remarks</th>
                        <td>{remarks}</td>
                    </tr>";
            
            // Replace placeholders with actual data
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

        /// <summary>
        /// Gets the expiry notification email template for multiple fire extinguishers
        /// </summary>
        private static string GenerateMultipleExpiryEmailTemplate(List<FireExtinguisherExpiryInfo> extinguishers)
        {
            // Path to the template file
            string templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EmailTemplates", "ExpiryEmailTemplate.html");
            
            // Read the template
            string template = File.ReadAllText(templatePath);
            
            // Determine the most critical expiry (for notification type)
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
            
            // Create the table rows for multiple extinguishers
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
            
            // Remove the countdown for multiple extinguishers
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

    /// <summary>
    /// Data class to hold fire extinguisher information for expiry emails
    /// </summary>
    public class FireExtinguisherExpiryInfo
    {
        public string SerialNumber { get; set; }
        public string Plant { get; set; }
        public string Level { get; set; }
        public string Location { get; set; }
        public DateTime ExpiryDate { get; set; }
        public string Remarks { get; set; }
    }
}
