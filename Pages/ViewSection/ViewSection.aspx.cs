using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FETS.Pages.ViewSection
{
    public partial class ViewSection : System.Web.UI.Page
    {
        protected UpdatePanel upMonitoring;
        protected UpdatePanel upMainGrid;
        protected UpdatePanel upServiceConfirmation;
        protected GridView gvServiceConfirmation;

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
                lblUsername.Text = User.Identity.Name;
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
            ddlFilterLevel.Items.Clear();
            ddlFilterLevel.Items.Add(new ListItem("-- All Levels --", ""));
            ddlFilterStatus.SelectedIndex = 0;
            txtSearch.Text = "";
            LoadFireExtinguishers();
        }

        /// <summary>
        /// Event handler for the logout button.
        /// Signs out the user and redirects to login page.
        /// </summary>
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Clear();
            Response.Redirect("~/Default.aspx");
        }

        /// <summary>
        /// Event handler for the back button.
        /// Returns to the dashboard page.
        /// </summary>
        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard.aspx");
        }

        /// <summary>
        /// Event handler for saving a new expiry date after service completion.
        /// Updates the fire extinguisher's status and expiry date.
        /// </summary>
        protected void btnSaveExpiryDate_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Page.IsValid)
                    return;

                string feIdString = hdnSelectedFEID.Value;
                if (string.IsNullOrEmpty(feIdString))
                {
                    throw new Exception("No fire extinguisher selected for service completion.");
                }

                int feId;
                if (!int.TryParse(feIdString, out feId))
                {
                    throw new Exception($"Invalid fire extinguisher ID format: {feIdString}");
                }

                if (string.IsNullOrEmpty(txtNewExpiryDate.Text))
                {
                    throw new Exception("Please enter a new expiry date.");
                }

                DateTime newExpiryDate;
                if (!DateTime.TryParse(txtNewExpiryDate.Text, out newExpiryDate))
                {
                    throw new Exception("Invalid expiry date format. Please enter a valid date.");
                }

                string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get the 'Active' status ID
                    int activeStatusId;
                    using (SqlCommand cmd = new SqlCommand("SELECT StatusID FROM Status WHERE StatusName = 'Active'", conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result == null)
                        {
                            throw new Exception("Could not find 'Active' status in the database. Please check Status table configuration.");
                        }
                        activeStatusId = (int)result;
                    }

                    // Update fire extinguisher
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE FireExtinguishers SET StatusID = @StatusID, DateExpired = @NewExpiryDate WHERE FEID = @FEID", conn))
                    {
                        cmd.Parameters.AddWithValue("@StatusID", activeStatusId);
                        cmd.Parameters.AddWithValue("@NewExpiryDate", newExpiryDate);
                        cmd.Parameters.AddWithValue("@FEID", feId);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        
                        if (rowsAffected == 0)
                        {
                            throw new Exception($"Fire extinguisher with ID {feId} not found.");
                        }
                    }
                }

                // Clear the hidden field and textbox
                hdnSelectedFEID.Value = string.Empty;
                txtNewExpiryDate.Text = string.Empty;

                // Refresh the data
                LoadMonitoringPanels();
                LoadFireExtinguishers();
                upMonitoring.Update();
                upMainGrid.Update();

                // Hide the expiry date panel after successful update
                ScriptManager.RegisterStartupScript(this, GetType(), "hideExpiryPanel", 
                    "hideExpiryDatePanel();", true);

                // Show success message
                ScriptManager.RegisterStartupScript(this, GetType(), "success", 
                    "alert('Service completed successfully. Fire extinguisher status updated to Active.');", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in btnSaveExpiryDate_Click: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "error", 
                    $"alert('Error: {ex.Message.Replace("'", "\\'")}');", true);
            }
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
            gvExpired.PageIndex = e.NewPageIndex;
            LoadTabData();
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
            gvExpiringSoon.PageIndex = e.NewPageIndex;
            LoadTabData();
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
        /// Event handler for sending all expired and expiring soon fire extinguishers to service.
        /// Shows confirmation dialog before proceeding.
        /// </summary>
        protected void btnSendAllToService_Click(object sender, EventArgs e)
        {
            try
            {
                LoadServiceConfirmationGrid("all");
                hdnSelectedFEIDForService.Value = "all";
                ScriptManager.RegisterStartupScript(this, GetType(), "showPanel", 
                    "showSendToServiceConfirmation('all');", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in btnSendAllToService_Click: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "error", 
                    $"alert('An error occurred: {ex.Message}');", true);
            }
        }

        /// <summary>
        /// Event handler for under service grid page index changing.
        /// Handles pagination for the under service fire extinguishers grid.
        /// </summary>
        protected void gvUnderService_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvUnderService.PageIndex = e.NewPageIndex;
            LoadTabData();
        }

        /// <summary>
        /// Event handler for under service grid row commands.
        /// Handles actions like completing service for fire extinguishers.
        /// </summary>
        protected void gvUnderService_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CompleteService")
            {
                int feId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedFEID.Value = feId.ToString();
                txtNewExpiryDate.Text = string.Empty;
                ScriptManager.RegisterStartupScript(this, GetType(), "showPanel", "showExpiryDatePanel();", true);
            }
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
                conn.Open();
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"
                        WITH MonitoringData AS (
                            SELECT 
                                fe.FEID,
                                fe.SerialNumber,
                                p.PlantName,
                                l.LevelName,
                                fe.Location,
                                t.TypeName,
                                fe.DateExpired,
                                s.StatusName,
                                DATEDIFF(day, fe.DateExpired, GETDATE()) as DaysExpired,
                                DATEDIFF(day, GETDATE(), fe.DateExpired) as DaysLeft,
                                CASE 
                                    WHEN fe.DateExpired < GETDATE() AND s.StatusName != 'Under Service' THEN 'Expired'
                                    WHEN fe.DateExpired >= GETDATE() AND fe.DateExpired <= DATEADD(day, 60, GETDATE()) AND s.StatusName != 'Under Service' THEN 'ExpiringSoon'
                                    WHEN s.StatusName = 'Under Service' THEN 'UnderService'
                                END as Category
                            FROM FireExtinguishers fe
                            INNER JOIN Status s ON fe.StatusID = s.StatusID
                            INNER JOIN Plants p ON fe.PlantID = p.PlantID
                            INNER JOIN Levels l ON fe.LevelID = l.LevelID
                            INNER JOIN FireExtinguisherTypes t ON fe.TypeID = t.TypeID
                        )
                        SELECT 
                            md.*,
                            (SELECT COUNT(*) FROM MonitoringData WHERE Category = 'Expired') as ExpiredCount,
                            (SELECT COUNT(*) FROM MonitoringData WHERE Category = 'ExpiringSoon') as ExpiringSoonCount,
                            (SELECT COUNT(*) FROM MonitoringData WHERE Category = 'UnderService') as UnderServiceCount
                        FROM MonitoringData md
                        WHERE md.Category = @Category
                        ORDER BY md.DateExpired ASC";

                    cmd.Parameters.AddWithValue("@Category", activeTab == "expired" ? "Expired" : 
                                                          activeTab == "expiringSoon" ? "ExpiringSoon" : "UnderService");

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            // Get the counts from the first row (they'll be the same in all rows)
                            ExpiredCount = Convert.ToInt32(dt.Rows[0]["ExpiredCount"]);
                            ExpiringSoonCount = Convert.ToInt32(dt.Rows[0]["ExpiringSoonCount"]);
                            UnderServiceCount = Convert.ToInt32(dt.Rows[0]["UnderServiceCount"]);

                            // Remove the count columns before binding to grid
                            dt.Columns.Remove("ExpiredCount");
                            dt.Columns.Remove("ExpiringSoonCount");
                            dt.Columns.Remove("UnderServiceCount");
                        }
                        else
                        {
                            // If no rows, get counts with a separate query
                            cmd.CommandText = @"
                                SELECT 
                                    SUM(CASE WHEN DateExpired < GETDATE() AND StatusName != 'Under Service' THEN 1 ELSE 0 END) as ExpiredCount,
                                    SUM(CASE WHEN DateExpired >= GETDATE() AND DateExpired <= DATEADD(day, 60, GETDATE()) AND StatusName != 'Under Service' THEN 1 ELSE 0 END) as ExpiringSoonCount,
                                    SUM(CASE WHEN StatusName = 'Under Service' THEN 1 ELSE 0 END) as UnderServiceCount
                                FROM FireExtinguishers fe
                                INNER JOIN Status s ON fe.StatusID = s.StatusID";

                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    ExpiredCount = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                                    ExpiringSoonCount = reader.IsDBNull(1) ? 0 : reader.GetInt32(1);
                                    UnderServiceCount = reader.IsDBNull(2) ? 0 : reader.GetInt32(2);
                                }
                            }
                        }

                        // Bind data to appropriate grid
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
            }

            // Update UI
            btnExpiredTab.DataBind();
            btnExpiringSoonTab.DataBind();
            btnUnderServiceTab.DataBind();
            upMonitoring.Update();
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
                lblUsername.Text = User.Identity.Name;
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
        /// Handles actions like deleting fire extinguishers or sending them for service.
        /// </summary>
        protected void gvFireExtinguishers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SendForService")
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
    }
} 