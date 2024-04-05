using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Pages
{
    public partial class UserConfig : System.Web.UI.Page
    {
        CmmFunc _db = new CmmFunc();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");

        }
        void addJavaScript()
        {
            string strScript = @"<script src='https://kendo.cdn.telerik.com/2023.1.117/js/kendo.all.min.js'></script>
<script src='../../Scripts/HomeScript.js'></script>";
            Controls.Add(new LiteralControl(strScript));
        }

    }
}