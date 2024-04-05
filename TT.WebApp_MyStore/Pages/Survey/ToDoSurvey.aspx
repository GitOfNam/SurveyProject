<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master" AutoEventWireup="true" CodeBehind="ToDoSurvey.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Survey.ToDoSurvey" %>

<asp:Content ID="ContentMy" ContentPlaceHolderID="BlankContent" runat="server">
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
   <div id='processcustome' style='display:none'>
        <img id='img-pro' src=''>
    </div>
    <div class='msgError'>
        <span id='messerror'></span>
    </div>
    <div class='Buttons' style='display:block;'>
        <input type="button" id="btnSaveTempo" class="btnSaveTempo" onclick="onbtnSaveTempo()" value="Lưu tạm" />
        <input type="button" id="btnCompleted" class="btnPreviosPage" onclick="onbtnCompleted()" value="Hoàn tất" />
    </div>
     <div style="display:none" id="JQRTempToDO">

    </div>
    <div style="display:none" class="accessDenied" id="AccessDeniedToDo">
        <h2>Bạn không có quyền truy cập phiếu này !</h2>
    </div>
    <div style="display:none" class="completed-survey" id="CompletedSurvey">
        <h2 >NTN <i class="fas fa-solid fa-heart"></i> Survey </h2>
        <div>
            <h3 style="color: #ee5744">Cảm ơn bạn đã tham gia vào cuộc khảo sát.</h3>
            Chúng tôi rất vui khi bạn đã dành thời gian trả lời các câu hỏi. Ý kiến đóng góp của bạn rất có giá trị và quan trọng đối với chúng tôi. Những thông tin bạn đã cung cấp sẽ giúp chúng tôi tiếp tục phát triển và hoàn thiện hệ thống hơn nữa.
            <br /><a href="/Pages/Home.aspx"><span>Quay lại Trang Chủ.</span> </a>
            <br /><a href="#" id="btnAgainSurvey" onclick="AgainSurvey()"><span>Thực hiện lại khảo sát.</span> </a>
        </div>
    </div>
    <div class='FormBody Form-ds' id="FormToDoSurvey">
        <div class="AllPage_ToDo">
           <div class="CssPage divTitleSurvey">
            <div class="div-Content-TitleSurvey">
                <div class="Content-TitleSurvey">
                <h3 id="hTitleSurvey">Tiêu đề</h3>
                </div>
            </div>
            <div class="div-Content-MoTaSurvey">
                <div class="Content-MoTaSurvey">
                <span id="spnMoTaSurvey">Mô tả</span>
                </div>
            </div>
           </div>
            <div class='ButtonsSurvey' style='display:block;'>
                <input type="button" id="btnNextPage" class="btnNextPage" onclick="onBtnNextPage()" value="Trang tiếp theo" />
                <input type="button" id="btnPreviosPage" class="btnPreviosPage" onclick="onBtnPreviosPage()" value="Trang trước" />
            </div>
            <div class="CssPage Page_1">
            <div class="PageNumber">
                <span class="PageName">Trang 1</span>
            </div>
            <div class="ContentPage" id="Content_Page_1">

            </div>
            </div>
              <div class="PlaceNewPage">

              </div>
        </div>
    </div>
    <script src="../../Scripts/SurveyScript/ToDoSurvey.js"></script>
</body>
</html>
</asp:Content>
