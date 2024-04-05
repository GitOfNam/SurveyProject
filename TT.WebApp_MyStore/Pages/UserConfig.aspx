<%@ Page Title="" Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="UserConfig.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.UserConfig" %>
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
        <div class='UserList'>
          <div class='UserListText'>
            <h2 id='lbUserList'>Danh sách người dùng</h2>
          </div>
          <div class='UserList-Grid'>
            <div id='GridUserList'></div>
          </div>
      </div>
    </div>
        <script src="../Scripts/UserConfigJS.js"></script>
</body>
</html>
</asp:Content>
