<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master"  AutoEventWireup="true" CodeBehind="InsUpdMailTemplate.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.MailTemplateSetting.InsUpdMailTemplate" %>

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
        <input type="button" id="btnSave" class="btnSave" onclick="onSaveMailTemplate()" value="Lưu" runat="server" />
    </div>
    <div class='FormBody Form-ds'>
        <div class='full-content'>
            <div id='UpdateInfo' class='title-child'  runat="server">Thông tin chung</div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbTitle'  runat="server">Tiêu đề </span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtTitle'  class="form-control" style="width: auto;" />
                    </div>
                </div>
                 <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbModule'  runat="server">Hạng mục</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                         <input type="text" id='txtModule'  class="form-control" style="width: auto;">
                    </div>
                </div>
            </div>
            </div>
             <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbSubject'  runat="server">Tiêu đề mail</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <textarea id='txtSubject'  class="form-control"></textarea>
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbBody'  runat="server">Nội dung mail</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <textarea id='txtBody'  class="form-control"></textarea>
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbThamSoSubject' runat="server">Tham số tiêu đề</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtThamSoSubject' class="form-control" style="width: auto;" />
                    </div>
                </div>
                <div class='ItemText Text'>
                    <span id='lbThamSoBody' runat="server">Tham số nội dung</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtThamSoBody' class="form-control" style="width: auto;" />
                    </div>
                </div>
            </div>
            
           
        </div>
    </div>
    <script src="../../Scripts/MailTemplateScript/InsUpdMailTemplateScript.js"></script>
</body>
</html>
</asp:Content>
