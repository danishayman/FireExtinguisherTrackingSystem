<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ViewSection.aspx.cs"
    Inherits="FETS.Pages.ViewSection.ViewSection" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="../../Assets/css/styles.css" rel="stylesheet" />
</asp:Content>

    <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="dashboard-container">
                            <div class="content-container">
                                <div class="panels-layout">
                                    <div class="view-section">
                                        <!-- STEP 1: First place the Monitoring Panel -->
                                        <asp:UpdatePanel ID="upMonitoring" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div class="monitoring-section">
                                                    <div class="monitoring-panel">
                                                        <h3 class="section-title">Monitoring Panel</h3>
                                                        <div class="tab-container">
                                                            <div class="panel-header">
                                                                <div class="tab-buttons">
                                                                    <asp:LinkButton ID="btnExpiredTab"
                                                                        runat="server" OnClick="btnExpiredTab_Click"
                                                                        CssClass='<%# GetTabButtonClass("expired") %>'
                                                                        CausesValidation="false">
                                                                        Expired (<%= ExpiredCount %>)
                                                                    </asp:LinkButton>
                                                                    <asp:LinkButton ID="btnExpiringSoonTab"
                                                                        runat="server"
                                                                        OnClick="btnExpiringSoonTab_Click"
                                                                        CssClass='<%# GetTabButtonClass("expiringSoon") %>'
                                                                        CausesValidation="false">
                                                                        Expiring Soon (<%= ExpiringSoonCount %>)
                                                                    </asp:LinkButton>
                                                                    <asp:LinkButton ID="btnUnderServiceTab"
                                                                        runat="server"
                                                                        OnClick="btnUnderServiceTab_Click"
                                                                        CssClass='<%# GetTabButtonClass("underService") %>'
                                                                        CausesValidation="false">
                                                                        Under Service (<%= UnderServiceCount %>)
                                                                    </asp:LinkButton>
                                                                </div>
                                                            </div>

                                                            <asp:MultiView ID="mvMonitoring" runat="server"
                                                                ActiveViewIndex="0">
                                                                <asp:View ID="vwExpired" runat="server">
                                                                    <div class="grid-wrapper" style="width: 100%; overflow-x: auto;">
                                                                        <asp:GridView ID="gvExpired" runat="server"
                                                                            AutoGenerateColumns="False"
                                                                            CssClass="grid-view monitoring-grid"
                                                                            AllowPaging="True" PageSize="5"
                                                                            OnPageIndexChanging="gvExpired_PageIndexChanging"
                                                                            OnRowCommand="gvExpired_RowCommand"
                                                                            EmptyDataText="No expired fire extinguishers found."
                                                                            PagerStyle-CssClass="grid-pager"
                                                                            PagerSettings-Mode="NumericFirstLast"
                                                                            PagerSettings-FirstPageText="First"
                                                                            PagerSettings-LastPageText="Last"
                                                                            PagerSettings-PageButtonCount="5">
                                                                            <Columns>
                                                                                <asp:TemplateField HeaderText="No">
                                                                                    <ItemTemplate>
                                                                                        <%# Container.DataItemIndex + 1
                                                                                            %>
                                                                                    </ItemTemplate>
                                                                                    <ItemStyle
                                                                                        HorizontalAlign="Center" />
                                                                                    <HeaderStyle
                                                                                        HorizontalAlign="Center" />
                                                                                </asp:TemplateField>
                                                                                <asp:BoundField DataField="SerialNumber"
                                                                                    HeaderText="Serial Number"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="PlantName"
                                                                                    HeaderText="Plant"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="LevelName"
                                                                                    HeaderText="Level"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="Location"
                                                                                    HeaderText="Location"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="TypeName"
                                                                                    HeaderText="Type"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="DateExpired"
                                                                                    HeaderText="Expiry Date"
                                                                                    DataFormatString="{0:d}"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="DaysExpired"
                                                                                    HeaderText="Days Expired"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </div>
                                                                </asp:View>

                                                                <asp:View ID="vwExpiringSoon" runat="server">
                                                                    <div class="grid-wrapper" style="width: 100%; overflow-x: auto;">
                                                                        <asp:GridView ID="gvExpiringSoon" runat="server"
                                                                            AutoGenerateColumns="False"
                                                                            CssClass="grid-view monitoring-grid"
                                                                            AllowPaging="True" PageSize="5"
                                                                            OnPageIndexChanging="gvExpiringSoon_PageIndexChanging"
                                                                            OnRowCommand="gvExpiringSoon_RowCommand"
                                                                            EmptyDataText="No fire extinguishers expiring soon."
                                                                            PagerStyle-CssClass="grid-pager"
                                                                            PagerSettings-Mode="NumericFirstLast"
                                                                            PagerSettings-FirstPageText="First"
                                                                            PagerSettings-LastPageText="Last"
                                                                            PagerSettings-PageButtonCount="5">
                                                                            <Columns>
                                                                                <asp:TemplateField HeaderText="No">
                                                                                    <ItemTemplate>
                                                                                        <%# Container.DataItemIndex + 1
                                                                                            %>
                                                                                    </ItemTemplate>
                                                                                    <ItemStyle
                                                                                        HorizontalAlign="Center" />
                                                                                    <HeaderStyle
                                                                                        HorizontalAlign="Center" />
                                                                                </asp:TemplateField>
                                                                                <asp:BoundField DataField="SerialNumber"
                                                                                    HeaderText="Serial Number"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="PlantName"
                                                                                    HeaderText="Plant"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="LevelName"
                                                                                    HeaderText="Level"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="Location"
                                                                                    HeaderText="Location"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="TypeName"
                                                                                    HeaderText="Type"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="DateExpired"
                                                                                    HeaderText="Expiry Date"
                                                                                    DataFormatString="{0:d}"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="DaysLeft"
                                                                                    HeaderText="Days Left"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </div>
                                                                </asp:View>

                                                                <asp:View ID="vwUnderService" runat="server">
                                                                    <div class="grid-wrapper" style="width: 100%; overflow-x: auto;">
                                                                        <asp:GridView ID="gvUnderService" runat="server"
                                                                            AutoGenerateColumns="False"
                                                                            CssClass="grid-view monitoring-grid"
                                                                            AllowPaging="True" PageSize="5"
                                                                            OnPageIndexChanging="gvUnderService_PageIndexChanging"
                                                                            OnRowCommand="gvUnderService_RowCommand"
                                                                            EmptyDataText="No fire extinguishers under service."
                                                                            PagerStyle-CssClass="grid-pager"
                                                                            PagerSettings-Mode="NumericFirstLast"
                                                                            PagerSettings-FirstPageText="First"
                                                                            PagerSettings-LastPageText="Last"
                                                                            PagerSettings-PageButtonCount="5">
                                                                            <Columns>
                                                                                <asp:TemplateField HeaderText="No">
                                                                                    <ItemTemplate>
                                                                                        <%# Container.DataItemIndex + 1
                                                                                            %>
                                                                                    </ItemTemplate>
                                                                                    <ItemStyle
                                                                                        HorizontalAlign="Center" />
                                                                                    <HeaderStyle
                                                                                        HorizontalAlign="Center" />
                                                                                </asp:TemplateField>
                                                                                <asp:BoundField DataField="SerialNumber"
                                                                                    HeaderText="Serial Number"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="PlantName"
                                                                                    HeaderText="Plant"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="LevelName"
                                                                                    HeaderText="Level"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="Location"
                                                                                    HeaderText="Location"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="TypeName"
                                                                                    HeaderText="Type"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField DataField="DateExpired"
                                                                                    HeaderText="Previous Expiry Date"
                                                                                    DataFormatString="{0:d}"
                                                                                    ItemStyle-HorizontalAlign="Center"
                                                                                    HeaderStyle-HorizontalAlign="Center" />
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </div>
                                                                </asp:View>
                                                            </asp:MultiView>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Expiry Date Panel -->
                                                <asp:Panel ID="pnlExpiryDate" runat="server" CssClass="modal-panel"
                                                    Style="display: none;">
                                                    <div class="modal-content">
                                                        <h4>Enter New Expiry Date</h4>
                                                        <asp:HiddenField ID="hdnSelectedFEID" runat="server" />
                                                        <div class="form-group">
                                                            <asp:Label ID="lblNewExpiryDate" runat="server"
                                                                Text="New Expiry Date:"
                                                                AssociatedControlID="txtNewExpiryDate"></asp:Label>
                                                            <asp:TextBox ID="txtNewExpiryDate" runat="server"
                                                                CssClass="form-control" TextMode="Date">
                                                            </asp:TextBox>
                                                            <asp:RequiredFieldValidator ID="rfvNewExpiryDate"
                                                                runat="server" ControlToValidate="txtNewExpiryDate"
                                                                ErrorMessage="Please enter a new expiry date"
                                                                Display="Dynamic" ValidationGroup="ExpiryDate"
                                                                CssClass="validation-error">
                                                            </asp:RequiredFieldValidator>
                                                        </div>
                                                        <div class="button-group">
                                                            <asp:Button ID="btnSaveExpiryDate" runat="server"
                                                                Text="Confirm" CssClass="btn btn-primary"
                                                                ValidationGroup="ExpiryDate"
                                                                OnClick="btnSaveExpiryDate_Click"
                                                                UseSubmitBehavior="false" />
                                                            <button type="button" class="btn btn-secondary"
                                                                onclick="hideExpiryDatePanel()">Cancel</button>
                                                        </div>
                                                    </div>
                                                </asp:Panel>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnExpiredTab"
                                                    EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnExpiringSoonTab"
                                                    EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnUnderServiceTab"
                                                    EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnSaveExpiryDate"
                                                    EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>

                                        <!-- STEP 2: Then place the Filter Section below Monitoring Panel -->
                                        <div class="expiry-filters">
                                            <div class="button-group">
                                                <asp:Label ID="lblExpiryStats" runat="server" CssClass="expiry-stats"></asp:Label>
                                            </div>
                                        </div>
                                    </div>

                                        <!-- STEP 3: Finally place the Fire Extinguisher List grid -->
                                        <div class="content-layout">
                                            <asp:UpdatePanel ID="upMainGrid" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <div class="grid-section">
                                                        <h3 class="section-title">Fire Extinguisher List</h3>
                                                        
                                                        <!-- Moved Filter Section here - below the heading but above the grid -->
                                                        <div class="filter-section" style="margin: 20px 0; padding: 15px; background-color: #f8f9fa; border-radius: 5px; border: 1px solid #dee2e6;">
                                                            <div class="filter-row">
                                                                <div class="filter-group">
                                                                    <asp:Label ID="lblFilterPlant" runat="server" Text="Plant:"
                                                                        AssociatedControlID="ddlFilterPlant"></asp:Label>
                                                                    <asp:DropDownList ID="ddlFilterPlant" runat="server"
                                                                        CssClass="form-control" AutoPostBack="true"
                                                                        OnSelectedIndexChanged="ddlFilterPlant_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </div>
                                                                <div class="filter-group">
                                                                    <asp:Label ID="lblFilterLevel" runat="server" Text="Level:"
                                                                        AssociatedControlID="ddlFilterLevel"></asp:Label>
                                                                    <asp:DropDownList ID="ddlFilterLevel" runat="server"
                                                                        CssClass="form-control" AutoPostBack="true"
                                                                        OnSelectedIndexChanged="ApplyFilters"></asp:DropDownList>
                                                                </div>
                                                                <div class="filter-group">
                                                                    <asp:Label ID="lblFilterStatus" runat="server" Text="Status:"
                                                                        AssociatedControlID="ddlFilterStatus"></asp:Label>
                                                                    <asp:DropDownList ID="ddlFilterStatus" runat="server"
                                                                        CssClass="form-control" AutoPostBack="true"
                                                                        OnSelectedIndexChanged="ApplyFilters"></asp:DropDownList>
                                                                </div>
                                                                <div class="filter-group">
                                                                    <asp:Label ID="lblSearch" runat="server" Text="Search:"
                                                                        AssociatedControlID="txtSearch"></asp:Label>
                                                                    <div class="search-box">
                                                                        <asp:TextBox ID="txtSearch" runat="server"
                                                                            CssClass="form-control"
                                                                            placeholder="Serial Number or Location"></asp:TextBox>
                                                                    </div>
                                                                    <div class="button-group">
                                                                        <asp:Button ID="btnSearch" runat="server" Text="Search"
                                                                            OnClick="ApplyFilters" CssClass="btn btn-primary" />
                                                                        <asp:Button ID="btnClearFilters" runat="server"
                                                                            Text="Clear Filters" OnClick="btnClearFilters_Click"
                                                                            CssClass="btn btn-secondary" />
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        
                                                        <div class="button-container" style="margin-bottom: 15px; text-align: right;">
                                                            <asp:Button ID="btnShowSelection" runat="server" Text="Send Multiple to Service" CssClass="btn btn-warning" OnClick="btnShowSelection_Click" OnClientClick="showServiceSelectionPanel(); return true;" />
                                                        </div>
                                                        <div class="grid-wrapper" style="width: 100%; overflow-x: auto;">
                                                            <asp:GridView ID="gvFireExtinguishers" runat="server"
                                                                AutoGenerateColumns="False" CssClass="grid-view"
                                                                AllowPaging="True" AllowSorting="True" PageSize="10"
                                                                OnPageIndexChanging="gvFireExtinguishers_PageIndexChanging"
                                                                OnSorting="gvFireExtinguishers_Sorting"
                                                                OnRowDataBound="gvFireExtinguishers_RowDataBound"
                                                                OnRowCommand="gvFireExtinguishers_RowCommand"
                                                                EmptyDataText="No fire extinguishers found for the selected criteria."
                                                                EmptyDataRowStyle-CssClass="empty-data-message"
                                                                PagerStyle-CssClass="grid-pager"
                                                                PagerSettings-Mode="NumericFirstLast"
                                                                PagerSettings-FirstPageText="First"
                                                                PagerSettings-LastPageText="Last"
                                                                PagerSettings-PageButtonCount="5">
                                                                <RowStyle CssClass="grid-row" />
                                                                <AlternatingRowStyle CssClass="grid-row-alt" />
                                                                <HeaderStyle CssClass="grid-header" />
                                                                <PagerStyle CssClass="grid-pager" />
                                                                <Columns>
                                                                    <asp:BoundField DataField="SerialNumber"
                                                                        HeaderText="Serial Number"
                                                                        SortExpression="SerialNumber">
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:BoundField>
                                                                    <asp:BoundField DataField="PlantName" HeaderText="Plant"
                                                                        SortExpression="PlantName">
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:BoundField>
                                                                    <asp:BoundField DataField="LevelName" HeaderText="Level"
                                                                        SortExpression="LevelName">
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:BoundField>
                                                                    <asp:BoundField DataField="Location"
                                                                        HeaderText="Location" SortExpression="Location">
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:BoundField>
                                                                    <asp:BoundField DataField="TypeName" HeaderText="Type"
                                                                        SortExpression="TypeName">
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:BoundField>
                                                                    <asp:BoundField DataField="DateExpired"
                                                                        HeaderText="Expiry Date"
                                                                        SortExpression="DateExpired"
                                                                        DataFormatString="{0:d}">
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:BoundField>
                                                                    <asp:TemplateField HeaderText="Status"
                                                                        SortExpression="StatusName">
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblStatus" runat="server"
                                                                                CssClass="status-badge"></asp:Label>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField DataField="Remarks" HeaderText="Remarks"
                                                                        SortExpression="Remarks">
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                    </asp:BoundField>
                                                                    <asp:TemplateField HeaderText="Actions">
                                                                        <ItemTemplate>
                                                                            <div class="action-buttons">
                                                                                <asp:Button ID="btnCompleteService"
                                                                                    runat="server"
                                                                                    CommandName="CompleteService"
                                                                                    CommandArgument='<%# Eval("FEID") %>'
                                                                                    data-feid='<%# Eval("FEID") %>'
                                                                                    CssClass='<%# Eval("StatusName").ToString() == "Under Service" ? "btn btn-sm btn-success" : "btn btn-sm btn-success disabled-service" %>'
                                                                                    Text="Complete Service"
                                                                                    Enabled='<%# Eval("StatusName").ToString() == "Under Service" %>'
                                                                                    OnClientClick="return showExpiryDatePanel(this);" />
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
                                                    <asp:AsyncPostBackTrigger ControlID="btnSaveExpiryDate"
                                                        EventName="Click" />
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
        .monitoring-panel,
        .content-layout {
            width: 100%;
            max-width: 100%;
            min-width: auto;
            margin: 0 auto;
            box-sizing: border-box;
            overflow-x: auto;
        }

        /* Make filter-row more responsive */
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            align-items: flex-start;
            justify-content: space-between;
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
            margin-bottom: 15px;
        }

        /* On smaller screens, stack filter elements */
        @media (max-width: 768px) {
            .filter-row {
                flex-direction: column;
            }
            
            .filter-group {
                width: 100%;
            }

            .button-container {
                text-align: center !important;
                margin-bottom: 20px;
            }
        }

        /* Responsive table styles */
        .monitoring-grid, 
        .grid-view {
            width: 100%;
            table-layout: auto;
        }

        /* Remove fixed min-width from content layout */
        .content-layout {
            min-width: auto;
            max-width: 100%;
        }

        /* Remove fixed widths from monitoring panel */
        .monitoring-panel {
            min-width: auto;
            max-width: 100%;
        }

        /* Remove fixed widths from tab container */
        .tab-container {
            min-width: auto;
            width: 100%;
        }

        /* Remove fixed min-width from grid section */
        .grid-section {
            min-width: auto;
            max-width: 100%;
        }

        /* Ensure grid tables can scroll horizontally on small screens */
        .grid-container {
            overflow-x: auto;
            width: 100%;
        }

        /* Service Selection Modal Styles */
        .service-selection-modal {
            max-width: 95%;
            width: 95%;
            padding: 20px;
            border-radius: 8px;
            max-height: 90vh;
            min-height: auto;
            min-width: auto;
            overflow-y: auto;
        }

        @media (max-width: 768px) {
            .service-selection-modal {
                width: 95%;
                padding: 15px;
                max-height: 80vh;
            }
            
            .modal-title {
                font-size: 1.4rem;
            }
            
            .selection-grid th, 
            .selection-grid td {
                padding: 8px 5px;
                font-size: 0.9rem;
            }
        }

        /* Modal content responsive styles */
        .modal-content {
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            padding: 20px;
        }

        @media (max-width: 768px) {
            .modal-content {
                width: 95%;
                padding: 15px;
            }
        }

        /* Make sure table content doesn't get cut off */
        .confirmation-grid {
            width: 100%;
            overflow-x: auto;
        }

        .modal-header {
            border-bottom: 2px solid #007bff;
            padding-bottom: 15px;
            margin-bottom: 25px;
        }

        .modal-title {
            color: #333;
            margin: 0;
            font-size: 1.8rem;
            font-weight: 600;
        }

        .modal-body {
            padding: 0 0 25px 0;
            min-height: 400px;
        }

        .selection-instruction {
            margin-bottom: 20px;
            color: #555;
            font-size: 1.1rem;
        }

        .grid-container {
            margin-bottom: 20px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            background-color: #fff;
            min-height: 350px;
            max-height: 500px;
            overflow-y: auto;
        }

        .selection-grid {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 0;
            table-layout: fixed;
        }

        .selection-grid th {
            background-color: #f0f2f5;
            padding: 14px 10px;
            border: 1px solid #dee2e6;
            font-weight: 600;
            color: #333;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .selection-grid td {
            padding: 12px 10px;
            border: 1px solid #dee2e6;
            vertical-align: middle;
            word-break: break-word;
        }

        .selection-checkbox {
            width: 20px;
            height: 20px;
            cursor: pointer;
        }

        .modal-footer {
            border-top: 1px solid #dee2e6;
            padding-top: 20px;
            display: flex;
            justify-content: flex-end;
            gap: 15px;
        }

        #btnShowSelection {
            margin: 15px 0;
            padding: 10px 18px;
            font-weight: 500;
            font-size: 1rem;
        }

        /* Set max-width for expanded sidebar state */
        body:not(.sidebar-collapsed) .filter-section,
        body:not(.sidebar-collapsed) .monitoring-section,
        body:not(.sidebar-collapsed) .grid-section,
        body:not(.sidebar-collapsed) .monitoring-panel,
        body:not(.sidebar-collapsed) .content-layout {
            max-width: calc(100vw - 290px); /* 250px sidebar + 40px padding */
        }

        /* Set max-width for collapsed sidebar state */
        body.sidebar-collapsed .filter-section,
        body.sidebar-collapsed .monitoring-section,
        body.sidebar-collapsed .grid-section,
        body.sidebar-collapsed .monitoring-panel,
        body.sidebar-collapsed .content-layout {
            max-width: calc(100vw - 110px); /* 70px sidebar + 40px padding */
        }

        .filter-section {
            background-color: #fff;
            border-radius: 5px;
            padding: 20px;
            margin-bottom: 30px;
        }

        /* Update the view-section container */
        .view-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
            padding: 30px;
            box-sizing: border-box;
        }

        .view-section {
            background-color: #fff;
            border-radius: 0px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        /* Update table layout to be more responsive */
        .monitoring-grid, 
        .grid-view {
            width: 100%;
            table-layout: fixed;
        }

        /* Make panel header responsive */
        .panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            gap: 15px;
            width: 100%;
            min-width: auto;
            box-sizing: border-box;
        }

        /* Make tab container responsive */
        .tab-container {
            padding: 20px;
            width: 100%;
            min-width: auto;
            box-sizing: border-box;
        }

        /* Ensure the monitoring panel adjusts properly */
        .monitoring-panel .tab-container > div {
            width: 100%;
            min-width: auto;
        }

        /* Media queries for responsive layout */
        @media (max-width: 1200px) {
            body:not(.sidebar-collapsed) .filter-section,
            body:not(.sidebar-collapsed) .monitoring-section,
            body:not(.sidebar-collapsed) .grid-section,
            body:not(.sidebar-collapsed) .monitoring-panel,
            body:not(.sidebar-collapsed) .content-layout {
                max-width: calc(100vw - 270px);
            }
            
            body.sidebar-collapsed .filter-section,
            body.sidebar-collapsed .monitoring-section,
            body.sidebar-collapsed .grid-section,
            body.sidebar-collapsed .monitoring-panel,
            body.sidebar-collapsed .content-layout {
                max-width: calc(100vw - 90px);
            }
        }

        @media (max-width: 992px) {
            .service-selection-modal {
                width: 95%;
                padding: 15px;
            }
            
            .tab-buttons {
                flex-wrap: wrap;
            }
            
            .tab-button {
                font-size: 0.85rem;
                padding: 6px 10px;
            }
        }

        @media (max-width: 768px) {
            body:not(.sidebar-collapsed) .filter-section,
            body:not(.sidebar-collapsed) .monitoring-section,
            body:not(.sidebar-collapsed) .grid-section,
            body:not(.sidebar-collapsed) .monitoring-panel,
            body:not(.sidebar-collapsed) .content-layout,
            body.sidebar-collapsed .filter-section,
            body.sidebar-collapsed .monitoring-section,
            body.sidebar-collapsed .grid-section,
            body.sidebar-collapsed .monitoring-panel,
            body.sidebar-collapsed .content-layout {
                max-width: 100%;
                overflow-x: auto;
            }
            
            .section-title {
                font-size: 1.3rem;
                text-align: center;
            }
            
            .status-badge {
                min-width: 60px;
                font-size: 0.8rem;
                padding: 4px 6px;
            }
            
            .btn-sm {
                min-width: 60px;
                font-size: 0.8rem;
                padding: 3px 6px;
            }
        }

        /* Remove duplicate media queries and styles */
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

        // Add this to your existing Sys.WebForms.PageRequestManager code
        if (typeof (Sys) !== 'undefined') {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_beginRequest(function() {
                saveScrollPosition();
            });
            prm.add_endRequest(function() {
                restoreScrollPosition();
            });
        }

        function showExpiryDatePanel(button) {
            var panel = document.getElementById('<%= pnlExpiryDate.ClientID %>');
            var feId = button.getAttribute('data-feid') || button.getAttribute('CommandArgument');
            document.getElementById('<%= hdnSelectedFEID.ClientID %>').value = feId;
            panel.style.display = 'flex';
            document.getElementById('modalOverlay').style.display = 'block';
            return false;
        }

        function hideExpiryDatePanel() {
            var panel = document.getElementById('<%= pnlExpiryDate.ClientID %>');
            panel.style.display = 'none';
            document.getElementById('modalOverlay').style.display = 'none';
            return false;
        }

        function showSendToServiceConfirmation(feId) {
            // Set the hidden field value
            document.getElementById('<%= hdnSelectedFEIDForService.ClientID %>').value = feId;
            
            // Show the panel and overlay
            document.getElementById('<%= pnlSendToService.ClientID %>').style.display = 'flex';
            document.getElementById('modalOverlay').style.display = 'block';
            
            return false;
        }

        function hideSendToServicePanel() {
            document.getElementById('<%= pnlSendToService.ClientID %>').style.display = 'none';
            document.getElementById('modalOverlay').style.display = 'none';
            return false;
        }

        // Close modal when clicking outside
        document.getElementById('modalOverlay').onclick = function() {
            hideExpiryDatePanel();
            hideSendToServicePanel();
        };

        // Prevent modal from closing when clicking inside it
        document.querySelectorAll('.modal-panel').forEach(function(panel) {
            panel.onclick = function(event) {
                event.stopPropagation();
            };
        });

        // Add this to your existing script section
        document.addEventListener('DOMContentLoaded', function() {
            // Check sidebar state on page load
            const sidebarState = localStorage.getItem('sidebarState');
            if (sidebarState === 'collapsed') {
                document.body.classList.add('sidebar-collapsed');
            } else {
                document.body.classList.remove('sidebar-collapsed');
            }
            
            // Listen for sidebar state changes
            window.addEventListener('storage', function(e) {
                if (e.key === 'sidebarState') {
                    if (e.newValue === 'collapsed') {
                        document.body.classList.add('sidebar-collapsed');
                    } else {
                        document.body.classList.remove('sidebar-collapsed');
                    }
                }
            });
            
            // Add a custom event listener for sidebar toggle
            document.addEventListener('sidebarToggled', function(e) {
                if (e.detail.collapsed) {
                    document.body.classList.add('sidebar-collapsed');
                } else {
                    document.body.classList.remove('sidebar-collapsed');
                }
            });
        });

        function showNotification(message, type = 'success', duration = 3000) {
            // Create notification element
            const notification = document.createElement('div');
            notification.className = `toast-notification ${type === 'error' ? 'error' : ''}`;
            notification.innerHTML = message;
            
            // Add to DOM
            document.body.appendChild(notification);
            
            // Trigger animation
            setTimeout(() => {
                notification.classList.add('show');
            }, 10);
            
            // Auto-hide after duration
            setTimeout(() => {
                notification.classList.add('hide');
                setTimeout(() => {
                    document.body.removeChild(notification);
                }, 300);
            }, duration);
        }

        // Service Selection Panel functions
        function showServiceSelectionPanel() {
            document.getElementById('modalOverlay').style.display = 'block';
            return true; // Allow the postback to occur
        }
        
        function hideServiceSelectionPanel() {
            document.getElementById('modalOverlay').style.display = 'none';
            return true; // Allow the postback to occur
        }
        
        // Add select all functionality for the service selection grid
        function toggleAllCheckboxes(checkbox) {
            const grid = document.getElementById('<%= gvServiceSelection.ClientID %>');
            if (!grid) return;
            
            const checkboxes = grid.getElementsByTagName('input');
            for (let i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].type === 'checkbox' && checkboxes[i] !== checkbox) {
                    checkboxes[i].checked = checkbox.checked;
                }
            }
        }
    </script>

<style>
    .toast-notification {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 24px;
        background-color: #4CAF50;
        color: white;
        border-radius: 4px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 10px;
        opacity: 0;
        transform: translateY(-20px);
    
    }

    .toast-notification.error {
        background-color: #f44336;
    }

    .toast-notification.show {
        opacity: 1;
        transform: translateY(0);
    }

    .toast-notification.hide {
        opacity: 0;
        transform: translateY(-20px);
    }
</style>
    
</asp:Content>


