$(document).ready(function () {
    if (!isNullOrEmpty(PageCurrentInfo)) {
        if (PageCurrentInfo.LanguageId == 1066)
            $("#languageIcon img").attr('src', '../../Assets/images/IconEnglish.png');
        else
            $("#languageIcon img").attr('src', '../../Assets/images/IconVN.jpg');
    }
});

function LoadJqueryTemplate(templatePath, elementOrElementId, callback) {
    templatePath = "/Scripts/HtmlTemplate/" + templatePath + ".html?v=" + Math.random();
    $.get(templatePath,
        function (templateData, textStatus, xmlHttpRequest) {
            if (textStatus === "success" && templateData !== "") {
                var elementTo = null;
                if (elementOrElementId !== undefined && elementOrElementId !== null) {
                    if (typeof elementOrElementId === "string") elementTo = $(elementOrElementId);
                    else elementTo = $(elementOrElementId);
                } else elementTo = $(document.body);
                if (elementTo.length > 0) elementTo.append(templateData);
                if (callback != null && callback != undefined) {
                    callback();
                }
            }
        });
}

function getParameterByName(name) {
    try {
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    } catch (e) {
        return null;
    }
}

function isNullOrEmpty(str) {
    var returnValue = false;
    if (!str
        || str == null
        || str === 'null'
        || str === ''
        || str === '{}'
        || str === 'undefined'
        || str.length === 0) {
        returnValue = true;
    }
    return returnValue;
}

function isLoading(isActive) {
    if (isActive)
        $("#isLoading").show();
    else
        $("#isLoading").hide();
}
function showDialog(url, title, width, heght, funtion) {
    if (isNullOrEmpty(width))
        width = 80;

    if (isNullOrEmpty(heght))
        heght = 80;

    var uploadwindow = $("#windowbysize");
    var widthOfForm = $(window).width() / 100 * width;
    var heightOfForm = $(window).height() / 100 * heght;
    if ($("#HiddenCloseDialogValue").length === 0) {
        $("body").append("<input type='hidden' id='HiddenCloseDialogValue'/>");
    }
    $("#HiddenCloseDialogValue").val("");
    if (uploadwindow.length === 0) {
        $("body").append("<div id='windowbysize'></div>");
        uploadwindow = $("#windowbysize");
    }

    $("body").addClass("fixContent");
    if (parent.$("#windowbysize").data("kendoWindow") !== undefined) {
        widthOfForm = parent.$("#windowbysize").width() - 30;
        heightOfForm = parent.$("#windowbysize").height() - 50;
        parent.$("#windowbysize").addClass("header-vt").prev().addClass("show-modal");
    }
    if (!uploadwindow.data("kendoWindow")) {
        uploadwindow.kendoWindow({
            actions: ["Close"],
            iframe: true,
            visible: false,
            content: "",
            resizable: false,
            draggable: true,
            close: function () {
                if (funtion) {
                    if (typeof (funtion) === 'string') {
                        eval(funtion);
                    } else {
                        funtion();
                    }
                }
                $("body").removeClass("fixContent");
                parent.$("#windowbysize").removeClass("header-vt").prev().removeClass("show-modal");
                uploadwindow.prev().removeClass("show-modal");
                uploadwindow.find("#windowbysize").remove();
                this.destroy();
            },
            resizable: false,
            open: function () {
                uploadwindow.width(widthOfForm);
                uploadwindow.height(heightOfForm);
                uploadwindow.data("kendoWindow").center();
                if (parent.$("#windowbysize").data("kendoWindow") !== undefined) {
                }
            },
            modal: true,
            animation: {
                close: {
                    effects: "fade:out"
                }
            }
        });
    }
    if (url.indexOf("?") > 0)
        url = url + "&IsDlg=1";
    else
        url = url + "?IsDlg=1";

    var kendoWindowElement = uploadwindow.data("kendoWindow");
    if (kendoWindowElement !== null && kendoWindowElement !== undefined) {
        if (kendoWindowElement.title !== null && kendoWindowElement.title !== undefined)
            kendoWindowElement.title(title);

        if (kendoWindowElement.refresh !== null && kendoWindowElement.refresh !== undefined)
            kendoWindowElement.refresh(url);

        if (kendoWindowElement.open !== null && kendoWindowElement.open !== undefined)
            kendoWindowElement.open().center();
    }
}
function closeDialog(value, object) {
    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}
function closeInsertUpdatePopup(value, object) {
   
    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        if (value == 1) {
            var grid = parent.$('#GridUserList').data("kendoGrid");
            grid.dataSource.read();
        }
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}
function closeInsertUpdateMenuPopup(value, object) {

    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        if (value == 1) {
            var grid = parent.$('#GridMenuList').data("kendoGrid");
            grid.dataSource.read();
        }
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}
function closeInsertUpdateGroupPopup(value, object) {

    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        if (value == 1) {
            var grid = parent.$('#GridGroupList').data("kendoGrid");
            grid.dataSource.read();
        }
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}
function closeInsertUpdateMailTemplatePopup(value, object) {

    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        if (value == 1) {
            var grid = parent.$('#GridMailTemplateList').data("kendoGrid");
            grid.dataSource.read();
        }
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}
function closeInsertUpdateConfigPopup(value, object) {

    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        if (value == 1) {
            var grid = parent.$('#GridSettingConfig').data("kendoGrid");
            grid.dataSource.read();
        }
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}
function closeInsertUpdatePermissionPopup(value, object) {
    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        if (value == 1) {
            var grid = parent.$('#GridPermissionList').data("kendoGrid");
            grid.dataSource.read();
        }
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}
function closeChangePassPopup(value, object) {
    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}

function closeImportPopup(value, object) {
    var isDlg = getParameterByName("IsDlg");
    if (!isNullOrEmpty(isDlg) && isDlg === "1") {
        if (object !== null) parent.returnObjectPopup = object;
        if (value == 1) {
            parent.window.location.assign("/Pages/Survey/AddNewSurvey.aspx?IDs=" + object);
        }
        parent.$("#HiddenCloseDialogValue").val(value);
        if (parent.$("#windowbysize").data("kendoWindow") !== undefined)
            parent.$("#windowbysize").data("kendoWindow").close();
    }
}