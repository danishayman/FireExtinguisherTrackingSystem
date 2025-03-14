using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Caching;

namespace FETS.Pages.MapLayout
{
    public partial class MapLayout : System.Web.UI.Page
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
                LoadMaps();
            }
        }

        private void LoadDropDownLists()
        {
            try
            {
                // Try to get plants from cache first
                DataTable dtPlants = Cache["Plants"] as DataTable;
                if (dtPlants == null)
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        using (SqlCommand cmd = new SqlCommand(@"
                            SELECT PlantID, PlantName 
                            FROM Plants WITH (NOLOCK)
                            ORDER BY PlantName", conn))
                        {
                            using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                            {
                                dtPlants = new DataTable();
                                adapter.Fill(dtPlants);
                                
                                // Cache the results for 1 hour
                                Cache.Insert("Plants", dtPlants, null, DateTime.Now.AddHours(1), Cache.NoSlidingExpiration);
                            }
                        }
                    }
                }

                // Populate dropdowns from DataTable
                ddlPlant.Items.Clear();
                ddlPlant.Items.Add(new ListItem("-- Select Plant --", ""));
                ddlFilterPlant.Items.Clear();
                ddlFilterPlant.Items.Add(new ListItem("-- All Plants --", ""));

                foreach (DataRow row in dtPlants.Rows)
                {
                    ListItem item = new ListItem(
                        row["PlantName"].ToString(),
                        row["PlantID"].ToString()
                    );
                    ddlPlant.Items.Add(item);
                    ddlFilterPlant.Items.Add(item);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in LoadDropDownLists: {ex.Message}");
                throw;
            }
        }

        protected void ddlPlant_SelectedIndexChanged(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine($"Plant selection changed to: {ddlPlant.SelectedValue}");
            LoadLevels(ddlPlant, ddlLevel);
            System.Diagnostics.Debug.WriteLine($"Number of levels loaded: {ddlLevel.Items.Count - 1}"); // -1 for the default item
        }

        protected void ddlFilterPlant_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadLevels(ddlFilterPlant, ddlFilterLevel);
            LoadMaps();
        }

        protected void ddlFilterLevel_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadMaps();
        }

        private void LoadLevels(DropDownList plantDropDown, DropDownList levelDropDown)
        {
            try
            {
                levelDropDown.Items.Clear();
                levelDropDown.Items.Add(new ListItem(plantDropDown == ddlFilterPlant ? "-- All Levels --" : "-- Select Level --", ""));

                if (string.IsNullOrEmpty(plantDropDown.SelectedValue))
                    return;

                // Try to get levels from cache first
                string cacheKey = $"Levels_{plantDropDown.SelectedValue}";
                DataTable dtLevels = Cache[cacheKey] as DataTable;

                if (dtLevels == null)
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        using (SqlCommand cmd = new SqlCommand(@"
                            SELECT LevelID, LevelName 
                            FROM Levels WITH (NOLOCK)
                            WHERE PlantID = @PlantID 
                            ORDER BY LevelName", conn))
                        {
                            cmd.Parameters.AddWithValue("@PlantID", plantDropDown.SelectedValue);
                            using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                            {
                                dtLevels = new DataTable();
                                adapter.Fill(dtLevels);
                                
                                // Cache the results for 1 hour
                                Cache.Insert(cacheKey, dtLevels, null, DateTime.Now.AddHours(1), Cache.NoSlidingExpiration);
                            }
                        }
                    }
                }

                // Populate dropdown from DataTable
                foreach (DataRow row in dtLevels.Rows)
                {
                    levelDropDown.Items.Add(new ListItem(
                        row["LevelName"].ToString(),
                        row["LevelID"].ToString()
                    ));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in LoadLevels: {ex.Message}");
                throw;
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            if (!fuMapImage.HasFile)
            {
                lblMessage.Text = "Please select a file to upload.";
                lblMessage.CssClass = "message error";
                return;
            }

            string fileExtension = Path.GetExtension(fuMapImage.FileName).ToLower();
            if (fileExtension != ".jpg" && fileExtension != ".jpeg" && fileExtension != ".png")
            {
                lblMessage.Text = "Only JPG and PNG files are allowed.";
                lblMessage.CssClass = "message error";
                return;
            }

            try
            {
                string fileName = $"{Guid.NewGuid()}{fileExtension}";
                string uploadPath = Server.MapPath("~/Uploads/Maps");
                
                if (!Directory.Exists(uploadPath))
                    Directory.CreateDirectory(uploadPath);

                string filePath = Path.Combine(uploadPath, fileName);
                fuMapImage.SaveAs(filePath);

                string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string insertQuery = @"
                        INSERT INTO MapImages (PlantID, LevelID, ImagePath, UploadDate)
                        VALUES (@PlantID, @LevelID, @ImagePath, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@PlantID", ddlPlant.SelectedValue);
                        cmd.Parameters.AddWithValue("@LevelID", ddlLevel.SelectedValue);
                        cmd.Parameters.AddWithValue("@ImagePath", fileName);

                        cmd.ExecuteNonQuery();

                        lblMessage.Text = "Map uploaded successfully.";
                        lblMessage.CssClass = "message success";
                        
                        // Clear form
                        ddlPlant.SelectedIndex = 0;
                        ddlLevel.Items.Clear();
                        ddlLevel.Items.Add(new ListItem("-- Select Level --", ""));
                        
                        // Reload maps grid
                        LoadMaps();
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error uploading map: " + ex.Message;
                lblMessage.CssClass = "message error";
            }
        }

        public void LoadMaps()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    SELECT m.MapID, m.PlantID, m.LevelID, m.ImagePath, m.UploadDate,
                           p.PlantName, l.LevelName
                    FROM MapImages m
                    INNER JOIN Plants p ON m.PlantID = p.PlantID
                    INNER JOIN Levels l ON m.LevelID = l.LevelID
                    WHERE (@PlantID IS NULL OR m.PlantID = @PlantID)
                    AND (@LevelID IS NULL OR m.LevelID = @LevelID)
                    ORDER BY m.UploadDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@PlantID", ddlFilterPlant.SelectedValue == "" ? DBNull.Value : (object)int.Parse(ddlFilterPlant.SelectedValue));
                    cmd.Parameters.AddWithValue("@LevelID", ddlFilterLevel.SelectedValue == "" ? DBNull.Value : (object)int.Parse(ddlFilterLevel.SelectedValue));

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvMaps.DataSource = dt;
                        gvMaps.DataBind();
                    }
                }
            }
        }

        protected string GetMapImageUrl(string imagePath)
        {
            return $"~/Uploads/Maps/{imagePath}";
        }

        protected void gvMaps_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMaps.PageIndex = e.NewPageIndex;
            LoadMaps();
        }

        protected void gvMaps_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewMap")
            {
                string[] args = e.CommandArgument.ToString().Split(',');
                if (args.Length == 2)
                {
                    string plantId = args[0];
                    string levelId = args[1];
                    Response.Redirect($"~/Pages/MapLayout/ViewMap.aspx?PlantID={plantId}&LevelID={levelId}");
                }
            }
            else if (e.CommandName == "DeleteMap")
            {
                DeleteMap(Convert.ToInt32(e.CommandArgument));
            }
        }

        private void DeleteMap(int mapId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Get the image path first
                string imagePath = string.Empty;
                using (SqlCommand cmd = new SqlCommand("SELECT ImagePath FROM MapImages WHERE MapID = @MapID", conn))
                {
                    cmd.Parameters.AddWithValue("@MapID", mapId);
                    imagePath = (string)cmd.ExecuteScalar();
                }

                // Delete the database record
                using (SqlCommand cmd = new SqlCommand("DELETE FROM MapImages WHERE MapID = @MapID", conn))
                {
                    cmd.Parameters.AddWithValue("@MapID", mapId);
                    cmd.ExecuteNonQuery();
                }

                // Delete the physical file
                if (!string.IsNullOrEmpty(imagePath))
                {
                    string filePath = Server.MapPath($"~/Uploads/Maps/{imagePath}");
                    if (File.Exists(filePath))
                    {
                        File.Delete(filePath);
                    }
                }

                LoadMaps();
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard/Dashboard.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Clear();
            Response.Redirect("~/Default.aspx");
        }
    }
} 