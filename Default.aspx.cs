using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Security;

namespace FETS
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Pages/Dashboard.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            if (ValidateUser(username, password))
            {
                FormsAuthentication.SetAuthCookie(username, false);
                Response.Redirect("~/Pages/Dashboard.aspx");
            }
            else
            {
                lblMessage.Text = "Invalid username or password.";
                lblMessage.CssClass = "message error";
                lblMessage.Visible = true;
            }
        }

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
                lblMessage.Text = "Please enter your username first.";
                lblMessage.CssClass = "message error";
                lblMessage.Visible = true;
                return;
            }

            // For admin user, reset to default password
            if (username.ToLower() == "admin")
            {
                ResetAdminPassword();
                lblMessage.Text = "Admin password has been reset to the default. Please try logging in with the default password.";
                lblMessage.CssClass = "message success";
                lblMessage.Visible = true;
                return;
            }

            // For other users, show message to contact admin
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
                    System.Diagnostics.Debug.WriteLine($"Error resetting admin password: {ex.Message}");
                    lblMessage.Text = "An error occurred while resetting the password. Please try again later.";
                    lblMessage.CssClass = "message error";
                    lblMessage.Visible = true;
                }
            }
        }
    }
} 