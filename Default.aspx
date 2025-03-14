<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="FETS.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>FETS - Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Assets/css/styles.css" rel="stylesheet" />
        <style>
          /* Enhanced styling for FETS login page */
            body {
                background-color: #f5f7fa;
                font-family: 'Poppins', sans-serif;
                margin: 0;
                padding: 0;
                display: flex;
                min-height: 100vh;
                overflow: hidden;
                justify-content: center;
                align-items: center;
            }

            .left-panel {
                flex: 1;
                height: 100vh;
                overflow: hidden;
                position: relative;
                box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
            }

            .left-panel img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                position: absolute;
                top: 0;
                left: 0;
            }

            .right-panel {
                width: 450px;
                height: 100vh;
                padding: 0 50px;
                background-color: #ffffff;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                box-shadow: -5px 0 25px rgba(0, 0, 0, 0.1);
                z-index: 1;
                position: relative;
            }

            .logo-container {
                text-align: center;
                margin-bottom: 20px;
                width: 100%;
                position: relative;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100px; 
                overflow: visible;
            }

            .logo {
                /* max-width: 120px; */
                height: auto;
                display: block;
                position: relative;
                top: 6rem;
                width: 50%;
            }

            .login-container {
                background-color: #ffffff;
                width: 100%;
                text-align: center;
                padding: 20px 0;
                border-radius: 8px;
            }

            .login-header {
                margin-bottom: 40px;
                text-align: center;
            }

            .login-header h1 {
                color: #3052a0;
                font-size: 2.2rem;
                font-weight: 700;
                margin: 0;
                letter-spacing: 1px;
            }

            .message {
                display: block;
                width: 100%;
                padding: 12px;
                margin-bottom: 20px;
                background-color: #ffe8e8;
                color: #d63031;
                border-left: 4px solid #d63031;
                border-radius: 4px;
                font-size: 14px;
                text-align: left;
                box-sizing: border-box;
            }

            .form-group {
                text-align: left;
                width: 100%;
                margin-bottom: 25px;
            }

            .form-group label {
                display: block;
                margin-bottom: 10px;
                color: #555;
                font-weight: 600;
                font-size: 14px;
            }

            .form-control {
                width: 100%;
                padding: 14px 16px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 15px;
                transition: all 0.3s;
                box-sizing: border-box;
                background-color: #f9f9f9;
            }

            .form-control:focus {
                outline: none;
                border-color: #3052a0;
                background-color: #fff;
                box-shadow: 0 0 0 3px rgba(48, 82, 160, 0.1);
            }

            .btn-login {
                width: 100%;
                padding: 14px;
                background-color: #3052a0;
                border: none;
                border-radius: 6px;
                color: white;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s;
                box-shadow: 0 4px 6px rgba(48, 82, 160, 0.2);
            }

            .btn-login:hover {
                background-color: #243b78;
                transform: translateY(-2px);
                box-shadow: 0 6px 8px rgba(48, 82, 160, 0.3);
            }

            .btn-login:active {
                transform: translateY(0);
                box-shadow: 0 2px 4px rgba(48, 82, 160, 0.2);
            }

            .password-actions {
                display: flex;
                justify-content: center;
                margin-top: 25px;
            }

            .password-actions a {
                text-decoration: none;
                color: #3052a0;
                font-size: 14px;
                font-weight: 500;
                transition: color 0.2s;
                position: relative;
            }

            .password-actions a:hover {
                color: #243b78;
                text-decoration: underline;
            }

            .footer {
                margin-top: 40px;
                text-align: center;
                font-size: 12px;
                color: #777;
                position: absolute;
                bottom: 20px;
                width: 100%;
            }

            @media (min-width: 1600px) {
                .logo {
                    width: 50%; /* Slightly larger logo for big screens */
                    top: 12rem; /* Adjust position slightly */
                }
            }

            /* Standard Desktop Screens */
            @media (max-width: 1440px) {
                .logo {
                    width: 50%; /* Standard size */
                    top: 8rem;
                }
            }

            /* Small Desktops and Laptops */
            @media (max-width: 1080px) {
                .logo {
                    width: 50%; /* Slightly smaller for smaller desktops */
                    top: 6rem;
                }
            }

            /* Tablets and Small Laptops */
            @media (max-width: 1024px) {
                .logo {
                    width: 40%; /* Reduce size */
                    top: 5rem;
                }
            }

            /* Mobile Screens */
            @media (max-width: 768px) {
                .logo {
                    width: 140px;
                    top: 10px;
                }
            }

            /* Very Small Phones */
            @media (max-width: 480px) {
                .logo {
                    width: 120px;
                    top: 5px;
                }
            }
        </style>
</head>
<body>
    <div class="left-panel">
        <img src="Uploads/misc/front-gate.jpg" alt="Left Panel Background">
    </div>

    <div class="right-panel">
        <form id="form1" runat="server">
            <div class="logo-container">
                <img src="Uploads/misc/logo.jpeg" alt="FETS Logo" class="logo" />
            </div>

            <div class="login-container">
                <div class="login-header">
                    <h1>FETS LOGIN SITE</h1>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>

                <div class="form-group">
                    <asp:Label ID="lblUsername" runat="server" Text="Username:" AssociatedControlID="txtUsername"></asp:Label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter your username"></asp:TextBox>
                </div>

                <div class="form-group">
                    <asp:Label ID="lblPassword" runat="server" Text="Password:" AssociatedControlID="txtPassword"></asp:Label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter your password"></asp:TextBox>
                </div>

                <div class="form-group">
                    <asp:Button ID="btnLogin" runat="server" Text="Sign in" OnClick="btnLogin_Click" CssClass="btn-login" />
                </div>

                <div class="password-actions">
                    <asp:LinkButton ID="lnkForgotPassword" runat="server" OnClick="lnkForgotPassword_Click">Forgot password?</asp:LinkButton>
                </div>
            </div>
        </form>
    </div>
</body>
</html>
