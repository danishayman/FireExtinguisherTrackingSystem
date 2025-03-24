using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI;
using System.Collections.Generic;

namespace FETS.Pages.Profile
{
    public partial class Profile : System.Web.UI.Page
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
                CheckAdminAccess();
                if (pnlUserManagement.Visible)
                {
                    LoadUsers();
                    LoadEmailRecipients();
                }
            }
        }
//test saja
        private void CheckAdminAccess()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT Role FROM Users WHERE Username = @Username", conn))
                {
                    cmd.Parameters.AddWithValue("@Username", User.Identity.Name);
                    string role = (string)cmd.ExecuteScalar();
                    pnlUserManagement.Visible = (role == "Administrator");
                    pnlEmailRecipients.Visible = (role == "Administrator");
                }
            }
        }

        private void LoadUsers()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT UserID, Username, Role FROM Users ORDER BY Username", conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvUsers.DataSource = dt;
                        gvUsers.DataBind();
                    }
                }
            }
        }

        protected void btnAddUser_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string username = txtNewUsername.Text.Trim();
            string password = txtUserPassword.Text;
            string role = ddlRole.SelectedValue;

            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Check if username already exists
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Username = @Username", conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    int count = (int)cmd.ExecuteScalar();
                    if (count > 0)
                    {
                        ShowMessage("Username already exists.", false);
                        return;
                    }
                }

                // Add new user
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO Users (Username, PasswordHash, Role) VALUES (@Username, HASHBYTES('SHA2_256', @Password), @Role)", conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", password);
                    cmd.Parameters.AddWithValue("@Role", role);
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("User added successfully!", true);
            ClearNewUserForm();
            LoadUsers();
        }

        protected void gvUsers_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteUser")
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                DeleteUser(userId);
            }
        }

        private void DeleteUser(int userId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM Users WHERE UserID = @UserID", conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("User deleted successfully!", true);
            LoadUsers();
        }

        private void ClearNewUserForm()
        {
            txtNewUsername.Text = string.Empty;
            txtUserPassword.Text = string.Empty;
            ddlRole.SelectedIndex = 0;
        }
        
        // Email Recipients Methods
        private void LoadEmailRecipients()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                // First check if the table exists
                bool tableExists = false;
                string checkTableQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EmailRecipients'";
                using (SqlCommand checkCmd = new SqlCommand(checkTableQuery, conn))
                {
                    int tableCount = (int)checkCmd.ExecuteScalar();
                    tableExists = (tableCount > 0);
                }
                
                // Create the table if it doesn't exist
                if (!tableExists)
                {
                    string createTableQuery = @"
                        CREATE TABLE EmailRecipients (
                            RecipientID INT IDENTITY(1,1) PRIMARY KEY,
                            EmailAddress NVARCHAR(255) NOT NULL,
                            RecipientName NVARCHAR(100),
                            NotificationType NVARCHAR(50) NOT NULL DEFAULT 'All',
                            IsActive BIT NOT NULL DEFAULT 1,
                            DateAdded DATETIME NOT NULL DEFAULT GETDATE()
                        )";
                    
                    using (SqlCommand createCmd = new SqlCommand(createTableQuery, conn))
                    {
                        createCmd.ExecuteNonQuery();
                    }
                }
                
                // Query to get all recipients
                using (SqlCommand cmd = new SqlCommand("SELECT RecipientID, EmailAddress, RecipientName, NotificationType, IsActive FROM EmailRecipients ORDER BY RecipientName", conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        gvEmailRecipients.DataSource = dt;
                        gvEmailRecipients.DataBind();
                    }
                }
            }
        }
        
        protected void btnAddRecipient_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;
                
            string emailAddress = txtEmailAddress.Text.Trim();
            string recipientName = txtRecipientName.Text.Trim();
            string notificationType = ddlNotificationType.SelectedValue;
            
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                // Check if email already exists
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM EmailRecipients WHERE EmailAddress = @EmailAddress", conn))
                {
                    cmd.Parameters.AddWithValue("@EmailAddress", emailAddress);
                    int count = (int)cmd.ExecuteScalar();
                    if (count > 0)
                    {
                        ShowMessage("Email address already exists.", false);
                        return;
                    }
                }
                
                // Add new recipient
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO EmailRecipients (EmailAddress, RecipientName, NotificationType) VALUES (@EmailAddress, @RecipientName, @NotificationType)", conn))
                {
                    cmd.Parameters.AddWithValue("@EmailAddress", emailAddress);
                    cmd.Parameters.AddWithValue("@RecipientName", recipientName);
                    cmd.Parameters.AddWithValue("@NotificationType", notificationType);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ShowMessage("Email recipient added successfully!", true);
            ClearRecipientForm();
            LoadEmailRecipients();
        }
        
        private void ClearRecipientForm()
        {
            txtEmailAddress.Text = string.Empty;
            txtRecipientName.Text = string.Empty;
            ddlNotificationType.SelectedIndex = 0;
        }
        
        protected void gvEmailRecipients_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRecipient")
            {
                int recipientId = Convert.ToInt32(e.CommandArgument);
                DeleteRecipient(recipientId);
            }
            else if (e.CommandName == "EditRecipient")
            {
                int recipientId = Convert.ToInt32(e.CommandArgument);
                LoadRecipientForEdit(recipientId);
            }
            else if (e.CommandName == "ToggleStatus")
            {
                int recipientId = Convert.ToInt32(e.CommandArgument);
                ToggleRecipientStatus(recipientId);
            }
        }
        
        private void DeleteRecipient(int recipientId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM EmailRecipients WHERE RecipientID = @RecipientID", conn))
                {
                    cmd.Parameters.AddWithValue("@RecipientID", recipientId);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ShowMessage("Email recipient deleted successfully!", true);
            LoadEmailRecipients();
        }
        
        private void LoadRecipientForEdit(int recipientId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT RecipientID, EmailAddress, RecipientName, NotificationType FROM EmailRecipients WHERE RecipientID = @RecipientID", conn))
                {
                    cmd.Parameters.AddWithValue("@RecipientID", recipientId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnRecipientID.Value = recipientId.ToString();
                            txtEmailAddress.Text = reader["EmailAddress"].ToString();
                            txtRecipientName.Text = reader["RecipientName"].ToString();
                            ddlNotificationType.SelectedValue = reader["NotificationType"].ToString();
                            
                            btnAddRecipient.Visible = false;
                            btnUpdateRecipient.Visible = true;
                            btnCancelEdit.Visible = true;
                        }
                    }
                }
            }
        }
        
        protected void btnUpdateRecipient_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;
                
            int recipientId = Convert.ToInt32(hdnRecipientID.Value);
            string emailAddress = txtEmailAddress.Text.Trim();
            string recipientName = txtRecipientName.Text.Trim();
            string notificationType = ddlNotificationType.SelectedValue;
            
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                // Check if email already exists but not for this recipient
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM EmailRecipients WHERE EmailAddress = @EmailAddress AND RecipientID != @RecipientID", conn))
                {
                    cmd.Parameters.AddWithValue("@EmailAddress", emailAddress);
                    cmd.Parameters.AddWithValue("@RecipientID", recipientId);
                    int count = (int)cmd.ExecuteScalar();
                    if (count > 0)
                    {
                        ShowMessage("Email address already exists for another recipient.", false);
                        return;
                    }
                }
                
                // Update recipient
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE EmailRecipients SET EmailAddress = @EmailAddress, RecipientName = @RecipientName, NotificationType = @NotificationType WHERE RecipientID = @RecipientID", conn))
                {
                    cmd.Parameters.AddWithValue("@RecipientID", recipientId);
                    cmd.Parameters.AddWithValue("@EmailAddress", emailAddress);
                    cmd.Parameters.AddWithValue("@RecipientName", recipientName);
                    cmd.Parameters.AddWithValue("@NotificationType", notificationType);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ShowMessage("Email recipient updated successfully!", true);
            ClearRecipientForm();
            btnAddRecipient.Visible = true;
            btnUpdateRecipient.Visible = false;
            btnCancelEdit.Visible = false;
            LoadEmailRecipients();
        }
        
        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ClearRecipientForm();
            btnAddRecipient.Visible = true;
            btnUpdateRecipient.Visible = false;
            btnCancelEdit.Visible = false;
        }
        
        private void ToggleRecipientStatus(int recipientId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                // Get current status and toggle it
                string toggleQuery = "UPDATE EmailRecipients SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE RecipientID = @RecipientID";
                using (SqlCommand cmd = new SqlCommand(toggleQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RecipientID", recipientId);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ShowMessage("Recipient status updated successfully!", true);
            LoadEmailRecipients();
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string username = User.Identity.Name;
            string currentPassword = txtCurrentPassword.Text;
            string newPassword = txtNewPassword.Text;

            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                // First verify current password
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Users WHERE Username = @Username AND PasswordHash = HASHBYTES('SHA2_256', @Password)", conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", currentPassword);
                    int count = (int)cmd.ExecuteScalar();

                    if (count == 0)
                    {
                        ShowMessage("Current password is incorrect.", false);
                        return;
                    }
                }

                // Update to new password
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE Users SET PasswordHash = HASHBYTES('SHA2_256', @NewPassword) WHERE Username = @Username", conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@NewPassword", newPassword);
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("Password changed successfully!", true);
            ClearPasswordForm();
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "message success" : "message error";
            lblMessage.Visible = true;
        }

        private void ClearPasswordForm()
        {
            txtCurrentPassword.Text = string.Empty;
            txtNewPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;
        }
    }
} 