using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Pages
{
    public partial class InsertUpdateUser : System.Web.UI.Page
    {
        CmmFunc _db = new CmmFunc();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");
            string _lang = Context.Session["LanguageId"] != null && !string.IsNullOrEmpty(Context.Session["LanguageId"] + string.Empty) ? Context.Session["LanguageId"] + string.Empty : "1066";
            if (_lang == "1066")
            {
                lbAccountName.InnerText = "Tên tài khoản";
                lbFullName.InnerText = "Tên đầy đủ";
                lbGender.InnerText = "Giới tính";
                lbBirthDay.InnerText = "Ngày sinh";
                lbAddress.InnerText = "Địa chỉ";
                lbMobile.InnerText = "Số điện thoại";
                lbImage.InnerText = "Ảnh đại diện";
                lbPosition.InnerText = "Chức vụ";
                lbPermission.InnerText = "Quyền";
                lbStatus.InnerText = "Trạng thái";
                btnSave.Value = "Lưu";
                UpdateInfo.InnerText = "Thông tin chung";
            }
            else
            {
                lbAccountName.InnerText = "Account Name";
                lbFullName.InnerText = "Full Name";
                lbGender.InnerText = "Gender";
                lbBirthDay.InnerText = "BirthDay";
                lbAddress.InnerText = "Address";
                lbMobile.InnerText = "Mobile";
                lbImage.InnerText = "Image";
                lbPosition.InnerText = "Position";
                lbPermission.InnerText = "Permission";
                lbStatus.InnerText = "User Status";
                btnSave.Value = "Save";
                UpdateInfo.InnerText = "Infomation";
            }


        }
    }
}