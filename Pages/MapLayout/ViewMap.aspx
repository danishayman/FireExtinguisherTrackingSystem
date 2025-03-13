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

        .map-container {
            display: flex;
            gap: 2rem;
            padding: 1rem;
            max-width: 1400px;
            margin: 0 auto;
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
            max-height: 600px;
            object-fit: contain;
            border: 1px solid #ddd;
            border-radius: 4px;
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
            border-collapse: collapse;
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
                        <asp:Image ID="imgMap" runat="server" CssClass="map-image" />
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