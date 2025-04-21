using System;
using System.Web.UI;
using System.Web.Security;
using FETS.Models;

namespace FETS
{
    /// <summary>
    /// Master page that implements the site's main navigation and layout
    /// Contains the navbar and sidebar navigation elements
    /// </summary>
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Context.User.Identity.IsAuthenticated)
                {
                    lblUsername.Text = Context.User.Identity.Name;

                    // Show Activity Logs link only to administrators
                    string userRole = RoleHelper.GetUserRole();
                    System.Diagnostics.Debug.WriteLine(string.Format("User role from RoleHelper: '{0}'", userRole));
                    System.Diagnostics.Debug.WriteLine(string.Format("Is admin: {0}", userRole.Equals("Administrator", StringComparison.OrdinalIgnoreCase)));
                    
                    liActivityLogs.Visible = RoleHelper.IsUserInRole("Administrator");

                    // Highlight the current page in the navigation sidebar
                    SetActivePage();
                }
                else
                {
                    // Check if the current page is the PublicDashboard
                    string currentPage = System.IO.Path.GetFileName(Request.Path);
                    if (currentPage.ToLower() != "publicdashboard.aspx")
                    {
                        // Redirect unauthenticated users to login page only if not on the PublicDashboard
                        Response.Redirect("~/Pages/Login/Login.aspx");
                    }
                }
            }
        }

        /// <summary>
        /// Sets the active navigation link based on the current URL
        /// Adds the "active" CSS class to the appropriate navigation button
        /// </summary>
        private void SetActivePage()
        {
            string currentUrl = Request.Url.AbsolutePath.ToLower();

            // Reset all navigation links to default state
            btnDashboard.CssClass = "nav-link";
            btnDataEntry.CssClass = "nav-link";
            btnViewSection.CssClass = "nav-link";
            btnMapLayout.CssClass = "nav-link";
            btnProfile.CssClass = "nav-link";
            btnActivityLogs.CssClass = "nav-link";

            // Set active class for the current page
            if (currentUrl.Contains("/dashboard/"))
            {
                btnDashboard.CssClass = "nav-link active";
            }
            else if (currentUrl.Contains("/dataentry/"))
            {
                btnDataEntry.CssClass = "nav-link active";
            }
            else if (currentUrl.Contains("/viewsection/"))
            {
                btnViewSection.CssClass = "nav-link active";
            }
            else if (currentUrl.Contains("/maplayout/"))
            {
                btnMapLayout.CssClass = "nav-link active";
            }
            else if (currentUrl.Contains("/profile/"))
            {
                btnProfile.CssClass = "nav-link active"; // Settings button (still links to Profile page)
            }
            else if (currentUrl.Contains("/admin/activitylogs"))
            {
                btnActivityLogs.CssClass = "nav-link active";
            }
        }

        /// <summary>
        /// Navigation event handlers for directing users to different system pages
        /// </summary>
        protected void btnDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard/Dashboard.aspx");
        }

        protected void btnDataEntry_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/DataEntry/DataEntry.aspx");
        }

        protected void btnViewSection_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/ViewSection/ViewSection.aspx");
        }

        protected void btnMapLayout_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/MapLayout/MapLayout.aspx");
        }

        protected void btnProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Profile/Profile.aspx");
        }

        /// <summary>
        /// Navigate to the Activity Logs page
        /// </summary>
        protected void btnActivityLogs_Click(object sender, EventArgs e)
        {
            // Only allow administrators to access activity logs
            if (RoleHelper.IsUserInRole("Administrator"))
            {
                Response.Redirect("~/Pages/Admin/ActivityLogs.aspx");
            }
        }

        /// <summary>
        /// Signs out the current user and redirects to login page
        /// </summary>
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                // Log logout action before signing out
                ActivityLogger.LogActivity("Logout", "User logged out");
            }
            catch (Exception ex)
            {
                // Don't let logging failure prevent logout
                System.Diagnostics.Debug.WriteLine(string.Format("Error logging logout: {0}", ex.Message));
            }

            FormsAuthentication.SignOut();
            Response.Redirect("~/Pages/Login/Login.aspx");
        }
    }
}