<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="FETS.Pages.Profile.Profile" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Base styles to match View Section and Data Entry */
        .dashboard-container {
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
        }

        .profile-section {
            width: 100%;
            max-width: 1100px;
            min-width: 1000px;
            margin: 0 auto 30px auto;
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

        .section-title {
            font-size: 1.5rem;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #007bff;
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

        .btn-primary {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 8px 16px;
            font-size: 1rem;
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

        .btn-danger {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 4px 8px;
            font-size: 0.875rem;
            min-width: 80px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .btn-danger:hover {
            background-color: #c82333;
        }

        .validation-error {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 5px;
            display: block;
        }

        .message {
            padding: 15px;
            margin: 0 auto 20px auto;
            border-radius: 4px;
            text-align: center;
            font-size: 0.95rem;
            max-width: 1100px;
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

        .btn-section {
            margin-top: 20px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        /* Grid styling */
        .user-management {
            margin-top: 30px;
        }

        .grid-view {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
            margin-top: 20px;
        }

        .grid-header th {
            background-color: #f8f9fa;
            color: #333;
            font-weight: 600;
            padding: 12px;
            text-align: center;
            border: 1px solid #dee2e6;
        }

        .grid-row td, .grid-row-alt td {
            padding: 10px;
            border: 1px solid #dee2e6;
            text-align: center;
            vertical-align: middle;
        }

        .grid-row-alt {
            background-color: #f8f9fa;
        }

        .grid-row:hover, .grid-row-alt:hover {
            background-color: #f2f2f2;
        }

        /* Form layout */
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-col {
            flex: 1;
            min-width: 0;
        }

        /* Responsive styles */
        @media (max-width: 1200px) {
            .profile-section {
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
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <h3>Profile Management</h3>
        
        <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>

        <!-- Change Password Section -->
        <section class="profile-section">
            <h4 class="section-title">Change Password</h4>
            
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtCurrentPassword">Current Password:</asp:Label>
                        <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" 
                            ControlToValidate="txtCurrentPassword"
                            ErrorMessage="Current password is required"
                            CssClass="validation-error"
                            Display="Dynamic"
                            ValidationGroup="ChangePassword">
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </div>

            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtNewPassword">New Password:</asp:Label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" 
                            ControlToValidate="txtNewPassword"
                            ErrorMessage="New password is required"
                            CssClass="validation-error"
                            Display="Dynamic"
                            ValidationGroup="ChangePassword">
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtConfirmPassword">Confirm New Password:</asp:Label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" 
                            ControlToValidate="txtConfirmPassword"
                            ErrorMessage="Confirm password is required"
                            CssClass="validation-error"
                            Display="Dynamic"
                            ValidationGroup="ChangePassword">
                        </asp:RequiredFieldValidator>
                        <asp:CompareValidator ID="cvPasswordMatch" runat="server"
                            ControlToValidate="txtConfirmPassword"
                            ControlToCompare="txtNewPassword"
                            ErrorMessage="New password and confirmation password do not match"
                            CssClass="validation-error"
                            Display="Dynamic"
                            ValidationGroup="ChangePassword">
                        </asp:CompareValidator>
                    </div>
                </div>
            </div>

            <div class="btn-section">
                <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" OnClick="btnChangePassword_Click" CssClass="btn btn-primary" ValidationGroup="ChangePassword" />
            </div>
        </section>

        <!-- User Management Section (Only visible to administrators) -->
        <asp:Panel ID="pnlUserManagement" runat="server" CssClass="profile-section" Visible="false">
            <h4 class="section-title">User Management</h4>
            
            <!-- Add New User Form -->
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtNewUsername">Username:</asp:Label>
                        <asp:TextBox ID="txtNewUsername" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvNewUsername" runat="server"
                            ControlToValidate="txtNewUsername"
                            ErrorMessage="Username is required"
                            CssClass="validation-error"
                            Display="Dynamic"
                            ValidationGroup="AddUser">
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtUserPassword">Password:</asp:Label>
                        <asp:TextBox ID="txtUserPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvUserPassword" runat="server"
                            ControlToValidate="txtUserPassword"
                            ErrorMessage="Password is required"
                            CssClass="validation-error"
                            Display="Dynamic"
                            ValidationGroup="AddUser">
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </div>

            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="ddlRole">Role:</asp:Label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control">
                            <asp:ListItem Text="User" Value="User" />
                            <asp:ListItem Text="Administrator" Value="Administrator" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="form-col">
                    <!-- Empty column for alignment -->
                </div>
            </div>

            <div class="btn-section">
                <asp:Button ID="btnAddUser" runat="server" Text="Add User" OnClick="btnAddUser_Click" CssClass="btn btn-primary" ValidationGroup="AddUser" />
            </div>

            <!-- Users Grid -->
            <div class="user-management">
                <h4 class="section-title">Existing Users</h4>
                <asp:GridView ID="gvUsers" runat="server" 
                    AutoGenerateColumns="False" 
                    CssClass="grid-view"
                    OnRowCommand="gvUsers_RowCommand"
                    HeaderStyle-CssClass="grid-header"
                    RowStyle-CssClass="grid-row"
                    AlternatingRowStyle-CssClass="grid-row-alt">
                    <Columns>
                        <asp:BoundField DataField="Username" HeaderText="Username" />
                        <asp:BoundField DataField="Role" HeaderText="Role" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnDelete" runat="server" 
                                    CommandName="DeleteUser" 
                                    CommandArgument='<%# Eval("UserID") %>'
                                    CssClass="btn btn-danger"
                                    OnClientClick="return confirm('Are you sure you want to delete this user?');"
                                    Visible='<%# Eval("Username").ToString() != "admin" %>'>
                                    Delete
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </asp:Panel>
    </div>
</asp:Content> 