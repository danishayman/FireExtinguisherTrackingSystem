using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI;

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
                lblUsername.Text = User.Identity.Name;
                CheckAdminAccess();
                if (pnlUserManagement.Visible)
                {
                    LoadUsers();
                }
            }
        }

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

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Response.Redirect("~/Default.aspx");
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard.aspx");
        }
    }
} 