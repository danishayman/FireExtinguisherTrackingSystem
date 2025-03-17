<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewMap.aspx.cs" Inherits="FETS.Pages.MapLayout.ViewMap" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>View Map - FETS</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="../../Assets/css/styles.css" rel="stylesheet" />
    <style>
        .dashboard-container {
            min-height: 100vh;
            background-color: #f5f6fa;
        }

        .dashboard-header {
            background: #2c3e50;
            padding: 1rem 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
        }

        .dashboard-header h2 {
            margin: 0;
            color: white;
            font-size: 1.5rem;
            font-weight: 500;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: white;
        }

        .btn-logout {
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 4px;
            color: white;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .btn-logout:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.3);
            color: white;
        }

        .content-container {
            padding: 2rem;
        }

        map-container {
            width: 100%;
            height: 600px; /* Fixed height for the map container */
            overflow: hidden; /* Hide overflow when zoomed in */
            position: relative; /* Ensure proper positioning for child elements */
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .map-section {
            flex: 1;
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .map-section h3 {
            margin-bottom: 1rem;
            color: #333;
            font-size: 1.5rem;
            font-weight: 500;
        }

        .map-image {
            width: 100%;
            height: 100%;
            object-fit: cover; /* Ensure the image covers the container */
            transition: transform 0.3s ease; /* Smooth transition for zoom */
            transform-origin: center center; /* Zoom from the center */
            cursor: grab; /* Change cursor to indicate draggable */
        }
        
        .map-image:active {
            cursor: grabbing; /* Change cursor when dragging */
        }

        .map-image:hover {
            transform: scale(1.05); /* Slightly zoom in on hover */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Add shadow for focus effect */
            cursor: pointer; /* Change cursor to indicate interactivity */
        }

        .info-section {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .fe-count {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            font-size: 1.2rem;
            color: #333;
            font-weight: 500;
        }

        .fe-list {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            flex-grow: 1;
        }

        .fe-list h4 {
            margin-bottom: 1rem;
            color: #333;
            font-size: 1.2rem;
            font-weight: 500;
        }

        .fe-grid {
            width: 100%; 
        }

        .fe-grid th {
            background: #f8f9fa;
            padding: 0.75rem;
            text-align: left;
            border-bottom: 2px solid #ddd;
            font-weight: 500;
            color: #333;
        }

        .fe-grid td {
            padding: 0.75rem;
            border-bottom: 1px solid #ddd;
            color: #444;
        }

        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 4px;
            color: white;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .last-updated {
            font-size: 0.875rem;
            color: #666;
            margin-top: 0.75rem;
        }

        @media (max-width: 1024px) {
            .map-container {
                flex-direction: column;
            }
            
            .dashboard-header {
                flex-direction: column;
                text-align: center;
                gap: 1rem;
                padding: 1rem;
            }
            
            .user-info {
                flex-direction: column;
            }
        }
    </style>
</head>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const mapContainer = document.querySelector(".map-container");
            const mapImage = document.getElementById("<%= imgMap.ClientID %>");

            if (mapImage) {
                let isDragging = false;
                let startX, startY, scrollLeft, scrollTop;

                // Zoom in on mouse enter
                mapContainer.addEventListener("mouseenter", function () {
                    mapImage.style.transform = "scale(1.4)"; // Zoom in 2x
                });

                // Reset zoom on mouse leave
                mapContainer.addEventListener("mouseleave", function () {
                    mapImage.style.transform = "scale(0.8)"; // Reset to original size
                    mapImage.style.left = "0"; // Reset position
                    mapImage.style.top = "0";
                });

                // Start dragging
                mapContainer.addEventListener("mousedown", function (e) {
                    isDragging = true;
                    startX = e.pageX - mapContainer.offsetLeft;
                    startY = e.pageY - mapContainer.offsetTop;
                    scrollLeft = mapImage.offsetLeft;
                    scrollTop = mapImage.offsetTop;
                });

                // Stop dragging
                mapContainer.addEventListener("mouseup", function () {
                    isDragging = false;
                });

                // Pan the map while dragging
                mapContainer.addEventListener("mousemove", function (e) {
                    if (!isDragging) return;
                    e.preventDefault();

                    const x = e.pageX - mapContainer.offsetLeft;
                    const y = e.pageY - mapContainer.offsetTop;

                    const walkX = (x - startX) * 2; // Adjust pan speed
                    const walkY = (y - startY) * 2;

                    mapImage.style.left = `${scrollLeft - walkX}px`;
                    mapImage.style.top = `${scrollTop - walkY}px`;
                });
            }
        });
    </script>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-container">
            <header class="dashboard-header">
                <h2>Fire Extinguisher Tracking System</h2>
                <div class="user-info">
                    Welcome, <asp:Label ID="lblUsername" runat="server"></asp:Label>
                    <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn-logout">Back to Map Layout</asp:LinkButton>
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">Logout</asp:LinkButton>
                </div>
            </header>

            <div class="content-container">
                <div class="map-container">
                    <div class="map-section">
                        <h3>
                            <asp:Label ID="lblPlantName" runat="server"></asp:Label> - 
                            <asp:Label ID="lblLevelName" runat="server"></asp:Label>
                        </h3>
                        <asp:Image ID="imgMap" runat="server" CssClass="map-image" ClientIDMode="Static"/>
                        <div class="last-updated">  
                            Last Updated: <asp:Label ID="lblLastUpdated" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="info-section">
                        <div class="fe-count">
                            Total Fire Extinguishers: <asp:Label ID="lblFECount" runat="server"></asp:Label>
                        </div>
                        <div class="fe-list">
                            <h4>Fire Extinguishers in this Level</h4>
                            <asp:GridView ID="gvFireExtinguishers" runat="server" 
                                AutoGenerateColumns="False" 
                                CssClass="fe-grid"
                                OnRowDataBound="gvFireExtinguishers_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" />
                                    <asp:BoundField DataField="Location" HeaderText="Location" />
                                    <asp:BoundField DataField="TypeName" HeaderText="Type" />
                                    <asp:BoundField DataField="DateExpired" HeaderText="Expiry Date" DataFormatString="{0:d}" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <asp:Label ID="lblStatus" runat="server" CssClass="status-badge"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html> 