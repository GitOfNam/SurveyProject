var _apiConfig = {
    InsertUpdateConfig: "/API/UserHandler.ashx?tbl=Setting&func=InsertUpdateConfig",
    GetConfigByIDs: "/API/UserHandler.ashx?tbl=Setting&func=GetConfigByIDs"
}
var formData = new FormData();
$(document).ready(function () {
    GetValue();
});

function GetValue() {
    var IDs = getParameterByName("IDs");
    if (!isNullOrEmpty(IDs)) {
        var formDataMenu = new FormData();
        formDataMenu.append("IDs", IDs);
        $.ajax({
            url: _apiConfig.GetConfigByIDs,
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
    $('#txtValue').val(data.Value);
    $('#txtDescript').val(data.Descript);
}
function onSaveConfig() {
    var IDs = getParameterByName("IDs");
    var object = {};
    if (!isNullOrEmpty($('#txtTitle').val())) {
        if (!isNullOrEmpty(IDs)) {
            formData.append("IDs", IDs);
        }
        object.Title = $('#txtTitle').val();
        object.Value = $('#txtValue').val();
        object.Descript = $('#txtDescript').val();

        formData.append("data", JSON.stringify(object));
        $.ajax({
            url: _apiConfig.InsertUpdateConfig,
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
                    closeInsertUpdateConfigPopup(1, "");
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
