using System;
using System.Web.Security;
using System.Web.UI;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Admin.Pages
{
    public partial class Home : System.Web.UI.Page
    {
        CmmFunc _db = new CmmFunc();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");
            if (!IsPostBack)
            {
                addHtml();
                addJavaScript();
            }
        }
        void addJavaScript()
        {
            string strScript= @"<script src='https://kendo.cdn.telerik.com/2023.1.117/js/kendo.all.min.js'></script>
           <script>
                $(document).ready(function () {
                    var _api = {
                        SetMenuNotify: '/API/UserHandler.ashx?tbl=Notify&func=SetMenuNotify'
                    }
                    
                });
$(document).ready(function () {
  $('#grid').kendoGrid({
                dataSource: {
                    transport: {
                        read: _api.SetMenuNotify,
                        dataType: 'json'
                    },
                    pageSize: 20,
                    schema: {
                        model: {
                            id: 'ID',
                            fields: {
                              Status: { type: 'int'},
                            }
                        }
                    }
                },
                height: 550,
                sortable: true,
                pageable: {
                    refresh: true,
                    pageSizes: true
                },
                columns: [{
                    field: 'Title',
                    title: 'Tiêu đề',
                    width: 240
                }, {
                    field: 'NguoiTao',
                    title: 'Người tạo'
                }, {
                    template: '<div>#=kendo.toString(Created, ""dd / MM / yyyy HH: mm"")#</div>',
                    field: 'Created',
                    title: 'Company Name'
                }, {
                  template: function(e)
        {
            if (e.Status == 1)
            {
                return '<input type=""checkbox"" checked=""true"" disabled />';
            }
            else
            {
                return '<input type=""checkbox"" checked=""false"" disabled />';
            }
        },
                    field: 'Status',
                    width: 150
                }]
            });
});
           </script>";
            Controls.Add(new LiteralControl(strScript));
        }
        void addHtml()
        {
            string strHTML = @"
                <div class='body-Content'>
    <div class='statistical-Content'>
        <div class='statistical-Chart'>

        </div>
    </div>
    <div class='ToDoList'>
      <div class='ToDoList-Grid'>
        <div id='GridNotify'></div>
      </div>
  </div>
</div>";
            Controls.Add(new LiteralControl(strHTML));
        }
    }
}