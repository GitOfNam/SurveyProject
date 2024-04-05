var _apiMenuGroups = {
    GetListGroups: "/API/UserHandler.ashx?tbl=GroupConfig&func=GetListGroup",
    DeleteGroups: "/API/UserHandler.ashx?tbl=GroupConfig&func=DeleteGroup"
}
var _linkInsert = {
    linkInsertUpdateGroups: "/Pages/GroupSetting/InsertUpdateGroup.aspx"
}
$(document).ready(function () {
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                // The remote endpoint from which the data is retrieved.
                url: _apiMenuGroups.GetListGroups,
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
    $('#GridGroupList').kendoGrid({
        dataSource: dataSource,
        toolbar: [{
            name: 'new',
            id: 'btnCreate',
            class: 'btnCreate',
            text: "Thêm mới",
            click: function (e) {
                showDialog(_linkInsert.linkInsertUpdateGroups, "Thêm mới nhóm");
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
                title: 'Tiêu đề tiếng Việt',
            }, {
                field: 'TitleEN',
                title: 'Tiêu đề tiếng Anh',
            }, {
                command: [
                    {
                        name: "details",
                        className: 'button-edit',
                        click: function (e) {
                            var grid = $('#GridGroupList').data('kendoGrid');
                            var row = $(e.target).closest('tr');
                            var dataItemCurr = grid.dataItem(row);
                            showDialog(_linkInsert.linkInsertUpdateGroups + "?IDs=" + dataItemCurr.ID, "Chỉnh sửa thông tin menu");
                        }
                    },
                    {
                        name: "delete", className: 'button-delete', click: function (e) {
                            if (confirm("Bạn có chắc chắn muốn xóa bỏ menu này!")) {
                                var grid = $('#GridGroupList').data('kendoGrid');
                                var row = $(e.target).closest('tr');
                                var dataItemCurr = grid.dataItem(row);
                                $.ajax({
                                    url: _apiMenuGroups.DeleteGroups,
                                    data: { data: JSON.stringify(dataItemCurr.ID) },
                                    type: "POST",
                                    scriptCharset: "utf8",
                                    dataType: "json",
                                    success: function (response) {
                                        if (response != null && response.status == 'SUCCESS') {
                                            $('#GridGroupList').data("kendoGrid").dataSource.read();
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
