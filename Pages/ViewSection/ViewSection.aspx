<%@ Page Title="View Section" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ViewSection.aspx.cs" Inherits="FETS.Pages.ViewSection.ViewSection" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
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
                                    <h3>View Fire Extinguishers</h3>
                                    
                                    <div class="filter-section">
                                        <div class="filter-row">
                                            <div class="filter-group">
                                                <asp:Label ID="lblFilterPlant" runat="server" Text="Plant:" AssociatedControlID="ddlFilterPlant"></asp:Label>
                                                <asp:DropDownList ID="ddlFilterPlant" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterPlant_SelectedIndexChanged"></asp:DropDownList>
                                            </div>
                                            <div class="filter-group">
                                                <asp:Label ID="lblFilterLevel" runat="server" Text="Level:" AssociatedControlID="ddlFilterLevel"></asp:Label>
                                                <asp:DropDownList ID="ddlFilterLevel" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters"></asp:DropDownList>
                                            </div>
                                            <div class="filter-group">
                                                <asp:Label ID="lblFilterStatus" runat="server" Text="Status:" AssociatedControlID="ddlFilterStatus"></asp:Label>
                                                <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ApplyFilters"></asp:DropDownList>
                                            </div>
                                            <div class="filter-group">
                                                <asp:Label ID="lblSearch" runat="server" Text="Search:" AssociatedControlID="txtSearch"></asp:Label>
                                                <div class="search-box">
                                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search by Serial Number or Location"></asp:TextBox>
                                                </div>
                                                <div class="button-group">
                                                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="ApplyFilters" CssClass="btn btn-primary" />
                                                    <asp:Button ID="btnClearFilters" runat="server" Text="Clear Filters" OnClick="btnClearFilters_Click" CssClass="btn btn-secondary" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="expiry-filters">
                                            <div class="button-group">
                                                <asp:Button ID="btnShowExpired" runat="server" Text="Show Expired" OnClick="btnExpiredTab_Click" CssClass="btn btn-danger" />
                                                <asp:Button ID="btnShowExpiringSoon" runat="server" Text="Show Expiring Soon" OnClick="btnExpiringSoonTab_Click" CssClass="btn btn-warning" />
                                                <asp:Label ID="lblExpiryStats" runat="server" CssClass="expiry-stats"></asp:Label>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="content-layout">
                                        <!-- Wrap the original monitoring section with UpdatePanel -->
                                        <asp:UpdatePanel ID="upMonitoring" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div class="monitoring-section">
                                                    <div class="monitoring-panel">
                                                        <h3 class="section-title">FE Monitoring Panel</h3>
                                                        <div class="tab-container">
                                                            <div class="panel-header">
                                                                <div class="tab-buttons">
                                                                    <asp:LinkButton ID="btnExpiredTab" runat="server" OnClick="btnExpiredTab_Click" CssClass='<%# GetTabButtonClass("expired") %>' CausesValidation="false"></asp:LinkButton>
                                                                        Expired (<%= ExpiredCount %>)
                                                                    </asp:LinkButton>
                                                                    <asp:LinkButton ID="btnExpiringSoonTab" runat="server" OnClick="btnExpiringSoonTab_Click" CssClass='<%# GetTabButtonClass("expiringSoon") %>' CausesValidation="false">
                                                                        Expiring Soon (<%= ExpiringSoonCount %>)
                                                                    </asp:LinkButton>
                                                                    <asp:LinkButton ID="btnUnderServiceTab" runat="server" OnClick="btnUnderServiceTab_Click" CssClass='<%# GetTabButtonClass("underService") %>' CausesValidation="false">
                                                                        Under Service (<%= UnderServiceCount %>)
                                                                    </asp:LinkButton>
                                                                </div>
                                                                <asp:Button ID="btnSendAllToService" runat="server" 
                                                                    Text="Send All to Service" 
                                                                    CssClass="btn btn-warning btn-sm"
                                                                    OnClick="btnSendAllToService_Click"
                                                                    CausesValidation="false"
                                                                    OnClientClick="return confirm('Are you sure you want to send all expired and expiring soon fire extinguishers for service?');" />
                                                            </div>

                                                            <asp:MultiView ID="mvMonitoring" runat="server" ActiveViewIndex="0">
                                                                <asp:View ID="vwExpired" runat="server">
                                                                    <asp:GridView ID="gvExpired" runat="server" 
                                                                        AutoGenerateColumns="False" 
                                                                        CssClass="grid-view monitoring-grid"
                                                                        AllowPaging="True"
                                                                        PageSize="5"
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
                                                                                        OnClientClick='<%# "return showSendToServiceConfirmation(" + Eval("FEID") + ");" %>'>
                                                                                        Send to Service
                                                                                    </asp:LinkButton>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </asp:View>

                                                                <asp:View ID="vwExpiringSoon" runat="server">
                                                                    <asp:GridView ID="gvExpiringSoon" runat="server" 
                                                                        AutoGenerateColumns="False" 
                                                                        CssClass="grid-view monitoring-grid"
                                                                        AllowPaging="True"
                                                                        PageSize="5"
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
                                                                                        OnClientClick='<%# "return showSendToServiceConfirmation(" + Eval("FEID") + ");" %>'>
                                                                                        Send to Service
                                                                                    </asp:LinkButton>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </asp:View>

                                                                <asp:View ID="vwUnderService" runat="server">
                                                                    <asp:GridView ID="gvUnderService" runat="server" 
                                                                        AutoGenerateColumns="False" 
                                                                        CssClass="grid-view monitoring-grid"
                                                                        AllowPaging="True"
                                                                        PageSize="5"
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
                                                <div class="grid-section">
                                                    <h3 class="section-title">Fire Extinguisher List</h3>
                                                    <asp:GridView ID="gvFireExtinguishers" runat="server" 
                                                        AutoGenerateColumns="False" 
                                                        CssClass="grid-view"
                                                        AllowPaging="True"
                                                        AllowSorting="True"
                                                        PageSize="10"
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
                                                            <asp:TemplateField HeaderText="No">
                                                                <ItemTemplate>
                                                                    <%# Container.DataItemIndex + 1 %>
                                                                </ItemTemplate>
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:TemplateField>
                                                            <asp:BoundField DataField="SerialNumber" HeaderText="Serial Number" SortExpression="SerialNumber">
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:BoundField DataField="PlantName" HeaderText="Plant" SortExpression="PlantName">
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:BoundField DataField="LevelName" HeaderText="Level" SortExpression="LevelName">
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:BoundField DataField="Location" HeaderText="Location" SortExpression="Location">
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:BoundField DataField="TypeName" HeaderText="Type" SortExpression="TypeName">
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:BoundField DataField="DateExpired" HeaderText="Expiry Date" SortExpression="DateExpired" DataFormatString="{0:d}">
                                                                <ItemStyle HorizontalAlign="Center" />
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
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
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnSaveExpiryDate" EventName="Click" />
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
        .panels-layout {
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .monitoring-panel .section-title {
            font-size: 1.5rem;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #007bff;
            text-align: center;
        }

        .view-section {
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 30px;
            width: 100%;
            max-width: 1400px;
            box-sizing: border-box;
        }

        .content-layout {
            display: flex;
            flex-direction: column;
            gap: 30px;
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            box-sizing: border-box;
        }

        .monitoring-section {
            width: 95%;
            max-width: 1100px;
            box-sizing: border-box;
            margin: 0 auto;
        }

        .monitoring-panel {
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            width: 100%;
            box-sizing: border-box;
            margin: 0 auto;
        }

        .tab-container {
            padding: 20px;
            width: 100%;
            box-sizing: border-box;
        }

        .panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            gap: 10px;
            width: 100%;
            box-sizing: border-box;
        }

        .tab-buttons {
            display: flex;
            gap: 10px;
            flex: 3;
        }

        .tab-button {
            flex: 1;
            padding: 8px 15px;
            border-radius: 4px;
            text-decoration: none;
            color: #666;
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            text-align: center;
            font-size: 0.9rem;
            transition: all 0.2s ease;
        }

        .tab-button:hover {
            background-color: #e9ecef;
            color: #333;
            text-decoration: none;
        }

        .tab-button.active {
            background-color: #007bff;
            color: #fff;
            border-color: #007bff;
        }

        .tab-button:not(.active) {
            background-color: #f8f9fa;
            color: #666;
            border-color: #dee2e6;
        }

        #btnSendAllToService {
            white-space: nowrap;
            flex: 1;
        }

        .monitoring-grid {
            width: 100%;
            margin-top: 15px;
            border-collapse: collapse;
        }

        .monitoring-grid th {
            background-color: #f8f9fa;
            padding: 10px;
            border: 1px solid #dee2e6;
        }

        .monitoring-grid td {
            padding: 8px;
            border: 1px solid #dee2e6;
        }

        .grid-section {
            width: 95%;
            max-width: 1100px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
            box-sizing: border-box;
            margin: 0 auto;
        }

        .section-title {
            font-size: 1.5rem;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #007bff;
        }

        .grid-view {
            width: 100%;
            border-collapse: collapse;
        }

        /* Table responsiveness */
        .monitoring-grid, .grid-view {
            table-layout: fixed;
        }

        .monitoring-grid td, .grid-view td,
        .monitoring-grid th, .grid-view th {
            word-wrap: break-word;
            overflow-wrap: break-word;
        }

        /* Column widths for monitoring grid */
        .monitoring-grid td:nth-child(1) { width: 20%; } /* Serial Number */
        .monitoring-grid td:nth-child(2) { width: 30%; } /* Location */
        .monitoring-grid td:nth-child(3) { width: 20%; } /* Date */
        .monitoring-grid td:nth-child(4) { width: 15%; } /* Days */
        .monitoring-grid td:nth-child(5) { width: 15%; } /* Action */

        /* Column widths for main grid */
        .grid-view td:nth-child(1) { width: 5%; }  /* No */
        .grid-view td:nth-child(2) { width: 10%; } /* Serial Number */
        .grid-view td:nth-child(3) { width: 10%; } /* Plant */
        .grid-view td:nth-child(4) { width: 8%; }  /* Level */
        .grid-view td:nth-child(5) { width: 15%; } /* Location */
        .grid-view td:nth-child(6) { width: 10%; } /* Type */
        .grid-view td:nth-child(7) { width: 10%; } /* Expiry Date */
        .grid-view td:nth-child(8) { width: 10%; } /* Status */
        .grid-view td:nth-child(9) { width: 12%; } /* Remarks */
        .grid-view td:nth-child(10) { width: 10%; } /* Actions */

        .grid-view td, .grid-view th {
            vertical-align: middle;
            text-align: center;
        }

        .empty-data-message {
            padding: 20px;
            text-align: center;
            font-size: 1.1em;
            color: #666;
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            color: white;
            text-align: center;
            min-width: 80px;
        }

        /* Ensure consistent button sizes in grids */
        .btn-sm {
            padding: 4px 8px;
            font-size: 0.875rem;
            min-width: 80px;
        }

        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        /* Rest of your existing styles... */

        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 999;
        }
        
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
        }

        .modal-content {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            width: 90%;
            max-width: 400px;
            margin: auto;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        .modal-content h4 {
            margin-top: 0;
            margin-bottom: 20px;
            color: #333;
            text-align: center;
            font-size: 1.2rem;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #666;
            font-size: 0.9rem;
        }

        .form-control {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 0.9rem;
        }

        .button-group {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }

        .button-group .btn {
            min-width: 80px;
            padding: 6px 12px;
        }

        .validation-error {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 5px;
            display: block;
        }

        .expired-row {
            background-color: #ffe6e6 !important;
        }

        .expiring-soon-row {
            background-color: #fff3cd !important;
        }

        .under-maintenance-row {
            background-color: #e8f4f8 !important;
        }

        @media (max-width: 1200px) {
            .panels-layout {
                flex-direction: column;
            }

            .monitoring-section {
                max-width: none;
            }
        }

        .confirmation-grid {
            width: 100%;
            margin: 15px 0;
            border-collapse: collapse;
        }

        .confirmation-grid th {
            background-color: #f8f9fa;
            padding: 8px;
            border: 1px solid #dee2e6;
            font-size: 0.9rem;
        }

        .confirmation-grid td {
            padding: 6px;
            border: 1px solid #dee2e6;
            font-size: 0.9rem;
        }

        .modal-content {
            max-height: 80vh;
            overflow-y: auto;
        }

        .grid-pager {
            text-align: center;
            padding: 10px 0;
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
        }

        .grid-pager table {
            margin: 0 auto;
        }

        .grid-pager td {
            padding: 0 5px;
        }

        .grid-pager a, .grid-pager span {
            padding: 5px 10px;
            margin: 0 2px;
            border: 1px solid #dee2e6;
            border-radius: 3px;
            text-decoration: none;
            color: #007bff;
            background-color: #fff;
            display: inline-block;
            min-width: 32px;
        }

        .grid-pager span {
            background-color: #007bff;
            color: #fff;
            border-color: #007bff;
        }

        .grid-pager a:hover {
            background-color: #e9ecef;
            border-color: #dee2e6;
            color: #0056b3;
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
    </script>
</asp:Content>