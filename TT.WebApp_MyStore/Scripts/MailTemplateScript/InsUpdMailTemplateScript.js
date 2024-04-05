var _apiMenuMailTemplate = {
    InsertUpdateMailTemplate: "/API/UserHandler.ashx?tbl=MailTemplate&func=InsertUpdateMailTemplate",
    GetMailTemplateByIDs: "/API/UserHandler.ashx?tbl=MailTemplate&func=GetMailTemplateByIDs"
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
            url: _apiMenuMailTemplate.GetMailTemplateByIDs,
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
    $('#txtModule').val(data.Module);
    $('#txtSubject').val(data.Subject);
    $('#txtBody').val(data.Body);
    $('#txtThamSoSubject').val(data.ThamSoSubject);
    $('#txtThamSoBody').val(data.ThamSoBody);
}
function onSaveMailTemplate() {
    var IDs = getParameterByName("IDs");
    var object = {};
    if (!isNullOrEmpty($('#txtTitle').val())) {
        if (!isNullOrEmpty(IDs)) {
            formData.append("IDs", IDs);
        }
        object.Title = $('#txtTitle').val();
        object.Module = $('#txtModule').val();
        object.Subject = $('#txtSubject').val();
        object.Body = $('#txtBody').val();
        object.ThamSoSubject = $('#txtThamSoSubject').val();
        object.ThamSoBody = $('#txtThamSoBody').val();

        formData.append("data", JSON.stringify(object));
        $.ajax({
            url: _apiMenuMailTemplate.InsertUpdateMailTemplate,
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
                    closeInsertUpdateMailTemplatePopup(1, "");
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
