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

                // Build email body
                string body = $@"
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; }}
                        table {{ border-collapse: collapse; width: 100%; }}
                        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                        th {{ background-color: #f2f2f2; }}
                        .urgent {{ color: red; font-weight: bold; }}
                        .warning {{ color: orange; font-weight: bold; }}
                    </style>
                </head>
                <body>
                    <h2>Fire Extinguisher Expiry Notification</h2>
                    <p>The following fire extinguishers will expire soon and require attention:</p>
                    <table>
                        <tr>
                            <th>Serial Number</th>
                            <th>Plant</th>
                            <th>Level</th>
                            <th>Location</th>
                            <th>Type</th>
                            <th>Expiry Date</th>
                            <th>Days Until Expiry</th>
                        </tr>";

                foreach (var fe in fireExtinguishers)
                {
                    string rowClass = fe.DaysUntilExpiry <= 7 ? "urgent" : (fe.DaysUntilExpiry <= 30 ? "warning" : "");
                    body += $@"
                        <tr class='{rowClass}'>
                            <td>{fe.SerialNumber}</td>
                            <td>{fe.PlantName}</td>
                            <td>{fe.LevelName}</td>
                            <td>{fe.Location}</td>
                            <td>{fe.TypeName}</td>
                            <td>{fe.DateExpired:yyyy-MM-dd}</td>
                            <td>{fe.DaysUntilExpiry}</td>
                        </tr>";
                }

                body += @"
                    </table>
                    <p>Please take appropriate action to ensure these fire extinguishers are serviced before they expire.</p>
                </body>
                </html>";

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
}
