var _apiMenuTemplate = {
    GetListMailTemplate: "/API/UserHandler.ashx?tbl=MailTemplate&func=GetListMailTemplate",
    DeleteMailTemplate: "/API/UserHandler.ashx?tbl=MailTemplate&func=DeleteMailTemplate"
}
var _linkInsert = {
    linkInsertUpdateMailTemplate: "/Pages/MailTemplateSetting/InsUpdMailTemplate.aspx"
}
$(document).ready(function () {
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                // The remote endpoint from which the data is retrieved.
                url: _apiMenuTemplate.GetListMailTemplate,
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
    $('#GridMailTemplateList').kendoGrid({
        dataSource: dataSource,
        toolbar: [{
            name: 'new',
            id: 'btnCreate',
            class: 'btnCreate',
            text: "Thêm mới",
            click: function (e) {
                showDialog(_linkInsert.linkInsertUpdateMailTemplate, "Thêm mới mẫu mail");
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
                field: 'Subject',
                title: 'Tiêu đề tiếng Việt',
            }, {
                field: 'SubjectEN',
                title: 'Tiêu đề tiếng Anh',
            },
            {
                field: 'ThamSoSubject',
                title: 'Tham số tiêu đề',
            }, {
                field: 'Body',
                title: 'Nội dung',
            },
            {
                field: 'ThamSoBody',
                title: 'Thamm số nội dung',
            }, {
                command: [
                    {
                        name: "details",
                        className: 'button-edit',
                        click: function (e) {
                            var grid = $('#GridMailTemplateList').data('kendoGrid');
                            var row = $(e.target).closest('tr');
                            var dataItemCurr = grid.dataItem(row);
                            showDialog(_linkInsert.linkInsertUpdateMailTemplate + "?IDs=" + dataItemCurr.ID, "Chỉnh sửa mẫu mail");
                        }
                    },
                    {
                        name: "delete", className: 'button-delete', click: function (e) {
                            if (confirm("Bạn có chắc chắn muốn xóa bỏ menu này!")) {
                                var grid = $('#GridMailTemplateList').data('kendoGrid');
                                var row = $(e.target).closest('tr');
                                var dataItemCurr = grid.dataItem(row);
                                $.ajax({
                                    url: _apiMenuTemplate.DeleteMailTemplate,
                                    data: { data: JSON.stringify(dataItemCurr.ID) },
                                    type: "POST",
                                    scriptCharset: "utf8",
                                    dataType: "json",
                                    success: function (response) {
                                        if (response != null && response.status == 'SUCCESS') {
                                            $('#GridMailTemplateList').data("kendoGrid").dataSource.read();
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
