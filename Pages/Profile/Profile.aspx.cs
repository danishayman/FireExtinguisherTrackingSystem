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
            // Redirect unauthenticated users to the login page
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

        /// <summary>
        /// Checks if the current user has administrator privileges and shows/hides admin panels accordingly
        /// </summary>
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

        /// <summary>
        /// Loads all users from the database and binds them to the users grid view
        /// </summary>
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

        /// <summary>
        /// Handles the add user button click event to create a new user in the system
        /// </summary>
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

        /// <summary>
        /// Handles row commands in the users grid view
        /// </summary>
        protected void gvUsers_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteUser")
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                DeleteUser(userId);
            }
        }

        /// <summary>
        /// Deletes a user from the database by user ID
        /// </summary>
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

        /// <summary>
        /// Clears the new user form fields
        /// </summary>
        private void ClearNewUserForm()
        {
            txtNewUsername.Text = string.Empty;
            txtUserPassword.Text = string.Empty;
            ddlRole.SelectedIndex = 0;
        }
        
        /// <summary>
        /// Loads all email recipients from the database and creates the table if it doesn't exist
        /// </summary>
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
        
        /// <summary>
        /// Adds a new email recipient to the database
        /// </summary>
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
        
        /// <summary>
        /// Clears the recipient form fields
        /// </summary>
        private void ClearRecipientForm()
        {
            txtEmailAddress.Text = string.Empty;
            txtRecipientName.Text = string.Empty;
            ddlNotificationType.SelectedIndex = 0;
        }
        
        /// <summary>
        /// Handles row commands in the email recipients grid view
        /// </summary>
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
        
        /// <summary>
        /// Deletes an email recipient from the database
        /// </summary>
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
        
        /// <summary>
        /// Loads a recipient's data for editing
        /// </summary>
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
        
        /// <summary>
        /// Updates an existing email recipient
        /// </summary>
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
        
        /// <summary>
        /// Cancels the current recipient edit operation
        /// </summary>
        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ClearRecipientForm();
            btnAddRecipient.Visible = true;
            btnUpdateRecipient.Visible = false;
            btnCancelEdit.Visible = false;
        }
        
        /// <summary>
        /// Toggles the active status of an email recipient (enabled/disabled)
        /// </summary>
        private void ToggleRecipientStatus(int recipientId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE EmailRecipients SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE RecipientID = @RecipientID", conn))
                {
                    cmd.Parameters.AddWithValue("@RecipientID", recipientId);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ShowMessage("Recipient status updated successfully!", true);
            LoadEmailRecipients();
        }

        /// <summary>
        /// Handles password change for the currently logged in user
        /// </summary>
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

        /// <summary>
        /// Displays a message to the user with appropriate styling
        /// </summary>
        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "message success" : "message error";
            lblMessage.Visible = true;
        }

        /// <summary>
        /// Clears the password change form fields
        /// </summary>
        private void ClearPasswordForm()
        {
            txtCurrentPassword.Text = string.Empty;
            txtNewPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;
        }
    }
}