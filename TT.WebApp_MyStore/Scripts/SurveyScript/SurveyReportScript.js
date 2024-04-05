var _apiSurvey = {
    GetListUserAndGroup: "/API/UserHandler.ashx?tbl=Survey&func=GetListUserAndGroup",
    GetSurveyCategory: "/API/UserHandler.ashx?tbl=Survey&func=GetSurveyCategory",
    GetListSurveyByUserID: "/API/UserHandler.ashx?tbl=Survey&func=GetListSurveyByUserID",
    InsertUpdateSurveyTable: "/API/UserHandler.ashx?tbl=Survey&func=InsertUpdateSurveyTable",
    GetDataSurvey: "/API/UserHandler.ashx?tbl=Survey&func=GetDataSurvey",
    GetDataReportSurvey: "/API/UserHandler.ashx?tbl=Survey&func=GetDataReportSurvey",
}
var _linkInsert = {
    linkInsertUpdateSurvey: "/Pages/Survey/AddNewSurvey.aspx?IDs="
}
var DataChart = [];
$(document).ready(function () {
    $('#ddlDateFrom').kendoDatePicker({
        change: CheckDateStart,
        value: new Date(),
        format: 'dd/MM/yyyy'
    });
    $('#ddlDateTo').kendoDatePicker({
        change: CheckDateEnd,
        value: new Date(),
        format: 'dd/MM/yyyy'
    });
    $('#ddlType').kendoDropDownList();

    //report
    var Type = $('#ddlType').val();
    var DateFrom = $('#ddlDateFrom').val();
    var DateTo = $('#ddlDateTo').val();
    GetDataChart();
    var dataSourceDoc = new kendo.data.DataSource({
        transport: {
            read: {
                url: _apiSurvey.GetDataReportSurvey + '&Type=' + $('#ddlType').val() + '&DateFrom=' + $('#ddlDateFrom').val() + '&DateTo=' + $('#ddlDateTo').val(),
                dataType: 'json',
            }
        },
        schema: {
            model: {
                fields: {
                    InProcess: { type: 'number', editable: false },
                    CompletedInTime: { type: 'number', editable: false },
                    CompletedOverTime: { type: 'number', editable: false },
                    TotalItem: { type: 'number', editable: false }
                }
            },
            parse: function (response) {
                return response.data.dataReport != null && response.data.dataReport.length > 0 ? response.data.dataReport : [];
            }
        },
    });
    $('#grid').kendoGrid({
        dataSource: dataSourceDoc,
        resizable: true,
        selectable: 'row',
        change: selectRows,
        columns: [{
            field: 'Category',
            title: 'Thời gian',
            headerAttributes:
            {
                style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
            }
        }, {
            field: 'TotalItem',
                title: 'Đã tạo',
            headerAttributes:
            {
                style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
            }
        },
        {
            template: '<div title="#=InProcess == 0 ? " " : InProcess #" class="field_InProcess" style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">#=InProcess == 0 ? " " : InProcess#</div>',
            field: 'InProcess',
            title: 'Đang thực hiện',
            headerAttributes:
            {
                style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
            }
        },
        {
            template: '<div title="#=CompletedInTime == 0 ? " " : CompletedInTime #" class="field_CompletedInTime" style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">#=CompletedInTime == 0 ? " " : CompletedInTime#</div>',
            field: 'CompletedInTime',
            title: 'Hoàn tất đúng hạn',
            headerAttributes:
            {
                style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
            }
        },
        {
            template: '<div title="#=CompletedOverTime == 0 ? " " : CompletedOverTime #" class="field_CompletedOverDue" style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">#=CompletedOverTime == 0 ? " " : CompletedOverTime#</div>',
            field: 'CompletedOverTime',
            title: 'Hoàn tất trễ hạn',
            headerAttributes:
            {
                style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
            }
        }],
        noRecords: {
            template: '<div style="color:red;text-align:center">Hiện tại không có dữ liệu trong khoảng thời gian bạn tra cứu.</div>'
        }
    }).data('kendoGrid');
    //grid2
    var dataSourceDoc2 = new kendo.data.DataSource({
        transport: {
            read: {
                url: _apiSurvey.GetDataReportSurvey + '&Type=' + $('#ddlType').val() + '&DateFrom=' + $('#ddlDateFrom').val() + '&DateTo=' + $('#ddlDateTo').val(),
                dataType: 'json',
            }
        },
        pageSize: 20,
        schema: {
            model: {
                id: 'ID',
                fields: {
                    STT: { type: 'number', editable: false },
                }
            },
            parse: function (response) {
                return response.data.dataGridDetail != null && response.data.dataGridDetail.length > 0? response.data.dataGridDetail : [];
            }
        },
    });
    $('#gridDetail').kendoGrid({
        dataSource: dataSourceDoc2,
        toolbar: ["excel"],
        excel: {
            fileName: "ReportSurvey.xlsx"
        },
        resizable: true,
        sortable: true,
        pageable: {
            refresh: true,
            pageSizes: true
        },
        columns: [{
                template: '<div style="text-align: center">#:STT#</div>',
                field: 'STT',
                title: 'STT',
                width: 48,
                headerAttributes: {
                    style: 'text-align:center;color: #2a3342;line-height: normal; min-height: inherit; '
                }
        }, {
                template: '<div style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;" title="#:Title#"><a href="#=_linkInsert.linkInsertUpdateSurvey + ID + "&Step=2"#" target="_blank" >#:Title#</a></div>',
                field: 'Title',
                title: 'Tiêu đề',
                width: 240,
                headerAttributes: {
                    style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
                }
        }, {
                template: '#= kendo.toString(kendo.parseDate(Created), "dd/MM/yyyy") #',
                field: 'Created',
                title: 'Ngày trình duyệt',
                headerAttributes:
                {
                    style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
                }
        },
        {
            template: '#= Overdue != null ? kendo.toString(kendo.parseDate(Overdue), "dd/MM/yyyy"):" " #',
            field: 'Overdue',
            title: 'Hạn xử lý',
            headerAttributes:
            {
                style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
            }
        },
        {
            template: '#= Modified == null ? " " : kendo.toString(kendo.parseDate(Modified), "dd/MM/yyyy") #',
            field: 'Modified',
            title: 'Ngày hoàn tất',
            headerAttributes:
            {
                style: 'text-align:left;color: #2a3342;line-height: normal; min-height: inherit; '
            }
        }
        ],
        selectable: 'row',
        noRecords: {
            template: '<div style="color:red;text-align:center">Hiện tại không có dữ liệu trong khoảng thời gian bạn tra cứu.</div>'
        }
    }).data('kendoGrid');
    $(document).ready(createChart);
    $(document).bind('kendo:skinChange', createChart);
});
//Function
function CheckDateStart() {
    if ($('#ddlType').val() == 'Week') {
        var datepicker = $('#ddlDateFrom').data('kendoDatePicker');
        var start = kendo.parseDate($('#ddlDateFrom').val());
        if (isInArray(start, '" + ListdisableStartDates + @"') == true) {
            datepicker.bind('close', function (e) {
                e.preventDefault(); //prevent popup closing
            });
            $('#ddlDateFrom').data('kendoDatePicker').value('');
        }
        else {
            datepicker.bind('close', function (e) {
                e.preventDefault(); //prevent popup opening
                e._defaultPrevented = false
            });
        }
    }
    var Today = new Date();
    if ($('#ddlType').val() == 'Week' || $('#ddlType').val() == 'Day') {
        var value = kendo.parseDate($('#ddlDateFrom').val());
        if (value > Today) {
            $('#ddlDateFrom').data('kendoDatePicker').value('');
        }
    }
    else if ($('#ddlType').val() == 'Month') {
        var value = kendo.parseDate('01/' + $('#ddlDateFrom').val());
        if (value.getFullYear() > Today.getFullYear()) {
            $('#ddlDateFrom').data('kendoDatePicker').value('');
        }
        else if (value.getMonth() > Today.getMonth()) {
            $('#ddlDateFrom').data('kendoDatePicker').value('');
        }
    }
    else if ($('#ddlType').val() == 'Year') {
        var value = kendo.parseDate($('#ddlDateFrom').val() + '-01-01');
        if (value.getFullYear() > Today.getFullYear()) {
            $('#ddlDateFrom').data('kendoDatePicker').value('');
        }
    }
};
function CheckDateEnd() {
    if ($('#ddlType').val() == 'Week') {
        var datepicker = $('#ddlDateTo').data('kendoDatePicker');
        var end = kendo.parseDate($('#ddlDateTo').val());
        if (isInArray(end, '" + ListdisableEndDates + @"') == true) {
            datepicker.bind('close', function (e) {
                e.preventDefault(); //prevent popup closing
            });
            $('#ddlDateTo').data('kendoDatePicker').value('');
        }
        else {
            datepicker.bind('close', function (e) {
                e.preventDefault(); //prevent popup opening
                e._defaultPrevented = false
            });
        }
    }
    var Today = new Date();
    if ($('#ddlType').val() == 'Week' || $('#ddlType').val() == 'Day') {
        var value = kendo.parseDate($('#ddlDateTo').val());
        if (value > Today) {
            $('#ddlDateTo').data('kendoDatePicker').value('');
        }
    }
    else if ($('#ddlType').val() == 'Month') {
        var value = kendo.parseDate('01/' + $('#ddlDateTo').val());
        if (value.getFullYear() > Today.getFullYear()) {
            $('#ddlDateTo').data('kendoDatePicker').value('');
        }
        else if (value.getMonth() > Today.getMonth()) {
            $('#ddlDateTo').data('kendoDatePicker').value('');
        }
    }
    else if ($('#ddlType').val() == 'Year') {
        var value = kendo.parseDate($('#ddlDateTo').val() + '-01-01');
        if (value.getFullYear() > Today.getFullYear()) {
            $('#ddlDateTo').data('kendoDatePicker').value('');
        }
    }
};
function ToDetail(target) {
    window.open('?TypeDetail=' + target + '&Type=' + $('#ddlType').val() + '&DateFrom=' + $('#ddlDateFrom').val() + '&DateTo=' + $('#ddlDateTo').val() + '&Workflow=' + $('#ddlWorkflow').val() + '&Department=' + $('#ddlDepartment').val(), '_blank');
};
function selectRows(e) {
    var e = $('#gridDoc').data('kendoGrid').select();
    var datasItem = $('#gridDoc').data('kendoGrid').dataItem($(e).closest('tr'));
    if (datasItem.StartDateNum) {
        window.open('" + strHref + @"?TypeDetail=ShowDetail&Tab=Doc&Type=' + $('#ddlType').val() + '&DateFrom=' + datasItem.StartDateNum + '&DateTo=' + datasItem.EndDateNum + '&Workflow=' + $('#ddlWorkflow').val() + '&Department=' + $('#ddlDepartment').val(), '_blank');
    }
};
function selectRowsDept(e) {
    var e = $('#grid').data('kendoGrid').select();
    var datasItem = $('#grid').data('kendoGrid').dataItem($(e).closest('tr'));
    if (datasItem.DeptID) {
        window.open('" + strHref + @"?TypeDetail=ShowDetail&Tab=Dept&Type=' + $('#ddlType').val() + '&DateFrom=' + $('#ddlDateFrom').val() + '&DateTo=' + $('#ddlDateTo').val() + '&Workflow=' + $('#ddlWorkflow').val() + '&Department=' + datasItem.DeptID, '_blank');
    }
};
//Document
function ChangeType() {
    $('#ddlDateTo').val('');
    $('#ddlDateFrom').val('');
    var DateFrom = $('#ddlDateFrom').data('kendoDatePicker');
    var DateTo = $('#ddlDateTo').data('kendoDatePicker');
    DateFrom.destroy();
    DateTo.destroy();
    if ($('#ddlType').val() == 'Day') {
        $('#ddlDateFrom').kendoDatePicker({
            change: CheckDateStart,
            format: 'dd/MM/yyyy'
        });
        $('#ddlDateTo').kendoDatePicker({
            change: CheckDateEnd,
            format: 'dd/MM/yyyy'
        });
    }
    else if ($('#ddlType').val() == 'Week') {
        $('#ddlDateFrom').kendoDatePicker({
            change: CheckDateStart,
            disableDates: ["mo"],
            format: 'dd/MM/yyyy'
        });
        $('#ddlDateTo').kendoDatePicker({
            change: CheckDateEnd,
            disableDates: ["su"],
            format: 'dd/MM/yyyy'
        });
    }
    else if ($('#ddlType').val() == 'Month') {
        $('#ddlDateFrom').kendoDatePicker({
            change: CheckDateStart,
            start: 'year',
            depth: 'year',
            format: 'MM/yyyy',
        });
        $('#ddlDateTo').kendoDatePicker({
            change: CheckDateEnd,
            start: 'year',
            depth: 'year',
            format: 'MM/yyyy',
        });
    }
    else {
        $('#ddlDateFrom').kendoDatePicker({
            change: CheckDateStart,
            start: 'decade',
            depth: 'decade',
            format: 'yyyy'
        });
        $('#ddlDateTo').kendoDatePicker({
            change: CheckDateEnd,
            start: 'decade',
            depth: 'decade',
            format: 'yyyy'
        });
    }
};
function createChart() {
    $('#chart').kendoChart({
        dataSource: DataChart,
        legend:
        {
            position: 'bottom',
            labels:
            {
                template: '#:text#',
            }
        },
        series: [
            {
                type: 'bar',
                field: 'InProcess',
                categoryField: 'Category',
                name: 'Đang thực hiện',
                color: '#5BAFFE',
            },
            {
                type: 'bar',
                field: 'CompletedInTime',
                categoryField: 'Category',
                name: 'Hoàn tất đúng hạn',
                color: '#6BD864',
            },
            {
                type: 'bar',
                field: 'CompletedOverTime',
                categoryField: 'Category',
                name: 'Hoàn tất trễ hạn',
                color: '#E36060',
            }
        ],
        tooltip: {
            visible: true
        }
    });
}
//Cancel
function GetDataChart() {
    $.ajax({
        type: 'POST',
        url: _apiSurvey.GetDataReportSurvey + '&Type=' + $('#ddlType').val() + '&DateFrom=' + $('#ddlDateFrom').val() + '&DateTo=' + $('#ddlDateTo').val(),
        cache: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        success: function (httpRequest) {
            if (httpRequest.data != null || httpRequest.data != '') {
                if (httpRequest.data.dataReport.length > 0) {
                    var chart = $('#chart').data('kendoChart');
                    var dataSource = new kendo.data.DataSource({
                        data: httpRequest.data.dataReport
                    });
                    chart.setDataSource(dataSource);
                }
            }

        },
        error: function (httpRequest, textStatus, errorThrown) {
            alert('Error: ' + textStatus + ' ' + errorThrown + ' ' + httpRequest);
        }
    });
};
function GetDataGrid() {
    $.ajax({
        type: 'POST',
        url: _apiSurvey.GetDataReportSurvey + '&Type=' + $('#ddlType').val() + '&DateFrom=' + $('#ddlDateFrom').val() + '&DateTo=' + $('#ddlDateTo').val(),
        cache: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        success: function (httpRequest) {
            if (httpRequest.data != null || httpRequest.data != '') {
                var grid = $('#grid').data('kendoGrid');
                var dataSource = new kendo.data.DataSource({
                    data: httpRequest.data.dataReport
                });
                grid.setDataSource(dataSource);
            }

        },
        error: function (httpRequest, textStatus, errorThrown) {
            alert('Error: ' + textStatus + ' ' + errorThrown + ' ' + httpRequest);
        }
    });
};
function GetDataGridDetail() {
    $.ajax({
        type: 'POST',
        url: _apiSurvey.GetDataReportSurvey + '&Type=' + $('#ddlType').val() + '&DateFrom=' + $('#ddlDateFrom').val() + '&DateTo=' + $('#ddlDateTo').val(),
        cache: false,
        scriptCharset: 'utf8',
        dataType: 'json',
        success: function (httpRequest) {
            if (httpRequest.data != null || httpRequest.data != '') {
                var grid = $('#gridDetail').data('kendoGrid');
                var dataSource = new kendo.data.DataSource({
                    data: httpRequest.data.dataGridDetail
                });
                grid.setDataSource(dataSource);
            }

        },
        error: function (httpRequest, textStatus, errorThrown) {
            alert('Error: ' + textStatus + ' ' + errorThrown + ' ' + httpRequest);
        }
    });
};

function duration() {
    const get_day_of_time = (d1, d2) => {
        let ms1 = d1.getTime();
        let ms2 = d2.getTime();
        return Math.ceil((ms2 - ms1) / (24 * 60 * 60 * 1000));
    };
    var start = $('#ddlDateFrom').data('kendoDatePicker').value();
    var end = $('#ddlDateTo').data('kendoDatePicker').value();

    let time = get_day_of_time(start, end)
    console.log(time + ' day');
    return time;
};
function Search() {
    var time = 0;
    if ($('#ddlType').val() == 'Day') {
        time = duration();
    }
    if ($('#ddlDateFrom').val() == '' || $('#ddlDateFrom').val() == undefined || $('#ddlDateTo').val() == '' || $('#ddlDateTo').val() == undefined) {
        alert('Vui lòng nhập các trường bắt buộc');
    }
    else if (time >= 30) {
        alert('Bạn không thể tra cứu vượt quá " + LimitDateShow + @" ngày');
    }
    else {
        var check = false;
        if ($('#ddlType').val() == 'Week' || $('#ddlType').val() == 'Day') {
            var start = kendo.parseDate($('#ddlDateFrom').val());
            var end = kendo.parseDate($('#ddlDateTo').val());
            if (start > end) {
                alert('Không thể tra cứu với giá trị Từ Ngày lớn hơn Đến Ngày!');
            }
            else {
                check = true;
            }
        }
        else if ($('#ddlType').val() == 'Month') {
            var start = kendo.parseDate('01/' + $('#ddlDateFrom').val());
            var end = kendo.parseDate('01/' + $('#ddlDateTo').val());
            if (start.getFullYear() > end.getFullYear()) {
                alert('Không thể tra cứu với giá trị Từ Ngày lớn hơn Đến Ngày!');
            }
            else if (start.getMonth() > end.getMonth()) {
                alert('Không thể tra cứu với giá trị Từ Ngày lớn hơn Đến Ngày!');
            }
            else {
                check = true;
            }
        }
        else if ($('#ddlType').val() == 'Year') {
            var start = kendo.parseDate($('#ddlDateFrom').val() + '-01-01');
            var end = kendo.parseDate($('#ddlDateTo').val() + '-01-01');
            if (start.getFullYear() > end.getFullYear()) {
                alert('Không thể tra cứu với giá trị Từ Ngày lớn hơn Đến Ngày!');
            }
            else {
                check = true;
            }
        }
        if (check == true) {
            GetDataGrid();
            GetDataChart();
            GetDataGridDetail();
        }
    }
    return true;
}