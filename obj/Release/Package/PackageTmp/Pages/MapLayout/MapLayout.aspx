<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MapLayout.aspx.cs" Inherits="FETS.Pages.MapLayout.MapLayout" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>FETS - Map Layout</title>
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
                    <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn btn-logout">Back to Dashboard</asp:LinkButton>
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn btn-logout">Logout</asp:LinkButton>
                </div>
            </header>
            <div class="content-container">
                <div class="map-layout-section">
                    <h3>Map Layout Management</h3>
                    
                    <div class="upload-section">
                        <h4>Upload New Map</h4>
                        <div class="form-group">
                            <asp:Label ID="lblPlant" runat="server" Text="Plant:" AssociatedControlID="ddlPlant"></asp:Label>
                            <asp:DropDownList ID="ddlPlant" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPlant_SelectedIndexChanged" CausesValidation="false"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvPlant" runat="server" 
                                ControlToValidate="ddlPlant" 
                                ErrorMessage="Plant is required." 
                                CssClass="validation-error"
                                Display="Dynamic"
                                ValidationGroup="UploadMap"
                                InitialValue="">
                            </asp:RequiredFieldValidator>
                        </div>

                        <div class="form-group">
                            <asp:Label ID="lblLevel" runat="server" Text="Level:" AssociatedControlID="ddlLevel"></asp:Label>
                            <asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-control"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvLevel" runat="server" 
                                ControlToValidate="ddlLevel" 
                                ErrorMessage="Level is required." 
                                CssClass="validation-error"
                                Display="Dynamic"
                                ValidationGroup="UploadMap"
                                InitialValue="">
                            </asp:RequiredFieldValidator>
                        </div>

                        <div class="form-group">
                            <asp:Label ID="lblMapFile" runat="server" Text="Map Image:" AssociatedControlID="fuMapImage"></asp:Label>
                            <asp:FileUpload ID="fuMapImage" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator ID="rfvMapImage" runat="server" 
                                ControlToValidate="fuMapImage" 
                                ErrorMessage="Map image is required." 
                                CssClass="validation-error"
                                Display="Dynamic"
                                ValidationGroup="UploadMap">
                            </asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="revMapImage" runat="server"
                                ControlToValidate="fuMapImage"
                                ErrorMessage="Only image files (jpg, jpeg, png) are allowed."
                                ValidationExpression="^.*\.(jpg|jpeg|png|JPG|JPEG|PNG)$"
                                CssClass="validation-error"
                                Display="Dynamic"
                                ValidationGroup="UploadMap">
                            </asp:RegularExpressionValidator>
                        </div>

                        <div class="form-group">
                            <asp:Button ID="btnUpload" runat="server" Text="Upload Map" OnClick="btnUpload_Click" CssClass="btn btn-primary" ValidationGroup="UploadMap" />
                        </div>

                        <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                    </div>

                    <div class="view-maps-section">
                        <h4>View Maps</h4>
                        <div class="filter-section">
                            <div class="filter-row">
                                <div class="filter-group">
                                    <asp:Label ID="lblFilterPlant" runat="server" Text="Plant:" AssociatedControlID="ddlFilterPlant"></asp:Label>
                                    <asp:DropDownList ID="ddlFilterPlant" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterPlant_SelectedIndexChanged"></asp:DropDownList>
                                </div>
                                <div class="filter-group">
                                    <asp:Label ID="lblFilterLevel" runat="server" Text="Level:" AssociatedControlID="ddlFilterLevel"></asp:Label>
                                    <asp:DropDownList ID="ddlFilterLevel" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterLevel_SelectedIndexChanged"></asp:DropDownList>
                                </div>
                            </div>
                        </div>

                        <div class="maps-grid">
                            <asp:GridView ID="gvMaps" runat="server" 
                                AutoGenerateColumns="False" 
                                CssClass="grid-view"
                                AllowPaging="True"
                                PageSize="5"
                                OnPageIndexChanging="gvMaps_PageIndexChanging"
                                OnRowCommand="gvMaps_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="PlantName" HeaderText="Plant" />
                                    <asp:BoundField DataField="LevelName" HeaderText="Level" />
                                    <asp:BoundField DataField="UploadDate" HeaderText="Upload Date" DataFormatString="{0:d}" />
                                    <asp:TemplateField HeaderText="Preview">
                                        <ItemTemplate>
                                            <asp:Image ID="imgPreview" runat="server" ImageUrl='<%# GetMapImageUrl(Eval("ImagePath").ToString()) %>' CssClass="map-preview" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <div class="action-buttons">
                                                <asp:LinkButton ID="btnView" runat="server" 
                                                    CommandName="ViewMap" 
                                                    CommandArgument='<%# Eval("MapID") %>'
                                                    CssClass="btn btn-sm btn-primary"
                                                    Text="View" />
                                                <asp:LinkButton ID="btnDelete" runat="server" 
                                                    CommandName="DeleteMap" 
                                                    CommandArgument='<%# Eval("MapID") %>'
                                                    CssClass="btn btn-sm btn-danger"
                                                    Text="Delete"
                                                    OnClientClick="return confirm('Are you sure you want to delete this map?');" />
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <PagerStyle CssClass="grid-pager" />
                                <HeaderStyle CssClass="grid-header" />
                                <RowStyle CssClass="grid-row" />
                                <AlternatingRowStyle CssClass="grid-row-alt" />
                                <EmptyDataTemplate>
                                    <div class="empty-message">No maps found.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html> 