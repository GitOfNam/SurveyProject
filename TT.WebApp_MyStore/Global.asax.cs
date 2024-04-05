using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using TT.WebApp_MyStore.Areas;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore
{
    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            //RoleMasterModel role = new RoleMasterModel();
            //if (role.SelectAll().Count() == 0)
            //{
            //    var RoleUser = new RoleMasterModel();
            //    var RoleAdmin = new RoleMasterModel();
            //    var RoleNoAccount = new RoleMasterModel();

            //    RoleAdmin.RoleName = "Admin";
            //    RoleAdmin.RoleUrl = "/Admin";
            //    RoleAdmin.Created = DateTime.Now;
            //    RoleAdmin.Insert(RoleAdmin);

            //    RoleUser.RoleName = "User";
            //    RoleUser.Created = DateTime.Now;
            //    RoleUser.Insert(RoleUser);

            //    RoleNoAccount.RoleName = "NoAccount";
            //    RoleNoAccount.Created = DateTime.Now;
            //    RoleNoAccount.Insert(RoleNoAccount);
            //}

            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
    }
}
