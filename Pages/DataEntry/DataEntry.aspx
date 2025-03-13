<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DataEntry.aspx.cs" Inherits="FETS.Pages.DataEntry.DataEntry" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>FETS - Data Entry</title>
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
                    <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn btn-logout" CausesValidation="false">Back to Dashboard</asp:LinkButton>
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn btn-logout" CausesValidation="false">Logout</asp:LinkButton>
                </div>
            </header>
            <div class="content-container">
                <div class="data-entry-form">
                    <h3>Add New Fire Extinguisher</h3>
                    
                    <div class="form-group">
                        <asp:Label ID="lblSerialNumber" runat="server" Text="Serial Number:" AssociatedControlID="txtSerialNumber"></asp:Label>
                        <asp:TextBox ID="txtSerialNumber" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSerialNumber" runat="server" 
                            ControlToValidate="txtSerialNumber" 
                            ErrorMessage="Serial Number is required." 
                            CssClass="validation-error"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblPlant" runat="server" Text="Plant:" AssociatedControlID="ddlPlant"></asp:Label>
                        <asp:DropDownList ID="ddlPlant" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPlant_SelectedIndexChanged"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvPlant" runat="server" 
                            ControlToValidate="ddlPlant" 
                            ErrorMessage="Plant is required." 
                            CssClass="validation-error"
                            Display="Dynamic"
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
                            InitialValue="">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblLocation" runat="server" Text="Location:" AssociatedControlID="txtLocation"></asp:Label>
                        <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvLocation" runat="server" 
                            ControlToValidate="txtLocation" 
                            ErrorMessage="Location is required." 
                            CssClass="validation-error"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblType" runat="server" Text="Type:" AssociatedControlID="ddlType"></asp:Label>
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvType" runat="server" 
                            ControlToValidate="ddlType" 
                            ErrorMessage="Type is required." 
                            CssClass="validation-error"
                            Display="Dynamic"
                            InitialValue="">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblExpiryDate" runat="server" Text="Expiry Date:" AssociatedControlID="txtExpiryDate"></asp:Label>
                        <asp:TextBox ID="txtExpiryDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvExpiryDate" runat="server" 
                            ControlToValidate="txtExpiryDate" 
                            ErrorMessage="Expiry Date is required." 
                            CssClass="validation-error"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblRemarks" runat="server" Text="Remarks:" AssociatedControlID="txtRemarks"></asp:Label>
                        <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <asp:Button ID="btnSubmit" runat="server" Text="Save Fire Extinguisher" OnClick="btnSubmit_Click" CssClass="btn btn-primary" />
                    </div>

                    <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                </div>
            </div>
        </div>
    </form>
</body>
</html> 