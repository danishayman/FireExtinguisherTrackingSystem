<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DataEntry.aspx.cs" Inherits="FETS.Pages.DataEntry.DataEntry" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .data-entry-form {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .form-group {
            margin-bottom: 20px;
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
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
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
</asp:Content> 