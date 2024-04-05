<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="GroupConfig.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.GroupSetting.GroupConfig" %>

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
        <div class='GroupList'>
          <div class='GroupListText'>
            <h2 id='lbGroupList'>Danh sách nhóm</h2>
          </div>
          <div class='GroupList-Grid'>
            <div id='GridGroupList'></div>
          </div>
      </div>
    </div>
        <script src="../../Scripts/GroupScript/GroupScript.js"></script>
</body>
</html>
</asp:Content>
