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
            overflow: hidden; /* Prevent scrolling */
            justify-content: center;
            align-items: center;
        }
    
        .left-panel {
            flex: 1;
            height: 100vh;
            overflow: hidden;
            position: relative;
        }
    
        .left-panel img {
            width: 100%;
            height: 100%;
            object-fit: cover; /* Ensure the image covers the entire panel */
            position: absolute;
            top: 0;
            left: 0;
        }
    
        .right-panel {
            width: 451px;
            height: 100vh;
            padding: 40px;
            background-color: #ffffff;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            box-shadow: -5px 0 15px rgba(0, 0, 0, 0.1);
            z-index: 1;
            overflow: visible;
            box-sizing: border-box;
        }
    
            .logo-container {
            text-align: center;
            margin-bottom: 20px; /* Positive margin */
            height: auto; /* Adjust to logo height */
            overflow: visible; /* Prevent clipping */
        }

        .logo {
            max-width: 150px; /* Adjust as needed */
            height: auto; /* Maintain aspect ratio */
        }

    
        .login-container {
            background-color: #ffffff;
            width: 100%;
            text-align: center;
        }
    
        .login-header {
            margin-bottom: 30px;
            text-align: center;
        }
    
        .login-header h1 {
            color: #3052a0;
            font-size: 2rem;
            font-weight: 700;
            margin: 0;
            text-transform: uppercase;
        }
    
        .form-group {
            text-align: left;
            width: 100%;
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
            background-color: #243b78;
        }
    
        .password-actions {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-top: 20px;
            text-align: center;
        }
    
        .password-actions a {
            text-decoration: none;
            color: #3052a0;
            font-size: 14px;
            font-weight: 500;
        }
    
        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 12px;
            color: #777;
        }
    
        @media (max-width: 992px) {
            body {
                flex-direction: column;
                justify-content: flex-start;
            }
    
            .left-panel {
                height: 40vh;
                width: 100%;
            }
    
            .right-panel {
                width: 100%;
                height: auto;
                padding: 30px 20px;
                box-shadow: none;
            }
    
            .logo-container {
                margin-bottom: 10px;
            }
    
            .login-header h1 {
                font-size: 1.75rem;
            }
        }
    
        @media (max-width: 768px) {
            .right-panel {
                padding: 20px;
            }
    
            .login-header h1 {
                font-size: 1.5rem;
            }
    
            .form-control {
                padding: 10px;
            }
    
            .btn-login {
                padding: 10px;
                font-size: 14px;
            }
        }
    
        @media (max-width: 480px) {
            .right-panel {
                padding: 15px;
            }
    
            .logo {
                max-width: 120px;
            }
    
            .login-header h1 {
                font-size: 1.25rem;
            }
    
            .form-group label {
                font-size: 12px;
            }
    
            .form-control {
                font-size: 12px;
            }
    
            .btn-login {
                font-size: 12px;
            }
    
            .password-actions a {
                font-size: 12px;
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
