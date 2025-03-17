<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FETS.Pages.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .dashboard-container {
            padding: 20px;
            max-width: 1400px;
            margin: 0 auto;
        }

        .dashboard-header {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }

        .dashboard-header h2 {
            margin: 0;
            color: #2c3e50;
            font-size: 24px;
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 30px;
        }

        @media (max-width: 1200px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }

        .chart-section {
            height: 100%;
            min-height: 400px;
            display: flex;
            flex-direction: column;
        }

        .chart-section h3 {
            margin: 0 0 20px 0;
            color: #2c3e50;
            font-size: 20px;
        }

        .chart-container {
            flex: 1;
            position: relative;
            min-height: 300px;
            max-height: 400px;
        }

        .plants-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
        }

        .plant-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s ease;
        }

        .plant-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .plant-title {
            color: #2c3e50;
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #eef2f7;
        }

        .stat-item {
            padding: 12px 0;
            border-bottom: 1px solid #eef2f7;
        }

        .stat-label {
            color: #6c757d;
            font-size: 15px;
            font-weight: 500;
        }

        .stat-value {
            font-size: 20px;
            font-weight: 600;
        }

        .stat-value.total { color: #3498db; }
        .stat-value.in-use { color: #2ecc71; }
        .stat-value.under-service { color: #f1c40f; }
        .stat-value.expired { color: #e74c3c; }
        .stat-value.expiring-soon { color: #e67e22; }

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
        <header class="dashboard-header">
            <h2>Fire Extinguisher Tracking System</h2>
        </header>

        <div class="dashboard-grid">
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
                            '#3498db', // Updated blue for ABC
                            '#2ecc71'  // Updated green for CO2
                        ],
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '75%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                font: {
                                    size: 14,
                                    weight: '500'
                                },
                                generateLabels: function(chart) {
                                    const data = chart.data;
                                    return data.labels.map((label, i) => ({
                                        text: `${label}: ${data.datasets[0].data[i]}`,
                                        fillStyle: data.datasets[0].backgroundColor[i],
                                        index: i
                                    }));
                                }
                            }
                        }
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true,
                        duration: 1000
                    }
                }
            });
        });
    </script>
</asp:Content> 