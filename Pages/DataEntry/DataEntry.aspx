<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DataEntry.aspx.cs" Inherits="FETS.Pages.DataEntry.DataEntry"
    MasterPageFile="~/Site.Master" %>

    <asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            .content-container {
                flex: 1;
                padding: 20px;
                max-width: 1200px;
                margin: 0 auto;
                width: 100%;
            }

            .data-entry-form {
                width: 100%;
                max-width: 1100px;
                min-width: 1000px;
                margin: 0 auto;
                background-color: #fff;
                border-radius: 5px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
                padding: 30px;
                box-sizing: border-box;
            }

            h3 {
                text-align: center;
                margin: 0 0 30px 0;
                color: #333;
                font-size: 1.75rem;
                font-weight: 600;
                padding-bottom: 15px;
                border-bottom: 2px solid #007bff;
            }

            .form-row {
                display: flex;
                gap: 20px;
                margin-bottom: 20px;
            }

            .form-col {
                flex: 1;
                min-width: 0;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-group label {
                display: block;
                margin-bottom: 5px;
                color: #333;
                font-weight: 500;
                font-size: 0.95rem;
            }

            .form-control {
                width: 100%;
                padding: 8px;
                border: 1px solid #ddd;
                border-radius: 4px;
                box-sizing: border-box;
                font-size: 0.95rem;
                min-height: 38px;
            }

            .form-control:focus {
                border-color: #007bff;
                box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
                outline: none;
            }

            textarea.form-control {
                min-height: 100px;
                resize: vertical;
            }

            .btn-primary {
                background-color: #007bff;
                color: white;
                border: none;
                padding: 8px 16px;
                font-size: 1.5rem;
                min-width: 120px;
                height: auto;
                font-weight: 500;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 4px;
                cursor: pointer;
                transition: background-color 0.2s;
            }

            .btn-primary:hover {
                background-color: #0056b3;
            }

            .validation-error {
                color: #dc3545;
                font-size: 0.875rem;
                margin-top: 5px;
                display: block;
            }

            .message {
                padding: 15px;
                margin-top: 20px;
                border-radius: 4px;
                text-align: center;
                font-size: 0.95rem;

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

            /* Responsive styles */
            @media (max-width: 1200px) {
                .data-entry-form {
                    min-width: auto;
                    width: 100%;
                    padding: 20px;
                }

                .form-row {
                    flex-direction: column;
                    gap: 0;
                }

                .form-col {
                    width: 100%;
                }
            }

            /* Update the Save Fire Extinguisher button style */
            #btnSubmit {
                background-color: #007bff;
                color: white;
                border: none;
                padding: 16px 32px;
                font-size: 1.1rem;
                min-width: 250px;
                height: 60px;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 4px;
                cursor: pointer;
                transition: background-color 0.2s;
                margin-top: 15px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }

            #btnSubmit:hover {
                background-color: #0056b3;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            }

            /* Update the text-center class to provide better spacing */
            .text-center {
                text-align: center;
                margin-top: 20px;
                margin-bottom: 10px;
            }

            .popup-panel {
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

            .popup-content {
                background-color: white;
                padding: 20px;
                border-radius: 5px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
                width: 400px;
            }

            .popup-content table {
                width: 100%;
                margin-bottom: 20px;
            }

            .popup-content td {
                padding: 5px;
            }

            .popup-buttons {
                text-align: center;
            }

            .button {
                padding: 8px 15px;
                margin-left: 10px;
                cursor: pointer;
            }

            .confirm {
                background-color: #007bff;
                color: white;
                font-weight: 500;
                border: none;
                align-items: center;
                border-radius: 4px;
                font-size: 1.2rem;
                transition: background-color 0.2s;
            }

            .confirm:hover {
                background-color: #0056b3;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            }

            .cancel {
                background-color: #f44336;
                color: white;
                font-weight: 500;
                border: none;
                align-items: center;
                border-radius: 4px;
                font-size: 1.2rem;
                transition: background-color 0.2s;
            }

            .cancel:hover {
                background-color: #c03026;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            }
        </style>

        <script type="text/javascript">
            function showConfirmationPopup() {
                document.getElementById('<%= pnlConfirmation.ClientID %>').style.display = 'flex';
            }

            function hideConfirmationPopup() {
                document.getElementById('<%= pnlConfirmation.ClientID %>').style.display = 'none';
            }
            window.onload = function() {
                var today = new Date().toISOString().split('T')[0];
                document.getElementById('<%= txtExpiryDate.ClientID %>').setAttribute('min', today);
            }
        </script>
    </asp:Content>

    <asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
        <div class="content-container">
            <div class="data-entry-form">
                <h3 class="text-center">Add New Fire Extinguisher</h3>

                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <asp:Label ID="lblSerialNumber" runat="server" Text="Serial Number:"
                                AssociatedControlID="txtSerialNumber"></asp:Label>
                            <asp:TextBox ID="txtSerialNumber" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSerialNumber" runat="server"
                                ControlToValidate="txtSerialNumber" ErrorMessage="Serial Number is required."
                                CssClass="validation-error" Display="Dynamic">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-col">
                        <div class="form-group">
                            <asp:Label ID="lblPlant" runat="server" Text="Plant:" AssociatedControlID="ddlPlant">
                            </asp:Label>
                            <asp:DropDownList ID="ddlPlant" runat="server" CssClass="form-control" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlPlant_SelectedIndexChanged"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvPlant" runat="server" ControlToValidate="ddlPlant"
                                ErrorMessage="Plant is required." CssClass="validation-error" Display="Dynamic"
                                InitialValue="">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <asp:Label ID="lblLevel" runat="server" Text="Level:" AssociatedControlID="ddlLevel">
                            </asp:Label>
                            <asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-control"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvLevel" runat="server" ControlToValidate="ddlLevel"
                                ErrorMessage="Level is required." CssClass="validation-error" Display="Dynamic"
                                InitialValue="">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-col">
                        <div class="form-group">
                            <asp:Label ID="lblLocation" runat="server" Text="Location:"
                                AssociatedControlID="txtLocation"></asp:Label>
                            <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvLocation" runat="server" ControlToValidate="txtLocation"
                                ErrorMessage="Location is required." CssClass="validation-error" Display="Dynamic">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <asp:Label ID="lblType" runat="server" Text="Type:" AssociatedControlID="ddlType">
                            </asp:Label>
                            <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvType" runat="server" ControlToValidate="ddlType"
                                ErrorMessage="Type is required." CssClass="validation-error" Display="Dynamic"
                                InitialValue="">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-col">
                        <div class="form-group">
                            <asp:Label ID="lblExpiryDate" runat="server" Text="Expiry Date:"
                                AssociatedControlID="txtExpiryDate"></asp:Label>
                            <asp:TextBox ID="txtExpiryDate" runat="server" CssClass="form-control" TextMode="Date">
                            </asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvExpiryDate" runat="server"
                                ControlToValidate="txtExpiryDate" ErrorMessage="Expiry Date is required."
                                CssClass="validation-error" Display="Dynamic">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <asp:Label ID="lblRemarks" runat="server" Text="Remarks:" AssociatedControlID="txtRemarks">
                    </asp:Label>
                    <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3">
                    </asp:TextBox>
                </div>

                <div class="form-group text-center">
                    <asp:Button ID="btnSubmit" runat="server" Text="Add Fire Extinguisher" OnClick="btnSubmit_Click"
                        CssClass="btn btn-primary" />
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
            </div>
        </div>


        <!-- Confirmation Popup -->
        <asp:Panel ID="pnlConfirmation" runat="server" CssClass="popup-panel" Style="display: none;">
            <div class="popup-content">
                <h3>Confirm Fire Extinguisher Details</h3>
                <table>
                    <tr>
                        <td>Serial Number:</td>
                        <td>
                            <asp:Label ID="lblConfirmSerialNumber" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Plant:</td>
                        <td>
                            <asp:Label ID="lblConfirmPlant" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Level:</td>
                        <td>
                            <asp:Label ID="lblConfirmLevel" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Location:</td>
                        <td>
                            <asp:Label ID="lblConfirmLocation" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Type:</td>
                        <td>
                            <asp:Label ID="lblConfirmType" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Expiry Date:</td>
                        <td>
                            <asp:Label ID="lblConfirmExpiryDate" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Remarks:</td>
                        <td>
                            <asp:Label ID="lblConfirmRemarks" runat="server"></asp:Label>
                        </td>
                    </tr>
                </table>
                <div class="popup-buttons">

                    <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                        OnClientClick="hideConfirmationPopup(); return false;" CssClass="button cancel" />

                    <asp:Button ID="btnConfirm" runat="server" Text="Confirm" OnClick="btnConfirm_Click"
                        CssClass="button confirm" />
                </div>
            </div>
        </asp:Panel>

        <asp:CustomValidator ID="cvExpiryDate" runat="server" ControlToValidate="txtExpiryDate"
            ErrorMessage="Expiry date cannot be in the past." CssClass="validation-error" Display="Dynamic"
            OnServerValidate="cvExpiryDate_ServerValidate">
        </asp:CustomValidator>
    </asp:Content>