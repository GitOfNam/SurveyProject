<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master" AutoEventWireup="true" CodeBehind="InsertUpdateGroup.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.GroupSetting.InsertUpdateGroup" %>

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
        <input type="button" id="btnSave" class="btnSave" onclick="onSaveGroup()" value="Lưu"  runat="server" />
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
                    <span id='lbStatus'  runat="server">Trạng thái</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='ddlStatus'  class="form-control" style="width: 210px;"  />
                    </div>
                </div>
            </div>
            
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbUserOnGroup'  runat="server">Người dùng thuộc group</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtUserOnGroup' class="form-control"  />
                    </div>
                </div>
            </div>

            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbIsManager'  runat="server">Nhóm quản trị</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input type='checkbox' id='ckIsManager'  class="form-control" style="width: 210px;" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="../../Scripts/GroupScript/InsertUpdateGroupScript.js"></script>
</body>
</html>
</asp:Content>
