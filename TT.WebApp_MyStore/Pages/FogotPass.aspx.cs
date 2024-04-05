using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Commons;
using TT.WebApp_MyStore.Controllers;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Pages
{
    public partial class FogotPass : System.Web.UI.Page
    {
        UserController DBUser = new UserController();
        UserModel currUser = new UserModel();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string SecretID = Page.Request.QueryString["SecretID"] + string.Empty;
                if (!string.IsNullOrEmpty(SecretID))
                {
                    UserModel user = new UserModel();
                    PublicFunction pbFunction = new PublicFunction();
                    user = user.SelectAll().Where(a => a.KeyChangePass == SecretID).FirstOrDefault();
                    if (user != null)
                    {
                        currUser = user;
                        bodySentMail.Visible = false;
                        bodyContent.Visible = true;
                        OverTimeMess.Visible = false;
                    }
                    else
                    {
                        bodySentMail.Visible = false;
                        bodyContent.Visible = false;
                        OverTimeMess.Visible = true;
                    }
                }
                else
                {
                    bodyContent.Visible = false;
                    OverTimeMess.Visible = false;
                    spWarningCompleted.Visible = false;
                }
            }
            
        }
        protected void btnCheckEmail_Click(object sender, EventArgs e)
        {

            UserModel user = new UserModel();
            PublicFunction pbFunction = new PublicFunction();
            
            user = user.SelectAll().Where(a => (a.AccountName == txtEmail.Value || a.Email == txtEmail.Value)).FirstOrDefault();
            if (user != null)
            {
                user.KeyChangePass = user.ID.ToString() + DateTime.Now.ToString("yyyyMMddHHmmss");
                user.Update(user);
                string link = Request.Url.AbsoluteUri + "?SecretID=" + user.KeyChangePass;
                DBUser.Sentmail("Đổi mật khẩu", user.Email, link);
                spWarningCompleted.Visible = true;
            }
            else
            {
                string strScript = @"<script>$('#messerror').text('Tên đăng nhập/ Email không tồn tại!'); setTimeout(function () { $('#messerror').html(''); }, 4000);</script>";
                Controls.Add(new LiteralControl(strScript));
            }
        }
        protected void btnChangePass_Click(object sender, EventArgs e)
        {
           
            PublicFunction pbFunction = new PublicFunction();
            string strNewPass = pbFunction.EncryptString(txtNewPassWord.Value);
            string strNewPassAgain = pbFunction.EncryptString(txtNewPassAgain.Value);
            if (strNewPassAgain == strNewPass)
            {
                currUser.KeyChangePass = null;
                currUser.Update(currUser);
                DBUser.UpdateChangePass(currUser.ID, strNewPass);
                string strScript = @"<script>alert('Đổi mật khẩu thành công!')</script>";
                Controls.Add(new LiteralControl(strScript));
                Response.Redirect("/Pages/Home.aspx");
            }
            else
            {
                string strScript = @"<script>$('#messerror').text('Nhập lại mật khẩu mới không trùng khớp!'); setTimeout(function () { $('#messerror').html(''); }, 4000);</script>";
                Controls.Add(new LiteralControl(strScript));
            }
        }
    }
}