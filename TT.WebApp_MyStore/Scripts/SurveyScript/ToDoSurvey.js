var DataToDo = {
    BeanSurveyTable: {},
    BeanSurveyQuestion: [],
    BeanSurveyPage: [],
    BeanSurveyResponsesValue: [],
    BeanSurveyResponses: {}
};
var currPage = 1;
var _apiSurvey = {
    GetListUserAndGroup: "/API/UserHandler.ashx?tbl=Survey&func=GetListUserAndGroup",
    GetSurveyCategory: "/API/UserHandler.ashx?tbl=Survey&func=GetSurveyCategory",
    InsertUpdateSurveyTable: "/API/UserHandler.ashx?tbl=Survey&func=InsertUpdateSurveyTable",
    Active: "/API/UserHandler.ashx?tbl=Survey&func=Active",
    UnActive: "/API/UserHandler.ashx?tbl=Survey&func=UnActive",
    GetDataSurvey: "/API/UserHandler.ashx?tbl=Survey&func=GetDataSurvey",
    GetDataSurveyIsActive: "/API/UserHandler.ashx?tbl=Survey&func=GetDataSurveyIsActive",
    GetDataServeyStatistical: "/API/UserHandler.ashx?tbl=Survey&func=GetDataServeyStatistical",
    SaveResTempo: "/API/UserHandler.ashx?tbl=Survey&func=SaveResTempo",
    SaveRes: "/API/UserHandler.ashx?tbl=Survey&func=SaveRes",
    SendMail: "/API/UserHandler.ashx?tbl=Survey&func=SendMail",
}
$(document).ready(function () {
    //loadTemplate
    LoadJqueryTemplate('ToDoSurveyTemplate', "#JQRTempToDO", function () {
        GetValueToDo();
    });
   
    
    //set button
});
function GetValueToDo() {
    var review = getParameterByName("review");
    if (review == 1) {
       
        SetFieldDesignToDo();
       
    }
    else {
        var IDs = getParameterByName("IDs");
        if (!isNullOrEmpty(IDs)) {
            var formDataMenu = new FormData();
            formDataMenu.append("IDs", IDs);
            $.ajax({
                url: _apiSurvey.GetDataSurveyIsActive,
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
                        DataToDo = response.data;
                        var isAllowMulti = false;
                        isAllowMulti = DataToDo.BeanSurveyTable.AllowMultipleResponses;
                        var isCompletedSurvey = false;
                        if (DataToDo.BeanSurveyResponsesValue != null && DataToDo.BeanSurveyResponsesValue.length > 0) {
                            isCompletedSurvey = DataToDo.BeanSurveyResponsesValue[0].Status;
                        }
                        
                        
                        if (!isAllowMulti) {
                            $('#btnAgainSurvey').hide();
                        }
                        if (!isCompletedSurvey) {
                            if (DataToDo.BeanSurveyTable) {
                                $('#hTitleSurvey').html(DataToDo.BeanSurveyTable.Title);
                                $('#spnMoTaSurvey').html(DataToDo.BeanSurveyTable.Description);
                            }
                            $('#btnPreviosPage').hide();
                            if (DataToDo.BeanSurveyPage.length <= 1) {
                                $('#btnNextPage').hide();
                                $('.ButtonsSurvey').hide();
                            }
                            SetFieldDesignToDo();
                        }
                        else {
                            $('#CompletedSurvey').show();
                            $('#FormToDoSurvey').hide();
                            $('.Buttons').hide();
                        }
                    }
                    else if (response != null && response.status == "MESSAGE" && response.data == "AccessDenied") {
                        $('#FormToDoSurvey').hide();
                        $('#AccessDeniedToDo').show();
                        $('.Buttons').hide();
                    }
                },
                error: function (errorData) {

                }
            });
        }
    }
   
}
function SetFieldDesignToDo() {
    var review = getParameterByName("review");
    if (review == 1) {
        var dataQuestion = parent.lstID;
        var dataPage = parent.DataSurvey.BeanSurveyPage;
        var dataTable = parent.DataSurvey.BeanSurveyTable;
        $('#btnPreviosPage').hide();
        if (dataPage.length <= 1) {
            $('#btnNextPage').hide();
            $('.ButtonsSurvey').hide();
        }
        $('.Buttons').hide();
        if (dataTable) {
            $('#hTitleSurvey').html(dataTable.Title);
            $('#spnMoTaSurvey').html(dataTable.Description);
        }
        if (dataQuestion != null) {
            if (dataPage.length > 1) {
                for (var i = 1; i < dataPage.length; i++) {
                    var divPlaceNewPage = $('div.PlaceNewPage');
                    divPlaceNewPage.removeClass('PlaceNewPage');
                    var data1 = [];
                    data1.push(dataPage[i]);
                    $("#PageTemplateReview").tmpl({ data: data1 }).appendTo(divPlaceNewPage);

                }
            }
            if (dataQuestion.length > 1) {
                for (var i = 0; i < dataQuestion.length; i++) {
                    var itemQuestion = dataQuestion[i];
                    //itemQuestion.Options = JSON.parse(itemQuestion.Options);
                    var data = [];
                    data.push(itemQuestion);
                    data[0].Options = JSON.parse(data[0].Options);
                    if (data[0].SQTId == 2) {
                        data[0].Value = JSON.parse(data[0].Value);
                        $("#Question_MultipleTextboxes_Template_ToDo").tmpl({ data: data }).appendTo("#Content_Page_" + itemQuestion.Page);
                        data[0].Value = JSON.stringify(data[0].Value);
                    }
                    else
                        $("#SingleTextboxTemplate_ToDo").tmpl({ data: data }).appendTo("#Content_Page_" + itemQuestion.Page);
                    
                    var ShowForm = $('#' + itemQuestion.ID).find("div.ShowItem");
                    ShowForm.show();
                    $("#Question_SingleTextbox_Template_ToDo").tmpl({ data: data }).appendTo(ShowForm);

                    itemQuestion.Options = JSON.stringify(itemQuestion.Options);
                }

            }
        }
    }
    else {
        if (DataToDo.BeanSurveyQuestion.length > 0) {
            if (DataToDo.BeanSurveyPage.length > 1) {
                for (var i = 1; i < DataToDo.BeanSurveyPage.length; i++) {
                    var divPlaceNewPage = $('div.PlaceNewPage');
                    divPlaceNewPage.removeClass('PlaceNewPage');
                    var data1 = [];
                    data1.push(DataToDo.BeanSurveyPage[i]);
                    $("#PageTemplateToDo").tmpl({ data: data1 }).appendTo(divPlaceNewPage);

                }
            }
            if (DataToDo.BeanSurveyQuestion.length > 1) {
                for (var i = 0; i < DataToDo.BeanSurveyQuestion.length; i++) {
                    var itemQuestion = DataToDo.BeanSurveyQuestion[i];
                    var Options = JSON.parse(itemQuestion.Options);
                    var data = [];
                    data.push(itemQuestion);
                    if (Options.ValidateAnswer != null) {
                        Options.ValidateAnswer = JSON.stringify(Options.ValidateAnswer);
                    }
                    data[0].Options = Options;
                    if (data[0].SQTId == 2) {
                        data[0].Value = JSON.parse(data[0].Value);
                        $("#Question_MultipleTextboxes_Template_ToDo").tmpl({ data: data }).appendTo("#Content_Page_" + itemQuestion.Page);
                        data[0].Value = JSON.stringify(data[0].Value);
                    }
                    else
                        $("#SingleTextboxTemplate_ToDo").tmpl({ data: data }).appendTo("#Content_Page_" + itemQuestion.Page);
                    
                    var ShowForm = $('#' + itemQuestion.ID).find("div.ShowItem");
                    ShowForm.show();
                    $("#Question_SingleTextbox_Template_ToDo").tmpl({ data: data }).appendTo(ShowForm);
                    if (Options.ValidateAnswer != null) {
                        Options.ValidateAnswer = JSON.parse(Options.ValidateAnswer);
                    }
                    if (DataToDo.BeanSurveyResponsesValue.length > 0) {
                        var dataResValue = jQuery.grep(DataToDo.BeanSurveyResponsesValue, function (n, i) {
                            return (n.SurveyQuestionId == itemQuestion.ID);
                        });
                        if (dataResValue != null) {
                            if (!isNullOrEmpty(dataResValue[0].Value)) {
                                if (itemQuestion.SQTId == 2) {
                                    var ValueResValue = JSON.parse(dataResValue[0].Value);
                                    if (ValueResValue.MultipleTextboxes.length > 0) {
                                        for (var item = 0; item < ValueResValue.MultipleTextboxes.length; item++) {
                                            $('#txtValue_' + ValueResValue.MultipleTextboxes[item].ID).val(ValueResValue.MultipleTextboxes[item].Value);
                                        }
                                    }
                                }
                                else
                                    $('#txtValue_' + itemQuestion.ID).val(dataResValue[0].Value);
                            }
                                
                        }
                    }
                    itemQuestion.Options = JSON.stringify(itemQuestion.Options);
                }

            }
        }
    }
}
function onBtnNextPage() {
    $('.Page_' + currPage).hide();
    currPage++;
    $('.Page_' + currPage).show();
    if (currPage == DataToDo.BeanSurveyPage.length) {
        $('#btnPreviosPage').show();
        $('#btnNextPage').hide();
    }
    else if (1 < currPage < DataToDo.BeanSurveyPage.length) {
        $('#btnPreviosPage').show();
        $('#btnNextPage').show();
    }
}
function onBtnPreviosPage() {
    $('.Page_' + currPage).hide();
    currPage--;
    $('.Page_' + currPage).show();
    if (currPage == 1) {
        $('#btnNextPage').show();
        $('#btnPreviosPage').hide();
    }
    else if (1 < currPage < DataToDo.BeanSurveyPage.length) {
        $('#btnPreviosPage').show();
        $('#btnNextPage').show();
    }
}
function validateFormat(ID, Validate) {

    var OjValidate = JSON.parse(Validate);
    var Value = $('#txtValue_' + ID).val();
    if (!OjValidate.value == "text_length") {
        if (isNaN(Value)) {
            $('#warningAlert_' + ID).html("<span>" + OjValidate.warning + "</span>");
            setTimeout(function () { $('#warningAlert_' + ID).html(""); }, 4000);
        } else {
            $('#txtValue_' + ID).val('');
        }
    }
    if (OjValidate.max < Value.length || Value.length < OjValidate.min) {
        $('#warningAlert_' + ID).html("<span>" + OjValidate.warning + "</span>");
        setTimeout(function () { $('#warningAlert_' + ID).html(""); }, 4000);
    }
}
function AgainSurvey() {
    $('#CompletedSurvey').hide();
    $('#FormToDoSurvey').show();
    $('.Buttons').show();
    DataToDo.BeanSurveyResponsesValue = [];
    DataToDo.BeanSurveyResponses = {};
    if (DataToDo.BeanSurveyTable) {
        $('#hTitleSurvey').html(DataToDo.BeanSurveyTable.Title);
        $('#spnMoTaSurvey').html(DataToDo.BeanSurveyTable.Description);
    }
    $('#btnPreviosPage').hide();
    if (DataToDo.BeanSurveyPage.length == 1) {
        $('#Content_Page_1')[0].innerHTML = ''
        $('#btnNextPage').hide();
        $('.ButtonsSurvey').hide();
    }
    if (DataToDo.BeanSurveyPage.length > 1) {
        for (var i = 1; i < DataToDo.BeanSurveyPage.length; i++) {
            if (!isNullOrEmpty($('#Content_Page_' + DataToDo.BeanSurveyPage[i].Index)))
                $('#Content_Page_' + DataToDo.BeanSurveyPage[i].Index)[0].innerHTML = '';
        }
    }
    SetFieldDesignToDo();
}
function onbtnSaveTempo() {
    var FormDataSave = SetPostDataRes('SaveTempo');
    if (FormDataSave != null) {
        $.ajax({
            url: _apiSurvey.SaveResTempo,
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
function SetPostDataRes(strActive) {
    
    var formData = new FormData();
    var checkLength = DataToDo.BeanSurveyResponsesValue.length > 0;
    if (DataToDo.BeanSurveyQuestion.length > 1) {
        for (var i = 0; i < DataToDo.BeanSurveyQuestion.length; i++) {
            var itemQuestion = DataToDo.BeanSurveyQuestion[i];
            
            if (itemQuestion.SQTId == 2) {
                var dataTempValue = {
                    MultipleTextboxes: []
                };
                if (checkLength) {
                    $.each(DataToDo.BeanSurveyResponsesValue, function (n, i) {
                        if (i.SurveyQuestionId == itemQuestion.ID) {
                            var itemQuestionValue = JSON.parse(itemQuestion.Value);
                            if (itemQuestionValue.MultipleTextboxes.length > 0) {
                                for (var item = 0; item < itemQuestionValue.MultipleTextboxes.length; item++) {
                                    var dataDefault = {};
                                    dataDefault.ID = itemQuestionValue.MultipleTextboxes[item].ID;
                                    dataDefault.Value = $('#txtValue_' + itemQuestionValue.MultipleTextboxes[item].ID).val();
                                    dataTempValue.MultipleTextboxes.push(dataDefault);
                                }
                            }
                            i.Value = JSON.stringify(dataTempValue);
                            i.Status = strActive != 'SaveTempo';
                        }
                    });
                }
                else {
                    var itemQuestionValue = JSON.parse(itemQuestion.Value);
                    if (itemQuestionValue.MultipleTextboxes.length > 0) {
                        for (var item = 0; item < itemQuestionValue.MultipleTextboxes.length; item++) {
                            var dataDefault = {};
                            dataDefault.ID = itemQuestionValue.MultipleTextboxes[item].ID;
                            dataDefault.Value = $('#txtValue_' + itemQuestionValue.MultipleTextboxes[item].ID).val();
                            dataTempValue.MultipleTextboxes.push(dataDefault);
                        }

                    }
                    var dataSurveyResValue = {};
                    dataSurveyResValue.SurveyQuestionId = itemQuestion.ID;
                    dataSurveyResValue.Value = JSON.stringify(dataTempValue);
                    dataSurveyResValue.Skipped = false;
                    dataSurveyResValue.OtherValue = "";
                    dataSurveyResValue.Status = strActive != 'SaveTempo';
                    DataToDo.BeanSurveyResponsesValue.push(dataSurveyResValue);
                }
            }
            else {
                if (checkLength) {
                    $.each(DataToDo.BeanSurveyResponsesValue, function (n, i) {
                        if (i.SurveyQuestionId == itemQuestion.ID) {
                            i.Value = $('#txtValue_' + itemQuestion.ID).val();
                            i.Status = strActive != 'SaveTempo';
                        }
                    });
                }
                else {
                    var dataSurveyResValue = {};
                    dataSurveyResValue.SurveyQuestionId = itemQuestion.ID;
                    dataSurveyResValue.Value = $('#txtValue_' + itemQuestion.ID).val();
                    dataSurveyResValue.Skipped = false;
                    dataSurveyResValue.OtherValue = "";
                    dataSurveyResValue.Status = strActive != 'SaveTempo';
                    DataToDo.BeanSurveyResponsesValue.push(dataSurveyResValue);
                }
            }
        }
    }
    formData.append("data", JSON.stringify(DataToDo));
    return formData;
}
function CheckRequired() {
    var result = true;
    if (DataToDo.BeanSurveyQuestion.length > 1) {
        var dataResValue = jQuery.grep(DataToDo.BeanSurveyQuestion, function (n, i) {
            return (n.Required == true);
        });
        if (dataResValue.length > 0) {
            for (var i = 0; i < dataResValue.length; i++) {
                var itemQuestion = dataResValue[i];
                if (isNullOrEmpty($('#txtValue_' + itemQuestion.ID).val())) {
                    if (itemQuestion.Page != currPage) {
                        setPage(itemQuestion.Page);
                    }
                    $('#txtValue_' + itemQuestion.ID).focus();
                    $("#messerror").html("<span>Vui lòng nhập các thông tin bắt buộc!</span>");
                    setTimeout(function () { $("#messerror").html(""); }, 4000);
                    result = false;
                    break;
                }
            }
        }
    }
    return result;
}
function setPage(id) {
    $('.Page_' + currPage).hide();
    currPage = id;
    $('.Page_' + id).show();
    if (currPage == 1) {
        $('#btnNextPage').show();
        $('#btnPreviosPage').hide();
    }
    else if (currPage == DataToDo.BeanSurveyPage.length) {
        $('#btnPreviosPage').show();
        $('#btnNextPage').hide();
    }
    else if (1 < currPage < DataToDo.BeanSurveyPage.length) {
        $('#btnPreviosPage').show();
        $('#btnNextPage').show();
    }
}
function onbtnCompleted() {
    var isCheckRequired = CheckRequired();
    if (isCheckRequired) {
        var FormDataSave = SetPostDataRes('Completed');
        if (FormDataSave != null) {
            $.ajax({
                url: _apiSurvey.SaveRes,
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
                        $('#CompletedSurvey').show();
                        $('#FormToDoSurvey').hide();
                        $('.Buttons').hide();
                    }
                },
                error: function (errorData) {

                }
            });
        }
    }
}
