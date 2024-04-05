using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TT.WebApp_MyStore.Pages.MailTemplateSetting
{
    public partial class InsUpdMailTemplate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");
            string _lang = Context.Session["LanguageId"] != null && !string.IsNullOrEmpty(Context.Session["LanguageId"] + string.Empty) ? Context.Session["LanguageId"] + string.Empty : "1066";
            if (_lang != "1066")
            {
                lbTitle.InnerText = "Tiêu đề";
                lbModule.InnerText = "Hạng mục";
                lbBody.InnerText = "Tiêu đề mail";
                lbSubject.InnerText = "Nội dung mail";
                lbThamSoBody.InnerText = "Tham số tiêu đề";
                lbThamSoSubject.InnerText = "Tham số nội dung";
                btnSave.Value = "Lưu";
                UpdateInfo.InnerText = "Thông tin chung";
            }
            else
            {
                lbTitle.InnerText = "Title";
                lbModule.InnerText = "Module";
                lbBody.InnerText = "Body";
                lbSubject.InnerText = "Subject";
                lbThamSoBody.InnerText = "Body Param";
                lbThamSoSubject.InnerText = "Subject Param";
                btnSave.Value = "Save";
                UpdateInfo.InnerText = "Infomation";
            }
        }
    }
}