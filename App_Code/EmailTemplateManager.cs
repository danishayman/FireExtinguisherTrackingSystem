using System;
using System.IO;
using System.Web;
using System.Collections.Generic;
using System.Text;

namespace FETS
{
    /// <summary>
    /// Manages email templates for the Fire Extinguisher Tracking System
    /// </summary>
    public static class EmailTemplateManager
    {
        /// <summary>
        /// Gets the service notification email template with placeholders replaced with actual data
        /// </summary>
        public static string GetServiceEmailTemplate(
            string serialNumber,
            string plant,
            string level,
            string location,
            string type,
            string remarks = null,
            DateTime? estimatedReturnDate = null)
        {
            // Path to the template file
            string templatePath = HttpContext.Current.Server.MapPath("~/EmailTemplates/ServiceEmailTemplate.html");
            
            // Read the template
            string template = File.ReadAllText(templatePath);
            
            // Generate remarks row if remarks exist
            string remarksRow = string.IsNullOrEmpty(remarks) 
                ? string.Empty 
                : "<tr>\r\n                        <th>Remarks</th>\r\n                        <td>" + remarks + "</td>\r\n                    </tr>";
            
            // Set default estimated return date if not provided (14 days from now)
            DateTime returnDate = estimatedReturnDate ?? DateTime.Now.AddDays(14);
            
            // Replace placeholders with actual data
            template = template.Replace("{SerialNumber}", serialNumber)
                               .Replace("{Plant}", plant)
                               .Replace("{Level}", level)
                               .Replace("{Location}", location)
                               .Replace("{Type}", type)
                               .Replace("{RemarksRow}", remarksRow)
                               .Replace("{ServiceDate}", DateTime.Now.ToString("MMMM dd, yyyy"))
                               .Replace("{EstimatedReturnDate}", returnDate.ToString("MMMM dd, yyyy"))
                               .Replace("{SystemUrl}", "https://yourcompany.com/FETS")
                               .Replace("{CurrentYear}", DateTime.Now.Year.ToString())
                               .Replace("{CompanyName}", "INARI AMERTRON BHD.");
            
            return template;
        }

        /// <summary>
        /// Gets the service notification email template for multiple fire extinguishers
        /// </summary>
        public static string GetMultipleServiceEmailTemplate(List<FireExtinguisherServiceInfo> extinguishers)
        {
            // Path to the template file
            string templatePath = HttpContext.Current.Server.MapPath("~/EmailTemplates/ServiceEmailTemplate.html");
            
            // Read the template
            string template = File.ReadAllText(templatePath);
            
            // Create the table rows for multiple extinguishers
            StringBuilder tableContent = new StringBuilder();
            tableContent.Append(@"
                <table>
                    <thead>
                        <tr>
                            <th>Serial Number</th>
                            <th>Plant</th>
                            <th>Level</th>
                            <th>Location</th>
                            <th>Type</th>
                        </tr>
                    </thead>
                    <tbody>");
            
            foreach (var extinguisher in extinguishers)
            {
                tableContent.Append("<tr>\r\n                            <td>" + extinguisher.SerialNumber + "</td>\r\n                            <td>" + extinguisher.Plant + "</td>\r\n                            <td>" + extinguisher.Level + "</td>\r\n                            <td>" + extinguisher.Location + "</td>\r\n                            <td>" + extinguisher.Type + "</td>\r\n                        </tr>");
            }
            
            tableContent.Append(@"
                    </tbody>
                </table>");
            
            // Replace the single extinguisher table with the multiple extinguisher table
            string modifiedTemplate = template
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
                    <th>Type</th>
                    <td>{Type}</td>
                </tr>
                {RemarksRow}
            </table>", "<h2>Fire Extinguishers Details:</h2>\n" + tableContent)
                .Replace("<p>This is to inform you that the following fire extinguisher has been sent for service on <strong>{ServiceDate}</strong>.</p>", 
                         "<p>This is to inform you that the following " + extinguishers.Count + " fire extinguishers have been sent for service on <strong>" + DateTime.Now.ToString("MMMM dd, yyyy") + "</strong>.</p>")
                .Replace("{ServiceDate}", DateTime.Now.ToString("MMMM dd, yyyy"))
                .Replace("{EstimatedReturnDate}", DateTime.Now.AddDays(14).ToString("MMMM dd, yyyy"))
                .Replace("{SystemUrl}", "https://yourcompany.com/FETS")
                .Replace("{CurrentYear}", DateTime.Now.Year.ToString())
                .Replace("{CompanyName}", "INARI AMERTRON BHD.");
            
            return modifiedTemplate;
        }

        /// <summary>
        /// Gets the expiry notification email template with placeholders replaced with actual data
        /// </summary>
        public static string GetExpiryEmailTemplate(
            string serialNumber,
            string plant,
            string level,
            string location,
            DateTime expiryDate,
            string remarks = null,
            string notificationType = "Expiry Notification")
        {
            // Path to the template file
            string templatePath = HttpContext.Current.Server.MapPath("~/EmailTemplates/ExpiryEmailTemplate.html");
            
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
                expiryStatus = "will expire in " + daysUntilExpiry + " days";
            }
            
            // Generate remarks row if remarks exist
            string remarksRow = string.IsNullOrEmpty(remarks) 
                ? string.Empty 
                : "<tr>\r\n                        <th>Remarks</th>\r\n                        <td>" + remarks + "</td>\r\n                    </tr>";
            
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
        public static string GetMultipleExpiryEmailTemplate(List<FireExtinguisherExpiryInfo> extinguishers)
        {
            // Path to the template file
            string templatePath = HttpContext.Current.Server.MapPath("~/EmailTemplates/ExpiryEmailTemplate.html");
            
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
            StringBuilder tableContent = new StringBuilder();
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
                
                tableContent.Append("<tr class='" + rowClass + "'>\r\n                            <td>" + extinguisher.SerialNumber + "</td>\r\n                            <td>" + extinguisher.Plant + "</td>\r\n                            <td>" + extinguisher.Level + "</td>\r\n                            <td>" + extinguisher.Location + "</td>\r\n                            <td>" + extinguisher.ExpiryDate.ToString("MMM dd, yyyy") + "</td>\r\n                            <td>" + daysUntilExpiry + "</td>\r\n                        </tr>");
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
            </table>", "<h2>Fire Extinguishers Expiry Details:</h2>\n" + tableContent)
                .Replace("<p>This is an <strong>important notification</strong> regarding a fire extinguisher that {ExpiryStatus}. Please take immediate action to ensure continued fire safety compliance.</p>", 
                         "<p>This is an <strong>important notification</strong> regarding " + extinguishers.Count + " fire extinguishers that require attention. Please take immediate action to ensure continued fire safety compliance.</p>")
                .Replace("{NotificationType}", notificationType)
                .Replace("{SystemUrl}", "https://yourcompany.com/FETS")
                .Replace("{CurrentYear}", DateTime.Now.Year.ToString())
                .Replace("{CompanyName}", "INARI AMERTRON BHD.");
            
            return modifiedTemplate;
        }
    }

    /// <summary>
    /// Data class to hold fire extinguisher information for service emails
    /// </summary>
    public class FireExtinguisherServiceInfo
    {
        public string SerialNumber { get; set; }
        public string Plant { get; set; }
        public string Level { get; set; }
        public string Location { get; set; }
        public string Type { get; set; }
        public string Remarks { get; set; }
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
