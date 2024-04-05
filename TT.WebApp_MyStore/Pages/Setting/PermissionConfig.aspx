<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="PermissionConfig.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Setting.PermissionConfig" %>

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
        <div class='PermissionList'>
          <div class='PermissionListText'>
            <h2 id='lbPermissionList'>Danh sách quyền</h2>
          </div>
          <div class='PermissionList-Grid'>
            <div id='GridPermissionList'></div>
          </div>
      </div>
    </div>
        <script src="../../Scripts/Setting/PermissionConfigScript.js"></script>
</body>
</html>
</asp:Content>