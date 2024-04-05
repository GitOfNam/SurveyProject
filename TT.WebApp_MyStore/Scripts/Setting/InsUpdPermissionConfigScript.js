
var _apiConfig = {
    GetListPermissionCheckList: "/API/UserHandler.ashx?tbl=Setting&func=GetListPermissionCheckList",
    DeletePermission: "/API/UserHandler.ashx?tbl=Setting&func=DeletePermission",
    InsUpdPermission: "/API/UserHandler.ashx?tbl=Setting&func=InsUpdPermission"
}
var checkedNodes = [];
$(document).ready(function () {
    $("#treeViewPermission").kendoTreeView({
        dataSource: [],
        dataTextField: "Title",
        dataValueField: "ID",
        checkboxes: {
            checkChildren: true
        },
    });
   
    GetValue();
});
function GetValue() {
    var IDs = getParameterByName("IDs");
    if (!isNullOrEmpty(IDs)) {
        var formDataMenu = new FormData();
        formDataMenu.append("IDs", IDs);
        $.ajax({
            url: _apiConfig.GetListPermissionCheckList,
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
                    $('#txtPermissionName').val(response.data.PermissionList.PermissionName);
                    $('#txtPermissionNameEN').val(response.data.PermissionList.PermissionNameEN);
                    for (var i = 0; i < response.data.Menu.length; i++) {
                        response.data.Menu[i].checked = response.data.Menu[i].IsExist;
                        if (response.data.Menu[i].items != null) {
                            for (var j = 0; j < response.data.Menu[i].items.length; j++) {
                                response.data.Menu[i].items[j].checked = response.data.Menu[i].items[j].IsExist;
                            }
                        }
                    }
                    var tree = $("#treeViewPermission").data("kendoTreeView");
                    var dataSource = new kendo.data.HierarchicalDataSource({ data: response.data.Menu });
                    tree.setDataSource(dataSource);
                    tree.dataSource.read();
                }
                else {
                }
            },
            error: function (errorData) {

            }
        });
    }
    else {
        $.ajax({
            type: "GET",
            url: _apiConfig.GetListPermissionCheckList,
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (result) {
                var tree = $("#treeViewPermission").data("kendoTreeView");
                var dataSource = new kendo.data.HierarchicalDataSource({ data: result.data });
                tree.setDataSource(dataSource);
                tree.dataSource.read();
            },
            error: function (httpRequest, textStatus, errorThrown) {
                alert("Error: " + textStatus + " " + errorThrown + " " + httpRequest);
            }
        });
    }
}
function checkedNodeIds(nodes, checkedNodes) {
    for (var i = 0; i < nodes.length; i++) {
        if (nodes[i].checked) {
            checkedNodes.push(nodes[i].ID);
        }
        else {
            if (nodes[i].hasChildren) {
                var arr1 = jQuery.grep(nodes[i].children.view(), function (n, i) {
                    return (n.checked);
                });
                if (arr1.length > 0)
                    checkedNodes.push(nodes[i].ID);
            }
        }

        if (nodes[i].hasChildren) {
            checkedNodeIds(nodes[i].children.view(), checkedNodes);
        }
    }
}

// show checked node IDs on datasource change
function onCheck() {
    var treeView = $("#treeViewPermission").data("kendoTreeView");
    checkedNodeIds(treeView.dataSource.view(), checkedNodes);
}
function onSavePermission() {
    var formData = new FormData();
    var IDs = getParameterByName("IDs");
    var object = {};
    if (!isNullOrEmpty(IDs)) {
        formData.append("IDs", IDs);
    }
    checkedNodes = [];
    onCheck();
    formData.append("checklist", checkedNodes);
    object.PermissionName = $('#txtPermissionName').val();
    object.PermissionNameEN = $('#txtPermissionNameEN').val();

    formData.append("data", JSON.stringify(object));
    $.ajax({
        url: _apiConfig.InsUpdPermission,
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
                closeInsertUpdatePermissionPopup(1, "");
            }
        },
        error: function (errorData) {

        }
    });
}