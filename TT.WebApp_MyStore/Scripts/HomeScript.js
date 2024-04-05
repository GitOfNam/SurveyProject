var _apiHome = {
    SetMenuNotifyAll: "/API/UserHandler.ashx?tbl=Notify&func=SetMenuNotifyAll",
    getDataChartHome: "/API/UserHandler.ashx?tbl=System&func=getDataChartHome"
}
var _linkImport = {
    linkImportSurvey: "/Pages/Survey/AddNewSurvey.aspx?IDs="
}
var colorOverDue = '#F44336';
var colorToday = '#FFEB3B';
var colorNextTo = '#9C27B0';
var dataKendoChart = [{ "category": "Trễ hạn", "value": 17 }, { "category": "Hoàn tất hôm nay", "value": 0 }, { "category": "Sắp tới", "value": 0 },];
$(document).ready(function () {
    if ($('#MenuId-1011')) {
        $('#MenuId-1011').click(function () { showDialog(_linkImport.linkImportSurvey, "Import excel"); });
    }
    var dataSource = new kendo.data.DataSource({
        transport: {
            read: {
                url: _apiHome.SetMenuNotifyAll,
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
    $('#GridNotify').kendoGrid({
        dataSource: dataSource,
        height: 550,
        sortable: true,
        pageable: {
            refresh: true,
            pageSizes: true
        },
        columns: [{
            
            template: "<a href='#:LinkUrl#'>#:Title#</a>",
            title: 'Tiêu đề',
            width: 240
        }, {
            field: 'NguoiTao',
            title: 'Người tạo'
        }, {
            template: "<div>#:kendo.toString(kendo.parseDate(Created),'dd/MM/yyyy HH:mm')#</div>",
            field: 'Created',
            title: 'Ngày tạo'
            },
            {
                template: "<div>#: Overdue != null ? kendo.toString(kendo.parseDate(Overdue),'dd/MM/yyyy HH:mm') : ''#</div>",
                field: 'Overdue',
                title: 'Trễ hạn'
            }, {
            template: function (e) {
                if (e.isOverDue) {
                    return " <div style='background-color: red; border-radius: 50%;width: 10px;height: 10px;'></div>";
                }
                else {
                    return " <div style='background-color: green; border-radius: 50%;width: 10px;height: 10px;'></div>";
                }
                },
                title: 'Trạng thái',
            field: 'Status',
            width: 150
        }]
    }).data('kendoGrid');
    //$("#Chart1").kendoChart({
    //    legend: {
    //        position: "right",
    //    },
    //    chartArea: {
    //        background: ""
    //    }, seriesDefaults: {
    //        labels: {
    //            visible: false,
    //            background: "transparent",
    //            template: "#= value#"
    //        }
    //    },
    //    theme: "material",
    //    series: [{
    //        type: "pie",
    //        startAngle: 150,
    //        data: [{
    //            category: "Đúng hạn",
    //            value: 53
    //        }, {
    //            category: "Trễ hạn",
    //            value: 16
    //        }]
    //    }],
    //    tooltip: {
    //        visible: true,
    //        format: "{0}%"
    //    }
    //});
    createChart();
   
    
   
});
function createChart(){
    $(document).bind('kendo:skinChange', createChart);
    $('#k-chart-dashboard').kendoChart({
        theme: 'metro',
        legend: {
            visible: false
        },
        chartArea: {
            background: ''
        },
        seriesDefaults: {
            type: 'donut',
            startAngle: 150
        },
        series: [{ field: "value" }],
        seriesColors: [colorOverDue, colorToday, colorNextTo],
        tooltip: {
            visible: true,
            template: "${ category } - #= kendo.format('{0:p1}', percentage) #"
        }
    });
    $.ajax({
        url: _apiHome.getDataChartHome,
        data: null,
        type: "POST",
        scriptCharset: "utf8",
        dataType: "json",
        success: function (res) {
            if (res.status == "SUCCESS") {
                var dataSource = new kendo.data.DataSource({
                    data: res.data.lstChart
                });
                var chart = $("#k-chart-dashboard").data("kendoChart");
                chart.setDataSource(dataSource);
                $('#notiOverDue').html(res.data.overdue);
                $('#notiToday').html(res.data.completedToday);
                $('#notiNextTo').html(res.data.continued);
                $('.ic-NotYetEval').html(res.data.UnCompleted);
                $('.ic-Evaluating').html(res.data.inprocess);
                $('.ic-Completed').html(res.data.completed);
            }
        },
        error: function (e) {
        },
    });
}

