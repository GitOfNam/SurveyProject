var _apiSurvey = {
    GetListUserAndGroup: "/API/UserHandler.ashx?tbl=Survey&func=GetListUserAndGroup",
    GetSurveyCategory: "/API/UserHandler.ashx?tbl=Survey&func=GetSurveyCategory",
    GetListSurveyByUserID: "/API/UserHandler.ashx?tbl=Survey&func=GetListSurveyByUserID",
    InsertUpdateSurveyTable: "/API/UserHandler.ashx?tbl=Survey&func=InsertUpdateSurveyTable",
    GetDataSurvey: "/API/UserHandler.ashx?tbl=Survey&func=GetDataSurvey",
    SearchAPI: "/API/UserHandler.ashx?tbl=System&func=SearchAPI"
}
var _linkInsert = {
    linkInsertUpdateSurvey: "/Pages/Survey/AddNewSurvey.aspx?IDs="
}
var dataSearch = {
    Title: '',
    Type: 'All',
    FromDate: null,
    ToDate: null,
    Category: 0
}
var dataTest = [{ ID: "8e396370-856a-42ec-bbad-f855756f8619", Title: "Test", Modified: new Date(), CountSurvey: 1, design: true, isComplete: true, collect: true, analyze: true }, { ID: "ADB467EB-3F19-44A9-B2BE-056ACE851BD0", Title: "Test", Modified: new Date(), CountSurvey: 1, design: true, isComplete: false, collect: true, analyze: true }];
$(document).ready(function () {
   
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                url: _apiSurvey.GetListSurveyByUserID,
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
    });
    $('#GridSurvey').kendoGrid({
        dataSource: dataSource,
        editable: false,
        sortable: true,
        resizable: true,
        pageable: {
            refresh: true,
            pageSizes: true
        },
        columns: [
            {
                field: 'Title',
                title: 'Khảo sát',
            }, {
                template: "<div>#:kendo.toString(kendo.parseDate(Modified),'dd/MM/yyyy HH:mm')#</div>",
                field: 'Modified',
                title: 'Ngày sửa',
            },
            {
                field: 'CountSurvey',
                title: 'Đánh giá',
            }, {
                template: '<a href="#=_linkInsert.linkInsertUpdateSurvey + ID + "&Step=2"#" target="_blank" class="a-design design-link" title="Thiết kế">Design</a>',
                field: 'design',
                title: 'Thiết kế',
            },
            {
                template: function (e) {
                    if (!e.isComplete) {
                        return '<a href="#" class="a-collect disabled" title="Danh sách đánh giá">Collect</a>';
                    }
                    else
                        return '<a href="/Pages/Survey/AddNewSurvey.aspx?IDs=' + e.ID + '&Step=3" target="_blank" class="a-collect" title="Danh sách đánh giá">Collect</a>';
                },
                field: 'collect',
                title: 'đánh giá',
            },
            {
                template: function (e) {
                    if (!e.isComplete) {
                        return '<a href="#" class="a-analyze disabled" title="Báo cáo">Analyze</a>';
                    }
                    else
                        return '<a href="/Pages/Survey/AddNewSurvey.aspx?IDs=' + e.ID + '&Step=4" target="_blank" class="a-analyze" title="Báo cáo">Analyze</a>';
                },
                field: 'analyze',
                title: 'Báo cáo',
            }, {
                command: [
                    {
                        name: "details",
                        className: 'button-edit',
                        click: function (e) {
                            var grid = $('#GridSurvey').data('kendoGrid');
                            var row = $(e.target).closest('tr');
                            var dataItemCurr = grid.dataItem(row);
                            window.open(_linkInsert.linkInsertUpdateSurvey + dataItemCurr.ID, '_blank');
                        }
                    },
                    {
                        name: "delete", className: "button-delete", click: function (e) {
                            if (confirm("Bạn có chắc chắn muốn xóa bỏ menu này!")) {
                                var grid = $('#GridSurvey').data('kendoGrid');
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
                                            $('#GridSurvey').data("kendoGrid").dataSource.read();
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
   
    //loadTemplate
    LoadJqueryTemplate('FilterTemplate', "#JQRTemp", function () {
        var dataFill = [];
        dataFill.push({ NamePage: "All" });
        $("#FilterTemp").tmpl({ data: dataFill }).appendTo("#divFilter");
        $('#txtSurveyCategorySearch').kendoDropDownList({
            dataSource: [],
            dataTextField: "Title",
            dataValueField: "ID",
            placeholder: "Enter value ..."
        });
        $('#txtFromDateSearch').kendoDatePicker({
            format: "dd/MM/yyyy"
        });
        $('#txtToDateSearch').kendoDatePicker({
            format: "dd/MM/yyyy"
        });
        setValueControl();
    });
   
   
});
function setValueControl(){
    $.ajax({
        url: _apiSurvey.GetSurveyCategory,
        data: null,
        type: "POST",
        scriptCharset: "utf8",
        dataType: "json",
        success: function (res) {
            if (res.status == "SUCCESS") {
                var DropDownList = $('#txtSurveyCategorySearch').data("kendoDropDownList");
                DropDownList.setDataSource(res.data);
            }
        },
        error: function (e) {
        },
    });
}
function onDesign(ID) {
    window.open(_linkInsert.linkInsertUpdateSurvey + ID + "&Step=2", '_blank');
}

function onCollect(ID) {
    window.open(_linkInsert.linkInsertUpdateSurvey + ID + "&Step=3", '_blank');
}

function onAnalyze(ID) {
    window.open(_linkInsert.linkInsertUpdateSurvey + ID + "&Step=4", '_blank');
}
function btnSearch(type) {
    var formSearch = new FormData();
    dataSearch.Title = $('#txtTitleSearch').val();
    dataSearch.Type = type;
    if (!isNullOrEmpty($('#txtSurveyCategorySearch').data('kendoDropDownList').value()))
        dataSearch.Category = $('#txtSurveyCategorySearch').data('kendoDropDownList').value();
    
    dataSearch.FromDate = $('#txtFromDateSearch').data('kendoDatePicker').value();
    dataSearch.ToDate = $('#txtToDateSearch').data('kendoDatePicker').value();
    formSearch.append("data", JSON.stringify(dataSearch));
    if (!isNullOrEmpty(dataSearch.FromDate))
        formSearch.append("FromDate", kendo.toString(dataSearch.FromDate, "yyyy/MM/dd"));
    if (!isNullOrEmpty(dataSearch.ToDate))
        formSearch.append("ToDate", kendo.toString(dataSearch.ToDate, "yyyy/MM/dd"));
    
    $.ajax({
        url: _apiSurvey.SearchAPI,
        type: 'POST',
        async: false,
        cache: false,
        processData: false,
        contentType: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        data: formSearch,
        success: function (response) {
            if (response != null && response.status == 'SUCCESS') {
                var grid = $('#GridSurvey').data('kendoGrid');
                grid.setDataSource(response.data);
            }
        },
        error: function (errorData) {

        }
    });

}