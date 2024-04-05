<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/DefaultMasterPages.Master" AutoEventWireup="true" CodeBehind="FogotPass.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.FogotPass" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
     <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
    <link rel="stylesheet" href="../Assets/css/UserMasterPages.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
</head>
<body>
   <div id='processcustome' style='display:none'>
        <img id='img-pro' src=''>
    </div>
    <div class='msgError'>
        <span id='messerror'></span>
    </div>
     <div class="accessDenied" runat="server" id="OverTimeMess">
        <h2>Đường dẫn này đã hết hạn truy cập!</h2>
    </div>
    <div class='FormBody Form-ds'>
        <div class='full-content' style="width: 60%;margin-left: 22%;">
            <!-- <div class='TitleF Master-Title'>
                <span id='WorkflowTitle'>Thông tin nhân viên</span>
            </div> -->
            <div id="bodySentMail" runat="server">
                <div class='ItemRow col-md-12' style="text-align:center">
                <div class='ItemText Text' style="width: 300px;">
                    <span id='lbEmail'  runat="server">Tên đăng nhập/ Email </span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtEmail' type="email" runat="server" class="form-control" style="width: auto;" />
                    </div>
                </div>
                 
            </div>
            <div id="DivMailCheck" style="text-align:center" runat="server">
                <asp:button CssClass="btn LoginKeyEnter" runat="server" OnClick="btnCheckEmail_Click" Text="Gửi mail đổi mật khẩu"/>
                <div id="spWarningCompleted" runat="server" >
                    <span style="color: blue" >Đã gửi thông tin tới địa chỉ mail trên.Vui lòng kiểm tra hộp thư!</span>
                </div>
            </div>
            </div>
            <div id="bodyContent" runat="server">
                 <div class='ItemRow col-md-12'  style="text-align:center">
                <div class='ItemText Text' style="width: 300px;">
                    <span id='lbNewPassWord'  runat="server">Nhập mật khẩu mới</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <span id='messerrorNewPassWord' class='msgErrorSpan'></span>
                         <input id='txtNewPassWord'  runat="server" type="password" onchange="validateField('NewPassWord')" class="form-control" style="width: auto;" />
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'  style="text-align:center">
                <div class='ItemText Text' style="width: 300px;">
                    <span id='lbNewPassAgain'  runat="server">Nhập lại mật khẩu mới</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <span id='messerrorNewPassAgain' class='msgErrorSpan'></span>
                        <input type="password"  runat="server" id='txtNewPassAgain' onchange="validateField('NewPassAgain')"  class="form-control" style="width: auto;" />
                    </div>
                </div>
                 
            </div>
                <div class='ItemRow col-md-12' style="padding-left: 31%;">
                 <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <asp:button CssClass="btn LoginKeyEnter" runat="server" OnClick="btnChangePass_Click" Text="Đổi mật khẩu"/>
                    </div>
                </div>
            </div>
            </div>
        </div>
    </div>

</body>
</html>
</asp:Content>

