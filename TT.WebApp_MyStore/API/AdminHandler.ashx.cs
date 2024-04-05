using Microsoft.VisualBasic.ApplicationServices;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using TT.WebApp_MyStore.Controllers;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.API
{
    /// <summary>
    /// Summary description for AdminHandler
    /// </summary>
    public class AdminHandler : IHttpHandler, IRequiresSessionState
    {

        CmmFunc _db = new CmmFunc();
        public bool IsReusable => true;
        private static class PRA_KEYNAME
        {
            public static readonly string FUNC = "func"; // Function sẽ lấy dữ liệu
            public static readonly string POST_DATA = "data"; // postData
            public static readonly string TBL = "tbl"; // Table cua resource
        }

        public void ProcessRequest(HttpContext context)
        {
            object retData = null;
            AdminController DBAdmin = new AdminController();
            var resStatus = RESPONES_STATE.NONE;
            var errMess = default(KeyValuePair<string, string>);
            var retDate = DateTime.Now;
            var func = PAR(context, PRA_KEYNAME.FUNC);
            try
            {
                var strPostData = PAR(context, PRA_KEYNAME.POST_DATA);
                var tbl = PAR(context, PRA_KEYNAME.TBL);
                if (resStatus == RESPONES_STATE.NONE)
                {
                    UserModel CurrentUser = _db.getDataLogin();
                    if(CurrentUser == null)
                        context.Response.Redirect("/Pages/Login.aspx");

                    var a = context.Session["LanguageId"] + "";
                    var LanguageId = !String.IsNullOrEmpty(context.Session["LanguageId"] + "") ? Convert.ToInt32(context.Session["LanguageId"] + "") : 1066;
                    resStatus = RESPONES_STATE.ERR;
                    switch (tbl)
                    {

                        #region MenuSettings 
                        case "MenuSettings":
                            {
                            switch (func)
                            {
                                #region Get All
                                case "GetAll":
                                    {
                                        retData = DBAdmin.MenuSettingsGetAll(LanguageId);
                                        resStatus = RESPONES_STATE.SUCCESS;
                                        break;
                                    }
                                    #endregion

                                #region SetSelectMenu
                                case "SetSelectMenu":
                                    {
                                        if (String.IsNullOrEmpty(strPostData))
                                        {
                                            return;
                                        }
                                        var MenuSelected = new
                                        {
                                            Parent = default(string),
                                            Selected = default(string),
                                            ClearMenu = default(bool),
                                        };

                                        MenuSelected = JsonConvert.DeserializeAnonymousType(strPostData, MenuSelected);
                                        if(MenuSelected.ClearMenu == true)
                                        {
                                            context.Session["MenuParent"] = "";
                                            context.Session["MenuSelected"] = "";
                                        }
                                        else
                                        {
                                            context.Session["MenuParent"] = MenuSelected.Parent;
                                            context.Session["MenuSelected"] = MenuSelected.Selected;
                                        }
                                        resStatus = RESPONES_STATE.SUCCESS;
                                        break;
                                    }
                                #endregion
                                }
                            }
                        break;
                        #endregion

                        #region User 
                        case "User":
                            {
                                switch (func)
                                {
                                    #region Update LanguageId 
                                    case "UpdateLanguageId":
                                        {
                                            UserModel UserUpdate = new UserModel();
                                            UserUpdate.ID = CurrentUser.ID;
                                            UserUpdate = UserUpdate.SelectByID(UserUpdate.ID);
                                            UserUpdate.LanguageId = LanguageId == 1066 ? 1033 : 1066;
                                            UserUpdate.Update(UserUpdate);
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                }
                            }
                            break;
                        #endregion

                        #region Manga 
                        case "Manga":
                            {
                                switch (func)
                                {
                                    #region Get All
                                    case "GetAll":
                                        {
                                            //var a = PAR(context, "data");
                                            //retData = DBAdmin.GetAll();
                                            //resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                }
                            }
                        break;
                        #endregion
                    }
                }
            }
            catch (Exception ex)
            {
                resStatus = RESPONES_STATE.ERR;
                errMess = new KeyValuePair<string, string>("199", ex.Message);
            }
            try
            {
                ReponseData(context, retData, resStatus, errMess, retDate);
            }
            catch (Exception ex)
            { }
        }

        public string PAR(HttpContext context, string keyName)
        {
            string retValue = "";

            if (context.Request.Params[keyName] != null)
            {
                retValue = context.Request.Params[keyName].ToString();
            }
            return retValue;
        }

        public virtual void ReponseData(HttpContext context, object data, RESPONES_STATE status = RESPONES_STATE.SUCCESS, KeyValuePair<string, string> mess = default(KeyValuePair<string, string>), DateTime dateNow = default(DateTime), object moreData = null)
        {
            if (dateNow == default(DateTime))
            {
                dateNow = DateTime.Now;
            }

            RES_DATA retData = new RES_DATA();
            retData.status = status.ToString();
            retData.mess = mess;
            retData.data = data;
            retData.dateNow = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.Write(JsonConvert.SerializeObject(retData));
            context.Response.Flush();
            context.ApplicationInstance.CompleteRequest();
        }

        public enum RESPONES_STATE
        {
            SUCCESS = 1,
            MESSAGE = 0,
            ERR = -1,
            NONE = 2
        }

        public class RES_DATA
        {
            public string status { get; set; }
            public KeyValuePair<string, string> mess { get; set; }
            public object data { get; set; }
            public string dateNow { get; set; }
        }
    }
}
