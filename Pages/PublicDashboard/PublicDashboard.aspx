<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PublicDashboard.aspx.cs" Inherits="FETS.Pages.PublicDashboard.PublicDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>INARI - Fire Extinguisher Tracking System</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --primary-color: #007bff;
            --success-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --alert-color: #fd7e14;
            --text-color: #333;
            --text-secondary: #666;
            --border-color: #dee2e6;
            --shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            --radius: 8px;
            --background-color: #f5f7fa;
            --card-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            --transition: all 0.3s ease;
        }

        body {
            background-color: var(--background-color);
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }

        .dashboard-container {
            padding: clamp(1rem, 2vw, 2rem);
            max-width: 1400px;
            margin: 0 auto;
            width: 100%;
            box-sizing: border-box;
        }

        .dashboard-header {
            width: 100%;
            text-align: center;
            background-color: #fff;
            border-radius: var(--radius);
            box-shadow: var(--card-shadow);
            padding: clamp(1.5rem, 3vw, 2rem);
            margin: 0 auto 2rem auto;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            box-sizing: border-box;
        }

        .dashboard-header h2 {
            margin: 0;
            color: var(--text-color);
            font-size: clamp(1.5rem, 3vw, 2rem);
            font-weight: 600;
            padding-bottom: 1rem;
            text-align: center;
            width: 100%;
            border-bottom: 2px solid var(--primary-color);
        }

        .logo-container {
            margin-bottom: 20px;
        }

        .logo {
            max-height: 100px;
            width: auto;
        }

        .dashboard-grid {
            display: flex;
            flex-direction: column;
            gap: 2rem;
            width: 100%;
        }

        .status-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            width: 100%;
        }

        .status-card {
            background-color: #fff;
            border-radius: var(--radius);
            box-shadow: var(--card-shadow);
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            text-align: center;
            transition: var(--transition);
        }

        .status-card:hover {
            transform: translateY(-5px);
        }

        .status-card.active {
            border-top: 4px solid var(--success-color);
        }

        .status-card.service {
            border-top: 4px solid var(--primary-color);
        }

        .status-card.expired {
            border-top: 4px solid var(--danger-color);
        }

        .status-card.soon {
            border-top: 4px solid var(--warning-color);
        }

        .status-card h3 {
            margin: 0 0 0.5rem 0;
            font-size: 1.1rem;
            color: var(--text-secondary);
        }

        .status-card .count {
            font-size: 2.5rem;
            font-weight: 700;
            margin: 0.5rem 0;
            color: var(--text-color);
        }

        .chart-section {
            background-color: #fff;
            padding: clamp(1.5rem, 3vw, 2rem);
            border-radius: var(--radius);
            box-shadow: var(--card-shadow);
            width: 100%;
            margin: 0 auto;
            box-sizing: border-box;
            height: auto;
        }

        .chart-section h3 {
            margin: 0 0 1.5rem 0;
            color: var(--text-color);
            font-size: clamp(1.2rem, 2vw, 1.5rem);
            text-align: center;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid var(--primary-color);
            width: 100%;
        }

        .chart-container {
            width: 100%;
            height: clamp(250px, 40vh, 400px);
            max-width: 600px;
            margin: 0 auto;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }

        .plants-section {
            background-color: #fff;
            padding: clamp(1.5rem, 3vw, 2rem);
            border-radius: var(--radius);
            box-shadow: var(--card-shadow);
            width: 100%;
            margin: 2rem auto 0;
            box-sizing: border-box;
        }

        .plants-section h3 {
            margin: 0 0 1.5rem 0;
            color: var(--text-color);
            font-size: clamp(1.2rem, 2vw, 1.5rem);
            text-align: center;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid var(--primary-color);
            width: 100%;
        }

        .plants-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
            width: 100%;
        }

        .plant-card {
            background-color: #fff;
            border-radius: var(--radius);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            transition: var(--transition);
            border: 1px solid var(--border-color);
        }

        .plant-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
        }

        .plant-header {
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid var(--primary-color);
        }

        .plant-title {
            margin: 0;
            color: var(--text-color);
            font-size: 1.2rem;
            font-weight: 600;
        }

        .plant-stats {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            gap: 0.75rem;
            text-align: left;
            width: 100%;
        }

        .stat-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            width: 100%;
            padding: 0.3rem 0;
            border-bottom: 1px dashed var(--border-color);
        }

        .stat-item:last-child {
            border-bottom: none;
        }

        .stat-label {
            margin: 0;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        .stat-value {
            margin: 0;
            color: var(--text-color);
            font-size: 1rem;
            font-weight: 600;
            min-width: 2.5rem;
            text-align: right;
        }

        .stat-value.active {
            color: var(--success-color);
        }

        .stat-value.service {
            color: var(--primary-color);
        }

        .stat-value.expired {
            color: var(--danger-color);
        }

        .stat-value.expiring {
            color: var(--warning-color);
        }

        .login-section {
            background-color: #fff;
            padding: clamp(1.5rem, 3vw, 2rem);
            border-radius: var(--radius);
            box-shadow: var(--card-shadow);
            width: 100%;
            margin: 2rem auto 0;
            box-sizing: border-box;
            text-align: center;
        }

        .login-section h3 {
            margin: 0 0 1.5rem 0;
            color: var(--text-color);
            font-size: clamp(1.2rem, 2vw, 1.5rem);
            text-align: center;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid var(--primary-color);
            width: 100%;
        }

        .login-section p {
            margin-bottom: 1.5rem;
            color: var(--text-secondary);
        }

        .btn-login {
            display: inline-block;
            padding: 10px 25px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border-radius: var(--radius);
            font-weight: 500;
            transition: var(--transition);
            margin: 0 10px;
        }

        .btn-login:hover {
            background-color: #0056b3;
            transform: translateY(-2px);
        }

        .footer {
            text-align: center;
            padding: 20px;
            margin-top: 40px;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-container">
            <div class="dashboard-header">
                <div class="logo-container">
                    <img src="<%=ResolveUrl("~/Uploads/misc/logo.jpeg")%>" alt="INARI Logo" class="logo" />
                </div>
                <h2>Fire Extinguisher Tracking System</h2>
            </div>

            <div class="dashboard-grid">
                <div class="status-cards">
                    <div class="status-card active">
                        <h3>Active Fire Extinguishers</h3>
                        <div class="count"><asp:Literal ID="litActiveCount" runat="server"></asp:Literal></div>
                    </div>
                    <div class="status-card service">
                        <h3>Under Service</h3>
                        <div class="count"><asp:Literal ID="litServiceCount" runat="server"></asp:Literal></div>
                    </div>
                    <div class="status-card expired">
                        <h3>Expired</h3>
                        <div class="count"><asp:Literal ID="litExpiredCount" runat="server"></asp:Literal></div>
                    </div>
                    <div class="status-card soon">
                        <h3>Expiring Soon</h3>
                        <div class="count"><asp:Literal ID="litExpiringSoonCount" runat="server"></asp:Literal></div>
                    </div>
                </div>

                <div class="chart-section">
                    <h3>Fire Extinguisher Types</h3>
                    <div class="chart-container">
                        <canvas id="feTypeChart"></canvas>
                        <asp:HiddenField ID="hdnChartData" runat="server" />
                    </div>
                </div>

                <div class="plants-section">
                    <h3>Plant Statistics</h3>
                    <div class="plants-grid">
                        <asp:Repeater ID="rptPlants" runat="server">
                            <ItemTemplate>
                                <div class="plant-card">
                                    <div class="plant-header">
                                        <h4 class="plant-title"><%# Eval("PlantName") %></h4>
                                    </div>
                                    <div class="plant-stats">
                                        <div class="stat-item">
                                            <span class="stat-label">Total Extinguishers:</span>
                                            <span class="stat-value"><%# Eval("TotalFE") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-label">Active:</span>
                                            <span class="stat-value active"><%# Eval("InUse") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-label">Under Service:</span>
                                            <span class="stat-value service"><%# Eval("UnderService") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-label">Expired:</span>
                                            <span class="stat-value expired"><%# Eval("Expired") %></span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-label">Expiring Soon:</span>
                                            <span class="stat-value expiring"><%# Eval("ExpiringSoon") %></span>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="login-section">
                    <h3>Authorized Access</h3>
                    <p>Log in to access complete system features including data entry, map view, and service management.</p>
                    <a href="<%=ResolveUrl("~/Pages/Login/Login.aspx")%>" class="btn-login">Login to System</a>
                </div>
            </div>

            <div class="footer">
                <p>&copy; <%= DateTime.Now.Year %> INARI AMERTRON BHD. - Environment, Health and Safety Department (EHS)</p>
            </div>
        </div>
    </form>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Get chart data from hidden field
            var chartDataString = document.getElementById('<%= hdnChartData.ClientID %>').value;
            var chartData = chartDataString.split(',').map(function (item) {
                return parseInt(item, 10);
            });

            // Create chart
            var ctx = document.getElementById('feTypeChart').getContext('2d');
            var feTypeChart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['ABC Type', 'CO2 Type'],
                    datasets: [{
                        data: chartData,
                        backgroundColor: [
                            '#4e73df',
                            '#1cc88a'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '70%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                usePointStyle: true,
                                pointStyle: 'circle'
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function (tooltipItem) {
                                    var label = tooltipItem.label || '';
                                    var value = tooltipItem.raw || 0;
                                    var total = tooltipItem.dataset.data.reduce((a, b) => a + b, 0);
                                    var percentage = Math.round((value / total) * 100);
                                    return label + ': ' + value + ' (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });
        });
    </script>
</body>
</html> 