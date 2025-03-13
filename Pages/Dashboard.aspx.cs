using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FETS.Pages
{
    public partial class Dashboard : System.Web.UI.Page
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
                LoadPlantStatistics();
                LoadChartData();
            }
        }

        private void LoadPlantStatistics()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        p.PlantID,
                        p.PlantName,
                        COUNT(fe.FEID) as TotalFE,
                        SUM(CASE WHEN s.StatusName = 'Active' THEN 1 ELSE 0 END) as InUse,
                        SUM(CASE WHEN s.StatusName = 'Under Service' THEN 1 ELSE 0 END) as UnderService,
                        SUM(CASE WHEN fe.DateExpired < GETDATE() THEN 1 ELSE 0 END) as Expired,
                        SUM(CASE 
                            WHEN fe.DateExpired >= GETDATE() 
                            AND fe.DateExpired <= DATEADD(month, 2, GETDATE()) 
                            THEN 1 ELSE 0 END) as ExpiringSoon
                    FROM Plants p
                    LEFT JOIN FireExtinguishers fe ON p.PlantID = fe.PlantID
                    LEFT JOIN Status s ON fe.StatusID = s.StatusID
                    GROUP BY p.PlantID, p.PlantName
                    ORDER BY p.PlantName", conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        // Handle null values
                        foreach (DataRow row in dt.Rows)
                        {
                            if (row["TotalFE"] == DBNull.Value) row["TotalFE"] = 0;
                            if (row["InUse"] == DBNull.Value) row["InUse"] = 0;
                            if (row["UnderService"] == DBNull.Value) row["UnderService"] = 0;
                            if (row["Expired"] == DBNull.Value) row["Expired"] = 0;
                            if (row["ExpiringSoon"] == DBNull.Value) row["ExpiringSoon"] = 0;
                        }

                        rptPlants.DataSource = dt;
                        rptPlants.DataBind();
                    }
                }
            }
        }

        private void LoadChartData()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT fet.TypeName as Type, COUNT(fe.FEID) as Count
                    FROM FireExtinguisherTypes fet
                    LEFT JOIN FireExtinguishers fe ON fet.TypeID = fe.TypeID
                    GROUP BY fet.TypeName
                    ORDER BY fet.TypeName", conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        int abcCount = 0;
                        int co2Count = 0;

                        while (reader.Read())
                        {
                            string type = reader["Type"].ToString();
                            int count = Convert.ToInt32(reader["Count"]);
                            
                            if (type == "ABC") abcCount = count;
                            else if (type == "CO2") co2Count = count;
                        }

                        hdnChartData.Value = $"{abcCount}, {co2Count}";
                    }
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Response.Redirect("~/Default.aspx");
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
    }
} 