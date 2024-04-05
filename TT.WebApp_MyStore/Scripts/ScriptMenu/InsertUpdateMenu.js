var _apiMenuUsers = {
    GetListMenu: "/API/UserHandler.ashx?tbl=MenuUsers&func=GetListMenu",
    InsertUpdateMenu: "/API/UserHandler.ashx?tbl=MenuUsers&func=InsertUpdateMenu",
    GetMenuByIDs: "/API/UserHandler.ashx?tbl=MenuUsers&func=GetMenuByIDs"
}
var formData = new FormData();
$(document).ready(function () {
    $('#ddlStatus').kendoDropDownList({
        dataSource: [
            { ID: 1, Text: "Kích hoạt" },
            { ID: 0, Text: "Vô hiệu" }
        ],
        dataTextField: "Text",
        dataValueField: "ID"
    });
    
    $('#dllParentID').kendoDropDownList({
        dataSource: [],
        dataTextField: "Title",
        dataValueField: "ID"
    });
    $.ajax({
        url: _apiMenuUsers.GetListMenu,
        type: 'POST',
        async: false,
        cache: false,
        processData: false,
        contentType: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        success: function (response) {
            if (response != null && response.status == 'SUCCESS') {
                var dropdownlist = $("#dllParentID").data("kendoDropDownList");
                dropdownlist.setDataSource(response.data);
            }
        },
        error: function (errorData) {

        }
    });
    GetValue();
});

function GetValue() {
    var IDs = getParameterByName("IDs");
    if (!isNullOrEmpty(IDs)) {
        var formDataMenu = new FormData();
        formDataMenu.append("IDs", IDs);
        $.ajax({
            url: _apiMenuUsers.GetMenuByIDs,
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
                }
                else {
                }
            },
            error: function (errorData) {

            }
        });
    }
}
function setFieldValue(data) {
    $('#txtTitle').val(data.Title);
    $('#txtTitleEN').val(data.TitleEN);
    $("#dllParentID").data("kendoDropDownList").value(data.ParentId);
    $("#ddlStatus").data("kendoDropDownList").value(data.Status);
    $('#ckExpanded')[0].checked = data.Expanded;
    $('#txtUrl').val(data.Url);
    $('#txtIcon').val(data.Icon);
    $('#txtIndex').val(data.Index);
}
function onSaveMenu() {
    var IDs = getParameterByName("IDs");
    var object = {};
    if (!isNullOrEmpty($('#txtTitle').val()) && !isNullOrEmpty($('#txtTitleEN').val())) {
        if (!isNullOrEmpty(IDs)) {
            object.ID = IDs;
        }
        object.Title = $('#txtTitle').val();
        object.TitleEN = $('#txtTitleEN').val();
        object.ParentId = $("#dllParentID").data("kendoDropDownList").value();
        object.Url = $('#txtUrl').val();
        object.Icon = $('#txtIcon').val();
        object.Status = $("#ddlStatus").data("kendoDropDownList").value();
        object.Expanded = $('#ckExpanded')[0].checked;
        object.Index = $('#txtIndex').val();
        formData.append("data", JSON.stringify(object));
        $.ajax({
            url: _apiMenuUsers.InsertUpdateMenu,
            type: 'POST',
            async: false,
            cache: false,
            processData: false,
            contentType: false,
            scriptCharset: 'utf8',
            dataType: 'json',
            data: formData,
            success: function (response) {
                if (response != null && response.status == 'SUCCESS') {
                    closeInsertUpdateMenuPopup(1, "");
                }
            },
            error: function (errorData) {

            }
        });
    }
    else {
        $("#messerror").html("<span>Vui lòng nhập các thông tin bắt buộc!</span>");
        setTimeout(function () { $("#messerror").html(""); }, 4000);
    }
}
