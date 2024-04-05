<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="MailTemplateConfig.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.MailTemplateSetting.MailTemplateConfig" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
</head>
<body>
   <div class='body-Content'>
        <div class='MailTemplateList'>
          <div class='MailTemplateListText'>
            <h2 id='lbMailTemplateList'>Danh sách mẫu mail</h2>
          </div>
          <div class='MailTemplateList-Grid'>
            <div id='GridMailTemplateList'></div>
          </div>
      </div>
    </div>
        <script src="../../Scripts/MailTemplateScript/MailTemplateConfigScript.js"></script>
</body>
</html>
</asp:Content>
