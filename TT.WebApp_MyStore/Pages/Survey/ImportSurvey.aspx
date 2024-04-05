<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master" AutoEventWireup="true" CodeBehind="ImportSurvey.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Survey.ImportSurvey" %>

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
<%--        <input type="button" id="btnExportExcel" class="btnExportExcel" onclick="onExportExcel()" value="Tải file mẫu" runat="server" />--%>
        <input type="button" id="btnImportExcel" class="btnImportExcel" onclick="onImportExcel()" value="Import" runat="server" />
    </div>
    <div class='FormBody Form-ds'>
         <div class='ItemRow col-md-12' >
                <div class='ItemText Text' style="width: 300px;">
                    <span id='lbUpload'  runat="server">Upload tài liệu</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                         <span id='messerrorUpload' class='msgErrorSpan'></span>
                        <input type='file' id='fuTemplate' accept='.xlsx' class="form-control" style="width: 210px;" />
                    </div>
                </div>
            </div>
    </div>
    <script src="../../Scripts/SurveyScript/ImportSurvey.js"></script>
</body>
</html>
</asp:Content>

