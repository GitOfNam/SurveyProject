using System;
using System.Web.Security;
using System.Web;
using TT.WebApp_MyStore.Models;
using System.Linq;
using System.Web.UI;
using Newtonsoft.Json;
using TT.WebApp_MyStore.Commons;
using TT.WebApp_MyStore.Areas;

namespace TT.WebApp_MyStore.Pages
{
    public partial class Login : System.Web.UI.Page
    {
        private void Page_Load(object sender, System.EventArgs e)
        {
            if (!IsPostBack)
            {
                
            }
        }
        protected void btnLogin_Click(object sender, EventArgs e)
        {
           
            UserModel user = new UserModel();
            PublicFunction pbFunction = new PublicFunction();
            string passEncrypt = pbFunction.EncryptString(Password.Value);
            user = user.SelectAll().Where(a => (a.AccountName == UserName.Value || a.Email == UserName.Value) && a.Password == passEncrypt).FirstOrDefault();
            if (user != null)
            {
                Session.Clear();
                user.ImagePath = null;
                var Ticket = new FormsAuthenticationTicket(1, name: user.AccountName, DateTime.Now, DateTime.Now.AddMinutes(100), true, JsonConvert.SerializeObject(user));
                Session["FullName"] = user.FullName;
                string Encrypt = FormsAuthentication.Encrypt(Ticket);
                var cookie = new HttpCookie(FormsAuthentication.FormsCookieName, Encrypt);
                cookie.HttpOnly = true;
                Response.Cookies.Add(cookie);
                Response.Redirect("/Pages/Home.aspx");
            }
        }
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            //#region Đăng ký ICallback, ICallbackEventHandler
            //String cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiverDiagram", "context");
            //String callbackScript = "function CallDiagram(arg, context)" + "{ " + cbReference + ";}";
            //Page.ClientScript.RegisterClientScriptBlock(GetType(), "Diagram", callbackScript, true);
            //#endregion
            if (!string.IsNullOrEmpty(txtEmail.Value))
            {
                UserModel user = new UserModel();
                PublicFunction pbFunction = new PublicFunction();
                string strHTML = "";
                var checklUser = user.SelectAll().Where(a => a.Email == txtEmail.Value).FirstOrDefault();
                if (checklUser != null)
                {
                    strHTML = @"<script>alert('Tài khoản này đã tồn tại!');</script>";
                }
                else
                {
                    user.ID = Guid.NewGuid();
                    user.Email = txtEmail.Value;
                    user.AccountName = txtEmail.Value;
                    user.FullName = txtFullName.Value;
                    user.Address = "";
                    user.Gender = true;
                    user.UserStatus = 1;
                    string passEncrypt = pbFunction.EncryptString(txtPass.Value.Trim());
                    user.Password = passEncrypt;
                    user.UserModified = DateTime.Now;
                    user.Permission = "NhanVien";
                    user.Insert(user);
                    BeanPermission setPer = new BeanPermission();
                    setPer.AssignTo = user.ID;
                    setPer.TableRelated = "SurveyTable";
                    setPer.SurveyTableID = user.ID;
                    setPer.IsSetting = true;
                    setPer.Permission = "NhanVien";
                    setPer.Created = setPer.Modified = DateTime.Now;
                    setPer.CreatedBy = setPer.ModifiedBy = user.ID;
                    setPer.Insert(setPer);
                    txtEmail.Value = "";
                    txtFullName.Value = "";
                    txtPass.Value = "";
                    strHTML = @"<script>alert('Thành công !'); window.location.reload();</script>";
                }

                Controls.Add(new LiteralControl(strHTML));
            }
            
        }
        
        #region CallbackEvent
        string strReturn = "";
        public void RaiseCallbackEvent(string eventArgument)
        {
            string[] arr = eventArgument.Split('#');
            if (!string.IsNullOrEmpty(arr[0]))
            {
                switch (arr[0])
                {
                    case "click":
                        {
                            strReturn = "ok";
                            break;
                        }
                }
            }
        }

        public string GetCallbackResult()
        {
            return strReturn;
        }
        #endregion
    }
}