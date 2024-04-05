using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TT.WebApp_MyStore.Pages.GroupSetting
{
    public partial class InsertUpdateGroup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");
            string _lang = Context.Session["LanguageId"] != null && !string.IsNullOrEmpty(Context.Session["LanguageId"] + string.Empty) ? Context.Session["LanguageId"] + string.Empty : "1066";
            if (_lang == "1066")
            {
                lbTitle.InnerText = "Tiêu đề";
                lbStatus.InnerText = "Trạng thái";
                lbUserOnGroup.InnerText = "Nhân viên trong nhóm";
                lbIsManager.InnerText = "Nhóm quản trị";
                btnSave.Value = "Lưu";
                UpdateInfo.InnerText = "Thông tin chung";
            }
            else
            {
                lbTitle.InnerText = "Title";
                lbUserOnGroup.InnerText = "User on group";
                lbIsManager.InnerText = "Manager Group";
                lbStatus.InnerText = "Status";
                btnSave.Value = "Save";
                UpdateInfo.InnerText = "Infomation";
            }
        }
    }
}