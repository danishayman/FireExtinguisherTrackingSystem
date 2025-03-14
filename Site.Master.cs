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
                }
                else
                {
                    Response.Redirect("~/Default.aspx");
                }
            }
        }

        protected void btnDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Dashboard.aspx");
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