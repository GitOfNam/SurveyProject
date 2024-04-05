<%@ Page Title="" Language="C#" MasterPageFile="~/Admin/MasterPages/AdminMasterPages.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="TT.WebApp_MyStore.Admin.Pages.Settings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <head>
        <meta charset="utf-8" />
        <title>Settings</title>
        <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1" />
    </head>
    <body>
        <div class="PageSettings">
      <%--      <div class="FormSearch">
                <div>
                    <input type ="text"/>
                </div>
            </div>--%>
            <div class="Title FormSettings"></div>
            <div id="gridFormSettings"></div>
        </div>

        <script>
            // Khai báo API
            //var _api = {
            //    GetMenuSettings: "/API/AdminHandler.ashx?tbl=MenuSettings&func=GetAll",
            //}

            //$(document).ready(function () {
            //    //$("#gridFormSettings").kendoGrid({
            //    //    dataSource: [],
            //    //    pageable: true,
            //    //    sortable: true,
            //    //    pageSize: 20,
            //    //    columns: [
            //    //        {
            //    //            field: "Title",
            //    //            title: "Title Name",
            //    //            width: 300
            //    //        },
            //    //        {
            //    //            field: "Title",
            //    //            title: "Title Name",
            //    //            width: 300
            //    //        },
            //    //    ],
            //    //});

            //    $.ajax({
            //        url: _api.GetMenuSettings,
            //        data: null,
            //        type: "POST",
            //        scriptCharset: "utf8",
            //        dataType: "json",
            //        success: function (res) {
            //            if (res.status == "SUCCESS") {
            //                //$("#gridFormSettings").data("kendoGrid").setDataSource(res.data);
            //                GetDataHome(res.data);
            //            }
            //        },
            //        error: function (e) {
            //        }
            //    });
            //});
        </script>
    </body>
</asp:Content>
