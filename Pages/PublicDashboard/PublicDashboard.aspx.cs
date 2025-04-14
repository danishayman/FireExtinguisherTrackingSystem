using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace FETS.Pages.PublicDashboard
{
    public partial class PublicDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTotalStatusCounts();
                LoadPlantStatistics();
            }
        }

        /// <summary>
        /// Loads total counts of fire extinguishers by status across all plants
        /// </summary>
        private void LoadTotalStatusCounts()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["FETSConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        SUM(CASE WHEN s.StatusName = 'Active' THEN 1 ELSE 0 END) as TotalActive,
                        SUM(CASE WHEN s.StatusName = 'Under Service' THEN 1 ELSE 0 END) as TotalUnderService,
                        SUM(CASE WHEN s.StatusName = 'Expired' THEN 1 ELSE 0 END) as TotalExpired,
                        SUM(CASE WHEN s.StatusName = 'Expiring Soon' THEN 1 ELSE 0 END) as TotalExpiringSoon
                    FROM FireExtinguishers fe
                    JOIN Status s ON fe.StatusID = s.StatusID", conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litActiveCount.Text = reader.IsDBNull(reader.GetOrdinal("TotalActive")) ? "0" : reader.GetInt32(reader.GetOrdinal("TotalActive")).ToString();
                            litServiceCount.Text = reader.IsDBNull(reader.GetOrdinal("TotalUnderService")) ? "0" : reader.GetInt32(reader.GetOrdinal("TotalUnderService")).ToString();
                            litExpiredCount.Text = reader.IsDBNull(reader.GetOrdinal("TotalExpired")) ? "0" : reader.GetInt32(reader.GetOrdinal("TotalExpired")).ToString();
                            litExpiringSoonCount.Text = reader.IsDBNull(reader.GetOrdinal("TotalExpiringSoon")) ? "0" : reader.GetInt32(reader.GetOrdinal("TotalExpiringSoon")).ToString();
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Loads fire extinguisher statistics for each plant into the repeater control
        /// </summary>
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
    SUM(CASE WHEN s.StatusName = 'Expired' THEN 1 ELSE 0 END) as Expired,
    SUM(CASE WHEN s.StatusName = 'Expiring Soon' THEN 1 ELSE 0 END) as ExpiringSoon
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

                        // Replace null values with zero to prevent rendering issues
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
    }
} 