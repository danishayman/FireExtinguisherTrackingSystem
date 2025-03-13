<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FETS.Pages.Dashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>FETS - Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="../Assets/css/styles.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f9fc;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            bottom: 0;
            width: 250px;
            background: linear-gradient(135deg, #0056b3 0%, #007bff 100%);
            box-shadow: 2px 0 4px rgba(0,0,0,0.1);
            z-index: 1000;
            display: flex;
            flex-direction: column;
        }

        .sidebar-brand {
            padding: 20px 15px;
            color: white;
            font-size: 20px;
            font-weight: 600;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-menu {
            display: flex;
            flex-direction: column;
            padding: 20px 0;
            flex-grow: 1;
        }

        .sidebar-menu .btn {
            background-color: transparent;
            border: none;
            color: white;
            padding: 15px;
            text-align: left;
            font-size: 14px;
            border-left: 3px solid transparent;
            transition: all 0.3s ease;
            margin-bottom: 5px;
        }

        .sidebar-menu .btn:hover, .sidebar-menu .btn.active {
            background-color: rgba(255, 255, 255, 0.1);
            border-left: 3px solid white;
        }

        .user-controls {
            padding: 15px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            color: white;
            font-size: 14px;
        }

        .btn-logout {
            background-color: rgba(220, 53, 69, 0.1);
            border: 1px solid rgba(220, 53, 69, 0.2);
            color: white;
            padding: 8px 16px;
            width: 100%;
            margin-top: 10px;
            transition: all 0.3s ease;
        }

        .btn-logout:hover {
            background-color: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
        }

        /* Main Content Styles */
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }

        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            margin-bottom: 30px;
        }

        .chart-section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            text-align: center;
        }

        .chart-container {
            width: 100%;
            max-width: 500px;
            margin: 0 auto;
            height: 300px;
        }

        .plants-section {
            margin: 30px 0;
        }

        .plants-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }

        .plant-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .plant-title {
            color: #0056b3;
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }

        .stats-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .stat-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }

        .stat-item:last-child {
            border-bottom: none;
        }

        .stat-label {
            color: #666;
            font-size: 14px;
        }

        .stat-value {
            font-size: 18px;
            font-weight: 600;
        }

        .stat-value.total { color: #2196F3; }
        .stat-value.in-use { color: #28a745; }
        .stat-value.under-service { color: #ffc107; }
        .stat-value.expired { color: #dc3545; }
        .stat-value.expiring-soon { color: #fd7e14; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-brand">
                F.E.T.S.
            </div> 
            <div class="sidebar-menu">
                <asp:Button ID="btnDashboard" runat="server" Text="Dashboard" CssClass="btn active" />
                <asp:Button ID="btnDataEntry" runat="server" Text="Data Entry" OnClick="btnDataEntry_Click" CssClass="btn" />
                <asp:Button ID="btnViewSection" runat="server" Text="View Section" OnClick="btnViewSection_Click" CssClass="btn" />
                <asp:Button ID="btnMapLayout" runat="server" Text="Map Layout" OnClick="btnMapLayout_Click" CssClass="btn" />
                <asp:Button ID="btnProfile" runat="server" Text="Profile Management" OnClick="btnProfile_Click" CssClass="btn" />
            </div>
            <div class="user-controls">
                Welcome, <asp:Label ID="lblUsername" runat="server"></asp:Label>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn btn-logout">Logout</asp:LinkButton>
            </div>
        </div>

        <div class="main-content">
            <div class="dashboard-container">
                <!-- Header Section -->
                <header class="header">
                    <div class="header-content">
                        <h2>Fire Extinguisher Tracking System</h2>
                    </div>
                </header>

                <!-- Chart Section -->
                <section class="chart-section">
                    <h3>Fire Extinguisher Types Distribution</h3>
                    <div class="chart-container">
                        <canvas id="feTypeChart"></canvas>
                    </div>
                    <asp:HiddenField ID="hdnChartData" runat="server" />
                </section>

                <!-- Plants Section -->
                <section class="plants-section">
                    <div class="plants-grid">
                        <asp:Repeater ID="rptPlants" runat="server">
                            <ItemTemplate>
                                <div class="plant-card">
                                    <div class="plant-title"><%# Eval("PlantName") %></div>
                                    <ul class="stats-list">
                                        <li class="stat-item">
                                            <span class="stat-label">Total FE</span>
                                            <span class="stat-value total"><%# Eval("TotalFE", "{0:N0}") %></span>
                                        </li>
                                        <li class="stat-item">
                                            <span class="stat-label">In Use</span>
                                            <span class="stat-value in-use"><%# Eval("InUse", "{0:N0}") %></span>
                                        </li>
                                        <li class="stat-item">
                                            <span class="stat-label">Under Service</span>
                                            <span class="stat-value under-service"><%# Eval("UnderService", "{0:N0}") %></span>
                                        </li>
                                        <li class="stat-item">
                                            <span class="stat-label">Expired</span>
                                            <span class="stat-value expired"><%# Eval("Expired", "{0:N0}") %></span>
                                        </li>
                                        <li class="stat-item">
                                            <span class="stat-label">Expiring Soon</span>
                                            <span class="stat-value expiring-soon"><%# Eval("ExpiringSoon", "{0:N0}") %></span>
                                        </li>
                                    </ul>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </section>
            </div>
        </div>
    </form>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var ctx = document.getElementById('feTypeChart').getContext('2d');
            var chartData = document.getElementById('<%= hdnChartData.ClientID %>').value.split(',').map(Number);
            
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['ABC', 'CO2'],
                    datasets: [{
                        data: chartData,
                        backgroundColor: [
                            '#4e73df', // Blue for ABC
                            '#1cc88a'  // Green for CO2
                        ],
                        borderWidth: 1,
                        borderColor: '#ffffff'
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
                                font: {
                                    family: 'Poppins',
                                    size: 14
                                }
                            }
                        }
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true
                    }
                }
            });
        });
    </script>
</body>
</html>