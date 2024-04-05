var _apiUser = {
    InsertUpdateUser: "/API/UserHandler.ashx?tbl=User&func=InsertUpdateUser",
    GetListPermission: "/API/UserHandler.ashx?tbl=Setting&func=GetListPermission",
    GetData: "/API/UserHandler.ashx?tbl=User&func=GetUserByIDs",
    GetPosition: "/API/UserHandler.ashx?tbl=User&func=GetPosition"
}
var formData = new FormData();
$(document).ready(function () {
    $('#dllPosition').kendoDropDownList({
        dataSource: [],
        dataTextField: "PositionName",
        dataValueField: "PositionCode"
    }
    );
    $('#dllPermission').kendoDropDownList({
        dataSource: [],
        dataTextField: "PermissionName",
        dataValueField: "PermissionNameEN"
    }   
    );
    $('#txtBirthDay').kendoDatePicker({
        format: "dd/MM/yyyy"
    });
    $('#fuTemplate').kendoUpload({
        validation: {
            allowedExtensions: [".jpg", ".jpeg", ".png", ".bmp", ".gif"]
        },
        select: onSelect,
        multiple: false,
    });
    $.ajax({
        url: _apiUser.GetListPermission,
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
                var Permission = $('#dllPermission').data("kendoDropDownList");
                Permission.setDataSource(response.data);
                var Per = getParameterByName("Per");
                if (!isNullOrEmpty(Per)) {
                    if (Per != "Admin") {
                        Permission.enable(false);
                    }
                }
            }
        },
        error: function (errorData) {

        }
    });
    $.ajax({
        url: _apiUser.GetPosition,
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
                var Position = $('#dllPosition').data("kendoDropDownList");
                Position.setDataSource(response.data);
                var Per = getParameterByName("Per");
                if (!isNullOrEmpty(Per)) {
                    if (Per != "Admin") {
                        Position.enable(false);
                        $('#ckStatus')[0].disabled = true
                    }
                }
                GetValue();
            }
        },
        error: function (errorData) {

        }
    });
});

function GetValue() {
    var IDs = getParameterByName("IDs");
    if (!isNullOrEmpty(IDs)) {
        var formDataUser = new FormData();
        formDataUser.append("IDs", IDs);
        $.ajax({
            url: _apiUser.GetData,
            type: 'POST',
            async: false,
            cache: false,
            processData: false,
            contentType: false,
            scriptCharset: 'utf8',
            dataType: 'json',
            data: formDataUser,
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
    $('#txtAccountName').val(data.AccountName);
    $('#txtFullName').val(data.FullName);
    $('#ckGender')[0].checked = data.Gender;
    $('#txtBirthDay').val(kendo.toString(kendo.parseDate(data.BirthDay), 'dd/MM/yyyy'));
    $('#txtEmail').val(data.Email);
    $('#txtMobile').val(data.Mobile);
    $('#txtAddress').val(data.Address);
    $('#ckStatus')[0].checked = data.UserStatus;
    $('#dllPosition').data("kendoDropDownList").value(data.Position);
    $('#dllPermission').data("kendoDropDownList").value(data.Permission);
    if (!isNullOrEmpty(data.Image)) {
        $(".product").remove();
        $("<div class='product'><img  src=" + data.Image + " /></div>").appendTo($("#products"));
    }
    else {
        $(".product").remove();
        $("<div class='product'>Không có ảnh đại diện</div>").appendTo($("#products"));
    }
}
function onSelect(e) {
    formData = new FormData();
    formData.append('file', e.files[0].rawFile);
    if (e.files) {
        for (var i = 0; i < e.files.length; i++) {
            var file = e.files[i].rawFile;

            //if (e.files.length == 1 || i == e.files.length - 1) {
            //    imgInfo += "{'value':'extension : " + e.files[i].extension + "- name : " + e.files[i].name + " - size : " + e.files[i].size + "','items': [],'control': 'kendoUpload'}";
            //}
            //else {
            //    imgInfo += "{'value':'extension : " + e.files[i].extension + "- name : " + e.files[i].name + " - size : " + e.files[i].size + "','items': [],'control': 'kendoUpload'},";
            //}
            //imgInfoarr.push({ Name: e.files[i].name, Size: e.files[i].size, Extension: e.files[i].extension });
            if (file) {
                var reader = new FileReader();
                reader.onloadend = function () {
                    $(".product").remove();
                    $("<div class='product'><img src=" + this.result + " /></div>").appendTo($("#products"));
                };

                reader.readAsDataURL(file);
            }
        }
    }
}
function onSaveUser() {
    var IDs = getParameterByName("IDs");
    var object = {};
    if (!isNullOrEmpty($('#txtAccountName').val()) && !isNullOrEmpty($('#txtFullName').val()) && !isNullOrEmpty($('#txtEmail').val())) {
        if (!isNullOrEmpty(IDs)) {
            formData.append("IDs", IDs);
            object.AccountName = $('#txtAccountName').val();
            object.FullName = $('#txtFullName').val();
            object.Gender = $('#ckGender')[0].checked;
            object.BirthDay = $('#txtBirthDay').data("kendoDatePicker").value();
            object.Email = $('#txtEmail').val();
            object.Mobile = $('#txtMobile').val();
            object.Address = $('#txtAddress').val();
            object.UserStatus = $('#ckStatus')[0].checked == true ? 1 : 0;
            object.Position = $('#dllPosition').data("kendoDropDownList").value();
            object.Permission = $('#dllPermission').data("kendoDropDownList").value();
        }
        else {
            object.AccountName = $('#txtAccountName').val();
            object.FullName = $('#txtFullName').val();
            object.Gender = $('#ckGender')[0].checked;
            object.BirthDay = $('#txtBirthDay').data("kendoDatePicker").value();
            object.Email = $('#txtEmail').val();
            object.Mobile = $('#txtMobile').val();
            object.Address = $('#txtAddress').val();
            object.UserStatus = $('#ckStatus')[0].checked == true ? 1 : 0;
            object.Position = $('#dllPosition').data("kendoDropDownList").value();
            object.Permission = $('#dllPermission').data("kendoDropDownList").value();
        }
        formData.append("data", JSON.stringify(object));
        $.ajax({
            url: _apiUser.InsertUpdateUser,
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
                    var Per = getParameterByName("Per");
                    if (!isNullOrEmpty(Per)) {
                        window.location.assign("/Pages/Home.aspx");
                    }
                    else {
                        closeInsertUpdatePopup(1, "");
                    }
                }
                else {
                    var entries = formData.entries();
                    for (var pair of entries) {
                        formData.delete(pair[0]);
                    }
                    $("#messerror").html("<span>" + response.mess.Value +"</span>");
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
