using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FETS.Pages.DataEntry
{
    public partial class DataEntry : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect unauthenticated users to login page
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDropDownLists();
                ddlLevel.Enabled = false; // Level dropdown is initially disabled until a plant is selected

                // Display any success messages from previous operations
                if (Session["SuccessMessage"] != null)
                {
                    lblMessage.Text = Session["SuccessMessage"].ToString();
                    lblMessage.CssClass = "message success";
                    Session["SuccessMessage"] = null;
                }
            }
        }

        /// <summary>
        /// Loads Plants and Fire Extinguisher Types into their respective dropdowns
        /// </summary>
        private void LoadDropDownLists()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Load Plants dropdown
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

                // Load Fire Extinguisher Types dropdown
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

        /// <summary>
        /// Determines the status ID based on the extinguisher's expiry date
        /// </summary>
        /// <param name="expiryDate">The extinguisher's expiry date</param>
        /// <param name="conn">An open SQL connection</param>
        /// <returns>Status ID from the database</returns>
        private int GetStatusIdBasedOnExpiryDate(DateTime expiryDate, SqlConnection conn)
        {
            try
            {
                string statusName;
                DateTime today = DateTime.Now.Date;
                TimeSpan timeUntilExpiry = expiryDate.Date - today;

                // Determine status based on time until expiry
                if (expiryDate.Date < today)
                {
                    statusName = "Expired";
                }
                else if (timeUntilExpiry.TotalDays <= 60) // Within 2 months of expiry
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

                    // Log available statuses for debugging
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

        /// <summary>
        /// Populates the Level dropdown when a plant is selected
        /// </summary>
        protected void ddlPlant_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlPlant.SelectedValue))
            {
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
                ddlLevel.Enabled = false;
                return;
            }
            
            ddlLevel.Enabled = true;

            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Load levels for selected plant
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

        /// <summary>
        /// Handles the initial submission and shows the confirmation dialog
        /// </summary>
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if(!Page.IsValid)
            {
                return;
            }

            // Validate dropdown selections
            int plantId, levelId, typeId;
            if (!int.TryParse(ddlPlant.SelectedValue, out plantId) ||
                !int.TryParse(ddlLevel.SelectedValue, out levelId) ||
                !int.TryParse(ddlType.SelectedValue, out typeId))
            {
                lblMessage.Text = "Please select valid Plant, Level and Type.";
                lblMessage.CssClass = "message error";
                return;
            }

            // Check if serial number is unique
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM FireExtinguishers WHERE SerialNumber = @SerialNumber", conn))
                {
                    cmd.Parameters.AddWithValue("@SerialNumber", txtSerialNumber.Text);
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    if (count > 0)
                    {
                        lblMessage.Text = "Serial number already exists.";
                        lblMessage.CssClass = "message error";
                        return;
                    }
                }
            }

            // Populate confirmation dialog fields
            lblConfirmSerialNumber.Text = txtSerialNumber.Text.Trim();
            lblConfirmPlant.Text = ddlPlant.SelectedItem.Text;
            lblConfirmLevel.Text = ddlLevel.SelectedItem.Text;
            lblConfirmLocation.Text = txtLocation.Text.Trim();
            lblConfirmType.Text = ddlType.SelectedItem.Text;
            DateTime expiryDate;
            if (DateTime.TryParse(txtExpiryDate.Text, out expiryDate))
            {
                lblConfirmExpiryDate.Text = expiryDate.ToString("dd/MM/yyyy");
            }
            else
            {
                lblConfirmExpiryDate.Text = txtExpiryDate.Text;
            }
            lblConfirmRemarks.Text = string.IsNullOrEmpty(txtRemarks.Text) ? "N/A" : txtRemarks.Text.Trim();

            // Show confirmation dialog
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", "showConfirmationPopup();", true);
        }

        /// <summary>
        /// Saves the new fire extinguisher to the database after confirmation
        /// </summary>
        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();

                    DateTime expiryDate = DateTime.Parse(txtExpiryDate.Text);
                    int statusId = GetStatusIdBasedOnExpiryDate(expiryDate, conn);

                    // Final validation of dropdown selections
                    int plantId, levelId, typeId;
                    if (!int.TryParse(ddlPlant.SelectedValue, out plantId) ||
                        !int.TryParse(ddlLevel.SelectedValue, out levelId) ||
                        !int.TryParse(ddlType.SelectedValue, out typeId))
                    {
                        lblMessage.Text = "Please select valid values for Plant, Level, and Type.";
                        lblMessage.CssClass = "message error";
                        return;
                    }

                    // Insert new fire extinguisher record
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

                        // Store success message and redirect to prevent form resubmission
                        Session["SuccessMessage"] = "Fire extinguisher added successfully.";
                        Response.Redirect(Request.Url.PathAndQuery, false);
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

        /// <summary>
        /// Resets all form fields to their default values
        /// </summary>
        private void ClearForm()
        {
            txtSerialNumber.Text = "";
            txtLocation.Text = "";
            txtExpiryDate.Text = "";
            txtRemarks.Text = "";
            ddlPlant.SelectedIndex = 0;
            ddlLevel.Items.Clear();
            ddlLevel.Enabled = false; 
            ddlType.SelectedIndex = 0;
        }

        /// <summary>
        /// Validates that the expiry date is not in the past
        /// </summary>
        protected void cvExpiryDate_ServerValidate(object source, ServerValidateEventArgs args)
        {
            DateTime enteredDate;
            if (DateTime.TryParse(args.Value, out enteredDate)) {
                args.IsValid = enteredDate.Date >= DateTime.Now.Date;
            }
            else {
                args.IsValid = false;
            }
        }
    }
}