<%@ Page Title="PageLogin" Language="C#" MasterPageFile="~/Pages/MasterPages/DefaultMasterPages.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <header>
        <link rel="stylesheet" href="../Assets/css/cssDefault/CssLoginPage.css" />
    </header>
    <body>
        <div class="main">
            <input type="checkbox" id="chk" aria-hidden="true">
            <div class="signup">
                <label for="chk" aria-hidden="true">Sign up</label>
                <input type="text" id="txtFullName" runat="server" placeholder="Full Name" class="txtFullName">
                <input type="email" id="txtEmail" runat="server" placeholder="Email" class="txtEmail">
                <input type="password" id="txtPass" runat="server" placeholder="Password" class="txtPass">
                <asp:button CssClass="btn" runat="server"  OnClick="btnRegister_Click" OnClientClick="return RegisterValidate();" Text="Register" />
            </div>
<%--            <asp:Panel DefaultButton="SignInUser" runat="server">
                    <label for="chk" aria-hidden="true">Login</label>
                    <input type="text" name="UserName" placeholder="Tài khoản" runat="server" id="Text1" class="UserName" />
                    <input type="password" name="Password" placeholder="Mật khẩu" runat="server" id="Password1" class="Password" />
                    <asp:Button ID="SignInUser" CssClass="btn" runat="server" OnClick="btnLogin_Click" OnClientClick="return SignInValidate();" Text="Login" />
                </asp:Panel>--%>
            <div class="login" >
                <label for="chk" aria-hidden="true">Login</label>
                <input type="text" name="UserName" placeholder="UserName or email" runat="server" id="UserName" class="UserName"/>
                <input type="password" name="Password" placeholder="Password" runat="server" id="Password" class="Password"/>
                <asp:button CssClass="btn LoginKeyEnter" runat="server" OnClick="btnLogin_Click" OnClientClick="return LoginValidate();" Text="Login"/>
                 <div style="text-align: center;font-size: 13px;font-family: initial;">
                    <a  href="/Pages/FogotPass.aspx" target="_blank" >Quên mật khẩu</a>
                </div>
            </div>
           
        </div>
    </body>
    <script type="text/javascript">
        var _linkChangePass = {
            ChangePass: "/Pages/ChangePass.aspx"
        }
        $(document).ready(function () {
            //$(document).keypress(function (event) {
            //    var keycode = (event.keyCode ? event.keyCode : event.which);
            //    if (keycode == '13') {
            //        $(".LoginKeyEnter").trigger("click");
            //    }
            //});
        });

        //function ReceiverDiagram(arg, context) {
        //    alert(arg);
        //}
        function OpenChangePass() {
            showDialog(_linkChangePass.ChangePass, "Thay đổi mật khẩu");
        }
        function LoginValidate() {
            if (isNullOrEmpty($(".Password").val()) || isNullOrEmpty($(".UserName").val())) {
                alert("Vui lòng nhập đủ các thông tin bắt buộc!");
                return false;
            }
            return true;
        }
        function RegisterValidate() {
            if (isNullOrEmpty($(".txtEmail").val()) || isNullOrEmpty($(".txtPass").val()) || isNullOrEmpty($(".txtFullName").val())) {
                alert("Vui lòng nhập đủ các thông tin bắt buộc!");
                return false;
            }
            return true;
        }
      
        function isNullOrEmpty(str) {
            var returnValue = false;
            if (!str
                || str == null
                || str === 'null'
                || str === ''
                || str === '{}'
                || str === 'undefined'
                || str.length === 0) {
                returnValue = true;
            }
            return returnValue;
        }
    </script>
</asp:Content>
