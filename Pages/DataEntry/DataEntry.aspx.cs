using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI.WebControls;

namespace FETS.Pages.DataEntry
{
    public partial class DataEntry : System.Web.UI.Page
    {
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
            }
        }

        private void LoadDropDownLists()
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
            }
        }

        private int GetStatusIdBasedOnExpiryDate(DateTime expiryDate, SqlConnection conn)
        {
            try
            {
                string statusName;
                DateTime today = DateTime.Now.Date;
                TimeSpan timeUntilExpiry = expiryDate.Date - today;

                // Determine status based on expiry date
                if (expiryDate.Date < today)
                {
                    statusName = "Expired";
                }
                else if (timeUntilExpiry.TotalDays <= 60) // Less than or equal to 2 months
                {
                    statusName = "Expiring Soon";
                }
                else
                {
                    statusName = "Active";
                }

                System.Diagnostics.Debug.WriteLine($"Determined status: {statusName} for expiry date: {expiryDate}");

                // Get status ID from database
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 StatusID FROM Status WITH (NOLOCK) WHERE StatusName = @StatusName", conn))
                {
                    cmd.Parameters.AddWithValue("@StatusName", statusName);
                    var result = cmd.ExecuteScalar();
                    
                    if (result != null)
                    {
                        int statusId = Convert.ToInt32(result);
                        System.Diagnostics.Debug.WriteLine($"Found StatusID: {statusId} for StatusName: {statusName}");
                        return statusId;
                    }

                    // If status not found, log available statuses
                    using (SqlCommand debugCmd = new SqlCommand(
                        "SELECT StatusID, StatusName FROM Status WITH (NOLOCK)", conn))
                    {
                        using (SqlDataReader reader = debugCmd.ExecuteReader())
                        {
                            System.Diagnostics.Debug.WriteLine("Available statuses in database:");
                            while (reader.Read())
                            {
                                System.Diagnostics.Debug.WriteLine($"StatusID: {reader["StatusID"]}, StatusName: {reader["StatusName"]}");
                            }
                        }
                    }

                    throw new Exception($"Status '{statusName}' not found in the database. Please ensure the Status table is properly initialized.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in GetStatusIdBasedOnExpiryDate: {ex.Message}");
                throw;
            }
        }

        protected void ddlPlant_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlPlant.SelectedValue))
            {
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Load Levels for selected Plant
                using (SqlCommand cmd = new SqlCommand("SELECT LevelID, LevelName FROM Levels WHERE PlantID = @PlantID ORDER BY LevelName", conn))
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

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();

                    // Check if serial number already exists
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM FireExtinguishers WHERE SerialNumber = @SerialNumber", conn))
                    {
                        cmd.Parameters.AddWithValue("@SerialNumber", txtSerialNumber.Text.Trim());
                        int count = (int)cmd.ExecuteScalar();
                        if (count > 0)
                        {
                            lblMessage.Text = "Serial Number already exists.";
                            lblMessage.CssClass = "message error";
                            return;
                        }
                    }

                    DateTime expiryDate = DateTime.Parse(txtExpiryDate.Text);
                    int statusId = GetStatusIdBasedOnExpiryDate(expiryDate, conn);

                    // Validate dropdown selections
                    int plantId, levelId, typeId;
                    if (!int.TryParse(ddlPlant.SelectedValue, out plantId) ||
                        !int.TryParse(ddlLevel.SelectedValue, out levelId) ||
                        !int.TryParse(ddlType.SelectedValue, out typeId))
                    {
                        lblMessage.Text = "Please select valid values for Plant, Level, and Type.";
                        lblMessage.CssClass = "message error";
                        return;
                    }

                    // Insert new fire extinguisher
                    string insertQuery = "INSERT INTO FireExtinguishers (SerialNumber, PlantID, LevelID, Location, TypeID, DateExpired, Remarks, StatusID) VALUES (@SerialNumber, @PlantID, @LevelID, @Location, @TypeID, @DateExpired, @Remarks, @StatusID)";
                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@SerialNumber", txtSerialNumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@PlantID", plantId);
                        cmd.Parameters.AddWithValue("@LevelID", levelId);
                        cmd.Parameters.AddWithValue("@Location", txtLocation.Text.Trim());
                        cmd.Parameters.AddWithValue("@TypeID", typeId);
                        cmd.Parameters.AddWithValue("@DateExpired", expiryDate);
                        cmd.Parameters.AddWithValue("@Remarks", string.IsNullOrEmpty(txtRemarks.Text) ? DBNull.Value : (object)txtRemarks.Text.Trim());
                        cmd.Parameters.AddWithValue("@StatusID", statusId);

                        cmd.ExecuteNonQuery();

                        lblMessage.Text = "Fire extinguisher added successfully.";
                        lblMessage.CssClass = "message success";
                        ClearForm();
                    }
                }
                catch (SqlException sqlEx)
                {
                    System.Diagnostics.Debug.WriteLine($"SQL Error: {sqlEx.Message}");
                    System.Diagnostics.Debug.WriteLine($"SQL Error Number: {sqlEx.Number}");
                    System.Diagnostics.Debug.WriteLine($"SQL State: {sqlEx.State}");
                    lblMessage.Text = $"Database error: {sqlEx.Message}";
                    lblMessage.CssClass = "message error";
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
                    System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
                    lblMessage.Text = $"Error adding fire extinguisher: {ex.Message}";
                    lblMessage.CssClass = "message error";
                }
            }
        }

        private void ClearForm()
        {
            txtSerialNumber.Text = "";
            txtLocation.Text = "";
            txtExpiryDate.Text = "";
            txtRemarks.Text = "";
            ddlPlant.SelectedIndex = 0;
            ddlLevel.Items.Clear();
            ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
            ddlType.SelectedIndex = 0;
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Clear();
            Response.Redirect("~/Default.aspx");
        }
    }
} 