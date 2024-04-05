var _apiConfig = {
    GetListPermission: "/API/UserHandler.ashx?tbl=Setting&func=GetListPermission",
    DeletePermission: "/API/UserHandler.ashx?tbl=Setting&func=DeletePermission"
}
var _linkInsert = {
    InsUpdPermissionConfig: "/Pages/Setting/InsUpdPermissionConfig.aspx"
}
$(document).ready(function () {
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                // The remote endpoint from which the data is retrieved.
                url: _apiConfig.GetListPermission,
                dataType: "json"
            }
        },
        pageSize: 20,
        schema: {
            model: {
                id: 'ID',
            },
            parse: function (response) {
                return response.data; // twitter's response is { "statuses": [ /* results */ ] }
            }
        }
    });
    $('#GridPermissionList').kendoGrid({
        dataSource: dataSource,
        toolbar: [{
            name: 'new',
            id: 'btnCreate',
            class: 'btnCreate',
            text: "Thêm mới",
            click: function (e) {
                showDialog(_linkInsert.InsUpdPermissionConfig, "Thêm mới quyền chức năng");
            }
        }],
        editable: false,
        sortable: true,
        pageable: {
            refresh: true,
            pageSizes: true
        },
        columns: [
            {
                field: 'PermissionName',
                title: 'Tên quyền',
            }, {
                field: 'PermissionNameEN',
                title: 'Tên gợi nhớ',
            },
            {
                command: [
                    {
                        name: "details",
                        className: 'button-edit',
                        click: function (e) {
                            var grid = $('#GridPermissionList').data('kendoGrid');
                            var row = $(e.target).closest('tr');
                            var dataItemCurr = grid.dataItem(row);
                            showDialog(_linkInsert.InsUpdPermissionConfig + "?IDs=" + dataItemCurr.ID, "Chỉnh sửa quyền chức năng");
                        }
                    },
                    {
                        name: "delete", className: 'button-delete', click: function (e) {
                            if (confirm("Bạn có chắc chắn muốn xóa bỏ menu này!")) {
                                var grid = $('#GridPermissionList').data('kendoGrid');
                                var row = $(e.target).closest('tr');
                                var dataItemCurr = grid.dataItem(row);
                                $.ajax({
                                    url: _apiConfig.DeleteConfig,
                                    data: { data: JSON.stringify(dataItemCurr.ID) },
                                    type: "POST",
                                    scriptCharset: "utf8",
                                    dataType: "json",
                                    success: function (response) {
                                        if (response != null && response.status == 'SUCCESS') {
                                            $('#GridPermissionList').data("kendoGrid").dataSource.read();
                                        }

                                    },
                                    error: function (e) {
                                    },
                                });
                            }
                        }
                    } // built-in "destroy" command
                ]
            }],
    }).data('kendoGrid');
});
