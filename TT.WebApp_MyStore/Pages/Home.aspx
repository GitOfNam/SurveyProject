<%@ Page Title="" Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Home" %>
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
        <div class='statistical-Content'>
            <div class='dashboard-content bgr-full'>
                <div id='k-chart-dashboard' class='k-chart-dashboard'></div>
                <div class='chart-left'>
                    <div><span class='ic-OverDue'></span><span class='chart-text title-Link'><span id="notiOverDue">2</span> trễ hạn</span></div>
                    <div><span class='ic-Today'></span><span class='chart-text title-Link'><span id="notiToday">2</span> Hoàn tất hôm nay</span></div>
                    <div><span class='ic-NextTo' ></span><span class='chart-text title-Link' ><span id="notiNextTo">2</span> Sắp tới</span></div>
                </div>
                <div class='chart-right'>
                    <div><span class='ic-NotYetEval'>10</span><span class='chart-text title-Link'>Chưa đánh giá</span></div>
                    <div><span class='ic-Evaluating'>20</span><span class='chart-text title-Link'>Đang đánh giá</span></div>
                    <div><span class='ic-Completed'>20</span><span class='chart-text title-Link'>Đã hoàn tất</span></div>
                </div>
            </div>
        </div>
        <div class='ToDoList'>
          <div class='ToDoList-Text'>
            <h2 id='TextNotify'>Việc cần xử lý</h2>
          </div>
          <div class='ToDoList-Grid'>
            <div id='GridNotify'></div>
          </div>
      </div>
    </div>
    <script src="../Scripts/HomeScript.js"></script>
</body>
</html>
</asp:Content>
