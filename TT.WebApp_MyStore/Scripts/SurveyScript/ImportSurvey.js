var _apiExcel = {
    DissectionExcel: "/API/UserHandler.ashx?tbl=Survey&func=DissectionExcel",
}
var _apiDownload = {
    DownloadTemplate: "/API/UserHandler.ashx?tbl=download&func=DownloadFile",
}
var checkedNodes = [];
var formData = new FormData();
$(document).ready(function () {
    $('#fuTemplate').kendoUpload({
        validation: {
            allowedExtensions: [".xlsx"]
        },
        select: onSelect,
        multiple: false,
    });

    GetValue();
});

// show checked node IDs on datasource change
function onSelect(e) {
    formData = new FormData();
    formData.append('file', e.files[0].rawFile);
}
function onImportExcel() {
    $.ajax({
        url: _apiExcel.DissectionExcel,
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
                closeImportPopup(1, response.data);
            }
            else {
                var entries = formData.entries();
                for (var pair of entries) {
                    formData.delete(pair[0]);
                }
                $("#messerror").html("<span>" + response.mess.Value + "</span>");
                setTimeout(function () { $("#messerror").html(""); }, 4000);
            }
        },
        error: function (errorData) {

        }
    });
}
function onExportExcel() {
    $.ajax({
        url: _apiDownload.DownloadTemplate,
        type: 'POST',
        async: false,
        cache: false,
        processData: false,
        contentType: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        success: function (response) {
            if (response != null && response.status == 'SUCCESS') {
               
            }
           
        },
        error: function (errorData) {

        }
    });
}