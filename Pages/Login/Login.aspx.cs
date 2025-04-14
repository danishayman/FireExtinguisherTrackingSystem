using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Security;

namespace FETS.Pages.Login
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if a user is already authenticated and redirect them to the dashboard
            // This prevents authenticated users from accessing the login page again
            if (User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Pages/Dashboard/Dashboard.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Extract and sanitize user credentials from input fields
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            // Attempt to validate user credentials against the database
            if (ValidateUser(username, password))
            {
                // For valid credentials:
                // 1. Create an authentication cookie (non-persistent)
                // 2. Redirect user to the dashboard
                FormsAuthentication.SetAuthCookie(username, false);
                Response.Redirect("~/Pages/Dashboard/Dashboard.aspx");
            }
            else
            {
                // For invalid credentials:
                // Display appropriate error message to the user
                // without revealing which field (username or password) was incorrect for security
                lblMessage.Text = "Invalid username or password!";
                lblMessage.CssClass = "message error";
                lblMessage.Visible = true;
            }
        }

        /// <summary>
        /// Validates user credentials against the database
        /// </summary>
        /// <param name="username">The username to validate</param>
        /// <param name="password">The password to validate (plain text)</param>
        /// <returns>True if credentials are valid, false otherwise</returns>
        private bool ValidateUser(string username, string password)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(1) FROM Users WHERE Username = @Username AND PasswordHash = HASHBYTES('SHA2_256', @Password)";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", password);

                    try
                    {
                        conn.Open();
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                    catch (Exception ex)
                    {
                        // Log error in production
                        System.Diagnostics.Debug.WriteLine($"Error validating user: {ex.Message}");
                        return false;
                    }
                }
            }
        }

        protected void lnkForgotPassword_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            
            if (string.IsNullOrEmpty(username))
            {
                // Prompt user to enter username
                lblMessage.Text = "Please enter your username first.";
                lblMessage.CssClass = "message error";
                lblMessage.Visible = true;
                return;
            }

            if (username.ToLower() == "admin")
            {
                // Reset admin password to default
                ResetAdminPassword();
                lblMessage.Text = "Admin password has been reset to the default. Please try logging in with the default password.";
                lblMessage.CssClass = "message success";
                lblMessage.Visible = true;
                return;
            }

            // Prompt other users to contact admin for password reset
            lblMessage.Text = "Please contact your system administrator to reset your password.";
            lblMessage.CssClass = "message success";
            lblMessage.Visible = true;
        }

        private void ResetAdminPassword()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Users SET PasswordHash = HASHBYTES('SHA2_256', N'admin123') WHERE Username = 'admin'", conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    // Log error and display message
                    System.Diagnostics.Debug.WriteLine($"Error resetting admin password: {ex.Message}");
                    lblMessage.Text = "An error occurred while resetting the password. Please try again later.";
                    lblMessage.CssClass = "message error";
                    lblMessage.Visible = true;
                }
            }
        }
    }
}