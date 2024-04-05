using Newtonsoft.Json;
using System;
using System.Web.Security;
using System.Web.UI;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Pages.MasterPages
{
    public partial class DefaultMasterPages : System.Web.UI.MasterPage
    {
        protected void Page_Init(object sender, EventArgs e)
        {
            //if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
            //    Response.Redirect("/Pages/Login.aspx");
        }

        protected void SignOut(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
        }
    }
}