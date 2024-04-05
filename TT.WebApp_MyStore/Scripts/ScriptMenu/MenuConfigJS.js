var _apiMenuUsers = {
    GetListMenu: "/API/UserHandler.ashx?tbl=MenuUsers&func=GetListMenu",
    DeleteMenu: "/API/UserHandler.ashx?tbl=MenuUsers&func=DeleteMenu"
}
var _linkInsert = {
    linkInsertUpdateMenu: "/Pages/MenuSetting/InsertUpdateMenuSetting.aspx"
}
$(document).ready(function () {
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                // The remote endpoint from which the data is retrieved.
                url: _apiMenuUsers.GetListMenu,
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
    $('#GridMenuList').kendoGrid({
        dataSource: dataSource,
        toolbar: [{
            name: 'new',
            id: 'btnCreate',
            text: "Thêm mới",
            click: function (e) {
                showDialog(_linkInsert.linkInsertUpdateMenu, "Thêm mới menu");
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
                field: 'Url',
                title: 'Đường dẫn'
        }, {
                field: 'Icon',
                title: 'Biểu tượng'
        },{
            command: [
                {
                    name: "details",
                    className: 'button-edit',
                    click: function (e) {
                        var grid = $('#GridMenuList').data('kendoGrid');
                        var row = $(e.target).closest('tr');
                        var dataItemCurr = grid.dataItem(row);
                        showDialog(_linkInsert.linkInsertUpdateMenu + "?IDs=" + dataItemCurr.ID, "Chỉnh sửa thông tin menu");
                    }
                },
                {
                    name: "delete", className: 'button-delete', click: function (e) {
                        if (confirm("Bạn có chắc chắn muốn xóa bỏ menu này!")) {
                            var grid = $('#GridMenuList').data('kendoGrid');
                            var row = $(e.target).closest('tr');
                            var dataItemCurr = grid.dataItem(row);
                            $.ajax({
                                url: _apiMenuUsers.DeleteMenu,
                                data: { data: JSON.stringify(dataItemCurr.ID) },
                                type: "POST",
                                scriptCharset: "utf8",
                                dataType: "json",
                                success: function (response) {
                                    if (response != null && response.status == 'SUCCESS') {
                                        $('#GridMenuList').data("kendoGrid").dataSource.read();
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
