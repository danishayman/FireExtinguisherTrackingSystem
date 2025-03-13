<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="FETS.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>FETS - Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Assets/css/styles.css" rel="stylesheet" />
    <style>
            body {
            background-color: #ffffff;
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            min-height: 100vh;
            overflow: hidden; /* Prevent body scrolling */
        }

        .left-panel {
            flex: 1;
            position: relative;
            height: 120vh; /* Fixed height equal to viewport height */
            overflow: hidden; /* Prevent scrolling */
        }

        .left-panel img {
            width: 100%;
            height: 100%;
            object-fit: cover; /* Ensures the image covers the panel without distortion */
            position: absolute;
            top: 0;
            left: 0;
        }

        .right-panel {
            width: 450px;
            padding: 40px;
            background-color: #ffffff;
            display: flex;
            flex-direction: column;
            justify-content: center;
            box-shadow: -5px 0 15px rgba(0, 0, 0, 0.1);
            z-index: 1;
            overflow-y: auto; /* Allow scrolling only for the right panel */
            height: 100vh; /* Match the height of the left panel */
        }

        .logo-container {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo {
            max-width: 200px;
            height: auto;
        }

        .login-container {
            background-color: #ffffff;
            padding: 0;
            width: 100%;
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-header h1 {
            color: #333;
            font-size: 1.8rem;
            font-weight: 600;
            margin: 0;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 500;
            font-size: 14px;
        }

        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.2s;
            box-sizing: border-box;
        }

        .form-control:focus {
            border-color: #3052a0;
            outline: none;
        }

        .btn-login {
            width: 100%;
            padding: 12px;
            background-color: #3052a0;
            border: none;
            border-radius: 4px;
            color: white;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .btn-login:hover {
            background-color: #253d7a;
        }

        .message {
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 15px;
            font-size: 14px;
        }

        .message.error {
            background-color: #fee2e2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }

        .message.success {
            background-color: #dcfce7;
            color: #16a34a;
            border: 1px solid #bbf7d0;
        }

        .password-actions {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-top: 20px;
        }

        .password-link {
            color: #3052a0;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.2s;
        }

        .password-link:hover {
            color: #253d7a;
            text-decoration: underline;
        }

        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 12px;
            color: #777;
        }

        .help-section {
            margin-top: 30px;
            text-align: center;
        }

        .help-title {
            color: #3052a0;
            font-size: 20px;
            margin-bottom: 10px;
        }

                @media (max-width: 1200px) {
            .left-panel {
                flex: 2;
            }
        }

        @media (max-width: 992px) {
            body {
                flex-direction: column;
            }

            .left-panel {
                height: 40vh; /* Adjust height for smaller screens */
                width: 100%;
            }

            .right-panel {
                width: 100%;
                box-sizing: border-box;
                padding: 30px 20px;
                height: auto; /* Allow the right panel to grow as needed */
            }
        }
    </style>
</head>
<body>
    <div class="left-panel">
        <img src="Uploads/misc/3eb76a9a-6ffb-4e4a-9f22-888678793bfd.jpg" alt="Fire Extinguisher Background">
    </div>

    <div class="right-panel">
        <form id="form1" runat="server">
            <div class="logo-container">
                <img src="Assets/images/fets-logo.png" alt="FETS Logo" class="logo" />
            </div>

            <div class="login-container">
                <div class="login-header">
                    <h1>FETS LOGIN PAGE</h1>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>

                <div class="form-group">
                    <asp:Label ID="lblUsername" runat="server" Text="Username:" AssociatedControlID="txtUsername"></asp:Label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter your username"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                        ControlToValidate="txtUsername"
                        ErrorMessage="Username is required"
                        Display="Dynamic"
                        CssClass="message error">
                    </asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <asp:Label ID="lblPassword" runat="server" Text="Password:" AssociatedControlID="txtPassword"></asp:Label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Fill Your Password Here"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                        ControlToValidate="txtPassword"
                        ErrorMessage="Password is required"
                        Display="Dynamic"
                        CssClass="message error">
                    </asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <asp:Button ID="btnLogin" runat="server" Text="Sign in" OnClick="btnLogin_Click" CssClass="btn-login" />
                </div>

                <div class="password-actions">
                    <asp:LinkButton ID="lnkChangePassword" runat="server" CssClass="password-link" CausesValidation="false">
                        Change Password
                    </asp:LinkButton>
                    <asp:LinkButton ID="lnkForgotPassword" runat="server" CssClass="password-link" OnClick="lnkForgotPassword_Click" CausesValidation="false">
                        Forgot Account ID
                    </asp:LinkButton>
                </div>

                <div class="help-section">
                    <div class="help-title">Need Help?</div>
                </div>

                <div class="footer">
                    <div>www.fets.com | Privacy</div>
                </div>
            </div>
        </form>
    </div>
</body>
</html>