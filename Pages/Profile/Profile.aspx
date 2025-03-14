<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="FETS.Pages.Profile.Profile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>FETS - Profile Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="../../Assets/css/styles.css" rel="stylesheet" />
    <style>
        

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
            color: white;
            font-size: 14px;
        }

        .btn-logout {
            padding: 8px 16px;
            background-color: rgba(220, 53, 69, 0.1);
            border: 1px solid rgba(220, 53, 69, 0.2);
            color: white;
            transition: all 0.3s ease;
        }

        .btn-logout:hover {
            background-color: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
        }

        .main-content {
            margin-top: 80px;
            padding: 20px;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }

        .profile-section {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }

        .section-title {
            color: #0056b3;
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
        }

        .validation-error {
            color: #dc3545;
            font-size: 12px;
            margin-top: 5px;
        }

        .btn-section {
            margin-top: 20px;
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        .message {
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 20px;
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

        .grid-view {
            width: 100%;
            margin-top: 20px;
        }
        .user-management {
            margin-top: 30px;
        }
        .role-select {
            width: 100%;
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Navigation Bar -->
        <nav class="nav-bar">
            <div class="user-info">
                Welcome, <asp:Label ID="lblUsername" runat="server"></asp:Label>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn btn-logout">Logout</asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            <!-- Header Section -->
            <header class="header">
                <div class="header-content">
                    <h2>Profile Management</h2>
                </div>
            </header>

            <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>

            <!-- Change Password Section -->
            <section class="profile-section">
                <h3 class="section-title">Change Password</h3>
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

                <div class="btn-section">
                    <asp:Button ID="btnBack" runat="server" Text="Back to Dashboard" OnClick="btnBack_Click" CssClass="btn btn-secondary" CausesValidation="false" />
                    <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" OnClick="btnChangePassword_Click" CssClass="btn btn-primary" ValidationGroup="ChangePassword" />
                </div>
            </section>

            <!-- User Management Section (Only visible to administrators) -->
            <asp:Panel ID="pnlUserManagement" runat="server" CssClass="profile-section" Visible="false">
                <h3 class="section-title">User Management</h3>
                
                <!-- Add New User Form -->
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

                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="ddlRole">Role:</asp:Label>
                    <asp:DropDownList ID="ddlRole" runat="server" CssClass="role-select">
                        <asp:ListItem Text="User" Value="User" />
                        <asp:ListItem Text="Administrator" Value="Administrator" />
                    </asp:DropDownList>
                </div>

                <div class="btn-section">
                    <asp:Button ID="btnAddUser" runat="server" Text="Add User" OnClick="btnAddUser_Click" CssClass="btn btn-primary" ValidationGroup="AddUser" />
                </div>

                <!-- Users Grid -->
                <div class="user-management">
                    <h4>Existing Users</h4>
                    <asp:GridView ID="gvUsers" runat="server" 
                        AutoGenerateColumns="False" 
                        CssClass="grid-view"
                        OnRowCommand="gvUsers_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="Username" HeaderText="Username" />
                            <asp:BoundField DataField="Role" HeaderText="Role" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnDelete" runat="server" 
                                        CommandName="DeleteUser" 
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="btn btn-danger btn-sm"
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
    </form>
</body>
</html> 