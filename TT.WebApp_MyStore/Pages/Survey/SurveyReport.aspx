<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="SurveyReport.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Survey.SurveyReport" %>

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
   <div class='container ReportSLADepartment'>
         <div class='Title'>
            <div class='TitleReport'>
                BÁO CÁO TỔNG QUAN TÌNH HÌNH KHẢO SÁT
            </div>
        </div>
        <div class='total'>
            <div class='nav-bar'>
                <div class='form-nav'>
                    <div class='grid-form'>
                        <div class='div-input'>
                            <Label>Xem theo</Label><span class='ms-accentText'  title='Đây là trường bắt buộc.'> *</span>
                              <select style='width: 100%' class='ddlType' onchange='ChangeType()' value='Day' id='ddlType'>
                                <option value='Day'>Ngày</option>
                                <option value='Week'>Tuần</option>
                                <option value='Month'>Tháng</option>
                                <option value='Year'>Năm</option>
                            </select>
                        </div>
                        <div class='div-input'>
                            <Label>Từ ngày</Label><span class='ms-accentText'  title='Đây là trường bắt buộc.'> *</span>
                           <input type='text' style='width: 100%' class='ddlDateFrom' id='ddlDateFrom'>
                        </div>
                        <div class='div-input'>
                            <Label>Đến ngày</Label><span class='ms-accentText'  title='Đây là trường bắt buộc.'> *</span>
                             <input type='text' style='width: 100%' class='ddlDateTo' id='ddlDateTo'>
                        </div>
                        <div class='div-input' style="padding: 32px">
                           <input type='button' class='btnSearch' onclick='Search()' value='Tra cứu' />
                        </div>
                    </div>
                </div>
            </div>
            
            <div class='Form-ds' id='workflowEdit'>
                <div class='Tab-Document'>
                    <div class='Top-body'>
                        <div class='ContentBody'>
                            <div class='Content-left'>
                                <h2>Số lượng khảo sát đã tạo</h2>
                                <div class='grid-area'>
                                    <div id='grid'></div>
                                </div>
                            </div>
                            <div class='Content-right'>
                                <div class='Content-Chart'>
                                    <div>Tình trạng đánh giá khảo sát theo thời gian</div>
                                    <div>
                                        <div id='chart'></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class='Bottom-body'>
                        <div class='Bottom-Content'>
                            <h2>Danh sách chi tiết</h2>
                            <div>
                                <div class='Bottom-grid'>
                                    <div id='gridDetail'></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
        <script src="../../Scripts/SurveyScript/SurveyReportScript.js"></script>
</body>
</html>
</asp:Content>
