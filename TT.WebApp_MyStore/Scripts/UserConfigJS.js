var _apiUser = {
    GetListUser: "/API/UserHandler.ashx?tbl=User&func=GetListUser",
    DeleteUser: "/API/UserHandler.ashx?tbl=User&func=DeleteUser"
}
var _linkInsert = {
    linkInsertUpdateUser: "/Pages/InsertUpdateUser.aspx"
}
$(document).ready(function () {
    //$.ajax({
    //    url: _apiUser.GetListUser,
    //    data: null,
    //    type: "POST",
    //    scriptCharset: "utf8",
    //    dataType: "json",
    //    success: function (res) {
    //        if (res.status == "SUCCESS") {
    //            var grid = $("#GridUserList").data("kendoGrid");
    //            grid.setDataSource(res.data);
    //        }
    //    },
    //    error: function (e) {
    //    },
    //});
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                // The remote endpoint from which the data is retrieved.
                url: _apiUser.GetListUser,
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
    $('#GridUserList').kendoGrid({
        dataSource: dataSource,
        toolbar: [{
            name: 'new',
            id: 'btnCreate',
            text: "Thêm mới",
            click: function (e) {
                showDialog(_linkInsert.linkInsertUpdateUser, "Thêm mới tài khoản");
            }
        }],
        editable: false,
        sortable: true,
        pageable: {
            refresh: true,
            pageSizes: true
        },
        columns: [{
            field: 'AccountName',
            title: 'Tên tài khoản',
            width: 240
        }, {
            field: 'FullName',
            title: 'Tên đầy đủ',
        }, {
            field: 'Email',
            title: 'Email'
        }, {
            field: 'Address',
            title: 'Địa chỉ'
        }, {
            template: function (e) {
                if (e.Status == 1) {
                    return "<input type='checkbox' checked='true' disabled />";
                }
                else {
                    return "<input type='checkbox' checked='false' disabled />";
                }
            },
            title: 'Trạng thái',
            field: 'Status',
            width: 150
            }, {
                command: [
                    {
                        name: "details",
                        className: 'button-edit',
                        click: function (e) {
                            var grid = $('#GridUserList').data('kendoGrid');
                            var row = $(e.target).closest('tr');
                            var dataItemCurr = grid.dataItem(row);
                            showDialog(_linkInsert.linkInsertUpdateUser + "?IDs=" + dataItemCurr.ID, "Chỉnh sửa thông tin tài khoản");
                        }
                    },
                    {
                        name: "delete", className: 'button-delete', click: function (e) {
                            if (confirm("Bạn có chắc chắn muốn xóa bỏ tài khoản này!")) {
                                var grid = $('#GridUserList').data('kendoGrid');
                                var row = $(e.target).closest('tr');
                                var dataItemCurr = grid.dataItem(row);
                                $.ajax({
                                    url: _apiUser.DeleteUser,
                                    data: { data: JSON.stringify(dataItemCurr.ID) },
                                    type: "POST",
                                    scriptCharset: "utf8",
                                    dataType: "json",
                                    success: function (response) {
                                        if (response != null && response.status == 'SUCCESS') {
                                            $('#GridUserList').data("kendoGrid").dataSource.read();
                                        }
                                        
                                    },
                                    error: function (e) {
                                    },
                                });
                            }
                        }} // built-in "destroy" command
                ]
            }],
    }).data('kendoGrid');
});
