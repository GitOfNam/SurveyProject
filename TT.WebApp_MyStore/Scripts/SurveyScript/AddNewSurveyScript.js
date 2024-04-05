var lstID = [];
var itemSurvey = 0, itemSurveyEdit = 0, CountPage = 1;
var isNew = true;
var surveyTableID = '';
var DataSurvey = {
    BeanSurveyTable: {},
    BeanSurveyQuestion: [],
    BeanSurveyPage:[],
    RankDaily: false,
    RankAll: false,
    IsActive: 0
};
var _apiSurvey = {
    GetListUserAndGroup: "/API/UserHandler.ashx?tbl=Survey&func=GetListUserAndGroup",
    GetSurveyCategory: "/API/UserHandler.ashx?tbl=Survey&func=GetSurveyCategory",
    InsertUpdateSurveyTable: "/API/UserHandler.ashx?tbl=Survey&func=InsertUpdateSurveyTable",
    Active: "/API/UserHandler.ashx?tbl=Survey&func=Active",
    UnActive: "/API/UserHandler.ashx?tbl=Survey&func=UnActive",
    GetDataSurvey: "/API/UserHandler.ashx?tbl=Survey&func=GetDataSurvey",
    GetDataServeyStatistical: "/API/UserHandler.ashx?tbl=Survey&func=GetDataServeyStatistical&IDs=",
    SearchSurveyDetail: "/API/UserHandler.ashx?tbl=Survey&func=SearchSurveyDetail&IDs=",
    ExportExcel: "/API/UserHandler.ashx?tbl=Survey&func=ExportExcel&IDs=",
}
var dataSearch = {
    FullName: '',
    Email: '',
    FromDate: null,
    ToDate: null
}
var _linkReview = {
    linkReviewSurvey: "/Pages/Survey/ToDoSurvey.aspx?review=1&"
}
$(document).ready(function () {
        //event step
        var navListItems = $('div.setup-panel div a'),
        allWells = $('.setup-content'),
            allNextBtn = $('.nextBtn');
      allWells.hide();
      navListItems.click(function (e) {
        e.preventDefault();
        var $target = $($(this).attr('href')),
          $item = $(this);

        if (!$item.hasClass('disabled')) {
        navListItems.removeClass('btn-success').addClass('btn-default');
          $item.addClass('btn-success');
          allWells.hide();
          $target.show();
          $target.find('input:eq(0)').focus();
        }
      });

    allNextBtn.click(function () {
        if (!isNew && $(this).closest(".setup-content").length > 0) {
            var isCheck = PrepareData(null);
            if (isCheck) {
               SaveDataTable();
                var curStep = $(this).closest(".setup-content"),
                    curStepBtn = curStep.attr("id"),
                    curStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]');
                nextStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]').parent().next().children("a"),
                    curInputs = curStep.find("input[type='text'],input[type='url']"),
                    isValid = true;
                $(curStepWizard).addClass('CheckDone').removeClass("nextBtn");
                $(".form-group").removeClass("has-error");
                for (var i = 0; i < curInputs.length; i++) {
                    if (!curInputs[i].validity.valid) {
                        isValid = false;
                        $(curInputs[i]).closest(".form-group").addClass("has-error");
                    }
                }

                if (isValid) nextStepWizard.removeAttr('disabled').trigger('click');
            }
        }
        else {
            isNew = false;
            var curStep = $(this).closest(".setup-content"),
                curStepBtn = curStep.attr("id"),
                curStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]');
            nextStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]').parent().next().children("a"),
                curInputs = curStep.find("input[type='text'],input[type='url']"),
                isValid = true;
            $(curStepWizard).addClass('CheckDone').removeClass("nextBtn");
            $(".form-group").removeClass("has-error");
            for (var i = 0; i < curInputs.length; i++) {
                if (!curInputs[i].validity.valid) {
                    isValid = false;
                    $(curInputs[i]).closest(".form-group").addClass("has-error");
                }
            }

            if (isValid) nextStepWizard.removeAttr('disabled').trigger('click');
        }
      });
        $('div.setup-panel div a.btn-success').trigger('click');
        //loadTemplate
        LoadJqueryTemplate('SurveyTemplate', "#JQRTemp", function () {
          
        });
        //kendoControl
    $('#txtFromDate').kendoDatePicker({
        format: "dd/MM/yyyy"
    });
    $('#txtToDate').kendoDatePicker({
        format: "dd/MM/yyyy"
    });
    $('#txtSearchFromDate').kendoDatePicker({
        format: "dd/MM/yyyy"
    });
    $('#txtSearchToDate').kendoDatePicker({
        format: "dd/MM/yyyy"
    });

    $('#txtUserOnGroup').kendoMultiSelect({
        dataSource: [],
        dataTextField: "Title",
        dataValueField: "ID",
        placeholder:"Nhập đối tượng khảo sát"
    });
    $('#txtSurveyCategory').kendoDropDownList({
        dataSource: [],
        dataTextField: "Title",
        dataValueField: "ID"
    });

    $.ajax({
        url: _apiSurvey.GetListUserAndGroup,
        data: null,
        type: "POST",
        scriptCharset: "utf8",
        dataType: "json",
        success: function (res) {
            if (res.status == "SUCCESS") {
                var MultiSelect = $('#txtUserOnGroup').data("kendoMultiSelect");
                MultiSelect.setDataSource(res.data);
            }
        },
        error: function (e) {
        },
    });
    
    $.ajax({
        url: _apiSurvey.GetSurveyCategory,
        data: null,
        type: "POST",
        scriptCharset: "utf8",
        dataType: "json",
        success: function (res) {
            if (res.status == "SUCCESS") {
                var DropDownList = $('#txtSurveyCategory').data("kendoDropDownList");
                DropDownList.setDataSource(res.data);
                GetValue();
            }
        },
        error: function (e) {
        },
    });
    //set button
    $('#btnUnactive').hide();
});
function GetValue() {
    var IDs = getParameterByName("IDs");
    if (!isNullOrEmpty(IDs)) {
        var formDataMenu = new FormData();
        formDataMenu.append("IDs", IDs);
        $.ajax({
            url: _apiSurvey.GetDataSurvey,
            type: 'POST',
            async: false,
            cache: false,
            processData: false,
            contentType: false,
            scriptCharset: 'utf8',
            dataType: 'json',
            data: formDataMenu,
            success: function (response) {
                if (response != null && response.status == 'SUCCESS') {
                    setFieldValue(response.data);
                    DataSurvey = response.data;
                    if (DataSurvey.BeanSurveyTable) {
                        $('#hTitleSurvey').html(DataSurvey.BeanSurveyTable.Title);
                        $('#spnMoTaSurvey').html(DataSurvey.BeanSurveyTable.Description);
                        SetFieldDesign();
                    }
                    if (DataSurvey.BeanSurveyPage == null || DataSurvey.BeanSurveyPage.length == 0) {
                        var dataTemp = {};
                        dataTemp.Title = "Trang " + 1;
                        dataTemp.Status = 0;
                        dataTemp.Index = 1;
                        DataSurvey.BeanSurveyPage.push(dataTemp);
                        CountPage = 1;
                    }
                    if (DataSurvey.IsActive == 0) {
                        $('#btnUnactive').hide();
                        $('#btnAcive').show();
                    }
                    else if (DataSurvey.IsActive == 1) {
                        $('#btnUnactive').show();
                        $('#btnAcive').hide();
                    }
                    SetStepLayout();
                    SetDataStatistical();
                }
                else if (response != null && response.status == "MESSAGE" && response.data == "AccessDenied") {
                    $('#FormAddNewSurvey').hide();
                    $('#AccessDenied').show();
                }
            },
            error: function (errorData) {

            }
        });
    }
    else {
        var dataTemp = {};
        dataTemp.Title = "Trang " + 1;
        dataTemp.Status = 0;
        dataTemp.Index = 1;
        DataSurvey.BeanSurveyPage.push(dataTemp);
    }
}
function SetDataStatistical(){
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                // The remote endpoint from which the data is retrieved.
                url: _apiSurvey.GetDataServeyStatistical + getParameterByName("IDs") ,
                dataType: "json"
            }
        },
        pageSize: 20,
        schema: {
            model: {
                id: 'ID',
            },
            parse: function (response) {
                if (response.data != null)
                    return response.data;
                else
                    return [];
                 // twitter's response is { "statuses": [ /* results */ ] }
            }
        }

    });
    $('#GridServeyStatistical').kendoGrid({
        dataSource: dataSource,
        editable: false,
        sortable: true,
        pageable: {
            refresh: true,
            pageSizes: true
        },
        columns: [
            {
                field: 'FullName',
                title: 'Tên',
            }, {
                template: "<div>#:kendo.toString(kendo.parseDate(Created),'dd/MM/yyyy HH:mm')#</div>",
                field: 'Created',
                title: 'Ngày sửa',
            },
            {
                template: "<div>#:kendo.toString(kendo.parseDate(Modified),'dd/MM/yyyy HH:mm')#</div>",
                field: 'Modified',
                title: 'Ngày hoàn tất',
            },
            {
                field: 'Email',
                title: 'Email',
            }, {
                field: 'Rank',
                title: 'Thứ hạng',
            }, {
                field: 'Score',
                title: 'Điểm',
            }],
    }).data('kendoGrid');
}
function SetStepLayout() {
    var step = getParameterByName("Step");
    if (!isNullOrEmpty(step)) {
        if (step == 2) {
            $("#step1").addClass('CheckDone').removeClass("nextBtn");
            $("#step2").addClass('nextBtn');
            $("#step2").removeAttr('disabled').trigger('click');
        }
        else if (step == 3) {
            $("#step1").addClass('CheckDone').removeClass("nextBtn");
            $("#step2").addClass('CheckDone').removeClass("nextBtn");
            $("#step2").removeAttr('disabled');
            $("#step3").addClass('nextBtn');
            $("#step3").removeAttr('disabled').trigger('click');
        }
        else if (step == 4) {
            $("#step1").addClass('CheckDone').removeClass("nextBtn");
            $("#step2").addClass('CheckDone').removeClass("nextBtn");
            $("#step3").addClass('CheckDone').removeClass("nextBtn");
            $("#step2").removeAttr('disabled');
            $("#step3").removeAttr('disabled');
            $("#step4").addClass('nextBtn');
            $("#step4").removeAttr('disabled').trigger('click');
        }
    }
    else {
        if (DataSurvey.IsActive == 0) {
            if (!isNullOrEmpty(DataSurvey.BeanSurveyTable.ID)) {
                $("#step1").addClass('CheckDone').removeClass("nextBtn");
                $("#step2").addClass('nextBtn');
                $("#step2").removeAttr('disabled').trigger('click');
            }
        }
        else if (DataSurvey.IsActive == 1) {
            $("#step1").addClass('CheckDone').removeClass("nextBtn");
            $("#step2").addClass('CheckDone').removeClass("nextBtn");
            $("#step2").removeAttr('disabled');
            $("#step3").addClass('nextBtn');
            $("#step3").removeAttr('disabled').trigger('click');
        }
    }
}
function SetFieldDesign() {
    CountPage = DataSurvey.BeanSurveyPage.length;
    if (DataSurvey.BeanSurveyPage.length > 1) {
        for (var i = 1; i < DataSurvey.BeanSurveyPage.length; i++) {
            var divPlaceNewPage = $('div.PlaceNewPage');
            divPlaceNewPage.removeClass('PlaceNewPage');
            var data1 = [];
            data1.push(DataSurvey.BeanSurveyPage[i]);
            $("#PageTemplate").tmpl({ data: data1 }).appendTo(divPlaceNewPage);
            $("#PageReportTemplate").tmpl({ data: data1 }).appendTo('#SurveyReportPage');
            
        }
       
    }
    if (DataSurvey.BeanSurveyQuestion.length > 0) {
        lstID = DataSurvey.BeanSurveyQuestion;
        itemSurvey = DataSurvey.BeanSurveyQuestion.length, itemSurveyEdit = DataSurvey.BeanSurveyQuestion.length;
        for (var i = 0; i < DataSurvey.BeanSurveyQuestion.length; i++) {
            var itemQuestion = DataSurvey.BeanSurveyQuestion[i];
            //itemQuestion.Options = JSON.parse(itemQuestion.Options);
            var data = [];
            data.push(itemQuestion);
            data[0].Options = JSON.parse(data[0].Options);
            if (data[0].SQTId == 2) {
                data[0].Value = JSON.parse(data[0].Value);
                $("#MultipleTextboxesTemplate").tmpl({ data: data }).appendTo("#Content_Page_" + itemQuestion.Page);
            }
            else
                $("#SingleTextboxTemplate").tmpl({ data: data }).appendTo("#Content_Page_" + itemQuestion.Page);
            
            var itemID = itemQuestion.ID;
            setDataOptions(itemID, data[0].Options);
            
            $('#btnSave_' + itemQuestion.ID).click(function () { saveSurvey(itemID) });
            $('#btnCancle_' + itemQuestion.ID).click(function () { CancleSurvey(itemID) });
            $('#btnCancleEdit_' + itemQuestion.ID).click(function () { CancleEdit(itemID) });
            var EditForm = $('#' + itemQuestion.ID).find("div.EditItem");
            var ShowForm = $('#' + itemQuestion.ID).find("div.ShowItem");
            $(EditForm).find("input#txtTitle_" + itemQuestion.ID).val(itemQuestion.Title);
            if (data[0].SQTId == 2) {
                if (data[0].Value.MultipleTextboxes.length > 0) {
                    for (var item = 0; item < data[0].Value.MultipleTextboxes.length; item++) {
                        $(EditForm).find("input#txtTitle_" + data[0].Value.MultipleTextboxes[item].ID).val(data[0].Value.MultipleTextboxes[item].Title);
                    }
                }
            }
            EditForm.hide();
            ShowForm.show();
            if (data[0].SQTId == 2) {
                $("#Question_MultipleTextboxes_Template").tmpl({ data: data }).appendTo(ShowForm);
                data[0].Value = JSON.stringify(data[0].Value);
            }
            else
                $("#Question_SingleTextbox_Template").tmpl({ data: data }).appendTo(ShowForm);
            
            $("#AnswerReport_SingleTextbox_Template").tmpl({ data: data }).appendTo("#Report_Content_Page_" + itemQuestion.Page);

            itemQuestion.Options = JSON.stringify(itemQuestion.Options);
        }

    }
}
function setDataOptions(ID, Options) {
    if (!isNullOrEmpty(Options.ValidateAnswer)) {
        $('#div_Options_' + ID).show();
        $('#ValidateAnswer_value_' + ID).val(Options.ValidateAnswer.value);
        $('#txtMinNum_' + ID).val(Options.ValidateAnswer.min);
        $('#txtMaxNum_' + ID).val(Options.ValidateAnswer.max);
        $('#txtWarning_' + ID).val(Options.ValidateAnswer.warning);
    }
}
function setFieldValue(data) {
    $('#txtTitle').val(data.BeanSurveyTable.Title);
    if (data.BeanSurveyTable.Status == 0)
        $('#btnUnactive').hide();
    else
        $('#btnUnactive').show();
    $('#txtFromDate').data("kendoDatePicker").value(kendo.toString(kendo.parseDate(data.BeanSurveyTable.StartDate), 'dd/MM/yyyy'));
    $('#txtToDate').data("kendoDatePicker").value(kendo.toString(kendo.parseDate(data.BeanSurveyTable.DueDate), 'dd/MM/yyyy'));
    $('#ckCalScore')[0].checked = data.BeanSurveyTable.IsCalScore;
    $('#ckAllowMultipleResponses')[0].checked = data.BeanSurveyTable.AllowMultipleResponses;
    $('#taMoTa').val(data.BeanSurveyTable.Description);
    $("#txtSurveyCategory").data("kendoDropDownList").value(data.BeanSurveyTable.SCID);
    var itemKN = [];
    if (!isNullOrEmpty(data.BeanSurveyTable.Permission)) {
        var mangUser = data.BeanSurveyTable.Permission.split(",");
        if (mangUser.length > 0) {
            for (var b = 0; b < mangUser.length; b++) {
                if (!isNullOrEmpty(mangUser[b])) {
                    itemKN.push(mangUser[b]);
                }
            }
        }
    }
    $("#txtUserOnGroup").data("kendoMultiSelect").value(itemKN);
    $("#ckRankAll")[0].checked = data.RankAll;
    $("#ckRankDaily")[0].checked = data.RankDaily;
    $('#hTitleSurvey').html(data.BeanSurveyTable.Title);
    $('#spnMoTaSurvey').html(data.BeanSurveyTable.Description);
}
function openMenu(evt, menuName) {
  var i, v_tabcontent, v_tablinks;
  v_tabcontent = document.getElementsByClassName("v_tabcontent");
  for (i = 0; i < v_tabcontent.length;i++) {
        v_tabcontent[i].style.display = "none";
  }
  v_tablinks = document.getElementsByClassName("v_tablinks");
  for (i = 0; i < v_tablinks.length;i++) {
        v_tablinks[i].className = v_tablinks[i].className.replace(" active", "");
  }
  document.getElementById(menuName).style.display = "block";
  evt.currentTarget.className += " active";
}
function saveSurvey(ID) {
    var EditForm = $('#' + ID).find("div.EditItem");
    var ShowForm = $('#' + ID).find("div.ShowItem");
    if (!isNullOrEmpty($("#txtTitle_" + ID).val())) {
        if (ShowForm.find('.ShowContent').length == 0) {
            var Vlue = $("#txtTitle_" + ID).val();
            saveValueQuestion(ID, Vlue);
            let data = jQuery.grep(lstID, function (n, i) {
                return (n.ID == ID);
            });
            if (data.length > 0) {
                data[0].Options = JSON.parse(data[0].Options);
                if (data[0].SQTId == 2) {
                    data[0].Value = JSON.parse(data[0].Value);
                    $("#Question_MultipleTextboxes_Template").tmpl({ data: data }).appendTo(ShowForm);
                    data[0].Value = JSON.stringify(data[0].Value);
                }
                else 
                    $("#Question_SingleTextbox_Template").tmpl({ data: data }).appendTo(ShowForm);
                
                data[0].Options = JSON.stringify(data[0].Options);
                
            }
            
            //ShowForm.append('<div class="ShowContent question-row" onmouseover="this" onmouseout="this"><div class="ActivedQuestion"><div class="HiddenButtons"><input type="button" class="btn btn-Edit" onclick="ShowEdit(event,' + ID + ')" value="Sửa"></div><div class="question-rowContent"><div class="QuestionTitle"><span class="type-icon SingleTextbox">' + data[0].Index + '</span><label class="q-Number-Title">' + data[0].Index + '. </label> <label class="q-Title">' + Vlue + '</label></div><div class="q-Preview SingleLineTextBox"><div class="warning hide"></div><div class="q-Content"><input type="text" class="q-SingleTextBox form-control q-Num-' + ID + '" placeholder=" Nhập câu trả lời"></div></div></div></div> </div>');
        }
        else {
            var ShowContent = ShowForm.find('.ShowContent');
            saveValueQuestion(ID, $("#txtTitle_" + ID).val());
            $(ShowContent).val($("#txtTitle_" + ID).val());
            $(ShowContent).find('.q-Title').html($("#txtTitle_" + ID).val());
        }
        hideAllForm();
    }
    else {
       
        $('#messerror_' + ID).html("<span>Vui lòng nhập tiêu đề!</span>");
        setTimeout(function () { $('#messerror_' + ID).html(""); }, 4000);
    }
}
function saveValueQuestion(ID,value){
    for (var i = 0; i < lstID.length; i++) {
        if (lstID[i].ID == ID) {
            var strOption = {};
            lstID[i].Title = value;
            lstID[i].Required = $('#ckRequired_' + ID)[0].checked;
            lstID[i].DisableDoAgain = $('#ckDisableDoAgain_' + ID)[0].checked;
            if ($('#ckAcceptResultFomart_' + ID)[0].checked) {
                  strOption = {
                    AllowMultipleLine: $('#ckAllowMultipleLine_' + ID)[0].checked,
                    OtherComment: "",
                    ValidateAnswer: {
                        value: $('#ValidateAnswer_value_' + ID).val(),
                        min: $('#txtMinNum_' + ID).val(),
                        max: $('#txtMaxNum_' + ID).val(), 
                        warning: $('#txtWarning_' + ID).val()
                    }
                };
            }
            else {
                strOption = {
                    AllowMultipleLine: $('#ckAllowMultipleLine_' + ID)[0].checked,
                    OtherComment: "",
                    ValidateAnswer: null
                };
            }
            if (lstID[i].SQTId == 2) {
                var ValueItem = lstID[i].Value;
                if (isNullOrEmpty(ValueItem.MultipleTextboxes)) {
                    ValueItem = JSON.parse(lstID[i].Value);
                }
                if (ValueItem.MultipleTextboxes.length > 0) {
                    for (var item = 0; item < ValueItem.MultipleTextboxes.length; item++) {
                        var itemValue = ValueItem.MultipleTextboxes[item];
                        itemValue.Title = $('#txtTitle_' + itemValue.ID).val();
                       
                    }
                    var QuestionSetting = $(".QuestionSetting_" + lstID[i].ID);
                    if (QuestionSetting.length > 0) {
                        QuestionSetting[0].innerHTML = '';
                        var valueRefresh = [];
                        lstID[i].Value = ValueItem;
                        lstID[i].Options = strOption;
                        valueRefresh.push(lstID[i]);
                        $("#Question_MultipleTextboxes_TemplateEdit").tmpl({ data: valueRefresh }).appendTo(QuestionSetting);
                    }
                }
                lstID[i].Value = JSON.stringify(ValueItem);
            }
            lstID[i].Options = JSON.stringify(strOption);
            break;
        }
    }
}
function CancleEdit(ID) {
    hideAllForm();
}

function CancleSurvey(ID) {
    if (confirm("Bạn có chắc chắn muốn xóa bỏ khoản mục này!")) {
        $('#' + ID).remove();
        for (var i = 0; i < lstID.length; i++) {
            if (lstID[i].ID == ID) {
                lstID.splice(i, 1);
                break;
            }
        }
        SetIndexQuestion();
        itemSurveyEdit--;
    }
}
function ShowEdit(e, ID) {
    $('#btnSave_' + ID).click(function () { saveSurvey(ID) });
    $('#btnCancle_' + ID).click(function () { CancleSurvey(ID) });
    $('#btnCancleEdit_' + ID).click(function () { CancleEdit(ID) });
    var EditForm = $('#'+ID).find("div.EditItem");
    var ShowForm = $('#' +ID).find("div.ShowItem");
    EditForm.show();
    ShowForm.hide();
    for (var i = 0; i < lstID.length; i++) {
        if (lstID[i].ID != ID) {
            EditForm = $('#' + lstID[i].ID).find("div.EditItem");
            ShowForm = $('#' + lstID[i].ID).find("div.ShowItem");
            if (ShowForm.find('.ShowContent').length == 0) {
                ShowForm.closest('div#' + lstID[i].ID).remove();
                lstID.splice(i, 1);
                itemSurveyEdit--;
            } else {
                EditForm.hide();
                ShowForm.show();
            }
        }
    }
}
function onClickSurveyQuestion(e, type) {
    var IDPage = "Content_Page_" + DataSurvey.BeanSurveyPage.length;
    var Numpage = DataSurvey.BeanSurveyPage.length;
    btnAdd(e, IDPage, Numpage, type);
}
function btnAdd(e, IDPage,NumPage,type) {
    var intID = itemSurvey; //$('#' + IDPage).find('div.ShowItem').length;
    
    if (intID > 0) {
        var EditForm = $('#' + lstID[itemSurveyEdit - 1].ID).find("div.EditItem");
        var ShowForm = $('#' + lstID[itemSurveyEdit - 1].ID).find("div.ShowItem");
        EditForm.hide();
        ShowForm.show();
        if (ShowForm.find('.ShowContent').length == 0) {
            var Number = convertNumber2Digital(intID);
            var Vlue = $(EditForm).find("input#txtTitle_" + IDPage + "_Survey_" + Number).val();
            var OID = IDPage + "_Survey_" + Number;
            saveValueQuestion(OID, Vlue);
            let data = jQuery.grep(lstID, function (n, i) {
                return (n.ID == OID);
            });
            if (data.length > 0) {
                data[0].Options = JSON.parse(data[0].Options);
                $("#Question_SingleTextbox_Template").tmpl({ data: data }).appendTo(ShowForm);
                data[0].Options = JSON.stringify(data[0].Options);
            }
           
            //ShowForm.append('<div class="ShowContent question-row" onmouseover="this" onmouseout="this"><div class="ActivedQuestion"><div class="HiddenButtons"><input type="button" class="btn btn-Edit" onclick="ShowEdit(event,' + OID + ')" value="Sửa"></div><div class="question-rowContent"><div class="QuestionTitle"><span class="type-icon SingleTextbox">' + data[0].Index + '</span> <label class="q-Number-Title">' + data[0].Index + '. </label> <label class="q-Title">' + Vlue + '</label></div><div class="q-Preview SingleLineTextBox"><div class="warning hide"></div><div class="q-Content"><input type="text" class="q-SingleTextBox form-control q-Num-' + OID + '" placeholder=" Nhập câu trả lời"></div></div></div></div> </div>');

            //ShowForm.append('<div class="ShowContent" onclick=ShowEdit(event,' + OID + ')>' + Vlue + '</div>');
        }
    }
    hideAllForm();
    var formattedNumber = convertNumber2Digital(intID + 1);
    var dataTemp = {};
    dataTemp.ID = IDPage + "_Survey_" + formattedNumber;
    dataTemp.Page = NumPage;
    dataTemp.SQTId = type;
    dataTemp.Title = "";
    dataTemp.Options = {
        AllowMultipleLine: false,
        OtherComment:"",
        ValidateAnswer: null
    };
    dataTemp.Value = null;
    dataTemp.AnsweredCount = 0;
    dataTemp.OtherValueCount = 0;
    dataTemp.ValueCount = 0;
    dataTemp.Required = false;
    dataTemp.DisableDoAgain = false;
    dataTemp.IsScoring = DataSurvey.BeanSurveyTable.IsCalScore;
    dataTemp.Score = null;
    if (type == 2) {
        if (dataTemp.Value == null) {
            dataTemp.Value = {
                MultipleTextboxes: []
            };
            var dataDefault = {};
            dataDefault.Index = 1;
            dataDefault.ID = dataTemp.ID+"_ItemRow_1";
            dataDefault.Title = "";
            dataTemp.Value.MultipleTextboxes.push(dataDefault);
        }
    }
    else 
        dataTemp.Value = null;
    dataTemp.Description = "";
    if (!isNullOrEmpty(getParameterByName("IDs")))
        dataTemp.SurveyTableId = getParameterByName("IDs");
    
    dataTemp.Index = lstID.length + 1;
    lstID.push(dataTemp);
    itemSurvey++;
    itemSurveyEdit++;
    var data = [];
    data.push(dataTemp);
    if (type == 2)
        $("#MultipleTextboxesTemplate").tmpl({ data: data }).appendTo("#" + IDPage);
    else
        $("#SingleTextboxTemplate").tmpl({ data: data }).appendTo("#" + IDPage);
    
    $('#btnSave_' + dataTemp.ID).click(function () { saveSurvey(dataTemp.ID) });
    $('#btnCancle_' + dataTemp.ID).click(function () { CancleSurvey(dataTemp.ID) });
    $('#btnCancleEdit_' + dataTemp.ID).click(function () { CancleEdit(dataTemp.ID) });
}
function ItemRow_onClickAddItemRow(control, IDQuestion, CurrIndex) {
    var divPlaceNewPage = $('div.NewItemRow_' + IDQuestion+'_new');
    divPlaceNewPage.removeClass('NewItemRow_' + IDQuestion + '_new');
    var arr = IDQuestion.split('_ItemRow_');
    var dataDefault = {};
    dataDefault.Index = CurrIndex*1 + 1;
    dataDefault.ID = arr[0] + "_ItemRow_" + dataDefault.Index;
    dataDefault.Title = "";
    for (var i = 0; i < lstID.length; i++) {
        var dataItem = lstID[i];
        if (dataItem.ID == arr[0]) {
            if (dataItem.SQTId == 2) {
                if (isNullOrEmpty(dataItem.Value.MultipleTextboxes))
                    dataItem.Value = JSON.parse(dataItem.Value);
                dataItem.Value.MultipleTextboxes.push(dataDefault);
            }
        }
    }
    var data = [];
    data.push(dataDefault);
    $("#ItemRowQuestion").tmpl({ data: data }).appendTo(divPlaceNewPage);
}
function convertNumber2Digital(n) {
    return n > 9 ? "" + n : "0" + n;
}
function hideAllForm() {
    for (var i = 0; i < lstID.length; i++) {
        EditForm = $('#' + lstID[i].ID).find("div.EditItem");
        ShowForm = $('#' + lstID[i].ID).find("div.ShowItem");
        EditForm.hide();
        ShowForm.show();
    }
}
function DelQuestionEditNotSave() {
    for (var i = 0; i < lstID.length; i++) {
        EditForm = $('#' + lstID[i].ID).find("div.EditItem");
        ShowForm = $('#' + lstID[i].ID).find("div.ShowItem");
        if (ShowForm.find('.ShowContent').length == 0) {
            ShowForm.closest('div#' + lstID[i].ID).remove();
            lstID.splice(i, 1);
            //lstID[i].Index--;
            itemSurveyEdit--;
        } else {
            EditForm.hide();
            ShowForm.show();
        }
    }
}
function AddPage(e) {
    hideAllForm();
    DelQuestionEditNotSave();
    var divPlaceNewPage = $('div.PlaceNewPage');
    divPlaceNewPage.removeClass('PlaceNewPage');
    CountPage++;
    var dataTemp = {};
    dataTemp.Title = "Trang " + CountPage;
    dataTemp.Status = 0;
    dataTemp.Index = CountPage;
    DataSurvey.BeanSurveyPage.push(dataTemp);
    var data = [];
    data.push(dataTemp);
    $("#PageTemplate").tmpl({ data: data }).appendTo(divPlaceNewPage);
     
}
function SetIndexQuestion(e) {
    var item = 1;
    for (var i = 0; i < lstID.length; i++) {
        var EditForm = $('#' + lstID[i].ID).find("div.EditItem");
        var Span = $(EditForm).find('span#spnTitle_' + lstID[i].ID);
        var ShowForm = $('#' + lstID[i].ID).find("div.ShowItem");
        var ShowContent = ShowForm.find('.ShowContent');
        $(Span).html("Câu " + item);
        $(ShowContent).find('.q-Number-Title').html(item + ". ");
        lstID[i].Index = item;
        item++;
    }

}
function PrepareData() {
    if (!isNullOrEmpty($('#txtTitle').val()) && $('#txtFromDate').data("kendoDatePicker").value() != null) {
        return true;
    } else {
        $("#step1").removeAttr('disabled').trigger('click');
        if (isNullOrEmpty($('#txtTitle').val()))
            $('#txtTitle').focus();
        else
            $('#txtFromDate').focus();
        $("#messerror").html("<span>Vui lòng nhập các thông tin bắt buộc!</span>");
        setTimeout(function () { $("#messerror").html(""); }, 4000);
        return false;
    }
}
function SetPostData() {
    var dataSurveyTable = {};
    var formData = new FormData();
    surveyTableID = getParameterByName("IDs");
    if (!isNullOrEmpty(surveyTableID)) {
        //formData.append("surveyTableID", surveyTableID);
        dataSurveyTable.ID = surveyTableID;
    }
    dataSurveyTable.Title = $('#txtTitle').val();
    dataSurveyTable.SCID = !isNullOrEmpty($("#txtSurveyCategory").data("kendoDropDownList").value()) ? $("#txtSurveyCategory").data("kendoDropDownList").value():1;
    dataSurveyTable.Status = 0;
    dataSurveyTable.StartDate = $('#txtFromDate').data("kendoDatePicker").value();
    dataSurveyTable.DueDate = $('#txtToDate').data("kendoDatePicker").value();
    dataSurveyTable.IsCalScore = $('#ckCalScore')[0].checked;
    dataSurveyTable.AllowMultipleResponses = $('#ckAllowMultipleResponses')[0].checked;
    dataSurveyTable.Description = $('#taMoTa').val();
    dataSurveyTable.Permission = "";
    var UserOnGroup = $("#txtUserOnGroup").data("kendoMultiSelect");
    for (var i = 0; i < UserOnGroup.dataItems().length; i++) {
        dataSurveyTable.Permission += UserOnGroup.dataItems()[i].ID + ",";
    }
    DataSurvey.BeanSurveyTable = dataSurveyTable;
    if (lstID.length > 0) {
        DataSurvey.BeanSurveyQuestion = lstID;
        for (var t = 0; t < DataSurvey.BeanSurveyQuestion.length; t++) {
            
            if (!validateGuid(DataSurvey.BeanSurveyQuestion[t].ID)) {
                delete DataSurvey.BeanSurveyQuestion[t].ID; 
            }
            if (DataSurvey.BeanSurveyQuestion[t].SQTId == 2) {
                var ValueItem = DataSurvey.BeanSurveyQuestion[t].Value;
                if (isNullOrEmpty(ValueItem.MultipleTextboxes)) {
                    ValueItem = JSON.parse(DataSurvey.BeanSurveyQuestion[t].Value);
                }
                if (ValueItem.MultipleTextboxes.length > 0) {
                    for (var item = 0; item < ValueItem.MultipleTextboxes.length; item++) {
                        var itemValue = ValueItem.MultipleTextboxes[item];
                        if (!validateGuid(itemValue.ID)) {
                            delete itemValue.ID;
                        }
                    }
                }
                DataSurvey.BeanSurveyQuestion[t].Value = JSON.stringify(ValueItem);
            }
        }
    }
    formData.append("data", JSON.stringify(DataSurvey));
    return formData;
}
function SaveDataTable() {
    var FormDataSave = SetPostData();
    if (FormDataSave != null) {
        $.ajax({
            url: _apiSurvey.InsertUpdateSurveyTable,
            type: 'POST',
            async: false,
            cache: false,
            processData: false,
            contentType: false,
            scriptCharset: 'utf8',
            dataType: 'json',
            data: FormDataSave,
            success: function (response) {
                if (response != null && response.status == 'SUCCESS') {
                    if (surveyTableID == "") {
                        surveyTableID = response.data;
                        DataSurvey.BeanSurveyTable.ID = response.data;
                        window.history.replaceState(null, null, '?IDs=' + response.data);
                    }

                    $('#hTitleSurvey').html(DataSurvey.BeanSurveyTable.Title);
                    $('#spnMoTaSurvey').html(DataSurvey.BeanSurveyTable.Description);
                }
            },
            error: function (errorData) {

            }
        });
    }
   
}
function btnActive() {
    var isCheck = PrepareData(null);
    if (isCheck) {
        DataSurvey.IsActive = 1;
        var FormDataSave = SetPostData();
        if (FormDataSave != null) {
            $.ajax({
                url: _apiSurvey.Active,
                type: 'POST',
                async: false,
                cache: false,
                processData: false,
                contentType: false,
                scriptCharset: 'utf8',
                dataType: 'json',
                data: FormDataSave,
                success: function (response) {
                    if (response != null && response.status == 'SUCCESS') {
                        window.location.reload();
                        //$('#btnUnactive').show();
                        //$('#btnAcive').hide();
                    }
                },
                error: function (errorData) {

                }
            });
        }
    }
   
}
function btnUnActive() {
    if (confirm("Bạn có chắc muốn hủy mẫu khảo sát này không?")) {
        DataSurvey.IsActive = 0;
        var FormDataSave = SetPostData();
        if (FormDataSave != null) {
            $.ajax({
                url: _apiSurvey.UnActive,
                type: 'POST',
                async: false,
                cache: false,
                processData: false,
                contentType: false,
                scriptCharset: 'utf8',
                dataType: 'json',
                data: FormDataSave,
                success: function (response) {
                    if (response != null && response.status == 'SUCCESS') {
                        window.location.reload();

                    }
                },
                error: function (errorData) {

                }
            });
        }
    }
}
function ValidateAnswerClick(e, ID) {
    var checkVlue = $('#ckAcceptResultFomart_' + ID)[0].checked;
    if (checkVlue) {
        $('#div_Options_' + ID).show();
    }
    else
        $('#div_Options_' + ID).hide();
}
function validateGuid(id) {
    var pattern = new RegExp('^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$', 'i');
    if (pattern.test(id) === true) {
        return true;
    } else {
        return false;
    }
}
function openReview() {
    if (DataSurvey.BeanSurveyTable.ID != null) {
        showDialog(_linkReview.linkReviewSurvey + "?IDs=" + DataSurvey.BeanSurveyTable.ID, "Xem trước khảo sát");
    }
    else
        alert("Bạn chưa lưu thông tin chung!");
}
function btnSearch() {
    var formSearch = new FormData();
    dataSearch.FullName = $('#txtUserSurvey').val();
    dataSearch.Email = $('#txtEmail').val();
    dataSearch.FromDate = $('#txtSearchFromDate').data('kendoDatePicker').value();
    dataSearch.ToDate = $('#txtSearchToDate').data('kendoDatePicker').value();
    formSearch.append("data", JSON.stringify(dataSearch));
    if (!isNullOrEmpty(dataSearch.FromDate))
        formSearch.append("FromDate", kendo.toString(dataSearch.FromDate, "yyyy/MM/dd"));
    if (!isNullOrEmpty(dataSearch.ToDate))
        formSearch.append("ToDate", kendo.toString(dataSearch.ToDate, "yyyy/MM/dd"));

    $.ajax({
        url: _apiSurvey.SearchSurveyDetail + getParameterByName("IDs"),
        type: 'POST',
        async: false,
        cache: false,
        processData: false,
        contentType: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        data: formSearch,
        success: function (response) {
            if (response != null && response.status == 'SUCCESS') {
                var grid = $('#GridServeyStatistical').data('kendoGrid');
                grid.setDataSource(response.data);
            }
        },
        error: function (errorData) {

        }
    });

}
function btnExportExcel() {
    $.ajax({
        url: _apiSurvey.ExportExcel + getParameterByName("IDs"),
        type: 'POST',
        async: false,
        cache: false,
        processData: false,
        contentType: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        success: function (response) {
            if (response != null && response.status == 'SUCCESS') {
                alert('Xuất excel thành công!');
            }
        },
        error: function (errorData) {

        }
    });

}
function CheckDate(type) {
    var isErr = false;
    var messErr = "";
    var frmDate = $('#txtFromDate').data('kendoDatePicker').value();
    var toDate = $('#txtToDate').data('kendoDatePicker').value();
    var toDay = new Date();
    if (frmDate.toLocaleDateString() < toDay.toLocaleDateString()) {
        isErr = true;
        messErr = "Ngày bắt đầu và ngày kết thúc không thể nhỏ hơn ngày hiện tại!";
        $('#txtFromDate').data('kendoDatePicker').value('');
    }
    if (!isNullOrEmpty(toDate)) {
        if (toDate.toLocaleDateString() < toDay.toLocaleDateString()) {
            isErr = true;
            messErr = "Ngày bắt đầu và ngày kết thúc không thể nhỏ hơn ngày hiện tại!";
            $('#txtToDate').data('kendoDatePicker').value('');
        }
        if (type == "From" && frmDate.toLocaleDateString() > toDate.toLocaleDateString()) {
            isErr = true;
            messErr = "Ngày bắt đầu không thể lớn hơn ngày kết thúc!";
            $('#txtFromDate').data('kendoDatePicker').value('');
        }
        else if (type == "To" && frmDate.toLocaleDateString() > toDate.toLocaleDateString()) {
            isErr = true;
            messErr = "Ngày kết thúc không thể nhỏ hơn ngày bắt đầu!";
            $('#txtToDate').data('kendoDatePicker').value('');
        }
    }
    if (isErr) {
        $('#messerror').html(messErr);
        setTimeout(function () { $('#messerror').html(""); }, 4000);
    }
}