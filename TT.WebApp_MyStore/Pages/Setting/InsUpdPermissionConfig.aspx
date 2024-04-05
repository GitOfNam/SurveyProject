<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master" AutoEventWireup="true" CodeBehind="InsUpdPermissionConfig.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Setting.InsUpdPermissionConfig" %>

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
     <div style="display:none" id="JQRTempPer">

    </div>
   <div id='processcustome' style='display:none'>
        <img id='img-pro' src=''>
    </div>
    <div class='msgError'>
        <span id='messerror'></span>
    </div>
    <div class='Buttons' style='display:block;'>
        <input type="button" id="btnSave" class="btnSave" onclick="onSavePermission()" value="Lưu" runat="server" />
    </div>
    <div class='FormBody Form-ds'>
         <div class='title-child'  runat="server">Thông tin chung</div>
        <%-- <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbUserOnGroup'  runat="server">Cấu hình quyền menu</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtUserOnGroup' class="form-control"  />
                    </div>
                </div>
            </div>--%>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbPermissionName'  runat="server">Tiêu đề </span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtPermissionName'  class="form-control" style="width: auto;" />
                    </div>
                </div>
                <div class='ItemText Text'>
                    <span id='lbPermissionNameEN'  runat="server">Tiêu đề tiếng Anh</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                         <input type="text" id='txtPermissionNameEN'  class="form-control" style="width: auto;">
                    </div>
                </div>
            </div>
            <div id='UpdateInfo' class='title-child'  runat="server">Cấu hình quyền nhân viên</div>
            <div  class='ItemRow col-md-12'>
                <div id="treeViewPermission"></div>
            </div>
         </div>
    </div>
    <script src="../../Scripts/Setting/InsUpdPermissionConfigScript.js"></script>
</body>
</html>
</asp:Content>
