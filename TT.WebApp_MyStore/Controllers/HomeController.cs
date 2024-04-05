using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Controllers
{
    public class HomeController : Controller
    {
        CmmFunc _db = new CmmFunc();
        public ActionResult Index()
        {
            UserModel user = _db.getDataLogin();
            if (user == null)
            {
                return Redirect("/Pages/Login.aspx");
            }
            else
            {
                //RoleMasterModel roleMaster = new RoleMasterModel();
                //roleMaster = roleMaster.SelectByID(user.RoleId);
                return Redirect("/Pages/Home.aspx");
            }        
        }
    }
}
