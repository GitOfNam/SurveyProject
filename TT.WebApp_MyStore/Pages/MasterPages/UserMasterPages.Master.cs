using Newtonsoft.Json;
using System;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Pages.MasterPages
{
    public partial class UserMasterPages : System.Web.UI.MasterPage
    {
        CmmFunc _db = new CmmFunc();
        protected void Page_Init(object sender, EventArgs e)
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
            FullNameAcc.InnerText = user.FullName;
            BeanPosition bean = new BeanPosition();
            if (!string.IsNullOrEmpty(user.Position))
            {
                bean = bean.SelectAll().Where(s => s.PositionCode == user.Position).FirstOrDefault();
                Position.InnerText = bean.PositionName;
            }
            if (pageCurrentInfo.LanguageId == 1066)
            {
                NotifyText.InnerText = "Tất cả thông báo";
                ProfileText.InnerText = "Thông tin tài khoản";
                ProfileText.HRef = "/Pages/InsertUpdateUser.aspx?IDs=" + user.ID + "&Per=" + user.Permission;
                PrivacySetting.InnerText = "Đổi mật khẩu";
                btnLogout.Text = "Đăng xuất";
                strHtml += @"<script src='../../Scripts/Resource/1066.js'></script>";
            }
            else
            {
                strHtml += @"<script src='../../Scripts/Resource/1033.js'></script>";
            }
            if(user.ImagePath != null)
            {
                string Url = "data:image/png;base64," + Convert.ToBase64String(user.ImagePath);
                strHtml += @"<script>$('#imgProfile')[0].src = '"+ Url + @"'</script>";
            }
            strHtml += @"<link rel='stylesheet' href='https://kendo.cdn.telerik.com/2023.1.117/styles/kendo.default-ocean-blue.min.css' />";
            Controls.Add(new LiteralControl(strHtml));
        }

        protected void SignOut(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            var strHtml = @"<script>window.location.reload();</script>";
            Controls.Add(new LiteralControl(strHtml));
        }
    }
}