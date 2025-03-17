using System;
using System.Web.UI;
using System.Web.Security;

namespace FETS
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Context.User.Identity.IsAuthenticated)
                {
                    lblUsername.Text = Context.User.Identity.Name;
                    
                    // Set active page in sidebar based on current URL
                    SetActivePage();
                }
                else
                {
                    Response.Redirect("~/Default.aspx");
                }
            }
        }
        
        // Add this new method to set the active page
        private void SetActivePage()
        {
            string currentUrl = Request.Url.AbsolutePath.ToLower();
            
            // Reset all navigation links
            btnDashboard.CssClass = "nav-link";
            btnDataEntry.CssClass = "nav-link";
            btnViewSection.CssClass = "nav-link";
            btnMapLayout.CssClass = "nav-link";
            btnProfile.CssClass = "nav-link";
            
            // Set active class based on current URL
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
                btnProfile.CssClass = "nav-link active";
            }
        }

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

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Response.Redirect("~/Default.aspx");
        }
    }
}