<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master" AutoEventWireup="true" CodeBehind="InsUpdSettingConfig.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Setting.InsUpdSettingConfig" %>

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
    <div class='Buttons' style='display:block;'>
        <input type="button" id="btnSave" class="btnSave" onclick="onSaveConfig()" value="Lưu"  runat="server" />
    </div>
    <div class='FormBody Form-ds'>
        <div class='full-content'>
            <!-- <div class='TitleF Master-Title'>
                <span id='WorkflowTitle'>Thông tin nhân viên</span>
            </div> -->
            <div id='UpdateInfo' class='title-child'  runat="server">Thông tin chung</div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbTitle'  runat="server">Tiêu đề</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtTitle'  class="form-control" style="width: auto;"  />
                    </div>
                </div>
                <div class='ItemText Text'>
                    <span id='lbValue'  runat="server">Giá trị </span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtValue'  class="form-control" style="width: auto;"  />
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbDescript'  runat="server">Mô tả</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtDescript'  class="form-control"  />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="../../Scripts/Setting/InsUpdSettingConfig.js"></script>
</body>
</html>
</asp:Content>
