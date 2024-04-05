<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/UserMasterPages.Master" AutoEventWireup="true" CodeBehind="AddNewSurvey.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.Survey.AddNewSurvey" %>

<asp:Content ID="ContentMy" ContentPlaceHolderID="Content" runat="server">
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
    <div style="display:none" class="accessDenied" id="AccessDenied">
        <h2>Bạn không có quyền truy cập phiếu này !</h2>
    </div>
    <div class="container" style=" margin-top: 30px;" id="FormAddNewSurvey">
        <div class="stepwizard">
          <div class="stepwizard-row setup-panel">
            <div class="stepwizard-step col-xs-4">
              <a href="#step-1" id="step1" type="button" class="btn btn-success btn-circle nextBtn">1</a>
              <p><small>Thông tin </small></p>
            </div>
            <div class="stepwizard-step col-xs-4">
              <a href="#step-2"  id="step2" type="button" class="btn btn-default btn-circle nextBtn" disabled="disabled">2</a>
              <p><small>Thiết kế</small></p>
            </div>
            <div class="stepwizard-step col-xs-4">
              <a href="#step-3"  id="step3" type="button"  class="btn btn-default btn-circle nextBtn" disabled="disabled">3</a>
              <p><small>Khảo sát</small></p>
            </div>
            <div class="stepwizard-step col-xs-4">
            <a href="#step-4"  id="step4" type="button" class="btn btn-default btn-circle nextBtn" disabled="disabled">4</a>
            <p><small>Báo cáo</small></p>
          </div>
          </div>
        </div>
        <div>
            <div class="panel panel-primary setup-content" style="border-color: #ffbba9;" id="step-1">
              <div class="OverView" id="OverViewPage">
                   <div class='msgError'>
                        <span id='messerror'></span>
                    </div>
                    <div class='Buttons' style='display:block;'>
                        <input type="button"  class="nextBtn btnSaveAndNext"  value="Tiếp" runat="server" />
                        <input type="button"  class="btn btnReturn" id="btnUnactive" onclick="btnUnActive(event)" value="Hủy kích hoạt" />
                    </div>
                    <div class='FormBody Form-ds'>
                        <div class='full-content'>
                            <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbTitle'  runat="server">Khảo sát </span><label> (*)</label>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtTitle'  class="form-control" style="width: auto;" />
                                    </div>
                                </div>
                                <div class='ItemText Text'>
                                    <span id='lbSurveyCategory'  runat="server">Loại </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtSurveyCategory'  class="form-control" style="width: 210px;" />
                                    </div>
                                </div>
                            </div>
                            <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbFromDate'  runat="server">Ngày bắt đầu </span><label> (*)</label>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtFromDate' onchange="CheckDate('From')" class="form-control" style="width: auto;" />
                                    </div>
                                </div>
                                <div class='ItemText Text'>
                                    <span id='lbToDate'  runat="server">Ngày kết thúc </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtToDate' onchange="CheckDate('To')"  class="form-control" style="width: auto;" />
                                    </div>
                                </div>
                            </div>
                             <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbMoTa'  runat="server">Mô tả</span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                       <textarea id="taMoTa" class="form-control"></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbUserOnGroup'  runat="server">Đối tượng khảo sát</span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtUserOnGroup' placeholder="Nhập đối tượng khảo sát" class="form-control"  />
                                    </div>
                                </div>
                            </div>
                             <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbAllowMultipleResponses'  runat="server">Đánh giá nhiều lần </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input type="checkbox" id='ckAllowMultipleResponses'  style="width: 210px;" />
                                    </div>
                                </div>
                                <div class='ItemText Text'>
                                    <span id='lbCalScore'  runat="server">Tính điểm </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input  type="checkbox" id='ckCalScore'  style="width: 210px;" />
                                    </div>
                                </div>
                            </div>
                             <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbRankDaily'  runat="server">Xem bảng xếp hạng theo ngày </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input type="checkbox" id='ckRankDaily' disabled  style="width: 210px;" />
                                    </div>
                                </div>
                                <div class='ItemText Text'>
                                    <span id='lbRankAll'  runat="server">Xem bảng xếp hạng tổng </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input  type="checkbox" id='ckRankAll' disabled  style="width: 210px;" />
                                    </div>
                                </div>
                            </div>
                        </div>
                   </div>
                </div>
            </div>
      
            <div class="panel setup-content" id="step-2">
                 <div class='Buttons' style='display:block;'>
                        <input type="button"  class="btnReview" onclick="openReview()" value="Xem trước" runat="server" />
                        <input type="button"  class="btnSend" id="btnAcive" onclick="btnActive()"  value="Kích hoạt" />
                     <input type="button"  class="nextBtn btnSaveAndNext" onclick="nextStep"  value="Tiếp" runat="server" />
                    </div>
                <div class="Form-Control">
                    <div class="ToolBuider">
                        <div data-type="Builder" class="group-category expanded">
                            <div class="header-category"> <span class="TitleF">Builder</span> <span class="group-expander"
                                    title="Đóng"></span> </div>
                                        <ul id="ListBuilder" class="addList mCustomScrollbar _mCS_2 mCS-autoHide" style="height: 434px;">
                                           <li class="item-category item-draggable bSelectToAddQuestion" data-qtype="1"
                                                        onclick="onClickSurveyQuestion(event,1);">
                                                        <div class="q-item-icon"></div> <a class="SingleTextbox" href="#" data-qtype="1"> <span
                                                                class="SingleTextbox" data-qtype="1">Single Textbox</span> </a>
                                                        <div class="description" style="display:none"></div>
                                                    </li>
                                                    <li class="item-category item-draggable bSelectToAddQuestion" data-qtype="2"
                                                        onclick="onClickSurveyQuestion(event,2);">
                                                        <div class="q-item-icon"></div> <a class="MultipleTextboxes" href="#" data-qtype="2"> <span
                                                                class="MultipleTextboxes" data-qtype="2">Multiple Textboxes</span> </a>
                                                        <div class="description" style="display:none"></div>
                                                    </li>
                                                    <%--<li class="item-category item-draggable bSelectToAddQuestion" data-qtype="3"
                                                        onclick="onClickSurveyQuestion(event,3);">
                                                        <div class="q-item-icon"></div> <a class="RadioChoiceDropdown" href="#" data-qtype="3"> <span
                                                                class="RadioChoiceDropdown" data-qtype="3">Radio / Choice / Dropdown</span> </a>
                                                        <div class="description" style="display:none"></div>
                                                    </li>
                                                    <li class="item-category item-draggable bSelectToAddQuestion" data-qtype="4"
                                                        onclick="onClickSurveyQuestion(event,4);">
                                                        <div class="q-item-icon"></div> <a class="DateTime" href="#" data-qtype="4"> <span class="DateTime"
                                                                data-qtype="4">Date / Time</span> </a>
                                                        <div class="description" style="display:none"></div>
                                                    </li>--%>
                                        </ul>
                        </div>
                    </div>
                    <div class="AllPage">
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
                       <div class="CssPage Page_1">
                        <div class="PageNumber">
                            <span class="PageName">Trang 1</span>
                        </div>
                        <div class="ContentPage" id="Content_Page_1">

                        </div>
                        <div class="NewQuestion">
                            <input type="button" class="btn btnAdd" onclick="btnAdd(event,'Content_Page_1',1,1)" value="Thêm mới">
                        </div>
                       </div>
                        <div class="PlaceNewPage">

                        </div>
                       <div class="divNewPage" onclick="AddPage(event)">
                            <div class="Content_divNewPage">
                                <i class="fas fa-file-plus"></i> <span class="spnNewPage"><b>Trang mới</b></span>
                            </div>
                        </div>
                    </div>
                </div>
              <br />
            </div>
            <div class="panel panel-primary setup-content"  style="border-color: #337ab7;" id="step-3">
             <div class="ServeyStatistical" id="ServeyStatisticalPage">
                    <div class='Buttons' style='display:block;'>
                        <input type="button" class="btnExport" id="btnExportStatistical"  onclick="btnExportExcel()" value="Xuất Excel" runat="server" />
                        <input type="button" id="btnSearchSurvey" class="btnSearch" value="Tìm kiếm" onclick="btnSearch()" runat="server" />
                    </div>
                    <div class='FormBody Form-ds'>
                        <div class='full-content'>
                            <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbUserSurvey'  runat="server">Người đánh giá </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtUserSurvey'  class="form-control" style="width: auto;" />
                                    </div>
                                </div>
                                <div class='ItemText Text'>
                                    <span id='lbEmail'  runat="server">Email </span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtEmail'  class="form-control" style="width: auto;" />
                                    </div>
                                </div>
                            </div>
                            <div class='ItemRow col-md-12'>
                                <div class='ItemText Text'>
                                    <span id='lbSearchFromDate'  runat="server">Từ </span><label> (*)</label>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtSearchFromDate'  class="form-control" style="width: auto;" />
                                    </div>
                                </div>
                                <div class='ItemText Text'>
                                    <span id='lbSearchToDate'  runat="server">Đến</span>
                                </div>
                                <div class='ItemInput Input'>
                                    <div class='ItemControl'>
                                        <input id='txtSearchToDate'  class="form-control" style="width: auto;" />
                                    </div>
                                </div>
                            </div>
                            
                        </div>
                        
                   </div>
                 <div class="bodyGrid">
                            <div id="GridServeyStatistical"></div>
                        </div>
                </div>
            </div>
           <div class="panel panel-primary setup-content" id="step-4">
              <div class="SurveyReport" id="SurveyReportPage">
                  <div class="CssPage Page_1">
                        <div class="PageNumber">
                            <span class="PageName">Trang 1</span>
                        </div>
                        <div class="Report_ContentPage" id="Report_Content_Page_1">
                            
                        </div>
                  </div>
              </div>
            </div>
            </div>
           
    </div>
    <script src="../../Scripts/SurveyScript/AddNewSurveyScript.js"></script>
</body>
</html>
</asp:Content>
