var _apiChangePass = {
    ChangePass: "/API/UserHandler.ashx?tbl=User&func=ChangePassWord",
}
var DataChange = {
    OldPass: '',
    NewPass: '',
    NewPassAgain: ''
};
var formData = new FormData();
$(document).ready(function () {
    
});

function onSavePass() {
    if (!isNullOrEmpty($('#txtOldPassWord').val()) && !isNullOrEmpty($('#txtNewPassWord').val()) && !isNullOrEmpty($('#txtNewPassAgain').val())) {
        DataChange.OldPass = $('#txtOldPassWord').val();
        DataChange.NewPass = $('#txtNewPassWord').val();
        DataChange.NewPassAgain = $('#txtNewPassAgain').val();
        
        formData.append("data", JSON.stringify(DataChange));
        $.ajax({
            url: _apiChangePass.ChangePass,
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
                    closeChangePassPopup(1, "");
                }
                else {
                    $("#messerror").html("<span>" + response.data + "</span>");
                    setTimeout(function () { $("#messerror").html(""); }, 4000);
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
function validateField(field) {
    var strValue = $('#txt' + field).val();
    if (strValue.length > 50 || strValue.length < 3) {
        $('#txt' + field).val("");
        $("#messerror" + field).html("<span>Mật khẩu không đc vượt quá 50 ký tự hoặc ngắn hơn 3 ký tự!</span>");
        setTimeout(function () { $("#messerror" + field).html(""); }, 4000);
    }
}
