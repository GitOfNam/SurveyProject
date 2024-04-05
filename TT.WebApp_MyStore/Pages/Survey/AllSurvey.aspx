<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="AllSurvey.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Survey.AllSurvey" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
        <link rel="stylesheet" href="../../Assets/css/Survey/SurveyCSS.css" />
</head>
<body>
     <div style="display:none" id="JQRTemp">

    </div>
   <div class='body-Content'>
        <div class='List-GridSurvey'>
          <div id="divFilter">

          </div>
          <div class='GridSurvey-Contentz'>
            <div id='GridSurvey'>

            </div>
          </div>
        </div>
    </div>
        <script src="../../Scripts/SurveyScript/AllSurvey.js"></script>
</body>
</html>
</asp:Content>
