using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MimeKit;
using MailKit.Net.Smtp;
using MailKit.Security;
using System.Collections.Generic;
using FETS;

namespace FETS.Pages.ViewSection
{
    public partial class ViewSection : System.Web.UI.Page, IPostBackEventHandler
    {
        // Class to store fire extinguisher details for emails and notifications
        public class FireExtinguisherDetails
        {
            public string SerialNumber { get; set; }
            public string Plant { get; set; }
            public string Level { get; set; }
            public string Location { get; set; }
            public string Type { get; set; }
            public string Remarks { get; set; }
        }

        protected UpdatePanel upMonitoring;
        protected UpdatePanel upMainGrid;
        protected UpdatePanel upServiceConfirmation;
        protected GridView gvServiceConfirmation;
        protected GridView gvServiceSelection;
        protected Panel pnlServiceSelection;
        protected UpdatePanel upServiceSelection;

        private string SortExpression
        {
            get { return ViewState["SortExpression"] as string ?? "SerialNumber"; }
            set { ViewState["SortExpression"] = value; }    
        }

        private string SortDirection
        {
            get { return ViewState["SortDirection"] as string ?? "ASC"; }
            set { ViewState["SortDirection"] = value; }
        }

        private string activeTab = "expired";

        // Properties for counts
        protected int ExpiredCount { get; private set; }
        protected int ExpiringSoonCount { get; private set; }
        protected int UnderServiceCount { get; private set; }

        // Method for tab button class
        protected string GetTabButtonClass(string tabName)
        {
            return "tab-button" + (activeTab == tabName ? " active" : "");
        }

        /// <summary>
        /// Loads the monitoring panels with fire extinguisher data:
        /// - Expired fire extinguishers
        /// - Fire extinguishers expiring soon (within 60 days)
        /// - Fire extinguishers under service
        /// Each panel shows relevant information and allows appropriate actions
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (Session["NotificationMessage"] != null)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "emailSentPopup",
                        $"showNotification('{Session["NotificationMessage"]}');", true);
                    Session["NotificationMessage"] = null; // Clear message after showing
                }

                LoadDropDownLists();
                LoadMonitoringPanels();
                LoadFireExtinguishers();
                
            }
            
        }

        
        /// <summary>
        /// Loads all dropdown lists with data:
        /// - Plants dropdown
        /// - Status dropdown
        /// Used for filtering fire extinguishers in the view
        /// </summary>
        private void LoadDropDownLists()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Load Plants
                using (SqlCommand cmd = new SqlCommand("SELECT PlantID, PlantName FROM Plants ORDER BY PlantName", conn))
                {
                    ddlFilterPlant.Items.Clear();
                    ddlFilterPlant.Items.Add(new ListItem("-- All Plants --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFilterPlant.Items.Add(new ListItem(
                                reader["PlantName"].ToString(),
                                reader["PlantID"].ToString()
                            ));
                        }
                    }
                }

                // Load Status
                using (SqlCommand cmd = new SqlCommand("SELECT StatusID, StatusName FROM Status ORDER BY StatusName", conn))
                {
                    ddlFilterStatus.Items.Clear();
                    ddlFilterStatus.Items.Add(new ListItem("-- All Status --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFilterStatus.Items.Add(new ListItem(
                                reader["StatusName"].ToString(),
                                reader["StatusID"].ToString()
                            ));
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Event handler for plant dropdown selection change.
        /// Loads levels based on the selected plant.
        /// </summary>
        protected void ddlFilterPlant_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlFilterPlant.SelectedValue))
            {
                ddlFilterLevel.Items.Clear();
                ddlFilterLevel.Items.Add(new ListItem("-- All Levels --", ""));
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT LevelID, LevelName FROM Levels WHERE PlantID = @PlantID ORDER BY LevelName", conn))
                {
                    cmd.Parameters.AddWithValue("@PlantID", ddlFilterPlant.SelectedValue);
                    ddlFilterLevel.Items.Clear();
                    ddlFilterLevel.Items.Add(new ListItem("-- All Levels --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFilterLevel.Items.Add(new ListItem(
                                reader["LevelName"].ToString(),
                                reader["LevelID"].ToString()
                            ));
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Loads the main fire extinguishers grid with optional filtering.
        /// Supports filtering by plant, level, status, and search text.
        /// </summary>
        private void LoadFireExtinguishers()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string baseQuery = @"
                    SELECT fe.FEID, fe.SerialNumber, p.PlantName, l.LevelName, 
                           fe.Location, t.TypeName, fe.DateExpired, s.StatusName,
                           s.ColorCode, fe.Remarks
                    FROM FireExtinguishers fe
                    INNER JOIN Plants p ON fe.PlantID = p.PlantID
                    INNER JOIN Levels l ON fe.LevelID = l.LevelID
                    INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                    INNER JOIN Status s ON fe.StatusID = s.StatusID
                    WHERE 1=1";

                // Add filters
                if (!string.IsNullOrEmpty(ddlFilterPlant.SelectedValue))
                    baseQuery += " AND fe.PlantID = @PlantID";
                if (!string.IsNullOrEmpty(ddlFilterLevel.SelectedValue))
                    baseQuery += " AND fe.LevelID = @LevelID";
                if (!string.IsNullOrEmpty(ddlFilterStatus.SelectedValue))
                    baseQuery += " AND fe.StatusID = @StatusID";
                if (!string.IsNullOrEmpty(txtSearch.Text))
                    baseQuery += " AND (fe.SerialNumber LIKE @Search OR fe.Location LIKE @Search)";

                baseQuery += " ORDER BY fe.DateExpired ASC";

                using (SqlCommand cmd = new SqlCommand(baseQuery, conn))
                {
                    if (!string.IsNullOrEmpty(ddlFilterPlant.SelectedValue))
                        cmd.Parameters.AddWithValue("@PlantID", ddlFilterPlant.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlFilterLevel.SelectedValue))
                        cmd.Parameters.AddWithValue("@LevelID", ddlFilterLevel.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlFilterStatus.SelectedValue))
                        cmd.Parameters.AddWithValue("@StatusID", ddlFilterStatus.SelectedValue);
                    if (!string.IsNullOrEmpty(txtSearch.Text))
                        cmd.Parameters.AddWithValue("@Search", "%" + txtSearch.Text + "%");

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvFireExtinguishers.DataSource = dt;
                        gvFireExtinguishers.DataBind();
                    }
                }
            }
        }

        /// <summary>
        /// Event handler for the main grid's row data binding.
        /// Sets the status badge color and text based on the fire extinguisher's status.
        /// </summary>
        protected void gvFireExtinguishers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView row = (DataRowView)e.Row.DataItem;
                Label lblStatus = (Label)e.Row.FindControl("lblStatus");
                if (lblStatus != null)
                {
                    lblStatus.Text = row["StatusName"].ToString();
                    lblStatus.Style["background-color"] = row["ColorCode"].ToString();
                }
            }
        }

        /// <summary>
        /// Event handler for applying filters to the fire extinguishers grid.
        /// Called when filter dropdowns change or search button is clicked.
        /// </summary>
        protected void ApplyFilters(object sender, EventArgs e)
        {
            LoadFireExtinguishers();
        }

        /// <summary>
        /// Event handler for clearing all filters.
        /// Resets all filter dropdowns and search text.
        /// </summary>
        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            ddlFilterPlant.SelectedIndex = 0;
            LoadDropDownLists();
            
            // Initialize Level dropdown with default "All Levels" option
            ddlFilterLevel.Items.Clear();
            ddlFilterLevel.Items.Add(new ListItem("-- All Levels --", ""));
            
            // Now we can safely set the selected index
            ddlFilterLevel.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            txtSearch.Text = string.Empty;
            ApplyFilters(sender, e);
        }

        /// <summary>
        /// Event handler for sending a fire extinguisher to service.
        /// Updates the fire extinguisher's status to 'Under Service'.
        /// </summary>
        protected void btnConfirmSendToService_Click(object sender, EventArgs e)
        {
            int feId;
            if (int.TryParse(hdnSelectedFEIDForService.Value, out feId))
            {
                // Get FE details for email
                string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"   
                        SELECT 
                            fe.SerialNumber,
                            p.PlantName,
                            l.LevelName,
                            fe.Location,
                            t.TypeName
                        FROM FireExtinguishers fe
                        INNER JOIN Plants p ON fe.PlantID = p.PlantID
                        INNER JOIN Levels l ON fe.LevelID = l.LevelID
                        INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                        WHERE fe.FEID = @FEID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FEID", feId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string serialNumber = reader["SerialNumber"].ToString();
                                string plant = reader["PlantName"].ToString();
                                string level = reader["LevelName"].ToString();
                                string location = reader["Location"].ToString();
                                string type = reader["TypeName"].ToString();

                                // Send email using the template
                                string recipientEmail = "danishaiman3b@gmail.com"; // Replace with the recipient's email
                                string subject = "Fire Extinguisher Sent for Service";
                                string body = EmailTemplateManager.GetServiceEmailTemplate(
                                    serialNumber,
                                    plant,
                                    level,
                                    location,
                                    type
                                );

                                var (success, message) = EmailService.SendEmail(recipientEmail, subject, body);

                                if (success)
                                {
                                    lblExpiryStats.Text = $"Fire extinguisher {serialNumber} sent for service. Email notification sent.";
                                }
                                else
                                {
                                    lblExpiryStats.Text = $"Fire extinguisher {serialNumber} sent for service. Failed to send email: {message}";
                                }
                            }
                        }
                    }
                }

                // Send FE to service
                SendSingleToService(feId);
                LoadMonitoringPanels();
                LoadFireExtinguishers();
                hideSendToServicePanel();
                upMonitoring.Update();
                upMainGrid.Update();
            }
        }

        private void SendSingleToService(int feId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Get the 'Under Service' status ID
                int underServiceStatusId;
                using (SqlCommand cmd = new SqlCommand("SELECT StatusID FROM Status WHERE StatusName = 'Under Service'", conn))
                {
                    underServiceStatusId = (int)cmd.ExecuteScalar();
                }

                // Update fire extinguisher status
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE FireExtinguishers SET StatusID = @StatusID WHERE FEID = @FEID", conn))
                {
                    cmd.Parameters.AddWithValue("@StatusID", underServiceStatusId);
                    cmd.Parameters.AddWithValue("@FEID", feId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Event handler for the expired tab button click.
        /// Shows the expired fire extinguishers panel and updates statistics.
        /// </summary>
        protected void btnExpiredTab_Click(object sender, EventArgs e)
        {
            activeTab = "expired";
            mvMonitoring.SetActiveView(vwExpired);
            LoadTabData();
        }

        /// <summary>
        /// Event handler for the expiring soon tab button click.
        /// Shows the fire extinguishers that will expire within 60 days.
        /// </summary>
        protected void btnExpiringSoonTab_Click(object sender, EventArgs e)
        {
            activeTab = "expiringSoon";
            mvMonitoring.SetActiveView(vwExpiringSoon);
            LoadTabData();
        }

        /// <summary>
        /// Event handler for the under service tab button click.
        /// Shows fire extinguishers currently under maintenance.
        /// </summary>
        protected void btnUnderServiceTab_Click(object sender, EventArgs e)
        {
            activeTab = "underService";
            mvMonitoring.SetActiveView(vwUnderService);
            LoadTabData();
        }

        /// <summary>
        /// Event handler for expired grid page index changing.
        /// Handles pagination for the expired fire extinguishers grid.
        /// </summary>
        protected void gvExpired_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            try
            {
                gvExpired.PageIndex = e.NewPageIndex;
                
                // Set the active tab to ensure correct data is loaded
                activeTab = "expired";
                mvMonitoring.SetActiveView(vwExpired);
                
                // Update all monitoring data
                LoadTabData();
                
                // Ensure the UpdatePanel is refreshed
                upMonitoring.Update();
                
                // Add debug information
                System.Diagnostics.Debug.WriteLine($"Changed Expired grid to page {e.NewPageIndex}");
            }
            catch (Exception ex)
            {
                // Log error and show user notification
                System.Diagnostics.Debug.WriteLine($"Error in gvExpired_PageIndexChanging: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "paginationError", 
                    $"showNotification('❌ Error changing page: {ex.Message.Replace("'", "\\'")}', 'error');", true);
            }
        }

        /// <summary>
        /// Event handler for expired grid row commands.
        /// Handles actions like sending expired fire extinguishers for service.
        /// </summary>
        protected void gvExpired_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SendForService")
            {
                int feId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedFEIDForService.Value = feId.ToString();
                LoadServiceConfirmationGrid("single");
                upServiceConfirmation.Update();
            }
        }

        /// <summary>
        /// Event handler for expiring soon grid page index changing.
        /// Handles pagination for the expiring soon fire extinguishers grid.
        /// </summary>
        protected void gvExpiringSoon_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            try
            {
                gvExpiringSoon.PageIndex = e.NewPageIndex;
                
                // Set the active tab to ensure correct data is loaded
                activeTab = "expiringSoon";
                mvMonitoring.SetActiveView(vwExpiringSoon);
                
                // Update all monitoring data
                LoadTabData();
                
                // Ensure the UpdatePanel is refreshed
                upMonitoring.Update();
                
                // Add debug information
                System.Diagnostics.Debug.WriteLine($"Changed ExpiringSoon grid to page {e.NewPageIndex}");
            }
            catch (Exception ex)
            {
                // Log error and show user notification
                System.Diagnostics.Debug.WriteLine($"Error in gvExpiringSoon_PageIndexChanging: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "paginationError", 
                    $"showNotification('❌ Error changing page: {ex.Message.Replace("'", "\\'")}', 'error');", true);
            }
        }

        /// <summary>
        /// Event handler for expiring soon grid row commands.
        /// Handles actions like sending expiring soon fire extinguishers for service.
        /// </summary>
        protected void gvExpiringSoon_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SendForService")
            {
                int feId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedFEIDForService.Value = feId.ToString();
                LoadServiceConfirmationGrid("single");
                upServiceConfirmation.Update();
            }
        }
    
        /// <summary>
        /// Event handler for under service grid page index changing.
        /// Handles pagination for the under service fire extinguishers grid.
        /// </summary>
        protected void gvUnderService_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            try
            {
                gvUnderService.PageIndex = e.NewPageIndex;
                
                // Set the active tab to ensure correct data is loaded
                activeTab = "underService";
                mvMonitoring.SetActiveView(vwUnderService);
                
                // Update all monitoring data
                LoadTabData();
                
                // Ensure the UpdatePanel is refreshed
                upMonitoring.Update();
                
                // Add debug information
                System.Diagnostics.Debug.WriteLine($"Changed UnderService grid to page {e.NewPageIndex}");
            }
            catch (Exception ex)
            {
                // Log error and show user notification
                System.Diagnostics.Debug.WriteLine($"Error in gvUnderService_PageIndexChanging: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "paginationError", 
                    $"showNotification('❌ Error changing page: {ex.Message.Replace("'", "\\'")}', 'error');", true);
            }
        }

        /// <summary>
        /// Event handler for under service grid row commands.
        /// Handles actions like completing service for fire extinguishers.
        /// </summary>
        protected void gvUnderService_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // The CompleteService command has been replaced by the bulk completion functionality
        }

        /// <summary>
        /// Loads the under service grid with fire extinguishers currently under maintenance.
        /// Shows serial number, location, expiry date, and status.
        /// </summary>
        private void LoadUnderServiceGrid()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        fe.FEID,
                        fe.SerialNumber,
                        p.PlantName,
                        l.LevelName,
                        fe.Location,
                        t.TypeName,
                        fe.DateExpired,
                        s.StatusName
                    FROM FireExtinguishers fe
                    INNER JOIN Status s ON fe.StatusID = s.StatusID
                    INNER JOIN Plants p ON fe.PlantID = p.PlantID
                    INNER JOIN Levels l ON fe.LevelID = l.LevelID
                    INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                    WHERE s.StatusName = 'Under Service'
                    ORDER BY fe.DateExpired ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvUnderService.DataSource = dt;
                        gvUnderService.DataBind();
                    }
                }
            }
        }

        /// <summary>
        /// Gets the connection string with extended timeout for long-running operations.
        /// </summary>
        private string GetConnectionString()
        {
            var builder = new SqlConnectionStringBuilder(
                ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString);
            builder.ConnectTimeout = 120; // 2 minutes
            return builder.ConnectionString;
        }

        /// <summary>
        /// Loads the service confirmation grid with fire extinguishers to be sent for service.
        /// Can handle single fire extinguisher or all expired/expiring soon ones.
        /// </summary>
        private void LoadServiceConfirmationGrid(string mode)
        {
            string connectionString = GetConnectionString();
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
                        fe.DateExpired,
                        s.StatusName,
                        CASE 
                            WHEN fe.DateExpired < GETDATE() THEN 'Expired'
                            ELSE 'Expiring Soon'
                        END as Status
                    FROM FireExtinguishers fe
                    INNER JOIN Plants p ON fe.PlantID = p.PlantID
                    INNER JOIN Levels l ON fe.LevelID = l.LevelID
                    INNER JOIN Status s ON fe.StatusID = s.StatusID
                    WHERE ";

                if (mode == "single")
                {
                    query += "fe.FEID = @FEID";
                }
                else
                {
                    query += @"(
                        (fe.DateExpired < GETDATE() OR 
                        (fe.DateExpired >= GETDATE() AND fe.DateExpired <= DATEADD(day, 60, GETDATE())))
                        AND s.StatusName != 'Under Service'
                    )
                    ORDER BY 
                        CASE 
                            WHEN fe.DateExpired < GETDATE() THEN 1
                            ELSE 2
                        END,
                        fe.DateExpired ASC";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (mode == "single")
                    {
                        int feId;
                        if (int.TryParse(hdnSelectedFEIDForService.Value, out feId))
                        {
                            cmd.Parameters.AddWithValue("@FEID", feId);
                        }
                        else
                        {
                            return;
                        }
                    }

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvServiceConfirmation.DataSource = dt;
                        gvServiceConfirmation.DataBind();
                    }
                }
            }
        }

        /// <summary>
        /// Loads all monitoring panels with their respective data and updates counts.
        /// </summary>
        private void LoadMonitoringPanels()
        {
            LoadTabData();
        }

        private void LoadTabData()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    
                    // First, get counts for all categories regardless of which tab is active
                    string countQuery = @"
                        SELECT 
                            SUM(CASE WHEN fe.DateExpired < GETDATE() AND s.StatusName != 'Under Service' THEN 1 ELSE 0 END) as ExpiredCount,
                            SUM(CASE WHEN fe.DateExpired >= GETDATE() AND fe.DateExpired <= DATEADD(day, 60, GETDATE()) AND s.StatusName != 'Under Service' THEN 1 ELSE 0 END) as ExpiringSoonCount,
                            SUM(CASE WHEN s.StatusName = 'Under Service' THEN 1 ELSE 0 END) as UnderServiceCount
                        FROM FireExtinguishers fe
                        INNER JOIN Status s ON fe.StatusID = s.StatusID";
                        
                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        using (SqlDataReader countReader = countCmd.ExecuteReader())
                        {
                            if (countReader.Read())
                            {
                                // Set the count properties for the badge displays
                                ExpiredCount = countReader.IsDBNull(0) ? 0 : countReader.GetInt32(0);
                                ExpiringSoonCount = countReader.IsDBNull(1) ? 0 : countReader.GetInt32(1);
                                UnderServiceCount = countReader.IsDBNull(2) ? 0 : countReader.GetInt32(2);
                            }
                            else
                            {
                                // Default to 0 if no data found
                                ExpiredCount = 0;
                                ExpiringSoonCount = 0;
                                UnderServiceCount = 0;
                            }
                        }
                    }
                    
                    // Now get the specific data for the active tab
                    string dataQuery = "";
                    
                    switch (activeTab)
                    {
                        case "expired":
                            dataQuery = @"
                                SELECT 
                                    fe.FEID,
                                    fe.SerialNumber,
                                    p.PlantName,
                                    l.LevelName,
                                    fe.Location,
                                    t.TypeName,
                                    fe.DateExpired,
                                    s.StatusName,
                                    DATEDIFF(day, fe.DateExpired, GETDATE()) as DaysExpired
                                FROM FireExtinguishers fe
                                INNER JOIN Status s ON fe.StatusID = s.StatusID
                                INNER JOIN Plants p ON fe.PlantID = p.PlantID
                                INNER JOIN Levels l ON fe.LevelID = l.LevelID
                                INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                                WHERE fe.DateExpired < GETDATE() AND s.StatusName != 'Under Service'
                                ORDER BY fe.DateExpired ASC";
                            break;
                            
                        case "expiringSoon":
                            dataQuery = @"
                                SELECT 
                                    fe.FEID,
                                    fe.SerialNumber,
                                    p.PlantName,
                                    l.LevelName,
                                    fe.Location,
                                    t.TypeName,
                                    fe.DateExpired,
                                    s.StatusName,
                                    DATEDIFF(day, GETDATE(), fe.DateExpired) as DaysLeft
                                FROM FireExtinguishers fe
                                INNER JOIN Status s ON fe.StatusID = s.StatusID
                                INNER JOIN Plants p ON fe.PlantID = p.PlantID
                                INNER JOIN Levels l ON fe.LevelID = l.LevelID
                                INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                                WHERE fe.DateExpired >= GETDATE() AND fe.DateExpired <= DATEADD(day, 60, GETDATE()) AND s.StatusName != 'Under Service'
                                ORDER BY fe.DateExpired ASC";
                            break;
                            
                        case "underService":
                            dataQuery = @"
                                SELECT 
                                    fe.FEID,
                                    fe.SerialNumber,
                                    p.PlantName,
                                    l.LevelName,
                                    fe.Location,
                                    t.TypeName,
                                    fe.DateExpired,
                                    s.StatusName
                                FROM FireExtinguishers fe
                                INNER JOIN Status s ON fe.StatusID = s.StatusID
                                INNER JOIN Plants p ON fe.PlantID = p.PlantID
                                INNER JOIN Levels l ON fe.LevelID = l.LevelID
                                INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                                WHERE s.StatusName = 'Under Service'
                                ORDER BY fe.DateExpired ASC";
                            break;
                    }
                    
                    // Execute the query and bind data to the appropriate grid
                    using (SqlCommand dataCmd = new SqlCommand(dataQuery, conn))
                    {
                        using (SqlDataAdapter adapter = new SqlDataAdapter(dataCmd))
                        {
                            DataTable dt = new DataTable();
                            adapter.Fill(dt);
                            
                            switch (activeTab)
                            {
                                case "expired":
                                    gvExpired.DataSource = dt;
                                    gvExpired.DataBind();
                                    break;
                                case "expiringSoon":
                                    gvExpiringSoon.DataSource = dt;
                                    gvExpiringSoon.DataBind();
                                    break;
                                case "underService":
                                    gvUnderService.DataSource = dt;
                                    gvUnderService.DataBind();
                                    break;
                            }
                        }
                    }
                    
                    // Update UI with count badges
                    btnExpiredTab.DataBind();
                    btnExpiringSoonTab.DataBind();
                    btnUnderServiceTab.DataBind();
                    upMonitoring.Update();
                }
                catch (Exception ex)
                {
                    // Log the error
                    System.Diagnostics.Debug.WriteLine($"Error in LoadTabData: {ex.Message}");
                    // Show error notification to user
                    ScriptManager.RegisterStartupScript(this, GetType(), "loadDataError", 
                        $"showNotification('❌ Error loading monitoring data: {ex.Message.Replace("'", "\\'")}', 'error');", true);
                }
            }
        }

        /// <summary>
        /// Override of the OnLoad event.
        /// Initializes the page and loads all necessary data.
        /// </summary>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (!IsPostBack)
            {
                LoadDropDownLists();
                LoadFireExtinguishers();
                LoadMonitoringPanels();
            }
        }

        private void hideSendToServicePanel()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "hideServicePanel", "hideSendToServicePanel();", true);
        }

        /// <summary>
        /// Event handler for the main grid's page index changing.
        /// Handles pagination for the main fire extinguishers grid.
        /// </summary>
        protected void gvFireExtinguishers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvFireExtinguishers.PageIndex = e.NewPageIndex;
            LoadFireExtinguishers();
        }

        /// <summary>
        /// Event handler for the main grid's sorting.
        /// Handles column sorting for the main fire extinguishers grid.
        /// </summary>
        protected void gvFireExtinguishers_Sorting(object sender, GridViewSortEventArgs e)
        {
            if (SortExpression == e.SortExpression)
            {
                SortDirection = SortDirection == "ASC" ? "DESC" : "ASC";
            }
            else
            {
                SortExpression = e.SortExpression;
                SortDirection = "ASC";
            }

            LoadFireExtinguishers();
        }

        /// <summary>
        /// Event handler for the main grid's row commands.
        /// Handles actions like editing, deleting fire extinguishers or sending them for service.
        /// </summary>
        protected void gvFireExtinguishers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRow")
            {
                int feId = Convert.ToInt32(e.CommandArgument);
                LoadFireExtinguisherForEdit(feId);
            }
            else if (e.CommandName == "SendForService")
            {
                int feId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedFEIDForService.Value = feId.ToString();
                LoadServiceConfirmationGrid("single");
                upServiceConfirmation.Update();
            }
            else if (e.CommandName == "DeleteRow")
            {
                int feId = Convert.ToInt32(e.CommandArgument);
                DeleteFireExtinguisher(feId);
                LoadMonitoringPanels();
                LoadFireExtinguishers();
                upMonitoring.Update();
                upMainGrid.Update();
            }
        }

        /// <summary>
        /// Deletes a fire extinguisher from the database.
        /// Refreshes the grid after successful deletion.
        /// </summary>
        private void DeleteFireExtinguisher(int feId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM FireExtinguishers WHERE FEID = @FEID", conn))
                {
                    cmd.Parameters.AddWithValue("@FEID", feId);
                    cmd.ExecuteNonQuery();
                }
            }

            LoadFireExtinguishers();
            LoadMonitoringPanels();
        }

        /// <summary>
        /// Updates a fire extinguisher's status in the database.
        /// Refreshes the grids after successful update.
        /// </summary>
        private void UpdateFireExtinguisherStatus(int feId, string statusName)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE FireExtinguishers 
                    SET StatusID = (SELECT StatusID FROM Status WHERE StatusName = @StatusName)
                    WHERE FEID = @FEID", conn))
                {
                    cmd.Parameters.AddWithValue("@FEID", feId);
                    cmd.Parameters.AddWithValue("@StatusName", statusName);
                    cmd.ExecuteNonQuery();
                }
            }

            LoadFireExtinguishers();
            LoadMonitoringPanels();
        }
    


            public class EmailService
        {
            public static (bool Success, string Message) SendEmail(string recipient, string subject, string body)
            {
                try
                {
                    var smtpHost = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as System.Net.Configuration.SmtpSection;
                    
                    if (smtpHost == null)
                    {
                        // Handle configuration error
                        Page page = HttpContext.Current.CurrentHandler as Page;
                        if (page != null)
                        {
                            ScriptManager.RegisterStartupScript(
                                page, page.GetType(), "emailErrorPopup",
                                "showNotification('❌ Failed to load mail settings.', 'error');", true
                            );
                        }
                        return (false, "Failed to load mail settings from configuration.");
                    }

                    var message = new MimeMessage();
                    message.From.Add(new MailboxAddress("Sender Name", smtpHost.From));
                    message.To.Add(new MailboxAddress("", recipient));
                    message.Subject = subject;

                    var bodyBuilder = new BodyBuilder { HtmlBody = body };
                    message.Body = bodyBuilder.ToMessageBody();

                    using (var client = new SmtpClient())
                    {
                        client.Connect(smtpHost.Network.Host, smtpHost.Network.Port, 
                                    smtpHost.Network.EnableSsl ? SecureSocketOptions.StartTls : SecureSocketOptions.Auto);

                        if (!string.IsNullOrEmpty(smtpHost.Network.UserName))
                        {
                            client.Authenticate(smtpHost.Network.UserName, smtpHost.Network.Password);
                        }

                        client.Send(message);
                        client.Disconnect(true);
                        
                        // Success notification with the new system
                        Page page = HttpContext.Current.CurrentHandler as Page;
                        if (page != null)
                        {
                            ScriptManager.RegisterStartupScript(
                                page, page.GetType(), "emailSentPopup",
                                "showNotification('✅ Email sent successfully!');", true
                            );
                        }

                        return (true, "Email sent successfully!");
                    }
                }
                catch (Exception ex)
                {
                    // Error notification with the new system
                    Page page = HttpContext.Current.CurrentHandler as Page;
                    if (page != null)
                    {
                        ScriptManager.RegisterStartupScript(
                            page, page.GetType(), "emailErrorPopup",
                            "showNotification('❌ " + ex.Message.Replace("'", "\\'") + "', 'error');", true
                        );
                    }
                    return (false, $"Email Error: {ex.Message}");
                }
            }
        }
         protected void btnSendToService_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string extinguisherId = btn.CommandArgument;
            string recipientEmail = "danishaiman3b@gmail.com"; // Change dynamically if needed

            // Get fire extinguisher details
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"   
                    SELECT 
                        fe.SerialNumber,
                        p.PlantName,
                        l.LevelName,
                        fe.Location,
                        t.TypeName,
                        fe.Remarks
                    FROM FireExtinguishers fe
                    INNER JOIN Plants p ON fe.PlantID = p.PlantID
                    INNER JOIN Levels l ON fe.LevelID = l.LevelID
                    INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                    WHERE fe.FEID = @FEID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FEID", extinguisherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string serialNumber = reader["SerialNumber"].ToString();
                            string plant = reader["PlantName"].ToString();
                            string level = reader["LevelName"].ToString();
                            string location = reader["Location"].ToString();
                            string type = reader["TypeName"].ToString();
                            string remarks = reader["Remarks"] != DBNull.Value ? reader["Remarks"].ToString() : null;

                            // Use the template manager to get the formatted email body
                            string subject = $"Fire Extinguisher {serialNumber} Sent for Service";
                            string body = EmailTemplateManager.GetServiceEmailTemplate(
                                serialNumber,
                                plant,
                                level,
                                location,
                                type,
                                remarks
                            );

                            var (success, message) = EmailService.SendEmail(recipientEmail, subject, body);

                            if (success)
                            {
                                ScriptManager.RegisterStartupScript(this, GetType(), "emailSentPopup",
                                    "showNotification('✅ Email sent successfully!'); setTimeout(function() { window.location.reload(); }, 2000);", true);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, GetType(), "emailErrorPopup",
                                    $"showNotification('❌ Email failed: {message.Replace("'", "\'")}', 'error');", true);
                            }
                        }
                    }
                }
            }
        }

        private void LoadServiceSelectionGrid()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
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
                        t.TypeName
                    FROM FireExtinguishers fe
                    INNER JOIN Plants p ON fe.PlantID = p.PlantID
                    INNER JOIN Levels l ON fe.LevelID = l.LevelID
                    INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                    INNER JOIN Status s ON fe.StatusID = s.StatusID
                    WHERE s.StatusName != 'Under Service'
                    AND (
                        fe.DateExpired < GETDATE() -- Expired
                        OR 
                        (fe.DateExpired >= GETDATE() AND fe.DateExpired <= DATEADD(day, 60, GETDATE())) -- Expiring Soon (within 60 days)
                    )
                    ORDER BY fe.DateExpired ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvServiceSelection.DataSource = dt;
                        gvServiceSelection.DataBind();
                    }
                }
            }
        }

        protected void btnShowSelection_Click(object sender, EventArgs e)
        {
            LoadServiceSelectionGrid();
            pnlServiceSelection.Visible = true;
            upServiceSelection.Update();
        }

        protected void btnConfirmSelection_Click(object sender, EventArgs e)
        {
            List<int> selectedFEIDs = new List<int>();
            
            foreach (GridViewRow row in gvServiceSelection.Rows)
            {
                CheckBox chkSelect = (CheckBox)row.FindControl("chkSelect");
                if (chkSelect != null && chkSelect.Checked)
                {
                    int feId = Convert.ToInt32(gvServiceSelection.DataKeys[row.RowIndex].Value);
                    selectedFEIDs.Add(feId);
                }
            }

            if (selectedFEIDs.Count > 0)
            {
                // Get details for all selected fire extinguishers
                List<FireExtinguisherServiceInfo> extinguisherDetails = new List<FireExtinguisherServiceInfo>();
                string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string feIdList = string.Join(",", selectedFEIDs);
                    string query = $@"   
                        SELECT 
                            fe.FEID,
                            fe.SerialNumber,
                            p.PlantName,
                            l.LevelName,
                            fe.Location,
                            t.TypeName,
                            fe.Remarks
                        FROM FireExtinguishers fe
                        INNER JOIN Plants p ON fe.PlantID = p.PlantID
                        INNER JOIN Levels l ON fe.LevelID = l.LevelID
                        INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                        WHERE fe.FEID IN ({feIdList})";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                extinguisherDetails.Add(new FireExtinguisherServiceInfo
                                {
                                    SerialNumber = reader["SerialNumber"].ToString(),
                                    Plant = reader["PlantName"].ToString(),
                                    Level = reader["LevelName"].ToString(),
                                    Location = reader["Location"].ToString(),
                                    Type = reader["TypeName"].ToString(),
                                    Remarks = reader["Remarks"] != DBNull.Value ? reader["Remarks"].ToString() : null
                                });
                            }
                        }
                    }
                    
                    // Update status to "Under Service" for all selected extinguishers
                    string updateQuery = $@"
                        UPDATE FireExtinguishers
                        SET StatusID = (SELECT StatusID FROM Status WHERE StatusName = 'Under Service')
                        WHERE FEID IN ({feIdList})";
                    
                    using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                    {
                        updateCmd.ExecuteNonQuery();
                    }
                }
                
                // Send email with the professional template
                string recipientEmail = "danishaiman3b@gmail.com";
                string subject = $"{extinguisherDetails.Count} Fire Extinguishers Sent for Service";
                string body = EmailTemplateManager.GetMultipleServiceEmailTemplate(extinguisherDetails);

                var (success, message) = EmailService.SendEmail(recipientEmail, subject, body);

                if (success)
                {
                    Session["NotificationMessage"] = "✅ Email sent successfully!";
                    Response.Redirect(Request.Url.PathAndQuery, false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    lblExpiryStats.Text = $"Email failed: {message}";
                }
            }
            else
            {
                lblExpiryStats.Text = "No fire extinguishers selected.";
            }
        }
        
        protected void btnCancelSelection_Click(object sender, EventArgs e)
        {
            pnlServiceSelection.Visible = false;
            upServiceSelection.Update();
        }

        /// <summary>
        /// IPostBackEventHandler implementation to handle custom events
        /// </summary>
        public void RaisePostBackEvent(string eventArgument)
        {
            if (eventArgument.StartsWith("LoadFireExtinguisherDetails:"))
            {
                // Extract the FEID from the postback argument
                string feIdStr = eventArgument.Replace("LoadFireExtinguisherDetails:", "");
                int feId;
                
                if (int.TryParse(feIdStr, out feId))
                {
                    LoadFireExtinguisherForEdit(feId);
                    ScriptManager.RegisterStartupScript(this, GetType(), "showEditPanel", "document.getElementById('" + pnlEditFireExtinguisher.ClientID + "').style.display = 'flex';", true);
                }
            }
        }

        /// <summary>
        /// Event handler for Plant dropdown change during edit
        /// </summary>
        protected void ddlPlant_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlPlant.SelectedValue))
            {
                // Clear levels dropdown if no plant is selected
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
                return;
            }

            // Load levels based on selected plant
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT LevelID, LevelName FROM Levels WHERE PlantID = @PlantID ORDER BY LevelName", conn))
                {
                    cmd.Parameters.AddWithValue("@PlantID", ddlPlant.SelectedValue);
                    ddlLevel.Items.Clear();
                    ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlLevel.Items.Add(new ListItem(
                                reader["LevelName"].ToString(),
                                reader["LevelID"].ToString()
                            ));
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Load fire extinguisher details for editing
        /// </summary>
        private void LoadFireExtinguisherForEdit(int feId)
        {
            // Load dropdown options
            LoadDropdownsForEdit();

            // Load fire extinguisher details
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        fe.SerialNumber, 
                        fe.PlantID, 
                        fe.LevelID, 
                        fe.Location, 
                        fe.TypeID, 
                        fe.StatusID, 
                        fe.DateExpired, 
                        fe.Remarks
                    FROM FireExtinguishers fe
                    WHERE fe.FEID = @FEID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FEID", feId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnEditFEID.Value = feId.ToString();
                            txtSerialNumber.Text = reader["SerialNumber"].ToString();
                            
                            // Set the plant dropdown
                            string plantId = reader["PlantID"].ToString();
                            ddlPlant.SelectedValue = plantId;
                            
                            // Get levels for selected plant then set level dropdown
                            LoadLevelsForPlant(plantId);
                            ddlLevel.SelectedValue = reader["LevelID"].ToString();
                            
                            txtLocation.Text = reader["Location"].ToString();
                            ddlType.SelectedValue = reader["TypeID"].ToString();
                            ddlStatus.SelectedValue = reader["StatusID"].ToString();
                            
                            // Format date for the date input
                            DateTime expiryDate = Convert.ToDateTime(reader["DateExpired"]);
                            txtExpiryDate.Text = expiryDate.ToString("yyyy-MM-dd");
                            
                            txtRemarks.Text = reader["Remarks"] as string ?? string.Empty;
                        }
                    }
                }
            }

            // Update the panel
            upEditFireExtinguisher.Update();
            
            // Show the panel with JavaScript
            ScriptManager.RegisterStartupScript(this, GetType(), "showEditPanel", 
                "document.getElementById('" + pnlEditFireExtinguisher.ClientID + "').style.display = 'flex';" +
                "document.getElementById('modalOverlay').style.display = 'block';", true);
        }

        /// <summary>
        /// Load dropdown lists for the edit form
        /// </summary>
        private void LoadDropdownsForEdit()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Load Plants
                using (SqlCommand cmd = new SqlCommand("SELECT PlantID, PlantName FROM Plants ORDER BY PlantName", conn))
                {
                    ddlPlant.Items.Clear();
                    ddlPlant.Items.Add(new ListItem("-- Select Plant --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlPlant.Items.Add(new ListItem(
                                reader["PlantName"].ToString(),
                                reader["PlantID"].ToString()
                            ));
                        }
                    }
                }

                // Load Fire Extinguisher Types
                using (SqlCommand cmd = new SqlCommand("SELECT TypeID, TypeName FROM FireExtinguisherTypes ORDER BY TypeName", conn))
                {
                    ddlType.Items.Clear();
                    ddlType.Items.Add(new ListItem("-- Select Type --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlType.Items.Add(new ListItem(
                                reader["TypeName"].ToString(),
                                reader["TypeID"].ToString()
                            ));
                        }
                    }
                }

                // Load Status
                using (SqlCommand cmd = new SqlCommand("SELECT StatusID, StatusName FROM Status ORDER BY StatusName", conn))
                {
                    ddlStatus.Items.Clear();
                    ddlStatus.Items.Add(new ListItem("-- Select Status --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlStatus.Items.Add(new ListItem(
                                reader["StatusName"].ToString(),
                                reader["StatusID"].ToString()
                            ));
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Load levels for a specific plant
        /// </summary>
        private void LoadLevelsForPlant(string plantId)
        {
            if (string.IsNullOrEmpty(plantId))
            {
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT LevelID, LevelName FROM Levels WHERE PlantID = @PlantID ORDER BY LevelName", conn))
                {
                    cmd.Parameters.AddWithValue("@PlantID", plantId);
                    ddlLevel.Items.Clear();
                    ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlLevel.Items.Add(new ListItem(
                                reader["LevelName"].ToString(),
                                reader["LevelID"].ToString()
                            ));
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Save edited fire extinguisher details
        /// </summary>
        protected void btnSaveEdit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                int feId;
                if (!int.TryParse(hdnEditFEID.Value, out feId))
                {
                    throw new Exception("Invalid fire extinguisher ID.");
                }

                string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        UPDATE FireExtinguishers 
                        SET 
                            SerialNumber = @SerialNumber,
                            PlantID = @PlantID,
                            LevelID = @LevelID,
                            Location = @Location,
                            TypeID = @TypeID,
                            StatusID = @StatusID,
                            DateExpired = @DateExpired,
                            Remarks = @Remarks
                        WHERE FEID = @FEID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FEID", feId);
                        cmd.Parameters.AddWithValue("@SerialNumber", txtSerialNumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@PlantID", ddlPlant.SelectedValue);
                        cmd.Parameters.AddWithValue("@LevelID", ddlLevel.SelectedValue);
                        cmd.Parameters.AddWithValue("@Location", txtLocation.Text.Trim());
                        cmd.Parameters.AddWithValue("@TypeID", ddlType.SelectedValue);
                        cmd.Parameters.AddWithValue("@StatusID", ddlStatus.SelectedValue);
                        
                        DateTime expiryDate;
                        if (DateTime.TryParse(txtExpiryDate.Text, out expiryDate))
                        {
                            cmd.Parameters.AddWithValue("@DateExpired", expiryDate);
                        }
                        else
                        {
                            throw new Exception("Invalid expiry date format.");
                        }
                        
                        if (string.IsNullOrEmpty(txtRemarks.Text))
                        {
                            cmd.Parameters.AddWithValue("@Remarks", DBNull.Value);
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
                        }

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected == 0)
                        {
                            throw new Exception("Fire extinguisher not found or could not be updated.");
                        }
                    }
                }

                // Refresh the data
                LoadMonitoringPanels();
                LoadFireExtinguishers();
                
                // Hide the edit panel
                ScriptManager.RegisterStartupScript(this, GetType(), "hideEditPanel", 
                    "hideEditPanel();", true);
                
                // Show success notification
                ScriptManager.RegisterStartupScript(this, GetType(), "saveSuccess", 
                    "showNotification('✅ Fire extinguisher updated successfully!');", true);
            }
            catch (Exception ex)
            {
                // Show error notification
                ScriptManager.RegisterStartupScript(this, GetType(), "saveError", 
                    $"showNotification('❌ Error: {ex.Message.Replace("'", "\\'")}', 'error');", true);
            }
        }

        /// <summary>
        /// Handles the click event for the Complete Service button.
        /// Loads and displays the panel showing all fire extinguishers under service.
        /// </summary>
        protected void btnCompleteServiceList_Click(object sender, EventArgs e)
        {
            LoadCompleteServiceGrid();
            pnlCompleteService.Visible = true;
            upCompleteService.Update();
            
            // Show the modal overlay
            ScriptManager.RegisterStartupScript(this, GetType(), "showCompleteServicePanel", 
                "showCompleteServicePanel();", true);
        }
        
        /// <summary>
        /// Loads the complete service grid with fire extinguishers that are under service.
        /// </summary>
        private void LoadCompleteServiceGrid()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
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
                        s.StatusName
                    FROM FireExtinguishers fe
                    INNER JOIN Plants p ON fe.PlantID = p.PlantID
                    INNER JOIN Levels l ON fe.LevelID = l.LevelID
                    INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                    INNER JOIN Status s ON fe.StatusID = s.StatusID
                    WHERE s.StatusName = 'Under Service'
                    ORDER BY fe.SerialNumber";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvCompleteService.DataSource = dt;
                        gvCompleteService.DataBind();
                    }
                }
            }
        }
        
        /// <summary>
        /// Handles row data binding for the Complete Service grid.
        /// </summary>
        protected void gvCompleteService_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Set minimum date to today for the expiry date input
                TextBox txtNewExpiryDate = (TextBox)e.Row.FindControl("txtNewExpiryDate");
                if (txtNewExpiryDate != null)
                {
                    // Default the expiry date to one year from today
                    txtNewExpiryDate.Text = DateTime.Today.AddYears(1).ToString("yyyy-MM-dd");
                }
            }
        }
        
        /// <summary>
        /// Handles the click event for confirming service completion.
        /// Updates the status and expiry dates for all fire extinguishers.
        /// </summary>
        protected void btnConfirmCompleteService_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;
                
            bool anySuccess = false;
            List<string> errors = new List<string>();
            List<FireExtinguisherServiceInfo> completedExtinguishers = new List<FireExtinguisherServiceInfo>();
            DateTime serviceDate = DateTime.Now;
            DateTime newExpiryDate = DateTime.Now.AddYears(1); // Default value
            
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                // Begin a single transaction for all updates
                using (SqlTransaction transaction = conn.BeginTransaction())
                {
                    try
                    {
                        foreach (GridViewRow row in gvCompleteService.Rows)
                        {
                            if (row.RowType == DataControlRowType.DataRow)
                            {
                                // Check if this row is selected
                                CheckBox chkSelectForComplete = (CheckBox)row.FindControl("chkSelectForComplete");
                                if (chkSelectForComplete == null || !chkSelectForComplete.Checked)
                                {
                                    // Skip if the checkbox is not checked
                                    continue;
                                }
                                
                                int feId = Convert.ToInt32(gvCompleteService.DataKeys[row.RowIndex].Value);
                                TextBox txtNewExpiryDate = (TextBox)row.FindControl("txtNewExpiryDate");
                                
                                if (txtNewExpiryDate != null && !string.IsNullOrEmpty(txtNewExpiryDate.Text))
                                {
                                    if (DateTime.TryParse(txtNewExpiryDate.Text, out newExpiryDate))
                                    {
                                        // Get the fire extinguisher details
                                        string query = @"
                                            SELECT 
                                                fe.SerialNumber,
                                                p.PlantName AS Plant,
                                                l.LevelName AS Level,
                                                fe.Location,
                                                t.TypeName AS Type,
                                                fe.Remarks
                                            FROM FireExtinguishers fe
                                            INNER JOIN Plants p ON fe.PlantID = p.PlantID
                                            INNER JOIN Levels l ON fe.LevelID = l.LevelID
                                            INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                                            WHERE fe.FEID = @FEID";
                                            
                                        using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
                                        {
                                            cmd.Parameters.AddWithValue("@FEID", feId);
                                            using (SqlDataReader reader = cmd.ExecuteReader())
                                            {
                                                if (reader.Read())
                                                {
                                                    // Add to the list of completed extinguishers
                                                    completedExtinguishers.Add(new FireExtinguisherServiceInfo
                                                    {
                                                        SerialNumber = reader["SerialNumber"].ToString(),
                                                        Plant = reader["Plant"].ToString(),
                                                        Level = reader["Level"].ToString(),
                                                        Location = reader["Location"].ToString(),
                                                        Type = reader["Type"].ToString(),
                                                        Remarks = reader["Remarks"] != DBNull.Value ? reader["Remarks"].ToString() : null
                                                    });
                                                }
                                            }
                                        }

                                        // Update the fire extinguisher status and expiry date
                                        string updateQuery = @"
                                            UPDATE FireExtinguishers
                                            SET StatusID = (SELECT StatusID FROM Status WHERE StatusName = 'Active'),
                                                DateExpired = @NewExpiryDate
                                            WHERE FEID = @FEID";
                                            
                                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn, transaction))
                                        {
                                            cmd.Parameters.AddWithValue("@FEID", feId);
                                            cmd.Parameters.AddWithValue("@NewExpiryDate", newExpiryDate);
                                            cmd.ExecuteNonQuery();
                                        }

                                        // Add service reminder for follow-up
                                        DateTime reminderDate = serviceDate.AddDays(7); // Remind in one week
                                        using (SqlCommand cmd = new SqlCommand(
                                            "INSERT INTO ServiceReminders (FEID, DateServiced, ReminderDate) VALUES (@FEID, @DateServiced, @ReminderDate)", 
                                            conn, transaction))
                                        {
                                            cmd.Parameters.AddWithValue("@FEID", feId);
                                            cmd.Parameters.AddWithValue("@DateServiced", serviceDate);
                                            cmd.Parameters.AddWithValue("@ReminderDate", reminderDate);
                                            cmd.ExecuteNonQuery();
                                        }
                                        
                                        anySuccess = true;
                                    }
                                    else
                                    {
                                        errors.Add($"Invalid expiry date format for extinguisher ID {feId}");
                                    }
                                }
                                else
                                {
                                    errors.Add($"No expiry date provided for extinguisher ID {feId}");
                                }
                            }
                        }
                        
                        // If we have any completed extinguishers, send the email
                        if (completedExtinguishers.Count > 0)
                        {
                            // Get email recipient
                            string recipientEmail = "danishaiman3b@gmail.com";
                            string subject = completedExtinguishers.Count == 1 
                                ? $"Fire Extinguisher Service Completed - {completedExtinguishers[0].SerialNumber}"
                                : $"{completedExtinguishers.Count} Fire Extinguishers Service Completed";
                            
                            string emailBody;
                            if (completedExtinguishers.Count == 1)
                            {
                                // Single extinguisher email
                                var fe = completedExtinguishers[0];
                                emailBody = EmailTemplateManager.GetServiceCompletionEmailTemplate(
                                    fe.SerialNumber,
                                    fe.Plant,
                                    fe.Level,
                                    fe.Location,
                                    fe.Type,
                                    serviceDate,
                                    newExpiryDate,
                                    fe.Remarks
                                );
                            }
                            else
                            {
                                // Multiple extinguishers email
                                emailBody = EmailTemplateManager.GetMultipleServiceCompletionEmailTemplate(
                                    completedExtinguishers,
                                    serviceDate,
                                    newExpiryDate
                                );
                            }
                            
                            try
                            {
                                // Send the email
                                var (success, emailMessage) = EmailService.SendEmail(recipientEmail, subject, emailBody);
                                if (!success)
                                {
                                    // Log the email failure but continue with the transaction
                                    System.Diagnostics.Debug.WriteLine($"Failed to send completion email: {emailMessage}");
                                    errors.Add($"Email could not be sent: {emailMessage}");
                                }
                            }
                            catch (Exception ex)
                            {
                                // Log the error but continue with the transaction
                                System.Diagnostics.Debug.WriteLine($"Error sending email: {ex.Message}");
                                errors.Add($"Email error: {ex.Message}");
                            }
                        }
                        
                        // Commit all changes if successful
                        transaction.Commit();
                        
                    }
                    catch (Exception ex)
                    {
                        // Roll back any changes if there was an error
                        transaction.Rollback();
                        errors.Add($"Transaction error: {ex.Message}");
                    }
                }
            }
            
            // Hide the panel and refresh the data
            pnlCompleteService.Visible = false;
            ScriptManager.RegisterStartupScript(this, GetType(), "hideCompleteServicePanel", 
                "hideCompleteServicePanel();", true);
            
            // Refresh the data
            LoadMonitoringPanels();
            LoadFireExtinguishers();
            upMonitoring.Update();
            upMainGrid.Update();
            
            // Show appropriate message
            if (anySuccess)
            {
                string message = $"Service completed successfully for {completedExtinguishers.Count} fire extinguisher(s).";
                if (errors.Count > 0)
                {
                    message += " However, some errors occurred: " + string.Join("; ", errors);
                }
                
                ScriptManager.RegisterStartupScript(this, GetType(), "successMessage", 
                    $"showNotification('{message.Replace("'", "\\'")}', '{(errors.Count > 0 ? "warning" : "success")}');", true);
            }
            else if (errors.Count > 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "errorMessage", 
                    $"showNotification('❌ Errors occurred: {string.Join("; ", errors).Replace("'", "\\'")}', 'error');", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "noSelectionMessage", 
                    $"showNotification('Please select at least one fire extinguisher to complete service for.', 'error');", true);
            }
        }
        
        /// <summary>
        /// Handles the click event for canceling service completion.
        /// </summary>
        protected void btnCancelCompleteService_Click(object sender, EventArgs e)
        {
            pnlCompleteService.Visible = false;
            upCompleteService.Update();
            
            ScriptManager.RegisterStartupScript(this, GetType(), "hideCompleteServicePanel", 
                "hideCompleteServicePanel();", true);
        }
    }
}
