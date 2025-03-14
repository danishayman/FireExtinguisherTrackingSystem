<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FETS.Pages.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .dashboard-container {
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
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

        .buttons-section {
            text-align: center;
            padding: 30px 0;
            margin-top: 30px;
            border-top: 1px solid #eee;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
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
</asp:Content> 