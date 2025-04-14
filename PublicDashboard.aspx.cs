using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace FETS
{
    public partial class PublicDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTotalStatusCounts();
                LoadChartData();
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
        /// Loads fire extinguisher type distribution data for the dashboard chart
        /// </summary>
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

                        // Store chart data as comma-separated values for JavaScript processing
                        hdnChartData.Value = $"{abcCount},{co2Count}";
                    }
                }
            }
        }
    }
} 