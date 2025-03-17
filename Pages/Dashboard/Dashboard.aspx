<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FETS.Pages.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Base styles to match View Section and Data Entry */
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
            --radius: 5px;
        }

        /* Layout */
        .dashboard-container {
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
        }

        .dashboard-header {
            width: 100%;
            max-width: 1100px;
            min-width: 1000px;
            text-align: center;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin: 0 auto 30px auto;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            box-sizing: border-box;
        }

        .dashboard-header h2 {
            margin: 0;
            color: #333;
            font-size: 1.75rem;
            font-weight: 600;
            padding-bottom: 15px;
            text-align: center;
            width: 100%;
            border-bottom: 2px solid #007bff;
        }

        .dashboard-grid {
            display: flex;
            flex-direction: column;
            gap: 30px;
            width: 100%;
        }

        /* Chart section */
        .chart-section {
            background-color: #fff;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 1100px;
            min-width: 1000px;
            margin: 0 auto;
            box-sizing: border-box;
            height: auto;
        }

        .chart-section h3 {
            margin: 0 0 20px 0;
            color: #333;
            font-size: 1.5rem;
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 2px solid #007bff;
            width: 100%;
        }

        .chart-container {
            width: 100%;
            height: 350px;
            max-width: 500px;
            margin: 0 auto;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* Plants section */
        .plants-section {
            background-color: #fff;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 1100px;
            min-width: 1000px;
            margin: 0 auto;
            box-sizing: border-box;
            padding-bottom: 50px;
        }

        .plants-section h3 {
            margin: 0 0 20px 0;
            color: #333;
            font-size: 1.5rem;
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 2px solid #007bff;
            width: 100%;
        }

        .plants-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 40px;
            width: 100%;
            padding: 15px;
        }

        .plant-card {
            background-color: #fff;
            padding: 10px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
            border: 1px solid #dee2e6;
            margin: 10px;
            position: relative;
            isolation: isolate;
        }

        .plant-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
            z-index: 1;
        }

        .plant-title {
            color: #333;
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 25px;
            padding-bottom: 12px;
            border-bottom: 2px solid #007bff;
            text-align: center;
            position: relative;
        }

        .stats-list {
            list-style: none;
            padding: 0;
            margin: 0;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        .stat-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #dee2e6;
            margin-bottom: 8px;
        }

        .stat-item:last-child {
            border-bottom: none;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 0.95rem;
            font-weight: 500;
        }

        .stat-value {
            font-size: 1.1rem;
            font-weight: 600;
            min-width: 60px;
            text-align: right;
            white-space: nowrap;
        }

        .stat-value.total { color: var(--primary-color); }
        .stat-value.in-use { color: var(--success-color); }
        .stat-value.under-service { color: var(--warning-color); }
        .stat-value.expired { color: var(--danger-color); }
        .stat-value.expiring-soon { color: var(--alert-color); }

        /* Responsive adjustments */
        @media (max-width: 1200px) {
            .chart-section,
            .plants-section,
            .dashboard-header {
                min-width: auto;
                width: 100%;
            }
        }

        @media (max-width: 768px) {
            .plants-grid {
                grid-template-columns: 1fr;
            }
            
            .chart-container {
                height: 300px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <div class="dashboard-header">
            <h2>Fire Extinguisher Tracking System</h2>
        </div>

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
                <h3>Plant Statistics</h3>
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
                            '#3498db',
                            '#2ecc71'
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
                                    const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                                    return data.labels.map((label, i) => ({
                                        text: `${label}: ${data.datasets[0].data[i]} (${Math.round(data.datasets[0].data[i]/total * 100)}%)`,
                                        fillStyle: data.datasets[0].backgroundColor[i],
                                        index: i
                                    }));
                                }
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const label = context.label || '';
                                    const value = context.raw || 0;
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = Math.round((value / total) * 100);
                                    return `${label}: ${value} (${percentage}%)`;
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