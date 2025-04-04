<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="FETS.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>FETS - Login</title>
    <!-- Link to Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <!-- Link to external CSS styles -->
    <link href="Assets/css/styles.css" rel="stylesheet" />
    <style>
        /* General body styling */
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

        /* Left panel styling */
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

        /* Right panel styling */
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

        /* Logo container styling */
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
            height: auto;
            display: block;
            position: relative;
            top: 6rem;
            width: 50%;
        }

        /* Login container styling */
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

        /* Message styling */
        .message {
            display: block;
            position: absolute;
            bottom: 20px;
            right: 20px;
            width: auto;
            max-width: 300px;
            padding: 12px 20px;
            background-color: #ffe8e8;
            color: #d63031;
            border-left: 4px solid #d63031;
            border-radius: 4px;
            font-size: 14px;
            text-align: left;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            z-index: 10;
        }

        /* Form group styling */
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

        /* Button styling */
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

        /* Password actions styling */
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

        /* Footer styling */
        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 12px;
            color: #777;
            position: absolute;
            bottom: 20px;
            width: 100%;
        }

        /* Responsive logo styling */
        @media (min-width: 1600px) {
            .logo {
                width: 50%;
                top: 12rem;
            }
        }

        @media (max-width: 1440px) {
            .logo {
                width: 50%;
                top: 8rem;
            }
        }

        @media (max-width: 1080px) {
            .logo {
                width: 50%;
                top: 6rem;
            }
        }

        @media (max-width: 1024px) {
            .logo {
                width: 40%;
                top: 5rem;
            }
        }

        @media (max-width: 768px) {
            .logo {
                width: 140px;
                top: 10px;
            }
        }

        @media (max-width: 480px) {
            .logo {
                width: 120px;
                top: 5px;
            }
        }
    </style>
</head>

<body>
    <!-- Left panel with background image -->
    <div class="left-panel">
        <img src="Uploads/misc/front-gate.jpg" alt="Left Panel Background">
    </div>

    <!-- Right panel with login form -->
    <div class="right-panel">
        <form id="form1" runat="server">
            <!-- Logo container -->
            <div class="logo-container">
                <img src="Uploads/misc/logo.jpeg" alt="FETS Logo" class="logo" />
            </div>

            <!-- Login container -->
            <div class="login-container">
                <div class="login-header">
                    <h1>FETS LOGIN SITE</h1>
                </div>
                <!-- Username input field -->
                <div class="form-group">
                    <asp:Label ID="lblUsername" runat="server" Text="Username:" AssociatedControlID="txtUsername"></asp:Label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter your username"></asp:TextBox>
                </div>

                <!-- Password input field -->
                <div class="form-group">
                    <asp:Label ID="lblPassword" runat="server" Text="Password:" AssociatedControlID="txtPassword"></asp:Label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter your password"></asp:TextBox>
                </div>

                <!-- Login button -->
                <div class="form-group">
                    <asp:Button ID="btnLogin" runat="server" Text="Sign in" OnClick="btnLogin_Click" CssClass="btn-login" />
                </div>

                <!-- Forgot password link -->
                <div class="password-actions">
                    <asp:LinkButton ID="lnkForgotPassword" runat="server" OnClick="lnkForgotPassword_Click">Forgot password?</asp:LinkButton>
                </div>
            </div>
        </form>
        <!-- Message label for displaying errors or notifications -->
        <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>
    </div>
</body>

</html>