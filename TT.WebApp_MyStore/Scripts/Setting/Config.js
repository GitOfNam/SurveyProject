var _apiConfig = {
    GetListConfig: "/API/UserHandler.ashx?tbl=Setting&func=GetListConfig",
    DeleteConfig: "/API/UserHandler.ashx?tbl=Setting&func=DeleteConfig"
}
var _linkInsert = {
    linkInsertUpdateMailTemplate: "/Pages/Setting/InsUpdSettingConfig.aspx"
}
$(document).ready(function () {
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                // The remote endpoint from which the data is retrieved.
                url: _apiConfig.GetListConfig,
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
        },
        group: {
            field: "Module"
        }
    });
    $('#GridSettingConfig').kendoGrid({
        dataSource: dataSource,
        toolbar: [{
            name: 'new',
            id: 'btnCreate',
            class: 'btnCreate',
            text: "Thêm mới",
            click: function (e) {
                showDialog(_linkInsert.linkInsertUpdateMailTemplate, "Thêm mới cấu hình hệ thống");
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
                field: 'Title',
                title: 'Tiêu đề',
            }, {
                field: 'Value',
                title: 'Giá trị',
            },
            {
                field: 'Descript',
                title: 'Mô tả',
            },
            {
                command: [
                    {
                        name: "details",
                        className: 'button-edit',
                        click: function (e) {
                            var grid = $('#GridSettingConfig').data('kendoGrid');
                            var row = $(e.target).closest('tr');
                            var dataItemCurr = grid.dataItem(row);
                            showDialog(_linkInsert.linkInsertUpdateMailTemplate + "?IDs=" + dataItemCurr.ID, "Chỉnh sửa cấu hình hệ thống");
                        }
                    },
                    {
                        name: "delete", className: 'button-delete', click: function (e) {
                            if (confirm("Bạn có chắc chắn muốn xóa bỏ menu này!")) {
                                var grid = $('#GridSettingConfig').data('kendoGrid');
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
                                            $('#GridSettingConfig').data("kendoGrid").dataSource.read();
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
