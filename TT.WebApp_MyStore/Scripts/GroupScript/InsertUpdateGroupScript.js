var _apiMenuGroup = {
    GetListUser: "/API/UserHandler.ashx?tbl=User&func=GetListUser",
    InsertUpdateGroup: "/API/UserHandler.ashx?tbl=GroupConfig&func=InsertUpdateGroup",
    GetGroupByIDs: "/API/UserHandler.ashx?tbl=GroupConfig&func=GetGroupByIDs"
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
     
    $('#txtUserOnGroup').kendoMultiSelect({
        dataSource: [],
        dataTextField: "FullName",
        dataValueField: "ID"
    });
    $.ajax({
        url: _apiMenuGroup.GetListUser,
        data: null,
        type: "POST",
        scriptCharset: "utf8",
        dataType: "json",
        success: function (res) {
            if (res.status == "SUCCESS") {
                var MultiSelect = $('#txtUserOnGroup').data("kendoMultiSelect");
                MultiSelect.setDataSource(res.data);
                GetValue();
            }
        },
        error: function (e) {
        },
    });
});

function GetValue() {
    var IDs = getParameterByName("IDs");
    if (!isNullOrEmpty(IDs)) {
        var formDataMenu = new FormData();
        formDataMenu.append("IDs", IDs);
        $.ajax({
            url: _apiMenuGroup.GetGroupByIDs,
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
    $("#ddlStatus").data("kendoDropDownList").value(data.IsActive);
    $('#ckIsManager')[0].checked = data.IsManagerGroup;
    var itemKN = [];
    var mangUser = data.UserOnGroup.split(",");
    if (mangUser.length > 0) {
        for (var b = 0; b < mangUser.length; b++) {
            if (!isNullOrEmpty(mangUser[b])) {
                itemKN.push(mangUser[b]);
            }
        }
    }
    $("#txtUserOnGroup").data("kendoMultiSelect").value(itemKN);
}
function onSaveGroup() {
    var IDs = getParameterByName("IDs");
    var object = {};
    if (!isNullOrEmpty($('#txtTitle').val())) {
        if (!isNullOrEmpty(IDs)) {
            formData.append("IDs", IDs);
        }
        object.Title = $('#txtTitle').val();
        object.IsActive = $("#ddlStatus").data("kendoDropDownList").value() == "1" ? true : false;
        object.IsManagerGroup = $('#ckIsManager')[0].checked;
        object.UserOnGroup = "";
        var UserOnGroup = $("#txtUserOnGroup").data("kendoMultiSelect");
        for (var i = 0; i < UserOnGroup.dataItems().length; i++) {
            //mularr.push({ "ID": UserOnGroup.dataItems()[i].ID, "FullName": UserOnGroup.dataItems()[i].FullName });
            object.UserOnGroup += UserOnGroup.dataItems()[i].ID + ",";
        }

        formData.append("data", JSON.stringify(object));
        $.ajax({
            url: _apiMenuGroup.InsertUpdateGroup,
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
                    closeInsertUpdateGroupPopup(1, "");
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
