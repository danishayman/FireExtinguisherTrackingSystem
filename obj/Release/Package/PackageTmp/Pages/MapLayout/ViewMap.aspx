<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewMap.aspx.cs" Inherits="FETS.Pages.MapLayout.ViewMap" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>FETS - View Map</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="../../Assets/css/styles.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-container">
            <header class="dashboard-header">
                <h2>Fire Extinguisher Tracking System</h2>
                <div class="user-info">
                    Welcome, <asp:Label ID="lblUsername" runat="server"></asp:Label>
                    <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn btn-logout">Back to Maps</asp:LinkButton>
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn btn-logout">Logout</asp:LinkButton>
                </div>
            </header>
            <div class="content-container">
                <div class="map-viewer-section">
                    <div class="map-info">
                        <h3>
                            <asp:Label ID="lblPlantName" runat="server"></asp:Label> - 
                            <asp:Label ID="lblLevelName" runat="server"></asp:Label>
                        </h3>
                        <div class="map-details">
                            Upload Date: <asp:Label ID="lblUploadDate" runat="server"></asp:Label>
                        </div>
                    </div>
                    
                    <div class="map-container">
                        <asp:Image ID="imgMap" runat="server" CssClass="full-map" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html> 