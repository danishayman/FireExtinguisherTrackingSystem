<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FETS.Pages.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Base styles */
        :root {
            --primary-color: #3498db;
            --success-color: #2ecc71;
            --warning-color: #f1c40f;
            --danger-color: #e74c3c;
            --alert-color: #e67e22;
            --text-color: #2c3e50;
            --text-secondary: #6c757d;
            --border-color: #eef2f7;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 8px rgba(0,0,0,0.15);
            --radius: 10px;
            --spacing-sm: 15px;
            --spacing-md: 25px;
            --spacing-lg: 30px;
        }

        /* Layout */
        .dashboard-container {
            padding: var(--spacing-md);
            max-width: 1400px;
            margin: 0 auto;
            width: 100%;
        }

        .dashboard-header {
            justify-content: center;
            width: 100%;
            text-align: center;
            background: white;
            padding: var(--spacing-md);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            margin-bottom: var(--spacing-lg);
        }

        .dashboard-header h2 {
            margin: 0;
            color: var(--text-color);
            font-size: 28px;
            font-weight: 600;
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: var(--spacing-lg);
            width: 100%;
        }

        /* Chart section */
        .chart-section {
            background: white;
            padding: var(--spacing-lg);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
        }

        .chart-section h3 {
            margin: 0 0 var(--spacing-md) 0;
            color: var(--text-color);
            font-size: 22px;
            text-align: center;
        }

        .chart-container {
            width: 100%;
            height: 400px;
            max-width: 500px;
            margin: 0 auto;
        }

        /* Plants section */
        .plants-section {
            width: 100%;
        }

        .plants-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: var(--spacing-lg);
            width: 100%;
            margin-left: var(--spacing-md);
        }

        .plant-card {
            background: white;
            padding: var(--spacing-md);
            border-radius: var(--radius);
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
            border: 1px solid var(--border-color);
        }

        .plant-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.15);
        }

        .plant-title {
            color: var(--text-color);
            font-size: 22px;
            font-weight: 600;
            margin-bottom: var(--spacing-md);
            padding-bottom: var(--spacing-sm);
            border-bottom: 2px solid var(--border-color);
            text-align: center;
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
            padding: var(--spacing-sm) 0;
            border-bottom: 1px solid var(--border-color);
        }

        .stat-item:last-child {
            border-bottom: none;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 15px;
            font-weight: 500;
        }

        .stat-value {
            font-size: 20px;
            font-weight: 600;
            min-width: 60px;
            text-align: right;
            white-space: nowrap;
        }

        .stat-value.total { color: var(--primary-color); }
        .stat-value.in-use { color: var(--success-color); }
        .stat-value.under-service { color: var(--warning-color); }
        .stat-value.expired { color: var(--danger-color); }
        .stat-value.expiring-soon { color: var(--alert-color);}

        /* Responsive adjustments */
        @media (min-width: 992px) {
            .dashboard-grid {
                grid-template-columns: 1fr 1fr;
            }
            
            .chart-section {
                grid-column: 1;
            }
            
            .plants-section {
                grid-column: 2;
            }
        }

        @media (max-width: 991px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
            
            .chart-section, .plants-section {
                grid-column: 1;
            }
        }

        @media (max-width: 768px) {
            .plants-grid {
                grid-template-columns: 1fr;
            }
            
            .chart-container {
                height: 300px;
            }
            
            .dashboard-header h2 {
                font-size: 24px;
            }
            
            .chart-section h3 {
                font-size: 20px;
            }
        }

        @media (max-width: 480px) {
            .dashboard-container {
                padding: 15px;
            }
            
            .dashboard-header, .chart-section, .plant-card {
                padding: 15px;
            }
            
            .chart-container {
                height: 250px;
            }
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