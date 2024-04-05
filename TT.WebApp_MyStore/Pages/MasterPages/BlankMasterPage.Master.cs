using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Pages.MasterPages
{
    public partial class BlankMasterPage : System.Web.UI.MasterPage
    {
        CmmFunc _db = new CmmFunc();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");

            UserModel user = _db.getDataLogin();

            PageCurrentInfo pageCurrentInfo = new PageCurrentInfo();
            Context.Session["LanguageId"] = user.LanguageId != null ? Convert.ToInt32(user.LanguageId) : 1066;
            pageCurrentInfo.LanguageId = user.LanguageId != null ? Convert.ToInt32(user.LanguageId) : 1066;
            pageCurrentInfo.StrDate = user.LanguageId == 1066 ? "dd/MM/yyyy" : "MM/dd/yyyy";
            pageCurrentInfo.StrDateTime = user.LanguageId == 1066 ? "dd/MM/yyyy HH:mm" : "MM/dd/yyyy HH:mm";
            pageCurrentInfo.StrDateSQL = "yyyy-MM-dd";
            pageCurrentInfo.MenuParent = Context.Session["MenuParent"] + "";
            pageCurrentInfo.MenuSelected = Context.Session["MenuSelected"] + "";

            var strHtml = @"<script>";
            strHtml += @"var PageCurrentInfo = " + JsonConvert.SerializeObject(pageCurrentInfo) + ";";
            strHtml += @"</script>";
            if (pageCurrentInfo.LanguageId == 1066)
            {
               
                strHtml += @"<script src='../../Scripts/Resource/1066.js'></script>";
            }
            else
            {
                strHtml += @"<script src='../../Scripts/Resource/1033.js'></script>";
            }
            strHtml += @"<link rel='stylesheet' href='https://kendo.cdn.telerik.com/2023.1.117/styles/kendo.default-ocean-blue.min.css' />";
            Controls.Add(new LiteralControl(strHtml));
        }
    }
}