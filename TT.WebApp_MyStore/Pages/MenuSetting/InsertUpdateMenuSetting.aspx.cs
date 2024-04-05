using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Pages.MenuSetting
{
    public partial class InsertUpdateMenuSetting : System.Web.UI.Page
    {
        CmmFunc _db = new CmmFunc();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");
            string _lang = Context.Session["LanguageId"] != null && !string.IsNullOrEmpty(Context.Session["LanguageId"] + string.Empty) ? Context.Session["LanguageId"] + string.Empty : "1066";
            if (_lang == "1066")
            {
                lbTitle.InnerText = "Tiêu đề tiếng Việt";
                lbTitleEN.InnerText = "Tiêu đề tiếng Anh";
                lbUrl.InnerText = "Đường dẫn";
                lbParentID.InnerText = "Mục cha";
                lbIcon.InnerText = "Biểu tượng";
                lbExpanded.InnerText = "Mở rộng";
                lbIndex.InnerText = "Thứ tự";
                lbStatus.InnerText = "Trạng thái";
                btnSave.Value = "Lưu";
                UpdateInfo.InnerText = "Thông tin chung";
            }
            else
            {
                lbTitle.InnerText = "Title";
                lbTitleEN.InnerText = "TitleEN";
                lbUrl.InnerText = "Url";
                lbParentID.InnerText = "Parent Menu";
                lbIcon.InnerText = "Icon";
                lbExpanded.InnerText = "Expanded";
                lbIndex.InnerText = "Index";
                lbStatus.InnerText = "Status";
                btnSave.Value = "Save";
                UpdateInfo.InnerText = "Infomation";
            }

        }
    }
}