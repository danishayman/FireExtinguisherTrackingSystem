
<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ViewSection.aspx.cs" Inherits="FETS.Pages.ViewSection.ViewSection" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="../../Assets/css/styles.css" rel="stylesheet" />
    <!-- Add Font Awesome for better icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <!-- Add Animate.css for smooth animations -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="main-card animate__animated animate__fadeIn">
                    <div class="dashboard-container">
                        <div class="content-container">
                            <div class="panels-layout">
                                <div class="view-section">
                                    <div class="section-header">
                                        <h3><i class="fas fa-fire-extinguisher"></i> View Fire Extinguishers</h3>
                                        <div class="section-actions">
                                            <button type="button" id="btnToggleFilters" class="btn btn-outline-primary btn-sm" onclick="toggleFilters()">
                                                <i class="fas fa-filter"></i> <span id="filterToggleText">Hide Filters</span>
                                            </button>
                                        </div>
                                    </div>
                                    
                                    <div id="filterContainer" class="filter-section card-container">
                                        <div class="card-header">
                                            <h4><i class="fas fa-search"></i> Search & Filter</h4>
                                        </div>
                                        <div class="filter-content">
                                        <div class="filter-row">
                                            <div class="filter-group">
                                                <asp:Label ID="lblFilterPlant" runat="server" Text="Plant:" AssociatedControlID="ddlFilterPlant"></asp:Label>
                                                    <div class="select-container">
                                                        <asp:DropDownList ID="ddlFilterPlant" runat="server" CssClass="form-control custom-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterPlant_SelectedIndexChanged"></asp:DropDownList>
                                                        <i class="fas fa-chevron-down select-arrow"></i>
                                                    </div>
                                            </div>
                                            <div class="filter-group">
                                                <asp:Label ID="lblFilterLevel" runat="server" Text="Level:" AssociatedControlID="ddlFilterLevel"></asp:Label>
                                                    <div class="select-container">
                                                        <asp:DropDownList ID="ddlFilterLevel" runat="server" CssClass="form-control custom-select" AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters"></asp:DropDownList>
                                                        <i class="fas fa-chevron-down select-arrow"></i>
                                                    </div>
                                            </div>
                                            <div class="filter-group">
                                                <asp:Label ID="lblFilterStatus" runat="server" Text="Status:" AssociatedControlID="ddlFilterStatus"></asp:Label>
                                                    <div class="select-container">
                                                        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control custom-select" AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters"></asp:DropDownList>
                                                        <i class="fas fa-chevron-down select-arrow"></i>
                                            </div>
                                                </div>
                                                <div class="filter-group search-group">
                                                <asp:Label ID="lblSearch" runat="server" Text="Search:" AssociatedControlID="txtSearch"></asp:Label>
                                                <div class="search-box">
                                                        <i class="fas fa-search search-icon"></i>
                                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Serial Number or Location"></asp:TextBox>
                                                </div>
                                                <div class="button-group">
                                                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="ApplyFilters" CssClass="btn btn-primary" />
                                                        <asp:Button ID="btnClearFilters" runat="server" Text="Clear" OnClick="btnClearFilters_Click" CssClass="btn btn-outline-secondary" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="expiry-filters">
                                                <div class="expiry-stats-container">
                                                <asp:Label ID="lblExpiryStats" runat="server" CssClass="expiry-stats"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="content-layout">
                                        <!-- Wrap the original monitoring section with UpdatePanel -->
                                        <asp:UpdatePanel ID="upMonitoring" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div class="monitoring-section card-container animate__animated animate__fadeIn">
                                                    <div class="card-header">
                                                        <h4><i class="fas fa-chart-line"></i> Monitoring Panel</h4>
                                                    </div>
                                                    <div class="monitoring-panel">
                                                        <div class="tab-container">
                                                            <div class="panel-header">
                                                                <div class="modern-tabs">
                                                                    <asp:LinkButton ID="btnExpiredTab" runat="server" OnClick="btnExpiredTab_Click" CssClass='<%# GetTabButtonClass("expired") %>' CausesValidation="false">
                                                                        <i class="fas fa-exclamation-circle text-danger"></i> Expired (<span class="badge badge-danger"><%= ExpiredCount %></span>)
                                                                    </asp:LinkButton>
                                                                    <asp:LinkButton ID="btnExpiringSoonTab" runat="server" OnClick="btnExpiringSoonTab_Click" CssClass='<%# GetTabButtonClass("expiringSoon") %>' CausesValidation="false">
                                                                        <i class="fas fa-clock text-warning"></i> Expiring Soon (<span class="badge badge-warning"><%= ExpiringSoonCount %></span>)
                                                                    </asp:LinkButton>
                                                                    <asp:LinkButton ID="btnUnderServiceTab" runat="server" OnClick="btnUnderServiceTab_Click" CssClass='<%# GetTabButtonClass("underService") %>' CausesValidation="false">
                                                                        <i class="fas fa-tools text-info"></i> Under Service (<span class="badge badge-info"><%= UnderServiceCount %></span>)
                                                                    </asp:LinkButton>
                                                                </div>
                                                                <asp:LinkButton ID="btnSendAllToService" runat="server" 
                                                                    CssClass="btn btn-warning btn-sm action-button"
                                                                    OnClick="btnSendAllToService_Click"
                                                                    CausesValidation="false"
                                                                    OnClientClick="return confirm('Are you sure you want to send all expired and expiring soon fire extinguishers for service?');">
                                                                    <i class="fas fa-truck-loading mr-1"></i> Send All to Service
                                                                </asp:LinkButton>
                                                            </div>

                                                            <div class="tab-content">
                                                            <asp:MultiView ID="mvMonitoring" runat="server" ActiveViewIndex="0">
                                                                <asp:View ID="vwExpired" runat="server">
                                                                        <div class="status-indicator expired">
                                                                            <i class="fas fa-exclamation-triangle"></i> Showing expired fire extinguishers
                                                                        </div>
                                                                    <asp:GridView ID="gvExpired" runat="server" 
                                                                        AutoGenerateColumns="False" 
                                                                        CssClass="grid-view monitoring-grid"
                                                                        AllowPaging="True"
                                                                        PageSize="5"
                                                                        OnPageIndexChanging="gvExpired_PageIndexChanging"
                                                                        OnRowCommand="gvExpired_RowCommand"
                                                                            EmptyDataText="<div class='empty-state'><i class='fas fa-check-circle'></i><p>No expired fire extinguishers found.</p></div>"
                                                                        PagerStyle-CssClass="grid-pager"
                                                                        PagerSettings-Mode="NumericFirstLast"
                                                                        PagerSettings-FirstPageText="First"
                                                                        PagerSettings-LastPageText="Last"
                                                                        PagerSettings-PageButtonCount="5">
                                                                        <Columns>
                                                                            <asp:TemplateField HeaderText="No">
                                                                                <ItemTemplate>
                                                                                    <%# Container.DataItemIndex + 1 %>
                                                                                </ItemTemplate>
                                                                                <ItemStyle HorizontalAlign="Center" />
                                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                            </asp:TemplateField>
                                                                            <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="PlantName" HeaderText="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="LevelName" HeaderText="Level" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="TypeName" HeaderText="Type" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="DateExpired" HeaderText="Expiry Date" DataFormatString="{0:d}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="DaysExpired" HeaderText="Days Expired" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                                                <ItemTemplate>
                                                                                    <asp:LinkButton ID="btnSendToService" runat="server" 
                                                                                        CommandName="SendForService" 
                                                                                        CommandArgument='<%# Eval("FEID") %>'
                                                                                        CssClass="btn btn-warning btn-sm"
                                                                                            OnClientClick='<%# "return showSendToServiceConfirmation(\"" + Eval("FEID") + "\");" %>'>
                                                                                        Send to Service
                                                                                    </asp:LinkButton>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </asp:View>

                                                                <asp:View ID="vwExpiringSoon" runat="server">
                                                                        <div class="status-indicator expiring-soon">
                                                                            <i class="fas fa-exclamation-triangle"></i> Showing expiring soon fire extinguishers
                                                                        </div>
                                                                    <asp:GridView ID="gvExpiringSoon" runat="server" 
                                                                        AutoGenerateColumns="False" 
                                                                        CssClass="grid-view monitoring-grid"
                                                                        AllowPaging="True"
                                                                        PageSize="5"
                                                                        OnPageIndexChanging="gvExpiringSoon_PageIndexChanging"
                                                                        OnRowCommand="gvExpiringSoon_RowCommand"
                                                                            EmptyDataText="<div class='empty-state'><i class='fas fa-check-circle'></i><p>No fire extinguishers expiring soon.</p></div>"
                                                                        PagerStyle-CssClass="grid-pager"
                                                                        PagerSettings-Mode="NumericFirstLast"
                                                                        PagerSettings-FirstPageText="First"
                                                                        PagerSettings-LastPageText="Last"
                                                                        PagerSettings-PageButtonCount="5">
                                                                        <Columns>
                                                                            <asp:TemplateField HeaderText="No">
                                                                                <ItemTemplate>
                                                                                    <%# Container.DataItemIndex + 1 %>
                                                                                </ItemTemplate>
                                                                                <ItemStyle HorizontalAlign="Center" />
                                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                            </asp:TemplateField>
                                                                            <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="PlantName" HeaderText="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="LevelName" HeaderText="Level" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="TypeName" HeaderText="Type" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="DateExpired" HeaderText="Expiry Date" DataFormatString="{0:d}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="DaysLeft" HeaderText="Days Left" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                                                <ItemTemplate>
                                                                                    <asp:LinkButton ID="btnSendToService" runat="server"
                                                                                        CommandName="SendForService"
                                                                                        CommandArgument='<%# Eval("FEID") %>'
                                                                                        CssClass="btn btn-warning btn-sm"
                                                                                            OnClick="btnSendToService_Click"
                                                                                            Text="Send to Service" />
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </asp:View>

                                                                <asp:View ID="vwUnderService" runat="server">
                                                                        <div class="status-indicator under-service">
                                                                            <i class="fas fa-exclamation-triangle"></i> Showing fire extinguishers under service
                                                                        </div>
                                                                    <asp:GridView ID="gvUnderService" runat="server" 
                                                                        AutoGenerateColumns="False" 
                                                                        CssClass="grid-view monitoring-grid"
                                                                        AllowPaging="True"
                                                                        PageSize="5"
                                                                        OnPageIndexChanging="gvUnderService_PageIndexChanging"
                                                                        OnRowCommand="gvUnderService_RowCommand"
                                                                            EmptyDataText="<div class='empty-state'><i class='fas fa-check-circle'></i><p>No fire extinguishers under service.</p></div>"
                                                                        PagerStyle-CssClass="grid-pager"
                                                                        PagerSettings-Mode="NumericFirstLast"
                                                                        PagerSettings-FirstPageText="First"
                                                                        PagerSettings-LastPageText="Last"
                                                                        PagerSettings-PageButtonCount="5">
                                                                        <Columns>
                                                                            <asp:TemplateField HeaderText="No">
                                                                                <ItemTemplate>
                                                                                    <%# Container.DataItemIndex + 1 %>
                                                                                </ItemTemplate>
                                                                                <ItemStyle HorizontalAlign="Center" />
                                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                            </asp:TemplateField>
                                                                            <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="PlantName" HeaderText="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="LevelName" HeaderText="Level" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="TypeName" HeaderText="Type" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField DataField="DateExpired" HeaderText="Previous Expiry Date" DataFormatString="{0:d}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                            <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                                                <ItemTemplate>
                                                                                    <asp:Button ID="btnCompleteService" runat="server" 
                                                                                        CommandName="CompleteService" 
                                                                                        CommandArgument='<%# Eval("FEID") %>'
                                                                                        data-feid='<%# Eval("FEID") %>'
                                                                                        CssClass="btn btn-success btn-sm"
                                                                                        Text="Complete Service"
                                                                                        OnClientClick='<%# "return showExpiryDatePanel(this);" %>' />
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </asp:View>
                                                            </asp:MultiView>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Expiry Date Panel -->
                                                <asp:Panel ID="pnlExpiryDate" runat="server" CssClass="modal-panel" Style="display: none;">
                                                    <div class="modal-content">
                                                        <h4>Enter New Expiry Date</h4>
                                                        <asp:HiddenField ID="hdnSelectedFEID" runat="server" />
                                                        <div class="form-group">
                                                            <asp:Label ID="lblNewExpiryDate" runat="server" Text="New Expiry Date:" AssociatedControlID="txtNewExpiryDate"></asp:Label>
                                                            <asp:TextBox ID="txtNewExpiryDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                                                            <asp:RequiredFieldValidator ID="rfvNewExpiryDate" runat="server" 
                                                                ControlToValidate="txtNewExpiryDate"
                                                                ErrorMessage="Please enter a new expiry date"
                                                                Display="Dynamic"
                                                                ValidationGroup="ExpiryDate"
                                                                CssClass="validation-error">
                                                            </asp:RequiredFieldValidator>
                                                        </div>
                                                        <div class="button-group">
                                                            <asp:Button ID="btnSaveExpiryDate" runat="server" 
                                                                Text="Confirm" 
                                                                CssClass="btn btn-primary"
                                                                ValidationGroup="ExpiryDate"
                                                                OnClick="btnSaveExpiryDate_Click"
                                                                UseSubmitBehavior="false" />
                                                            <button type="button" class="btn btn-secondary" onclick="hideExpiryDatePanel()">Cancel</button>
                                                        </div>
                                                    </div>
                                                </asp:Panel>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnExpiredTab" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnExpiringSoonTab" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnUnderServiceTab" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnSendAllToService" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnSaveExpiryDate" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>

                                        <asp:UpdatePanel ID="upMainGrid" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div class="grid-section card-container animate__animated animate__fadeIn">
                                                    <div class="card-header">
                                                        <h4><i class="fas fa-list"></i> Fire Extinguisher List</h4>
                                                        <div class="card-actions">
                                                            <asp:LinkButton ID="btnShowSelection" runat="server" 
                                                                CssClass="btn btn-warning btn-sm" 
                                                                OnClick="btnShowSelection_Click" 
                                                                OnClientClick="showServiceSelectionPanel(); return true;"
                                                                CausesValidation="false">
                                                                <i class="fas fa-truck-loading mr-1"></i> Send Multiple to Service
                                                            </asp:LinkButton>
                                                        </div>
                                                    </div>
                                                    <div class="grid-container">
                                                        <div class="loading-indicator" id="gridLoadingIndicator" style="display: none;">
                                                            <div class="spinner-border text-primary" role="status">
                                                                <span class="sr-only">Loading...</span>
                                                            </div>
                                                            <p>Loading data...</p>
                                                        </div>
                                                    <asp:GridView ID="gvFireExtinguishers" runat="server" 
                                                        AutoGenerateColumns="False" 
                                                            CssClass="grid-view main-grid"
                                                        AllowPaging="True"
                                                        AllowSorting="True"
                                                        OnPageIndexChanging="gvFireExtinguishers_PageIndexChanging"
                                                        OnSorting="gvFireExtinguishers_Sorting"
                                                        OnRowDataBound="gvFireExtinguishers_RowDataBound"
                                                        OnRowCommand="gvFireExtinguishers_RowCommand"
                                                            EmptyDataText="<div class='empty-state'><i class='fas fa-search'></i><p>No fire extinguishers found matching your criteria.</p></div>"
                                                        PagerStyle-CssClass="grid-pager"
                                                        PagerSettings-Mode="NumericFirstLast"
                                                            PagerSettings-FirstPageText="<i class='fas fa-angle-double-left'></i>"
                                                            PagerSettings-LastPageText="<i class='fas fa-angle-double-right'></i>"
                                                            PagerSettings-PreviousPageText="<i class='fas fa-angle-left'></i>"
                                                            PagerSettings-NextPageText="<i class='fas fa-angle-right'></i>"
                                                        PagerSettings-PageButtonCount="5">
                                                        <Columns>
                                                            <asp:TemplateField HeaderText="No">
                                                                <ItemTemplate>
                                                                    <%# Container.DataItemIndex + 1 %>
                                                                </ItemTemplate>
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:TemplateField>
                                                                <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                <asp:BoundField DataField="PlantName" HeaderText="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                <asp:BoundField DataField="LevelName" HeaderText="Level" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                <asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                <asp:BoundField DataField="TypeName" HeaderText="Type" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                                <asp:BoundField DataField="DateExpired" HeaderText="Expiry Date" DataFormatString="{0:d}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                            <asp:TemplateField HeaderText="Status" SortExpression="StatusName">
                                                                <ItemTemplate>
                                                                    <asp:Label ID="lblStatus" runat="server" CssClass="status-badge"></asp:Label>
                                                                </ItemTemplate>
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:TemplateField>
                                                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" SortExpression="Remarks">
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:TemplateField HeaderText="Actions">
                                                                <ItemTemplate>
                                                                    <div class="action-buttons">
                                                                        <asp:Button ID="btnCompleteService" runat="server" 
                                                                            CommandName="CompleteService" 
                                                                            CommandArgument='<%# Eval("FEID") %>'
                                                                            data-feid='<%# Eval("FEID") %>'
                                                                            CssClass='<%# Eval("StatusName").ToString() == "Under Service" ? "btn btn-sm btn-success" : "btn btn-sm btn-success disabled-service" %>'
                                                                            Text="Complete Service"
                                                                            Enabled='<%# Eval("StatusName").ToString() == "Under Service" %>'
                                                                            OnClientClick="return showExpiryDatePanel(this);" />
                                                                        <asp:Button ID="btnSendForService" runat="server" 
                                                                            CommandName="SendForService" 
                                                                            CommandArgument='<%# Eval("FEID") %>'
                                                                            Value='<%# Eval("FEID") %>'
                                                                            CssClass='<%# (DateTime.Parse(Eval("DateExpired").ToString()) <= DateTime.Now || 
                                                                                  (DateTime.Parse(Eval("DateExpired").ToString()) - DateTime.Now).TotalDays <= 60) &&
                                                                                  Eval("StatusName").ToString() != "Under Service" 
                                                                                  ? "btn btn-sm btn-warning" : "btn btn-sm btn-warning disabled-service" %>'
                                                                            Text="Send for Service"
                                                                            Enabled='<%# (DateTime.Parse(Eval("DateExpired").ToString()) <= DateTime.Now || 
                                                                                  (DateTime.Parse(Eval("DateExpired").ToString()) - DateTime.Now).TotalDays <= 60) &&
                                                                                  Eval("StatusName").ToString() != "Under Service" %>'
                                                                            OnClientClick='<%# "return showSendToServiceConfirmation(" + Eval("FEID") + ");" %>' />
                                                                        <asp:Button ID="btnDelete" runat="server" 
                                                                            CommandName="DeleteRow" 
                                                                            CommandArgument='<%# Eval("FEID") %>'
                                                                            CssClass="btn btn-sm btn-danger"
                                                                            Text="Delete"
                                                                            OnClientClick="return confirm('Are you sure you want to delete this fire extinguisher?');" />
                                                                    </div>
                                                                </ItemTemplate>
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                    </div>
                                                </div>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnSaveExpiryDate" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnConfirmSelection" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="ddlFilterPlant" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="ddlFilterLevel" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="ddlFilterStatus" EventName="SelectedIndexChanged" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <asp:UpdatePanel ID="upServiceSelection" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlServiceSelection" runat="server" Width="100%" CssClass="modal-panel" Visible="false">
            <div class="modal-content service-selection-modal">
                <div class="modal-header">
                    <h4 class="modal-title">Select Fire Extinguishers to Service</h4>
                </div>
                <div class="modal-body">
                    <p class="selection-instruction">Select the fire extinguishers you want to send for service from the list below:</p>
                    <div class="grid-container">
                        <asp:GridView ID="gvServiceSelection" runat="server" Width="100%" AutoGenerateColumns="false" DataKeyNames="FEID" 
                            CssClass="grid-view selection-grid" HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row"
                            AlternatingRowStyle-CssClass="grid-row-alt">
                            <Columns>
                                <asp:TemplateField HeaderText="Select" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="80px">
                                    <HeaderTemplate>
                                        <input type="checkbox" onclick="toggleAllCheckboxes(this)" id="chkSelectAll" class="selection-checkbox" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSelect" runat="server" CssClass="selection-checkbox" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="150px" />
                                <asp:BoundField DataField="PlantName" HeaderText="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="150px" />
                                <asp:BoundField DataField="LevelName" HeaderText="Level" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="120px" />
                                <asp:BoundField DataField="TypeName" HeaderText="Type" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="120px" />
                                <asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="250px" />
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="empty-data-message">No fire extinguishers available to send for service.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnConfirmSelection" runat="server" Text="Confirm Selection" CssClass="btn btn-primary btn-lg" OnClick="btnConfirmSelection_Click" />
                    <asp:Button ID="btnCancelSelection" runat="server" Text="Cancel" CssClass="btn btn-secondary btn-lg" OnClick="btnCancelSelection_Click" OnClientClick="hideServiceSelectionPanel(); return true;" />
                </div>
            </div>
        </asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>

    <!-- Send to Service Confirmation Modal -->
    <asp:UpdatePanel ID="upServiceConfirmation" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Panel ID="pnlSendToService" runat="server" CssClass="modal-panel" Style="display: none;">
                <div class="modal-content">
                    <h4>Send to Service Confirmation</h4>
                    <asp:HiddenField ID="hdnSelectedFEIDForService" runat="server" />
                    <div class="confirmation-message">
                        <p>The following fire extinguisher(s) will be sent for service:</p>
                        <asp:GridView ID="gvServiceConfirmation" runat="server" AutoGenerateColumns="False" CssClass="confirmation-grid">
                            <Columns>
                                <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="PlantName" HeaderText="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="LevelName" HeaderText="Level" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="DateExpired" HeaderText="Expiry Date" DataFormatString="{0:d}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="StatusName" HeaderText="Status" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                            </Columns>
                        </asp:GridView>
                        <p>This will change their status to "Under Service".</p>
                    </div>
                    <div class="button-group mt-3">
                        <asp:Button ID="btnConfirmSendToService" runat="server" Text="Confirm" CssClass="btn btn-warning" OnClick="btnConfirmSendToService_Click" UseSubmitBehavior="false" />
                        <asp:Button ID="btnCancelSendToService" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClientClick="hideSendToServicePanel(); return false;" UseSubmitBehavior="false" />
                    </div>
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <div id="modalOverlay" class="modal-overlay" style="display: none;"></div>

    <style type="text/css">
        /* Update the width-related styles for dynamic adjustment with sidebar */
        .filter-section,
        .monitoring-section,
        .grid-section,
        .content-layout {
            width: 100%;
            transition: all 0.3s ease;
        }

        /* Main card styling */
        .main-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            margin-bottom: 20px;
        }

        /* Card container styling */
        .card-container {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
            overflow: hidden;
        }

        .card-header {
            background-color: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .card-header h4 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
            color: #333;
            display: flex;
            align-items: center;
        }

        .card-header h4 i {
            margin-right: 10px;
            color: #007bff;
        }

        .card-actions {
            display: flex;
            gap: 10px;
        }

        /* Section header styling */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding: 0 10px;
        }

        .section-header h3 {
            font-size: 24px;
            font-weight: 600;
            margin: 0;
            color: #333;
            display: flex;
            align-items: center;
        }

        .section-header h3 i {
            margin-right: 10px;
            color: #007bff;
        }

        .section-actions {
            display: flex;
            gap: 10px;
        }

        /* Filter section styling */
        .filter-section {
            margin-bottom: 20px;
        }

        .filter-content {
            padding: 20px;
        }

        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 15px;
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
        }

        .search-group {
            flex: 2;
            display: flex;
            flex-direction: column;
        }

        .select-container {
            position: relative;
        }

        .select-arrow {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
            color: #6c757d;
        }

        .custom-select {
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            padding-right: 30px;
        }

        .search-box {
            position: relative;
            margin-bottom: 10px;
        }

        .search-icon {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
        }

        .search-box .form-control {
            padding-left: 35px;
        }

        .button-group {
            display: flex;
            gap: 10px;
        }

        .expiry-stats-container {
            background-color: #f8f9fa;
            padding: 10px 15px;
            border-radius: 4px;
            border-left: 4px solid #007bff;
        }

        /* Monitoring section styling */
        .monitoring-section {
            margin-bottom: 20px;
        }

        .monitoring-panel {
            padding: 0;
        }

        .modern-tabs {
            display: flex;
            border-bottom: 1px solid #dee2e6;
            margin-bottom: 15px;
        }

        .tab-button {
            padding: 10px 15px;
            background: none;
            border: none;
            color: #6c757d;
            cursor: pointer;
            font-weight: 500;
            position: relative;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .tab-button i {
            margin-right: 5px;
        }

        .tab-button.active {
            color: #007bff;
            font-weight: 600;
        }

        .tab-button.active::after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 0;
            width: 100%;
            height: 3px;
            background-color: #007bff;
        }

        .tab-content {
            padding: 15px;
        }

        /* Status indicators */
        .status-indicator {
            padding: 10px 15px;
            margin-bottom: 15px;
            border-radius: 4px;
            font-weight: 500;
            display: flex;
            align-items: center;
        }

        .status-indicator i {
            margin-right: 10px;
        }

        .status-indicator.expired {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
            border-left: 4px solid #dc3545;
        }

        .status-indicator.expiring-soon {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
            border-left: 4px solid #ffc107;
        }

        .status-indicator.under-service {
            background-color: rgba(23, 162, 184, 0.1);
            color: #17a2b8;
            border-left: 4px solid #17a2b8;
        }

        /* Grid styling */
        .grid-container {
            position: relative;
            padding: 15px;
        }

        .grid-view {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 0;
        }

        .grid-view th {
            background-color: #f8f9fa;
            padding: 12px 10px;
            border: 1px solid #dee2e6;
            font-weight: 600;
            color: #495057;
        }

        .grid-view td {
            padding: 12px 10px;
            border: 1px solid #dee2e6;
            vertical-align: middle;
        }

        .grid-view tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .grid-view tr:hover {
            background-color: #f2f2f2;
        }

        .grid-pager {
            padding: 10px;
            text-align: center;
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
        }

        .grid-pager a, .grid-pager span {
            display: inline-block;
            padding: 5px 10px;
            margin: 0 2px;
            border-radius: 4px;
        }

        .grid-pager a {
            background-color: #fff;
            border: 1px solid #dee2e6;
            color: #007bff;
            text-decoration: none;
        }

        .grid-pager span {
            background-color: #007bff;
            border: 1px solid #007bff;
            color: #fff;
        }

        /* Status badge styling */
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
            min-width: 100px;
        }

        /* Action buttons styling */
        .action-buttons {
            display: flex;
            gap: 5px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .action-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
        }

        /* Empty state styling */
        .empty-state {
            padding: 30px;
            text-align: center;
            color: #6c757d;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            color: #dee2e6;
        }

        .empty-state p {
            font-size: 16px;
            margin: 0;
        }

        /* Loading indicator */
        .loading-indicator {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 255, 255, 0.8);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 10;
        }

        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #007bff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Responsive adjustments */
        @media (max-width: 992px) {
            .filter-group {
                min-width: 150px;
            }
        }

        @media (max-width: 768px) {
            .filter-row {
                flex-direction: column;
                gap: 10px;
            }
            
            .filter-group {
            width: 100%;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .grid-view {
                font-size: 14px;
            }
            
            .card-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .card-header h4 {
                margin-bottom: 10px;
            }
        }

        /* Update the heading styles */
        .view-section h3 {
            text-align: center;
            margin: 0 0 30px 0;
            color: #333;
            font-size: 1.75rem;
            font-weight: 600;
            padding-bottom: 15px;
            border-bottom: 2px solid #007bff;
        }

        /* Update the button styles */
        .filter-group .button-group .btn {
            padding: 8px 16px;
            font-size: 0.95rem;
            min-width: 120px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            height: auto;
            white-space: nowrap;
        }

        /* Specific style for the Clear Filters button */
        .filter-group .button-group .btn-secondary {
            background-color: #6c757d;
            color: white;
            border: none;
            font-weight: 500;
        }

        .filter-group .button-group .btn-secondary:hover {
            background-color: #5a6268;
        }

        /* Add width control to the MultiView */
        .monitoring-panel .tab-container > div {
            width: 100%;
            min-width: 960px;
        }

        @media (max-width: 992px) {
            .service-selection-modal {
                min-width: 800px;
                min-height: 500px;
            }
        }

        #serviceSummaryPanel {
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 6px;
            margin-top: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        #serviceSummaryPanel h4 {
            margin-bottom: 15px;
            color: #495057;
            font-weight: 600;
        }

        #serviceSummaryPanel .summary-row {
            display: flex;
            margin-bottom: 10px;
            align-items: center;
        }

        #serviceSummaryPanel .summary-label {
            font-weight: 600;
            width: 180px;
            color: #495057;
        }

        #serviceSummaryPanel .summary-value {
            flex: 1;
        }
    </style>

    <style>
        /* Loading spinner */
        .spinner-border {
            display: inline-block;
            width: 2rem;
            height: 2rem;
            border: 0.25em solid currentColor;
            border-right-color: transparent;
            border-radius: 50%;
            animation: spinner-border .75s linear infinite;
        }
        
        .spinner-border.text-primary {
            color: #007bff;
        }
        
        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }
        
        @keyframes spinner-border {
            to { transform: rotate(360deg); }
        }
        
        .loading-indicator {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            text-align: center;
            color: #6c757d;
            font-weight: 500;
        }
        
        .loading-indicator p {
            margin-top: 1rem;
        }
    </style>

    <script type="text/javascript">
        // Add scroll position management
        var scrollPosition;

        function saveScrollPosition() {
            scrollPosition = window.scrollY;
        }

        function restoreScrollPosition() {
            if (scrollPosition !== undefined) {
                window.scrollTo(0, scrollPosition);
            }
        }

        // Show loading indicators during async operations
        function showLoading(gridId) {
            document.getElementById(gridId + 'LoadingIndicator').style.display = 'flex';
        }

        function hideLoading(gridId) {
            document.getElementById(gridId + 'LoadingIndicator').style.display = 'none';
        }

        // Toggle filter section visibility
        function toggleFilters() {
            var filterContainer = document.getElementById('filterContainer');
            var filterContent = filterContainer.querySelector('.filter-content');
            var toggleText = document.getElementById('filterToggleText');
            
            if (filterContent.style.display === 'none') {
                filterContent.style.display = 'block';
                toggleText.innerText = 'Hide Filters';
                filterContainer.classList.remove('filters-collapsed');
            } else {
                filterContent.style.display = 'none';
                toggleText.innerText = 'Show Filters';
                filterContainer.classList.add('filters-collapsed');
            }
        }

        // Add row hover effect
        function addRowHoverEffect() {
            var tables = document.querySelectorAll('.grid-view');
            tables.forEach(function(table) {
                var rows = table.querySelectorAll('tr');
                rows.forEach(function(row) {
                    row.addEventListener('mouseenter', function() {
                        this.classList.add('row-hover');
                    });
                    row.addEventListener('mouseleave', function() {
                        this.classList.remove('row-hover');
                    });
                });
            });
        }

        // Initialize toast notifications
        function showNotification(message, type = 'success') {
            var toast = document.createElement('div');
            toast.className = 'toast-notification ' + type;
            
            var icon = document.createElement('i');
            if (type === 'success') {
                icon.className = 'fas fa-check-circle';
            } else if (type === 'error') {
                icon.className = 'fas fa-exclamation-circle';
            } else if (type === 'warning') {
                icon.className = 'fas fa-exclamation-triangle';
            } else {
                icon.className = 'fas fa-info-circle';
            }
            
            var messageSpan = document.createElement('span');
            messageSpan.textContent = message;
            
            toast.appendChild(icon);
            toast.appendChild(messageSpan);
            
            document.body.appendChild(toast);
            
            setTimeout(function() {
                toast.classList.add('show');
            }, 100);
            
            setTimeout(function() {
                toast.classList.remove('show');
                setTimeout(function() {
                    document.body.removeChild(toast);
                }, 300);
            }, 5000);
        }

        // Add service selection panel functionality
        function showServiceSelectionPanel() {
            document.getElementById('modalOverlay').style.display = 'block';
            return true; // Allow the postback to occur
        }
        
        function hideServiceSelectionPanel() {
            document.getElementById('modalOverlay').style.display = 'none';
            return false; // Prevent default button behavior
        }

        // Add expiry date panel functionality
        function showExpiryDatePanel(button) {
            var feId = button.getAttribute('data-feid');
            document.getElementById('hidSelectedFEID').value = feId;
            document.getElementById('pnlExpiryDate').style.display = 'block';
            return false; // Prevent default button behavior
        }
        
        function hideExpiryDatePanel() {
            document.getElementById('pnlExpiryDate').style.display = 'none';
            return false; // Prevent default button behavior
        }

        // Add service confirmation functionality
        function showSendToServiceConfirmation(feId) {
            document.getElementById('hidServiceFEID').value = feId;
            document.getElementById('pnlSendToService').style.display = 'block';
            return false; // Prevent default button behavior
        }
        
        function hideSendToServiceConfirmation() {
            document.getElementById('pnlSendToService').style.display = 'none';
            return false; // Prevent default button behavior
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Add row hover effects
            addRowHoverEffect();
            
            // Register for async postback events
            if (typeof Sys !== 'undefined' && Sys.WebForms) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
                
            prm.add_beginRequest(function() {
                saveScrollPosition();
                    document.getElementById('gridLoadingIndicator').style.display = 'flex';
            });
                
            prm.add_endRequest(function() {
                    document.getElementById('gridLoadingIndicator').style.display = 'none';
                restoreScrollPosition();
                    addRowHoverEffect();
                    
                    // Re-initialize any dynamic elements after partial postback
                    var filterContent = document.querySelector('.filter-content');
                    if (filterContent) {
                        var toggleText = document.getElementById('filterToggleText');
                        if (toggleText && toggleText.innerText === 'Show Filters') {
                            filterContent.style.display = 'none';
                        }
                    }
                });
            }
        });
    </script>

<style>
    .toast-notification {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        background-color: white;
        color: #333;
        border-radius: 4px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        display: flex;
        align-items: center;
        gap: 10px;
        z-index: 9999;
        transform: translateX(120%);
        transition: transform 0.3s ease;
        max-width: 350px;
    }
    
    .toast-notification.show {
        transform: translateX(0);
    }
    
    .toast-notification i {
        font-size: 20px;
    }
    
    .toast-notification.success i {
        color: #28a745;
    }
    
    .toast-notification.error i {
        color: #dc3545;
    }
    
    .toast-notification.warning i {
        color: #ffc107;
    }
    
    .toast-notification.info i {
        color: #17a2b8;
    }

    /* Row hover effect */
    .row-hover {
        background-color: #f0f7ff !important;
        transition: background-color 0.2s ease;
    }

    /* Filter collapse animation */
    .filters-collapsed {
        max-height: 60px;
        overflow: hidden;
    }

    .filter-content {
        transition: all 0.3s ease;
    }

    /* Modal styling */
    .modal-panel {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 1000;
        display: flex;
        justify-content: center;
        align-items: center;
        backdrop-filter: blur(3px);
    }

    .modal-content {
        background-color: white;
        padding: 25px;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        width: 90%;
        max-width: 450px;
        animation: modalFadeIn 0.3s ease;
    }

    @keyframes modalFadeIn {
        from { opacity: 0; transform: translate(-50%, -60%); }
        to { opacity: 1; transform: translate(-50%, -50%); }
    }
</style>
</asp:Content>
