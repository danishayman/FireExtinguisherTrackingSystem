<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MapLayout.aspx.cs" Inherits="FETS.Pages.MapLayout.MapLayout" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .dashboard-container {
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .map-layout-section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .upload-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }

        .validation-error {
            color: #dc3545;
            font-size: 14px;
            margin-top: 5px;
            display: block;
        }

        .message {
            padding: 15px;
            margin-top: 20px;
            border-radius: 5px;
            display: block;
        }

        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .filter-section {
            margin-bottom: 20px;
        }

        .filter-row {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
        }

        .filter-group {
            flex: 1;
        }

        .maps-grid {
            margin-top: 20px;
        }

        .grid-view {
            width: 100%;
            border-collapse: collapse;
        }

        .grid-header {
            background-color: #f8f9fa;
            font-weight: 600;
            padding: 10px;
            text-align: left;
            border-bottom: 2px solid #dee2e6;
        }

        .grid-row, .grid-row-alt {
            border-bottom: 1px solid #dee2e6;
        }

        .grid-row-alt {
            background-color: #f8f9fa;
        }

        .grid-row td, .grid-row-alt td {
            padding: 10px;
        }

        .grid-pager {
            padding: 10px;
            text-align: center;
        }

        .grid-pager a {
            padding: 5px 10px;
            margin: 0 2px;
            border: 1px solid #dee2e6;
            text-decoration: none;
            color: #007bff;
        }

        .grid-pager a:hover {
            background-color: #f8f9fa;
        }

        .map-preview {
            max-width: 100px;
            max-height: 100px;
            border: 1px solid #dee2e6;
        }

        .action-buttons {
            display: flex;
            gap: 5px;
        }

        .btn-sm {
            padding: 5px 10px;
            font-size: 12px;
        }

        .empty-message {
            padding: 20px;
            text-align: center;
            color: #6c757d;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
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
                                            CommandArgument='<%# Eval("PlantID") + "," + Eval("LevelID") %>'
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
</asp:Content> 