<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FETS.Pages.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Base styles and variables */
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
            --background-color: #f5f7fa;
        }

        /* Layout */
        body {
            background-color: var(--background-color);
        }

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
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            padding: 25px;
            margin: 0 auto 30px auto;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            box-sizing: border-box;
        }

        .dashboard-header h2 {
            margin: 0;
            color: var(--text-color);
            font-size: 1.75rem;
            font-weight: 600;
            padding-bottom: 15px;
            text-align: center;
            width: 100%;
            border-bottom: 2px solid var(--primary-color);
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
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            width: 100%;
            max-width: 1100px;
            min-width: 1000px;
            margin: 0 auto;
            box-sizing: border-box;
            height: auto;
        }

        .chart-section h3 {
            margin: 0 0 20px 0;
            color: var(--text-color);
            font-size: 1.5rem;
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--primary-color);
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
            position: relative;
        }

        /* Style for crossed-out legend items */
        .chart-legend-item-hidden {
            text-decoration: line-through;
            opacity: 0.5;
        }
        
        /* Add a subtle border around the chart */
        canvas#feTypeChart {
            border-radius: 8px;
            background-color: #f9f9f9;
            padding: 10px;
        }

        /* Plants section */
        .plants-section {
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            width: 100%;
            max-width: 1100px;
            min-width: 1000px;
            margin: 0 auto;
            box-sizing: border-box;
            padding-bottom: 50px;
        }

        .plants-section h3 {
            margin: 0 0 20px 0;
            color: var(--text-color);
            font-size: 1.5rem;
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--primary-color);
            width: 100%;
        }

        .plants-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 30px;
            width: 100%;
            padding: 15px;
        }

        /* Plant Card Styles */
        .plant-card {
            background-color: #fff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
            border: 1px solid var(--border-color);
            position: relative;
            overflow: hidden;
        }

        .plant-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
        }

        .plant-card:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-color), var(--success-color));
        }

        .plant-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .plant-title {
            color: var(--text-color);
            font-size: 1.3rem;
            font-weight: 600;
            text-align: left;
            flex: 1;
        }

        .plant-total {
            display: flex;
            flex-direction: column;
            align-items: center;
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 8px 15px;
            border: 1px solid #e9ecef;
        }

        .total-number {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-color);
        }

        .total-label {
            font-size: 0.8rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Status Summary with mini chart */
        .status-summary {
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }

        .status-chart {
            width: 180px;
            height: 180px;
            position: relative;
        }

        .status-pie-container {
            width: 100%;
            height: 100%;
        }

        /* Stats list improvements */
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
            padding: 10px 0;
            margin-bottom: 10px;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 0.95rem;
            font-weight: 500;
            flex: 1;
            display: flex;
            align-items: center;
        }

        .stat-indicator {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 8px;
            display: inline-block;
        }

        .stat-indicator.in-use { background-color: var(--success-color); }
        .stat-indicator.under-service { background-color: var(--warning-color); }
        .stat-indicator.expired { background-color: var(--danger-color); }
        .stat-indicator.expiring-soon { background-color: var(--alert-color); }

        .stat-value-container {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 2;
        }

        .progress-bar {
            height: 10px;
            background-color: #f1f1f1;
            border-radius: 5px;
            overflow: hidden;
            flex: 1;
        }

        .progress {
            height: 100%;
            border-radius: 5px;
            transition: width 1s ease-in-out;
        }

        .progress.in-use { background-color: var(--success-color); }
        .progress.under-service { background-color: var(--warning-color); }
        .progress.expired { background-color: var(--danger-color); }
        .progress.expiring-soon { background-color: var(--alert-color); }

        .stat-value {
            font-size: 1.1rem;
            font-weight: 600;
            min-width: 40px;
            text-align: right;
            white-space: nowrap;
        }

        .stat-value.in-use { color: var(--success-color); }
        .stat-value.under-service { color: var(--warning-color); }
        .stat-value.expired { color: var(--danger-color); }
        .stat-value.expiring-soon { color: var(--alert-color); }

        /* Enhanced responsive design */
        @media (max-width: 1200px) {
            .chart-section,
            .plants-section,
            .dashboard-header {
                min-width: auto;
                width: 100%;
            }
            
            .plants-grid {
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            }
        }

        @media (max-width: 768px) {
            .plant-header {
                flex-direction: column;
                gap: 10px;
                align-items: flex-start;
            }
            
            .plant-total {
                align-self: flex-end;
            }
            
            .status-chart {
                width: 150px;
                height: 150px;
            }
            
            .dashboard-container {
                padding: 10px;
            }
            
            .chart-section, 
            .plants-section {
                padding: 20px;
            }
        }

        @media (max-width: 576px) {
            .plants-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .plant-card {
                padding: 15px;
            }
            
            .stat-value-container {
                flex-direction: column;
                align-items: flex-end;
                gap: 5px;
            }
            
            .progress-bar {
                width: 100%;
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
            <!-- Main chart showing overall distribution of fire extinguisher types -->
            <section class="chart-section">
                <h3>Fire Extinguisher Types Distribution</h3>
                <div class="chart-container">
                    <canvas id="feTypeChart"></canvas>
                </div>
                <asp:HiddenField ID="hdnChartData" runat="server" />
            </section>

            <!-- Cards showing statistics for each plant with responsive charts -->
            <section class="plants-section">
                <h3>Plant Statistics</h3>
                <div class="plants-grid">
                    <asp:Repeater ID="rptPlants" runat="server">
                        <ItemTemplate>
                            <div class="plant-card">
                                <div class="plant-header">
                                    <div class="plant-title"><%# Eval("PlantName") %></div>
                                    <div class="plant-total">
                                        <span class="total-number"><%# Eval("TotalFE", "{0:N0}") %></span>
                                        <span class="total-label">Total FE</span>
                                    </div>
                                </div>
                                
                                <div class="status-summary">
                                    <div class="status-chart">
                                        <div class="status-pie-container">
                                            <canvas class="status-pie" 
                                                   data-in-use="<%# Eval("InUse") %>" 
                                                   data-under-service="<%# Eval("UnderService") %>" 
                                                   data-expired="<%# Eval("Expired") %>" 
                                                   data-expiring-soon="<%# Eval("ExpiringSoon") %>">
                                            </canvas>
                                        </div>
                                    </div>
                                </div>
                                
                                <ul class="stats-list">
                                    <!-- In-Use extinguishers with percentage bar -->
                                    <li class="stat-item">
                                        <span class="stat-label">
                                            <span class="stat-indicator in-use"></span>
                                            In Use
                                        </span>
                                        <div class="stat-value-container">
                                            <div class="progress-bar">
                                                <div class="progress in-use" 
                                                     style="width: <%# GetPercentage(Eval("InUse"), Eval("TotalFE")) %>%;">
                                                </div>
                                            </div>
                                            <span class="stat-value in-use"><%# Eval("InUse", "{0:N0}") %></span>
                                        </div>
                                    </li>
                                    <!-- Under service extinguishers with percentage bar -->
                                    <li class="stat-item">
                                        <span class="stat-label">
                                            <span class="stat-indicator under-service"></span>
                                            Under Service
                                        </span>
                                        <div class="stat-value-container">
                                            <div class="progress-bar">
                                                <div class="progress under-service" 
                                                     style="width: <%# GetPercentage(Eval("UnderService"), Eval("TotalFE")) %>%;">
                                                </div>
                                            </div>
                                            <span class="stat-value under-service"><%# Eval("UnderService", "{0:N0}") %></span>
                                        </div>
                                    </li>
                                    <!-- Expired extinguishers with percentage bar -->
                                    <li class="stat-item">
                                        <span class="stat-label">
                                            <span class="stat-indicator expired"></span>
                                            Expired
                                        </span>
                                        <div class="stat-value-container">
                                            <div class="progress-bar">
                                                <div class="progress expired" 
                                                     style="width: <%# GetPercentage(Eval("Expired"), Eval("TotalFE")) %>%;">
                                                </div>
                                            </div>
                                            <span class="stat-value expired"><%# Eval("Expired", "{0:N0}") %></span>
                                        </div>
                                    </li>
                                    <!-- Soon-to-expire extinguishers with percentage bar -->
                                    <li class="stat-item">
                                        <span class="stat-label">
                                            <span class="stat-indicator expiring-soon"></span>
                                            Expiring Soon
                                        </span>
                                        <div class="stat-value-container">
                                            <div class="progress-bar">
                                                <div class="progress expiring-soon" 
                                                     style="width: <%# GetPercentage(Eval("ExpiringSoon"), Eval("TotalFE")) %>%;">
                                                </div>
                                            </div>
                                            <span class="stat-value expiring-soon"><%# Eval("ExpiringSoon", "{0:N0}") %></span>
                                        </div>
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
            // Initialize the FE Type Distribution Chart
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
                                        index: i,
                                        hidden: !chart.getDataVisibility(i),
                                        lineWidth: 1,
                                        strokeStyle: '#666'
                                    }));
                                },
                                onClick: function(e, legendItem, legend) {
                                    const index = legendItem.index;
                                    const chart = legend.chart;
                                    
                                    chart.toggleDataVisibility(index);
                                    
                                    legend.options.labels.generateLabels(chart);
                                    
                                    chart.update();
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
            
            // Initialize individual status charts for each plant
            document.querySelectorAll('.status-pie').forEach(canvas => {
                const ctx = canvas.getContext('2d');
                const inUse = parseInt(canvas.getAttribute('data-in-use')) || 0;
                const underService = parseInt(canvas.getAttribute('data-under-service')) || 0;
                const expired = parseInt(canvas.getAttribute('data-expired')) || 0;
                const expiringSoon = parseInt(canvas.getAttribute('data-expiring-soon')) || 0;
                
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['In Use', 'Under Service', 'Expired', 'Expiring Soon'],
                        datasets: [{
                            data: [inUse, underService, expired, expiringSoon],
                            backgroundColor: [
                                '#28a745', // success-color
                                '#ffc107', // warning-color
                                '#dc3545', // danger-color
                                '#fd7e14'  // alert-color
                            ],
                            borderWidth: 1,
                            borderColor: '#ffffff'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: true,
                        cutout: '70%',
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        const label = context.label || '';
                                        const value = context.raw || 0;
                                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                        if (total === 0) return `${label}: ${value}`;
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
            
            // Animate progress bars on page load for visual effect
            setTimeout(() => {
                document.querySelectorAll('.progress').forEach(bar => {
                    const width = bar.style.width;
                    bar.style.width = '0%';
                    setTimeout(() => {
                        bar.style.width = width;
                    }, 100);
                });
            }, 300);
        });
    </script>
</asp:Content>