using System;
using System.Web;
using System.Web.UI;
using System.Web.Security;
using System.IO;


namespace FETS
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user is logged in
                if (Session["Username"] != null)
                {
                    lblUsername.Text = Session["Username"].ToString();
                }
                else if (Context.User.Identity.IsAuthenticated)
                {
                    lblUsername.Text = Context.User.Identity.Name;
                }
                else
                {
                    // Redirect to login page if not logged in
                    Response.Redirect("~/Login.aspx");
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear session and redirect to login page
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("~/Login.aspx");
        }

        protected void btnDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard.aspx");
        }

        // These event handlers need to match exactly what's in the markup
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
    }
}