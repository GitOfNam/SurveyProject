<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master" AutoEventWireup="true" CodeBehind="ChangePass.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.ChangePass" %>

<asp:Content ID="ContentMy" ContentPlaceHolderID="BlankContent" runat="server">
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
</head>
<body>
   <div id='processcustome' style='display:none'>
        <img id='img-pro' src=''>
    </div>
    <div class='msgError'>
        <span id='messerror'></span>
    </div>
    <div class='FormBody Form-ds'>
        <div class='full-content'>
            <!-- <div class='TitleF Master-Title'>
                <span id='WorkflowTitle'>Thông tin nhân viên</span>
            </div> -->
            <div class='ItemRow col-md-12' style="text-align:center">
                <div class='ItemText Text' style="width: 300px;">
                    <span id='lbOldPassWord'  runat="server">Mật khẩu cũ</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                         <span id='messerrorOldPassWord' class='msgErrorSpan'></span>
                        <input id='txtOldPassWord' type="password" onchange="validateField('OldPassWord')" class="form-control" style="width: auto;" />
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'  style="text-align:center">
                <div class='ItemText Text' style="width: 300px;">
                    <span id='lbNewPassWord'  runat="server">Nhập mật khẩu mới</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <span id='messerrorNewPassWord' class='msgErrorSpan'></span>
                         <input id='txtNewPassWord'  type="password" onchange="validateField('NewPassWord')" class="form-control" style="width: auto;" />
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
                        <input type="password" id='txtNewPassAgain' onchange="validateField('NewPassAgain')"  class="form-control" style="width: auto;" />
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12' style="padding-left: 31%;">
                 <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input type="button" id="btnSave" class="btnSave" onclick="onSavePass()" value="Lưu"  runat="server" />
                    </div>
                </div>
            </div>
             
        </div>
    </div>
    <script src="../Scripts/ChangePass.js"></script>
</body>
</html>
</asp:Content>
