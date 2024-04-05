using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TT.WebApp_MyStore.Pages
{
    public partial class ChangePass : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");
            string _lang = Context.Session["LanguageId"] != null && !string.IsNullOrEmpty(Context.Session["LanguageId"] + string.Empty) ? Context.Session["LanguageId"] + string.Empty : "1066";
            if (_lang != "1066")
            {
                lbNewPassAgain.InnerText = "New Password Again";
                lbOldPassWord.InnerText = "Old Password";
                lbNewPassWord.InnerText = "New Password";
                btnSave.Value = "Save";
            }
        }
    }
}