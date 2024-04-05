using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using TT.WebApp_MyStore.Commons;
using TT.WebApp_MyStore.Controllers;
using TT.WebApp_MyStore.Models;
using excel = Microsoft.Office.Interop.Excel;

namespace TT.WebApp_MyStore.API
{
    public class UserHandler : IHttpHandler, IRequiresSessionState
    {

        CmmFunc _db = new CmmFunc();
        public bool IsReusable => true;
        private static class PRA_KEYNAME
        {
            public static readonly string FUNC = "func"; // Function sẽ lấy dữ liệu
            public static readonly string POST_DATA = "data"; // postData
            public static readonly string TBL = "tbl"; // Table cua resource
            public static readonly string IDs = "IDs"; // Table cua resource
            public static readonly string Active = "active"; // Table cua resource
        }

        public void ProcessRequest(HttpContext context)
        {
            object retData = null;
            bool isDownload = false;
            UserController DBUser = new UserController();
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
                    if (CurrentUser == null)
                        context.Response.Redirect("/Pages/Login.aspx");
          
                    var LanguageId = !String.IsNullOrEmpty(context.Session["LanguageId"] + "") ? Convert.ToInt32(context.Session["LanguageId"] + "") : 1066;
                    resStatus = RESPONES_STATE.ERR;
                    switch (tbl)
                    {
                        #region System 
                        case "System":
                            {
                                switch (func)
                                {
                                    case "getDataChartHome":
                                        {
                                            try
                                            {
                                                int overdue = 0;
                                                int completedToday = 0;
                                                int continued = 0;
                                                int completed = 0;
                                                int inprocess = 0;
                                                int UnCompleted = 0;
                                                List<DataChart> lstChart = new List<DataChart>();
                                                DataTable dataChart = DBUser.GetCountChart(CurrentUser.ID.ToString());
                                                if (dataChart != null && dataChart.Rows.Count > 0)
                                                {
                                                    DataChart itemChart = new DataChart();
                                                    itemChart.category = "Trễ hạn";
                                                    itemChart.value = Convert.ToInt32(dataChart.Rows[0]["overdue"] + string.Empty);
                                                    lstChart.Add(itemChart);
                                                    itemChart = new DataChart();
                                                    itemChart.category = "Hoàn tất hôm nay";
                                                    itemChart.value = Convert.ToInt32(dataChart.Rows[0]["completedToday"] + string.Empty);
                                                    lstChart.Add(itemChart);
                                                    itemChart = new DataChart();
                                                    itemChart.category = "Sắp tới";
                                                    itemChart.value = Convert.ToInt32(dataChart.Rows[0]["continued"] + string.Empty);
                                                    lstChart.Add(itemChart);
                                                    overdue = Convert.ToInt32(dataChart.Rows[0]["overdue"] + string.Empty);
                                                    completedToday = Convert.ToInt32(dataChart.Rows[0]["completedToday"] + string.Empty);
                                                    continued = Convert.ToInt32(dataChart.Rows[0]["continued"] + string.Empty);
                                                    completed = Convert.ToInt32(dataChart.Rows[0]["completed"] + string.Empty);
                                                    inprocess = Convert.ToInt32(dataChart.Rows[0]["inprocess"] + string.Empty);
                                                    UnCompleted = Convert.ToInt32(dataChart.Rows[0]["unCompleted"] + string.Empty);
                                                }

                                                retData = new { lstChart = lstChart, completed = completed, inprocess = inprocess, UnCompleted = UnCompleted, overdue= overdue, completedToday= completedToday, continued= continued };
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #region SearchAPI
                                    case "SearchAPI":
                                        {
                                            string errMes = "";
                                            try
                                            {
                                                SurveyController surveyController = new SurveyController();
                                                var PostObj = new
                                                {
                                                    Title = "",
                                                    Type = "",
                                                    Category = 0
                                                };
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                var Todate = PAR(context, "ToDate");
                                                var Fromdate = PAR(context, "FromDate");
                                                List<BeanSurveyTable> beanSurveyTables = surveyController.GetListSurveyByUserID(CurrentUser, ref errMes);
                                                if (!string.IsNullOrEmpty(PostObj.Title))
                                                    beanSurveyTables = beanSurveyTables.Where(s => s.Title.Contains(PostObj.Title)).ToList();
                                                if(PostObj.Category > 0)
                                                    beanSurveyTables = beanSurveyTables.Where(s => s.SCID == PostObj.Category).ToList();
                                                if (!string.IsNullOrEmpty(Fromdate))
                                                    beanSurveyTables = beanSurveyTables.Where(s => s.Created >= Convert.ToDateTime(Fromdate)).ToList();
                                                if (!string.IsNullOrEmpty(Todate))
                                                    beanSurveyTables = beanSurveyTables.Where(s => s.Created <= Convert.ToDateTime(Todate)).ToList();
                                                retData = beanSurveyTables;
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                        #endregion
                                }
                            }
                            break;
                        #endregion

                        #region MenuUsers 
                        case "MenuUsers":
                            {
                                switch (func)
                                {
                                    #region Get All
                                    case "GetAll":
                                        {
                                            retData = DBUser.MenuSettingsGetAll(LanguageId,CurrentUser);
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Menu
                                    case "GetListMenu":
                                        {
                                            MenuSettingModel menuSetting = new MenuSettingModel();
                                            retData = menuSetting.SelectAll(); 
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Delete Menu
                                    case "DeleteMenu":
                                        {
                                            if (!string.IsNullOrEmpty(strPostData))
                                            {
                                                string strData = JsonConvert.DeserializeObject<string>(strPostData);
                                                MenuSettingModel menuSetting = new MenuSettingModel();
                                                menuSetting = menuSetting.SelectByID(Convert.ToInt32(strData));
                                                menuSetting.Delete(menuSetting);
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Menu by ID 
                                    case "GetMenuByIDs":
                                        {
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                MenuSettingModel menuSetting = new MenuSettingModel();
                                                menuSetting = menuSetting.SelectByID(Convert.ToInt32(strIDs));
                                                retData = menuSetting;
                                            }
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
                                            if (MenuSelected.ClearMenu == true)
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
                                    #region Insert Update Menu 
                                    case "InsertUpdateMenu":
                                        {
                                            MenuSettingModel menuSetting = new MenuSettingModel();
                                            menuSetting = JsonConvert.DeserializeObject<MenuSettingModel>(strPostData);
                                            if (menuSetting.ID != 0)
                                            {
                                                MenuSettingModel menu = menuSetting.SelectByID(menuSetting.ID);
                                                menuSetting.Created = menu.Created;
                                                menuSetting.CreateBy = menu.CreateBy;
                                                menuSetting.Modified = menu.Modified;
                                                menuSetting.ModifiBy = menu.ModifiBy;
                                                menuSetting.Update(menuSetting);
                                                
                                            }
                                            else
                                            {
                                                menuSetting.Created = menuSetting.Modified = DateTime.Now;
                                                menuSetting.CreateBy = menuSetting.ModifiBy = CurrentUser.ID.ToString();
                                                menuSetting.Insert(menuSetting);
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
                                    #region Get List User 
                                    case "GetListUser":
                                        {
                                            retData = DBUser.GetListUser();
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get Position 
                                    case "GetPosition":
                                        {
                                            BeanPosition bean = new BeanPosition();
                                            retData = bean.SelectAll();
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List User 
                                    case "GetUserByIDs":
                                        {
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                UserModel User = new UserModel();
                                                User = User.SelectByID(Guid.Parse(strIDs));
                                                if (User.ImagePath != null)
                                                {
                                                    string Url = "data:image/png;base64," + Convert.ToBase64String(User.ImagePath);
                                                    User.Image = Url;
                                                }
                                                retData = User;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Delete User
                                    case "DeleteUser":
                                        {
                                            if (!string.IsNullOrEmpty(strPostData))
                                            {
                                                string strData = JsonConvert.DeserializeObject<string>(strPostData);
                                                UserModel User = new UserModel();
                                                User = User.SelectByID(Guid.Parse(strData));
                                                User.Delete(User);
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Insert Update User 
                                    case "InsertUpdateUser":
                                        {
                                            byte[] bytes = null;
                                            PublicFunction pbFunction = new PublicFunction();
                                            UserModel User = new UserModel();
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            //var PostObj = new { dataUser = "", Group = "" };
                                            if (HttpContext.Current.Request.Files.Count > 0)
                                            {

                                                var file = HttpContext.Current.Request.Files[0];
                                                System.IO.Stream fs = file.InputStream;
                                                System.IO.BinaryReader br = new System.IO.BinaryReader(fs);
                                                bytes = br.ReadBytes((Int32)fs.Length);
                                            }
                                            UserModel UserUpdate = JsonConvert.DeserializeObject<UserModel>(strPostData);
                                            if (bytes != null)
                                                UserUpdate.ImagePath = bytes;
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                UserUpdate.ID = Guid.Parse(strIDs);
                                                User = UserUpdate.SelectByID(UserUpdate.ID);
                                                UserUpdate.Department = !string.IsNullOrEmpty(UserUpdate.Department) ? UserUpdate.Department : User.Department;
                                                UserUpdate.DepartmentID = !string.IsNullOrEmpty(UserUpdate.DepartmentID +string.Empty) ? UserUpdate.DepartmentID : User.DepartmentID;
                                                UserUpdate.Manager = !string.IsNullOrEmpty(UserUpdate.Manager) ? UserUpdate.Manager : User.Manager;
                                                UserUpdate.BirthDay = !string.IsNullOrEmpty(UserUpdate.BirthDay +string.Empty) ? UserUpdate.BirthDay : User.BirthDay;
                                                UserUpdate.Address = !string.IsNullOrEmpty(UserUpdate.Address) ? UserUpdate.Address : User.Address;
                                                UserUpdate.IsRanking = User.IsRanking;
                                                UserUpdate.ImagePath = UserUpdate.ImagePath != null ? UserUpdate.ImagePath: User.ImagePath;
                                                UserUpdate.Position = !string.IsNullOrEmpty(UserUpdate.Position) ? UserUpdate.Position : User.Position;
                                                UserUpdate.Mobile = !string.IsNullOrEmpty(UserUpdate.Mobile) ? UserUpdate.Mobile : User.Mobile;
                                                UserUpdate.Permission = !string.IsNullOrEmpty(UserUpdate.Permission) ? UserUpdate.Permission : User.Permission;
                                                if(!string.IsNullOrEmpty(UserUpdate.Permission) && UserUpdate.Permission != User.Permission)
                                                {
                                                    BeanPermission setPer = new BeanPermission();
                                                    setPer = setPer.SelectAll().Where(s => s.AssignTo == UserUpdate.ID && s.TableRelated == "SurveyTable" && s.IsSetting == true).FirstOrDefault();
                                                    if(setPer != null)
                                                    {
                                                        setPer.Permission = UserUpdate.Permission;
                                                        setPer.Modified = DateTime.Now;
                                                        setPer.ModifiedBy = CurrentUser.ID;
                                                        setPer.Update(setPer);
                                                    }
                                                    else
                                                    {
                                                        BeanPermission newPer = new BeanPermission();
                                                        newPer.AssignTo = UserUpdate.ID;
                                                        newPer.TableRelated = "SurveyTable";
                                                        newPer.SurveyTableID = UserUpdate.ID;
                                                        newPer.IsSetting = true;
                                                        newPer.Permission = UserUpdate.Permission;
                                                        newPer.Created = newPer.Modified = DateTime.Now;
                                                        newPer.CreatedBy = newPer.ModifiedBy = CurrentUser.ID;
                                                        newPer.Insert(newPer);
                                                    }
                                                }
                                                UserUpdate.Password = User.Password;
                                                UserUpdate.LanguageId = User.LanguageId;
                                                UserUpdate.UserModified = DateTime.Now;
                                                UserUpdate.Update(UserUpdate);
                                               
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            else
                                            {
                                                var checklUser = User.SelectAll().Where(a => a.AccountName == UserUpdate.AccountName || a.Email == UserUpdate.Email).FirstOrDefault();
                                                if (checklUser != null)
                                                {
                                                    errMess = new KeyValuePair<string, string>("199", LanguageId == 1066 ? "Tên tài khoản hoặc email đã tồn tại!" : "Account Name or Email is existed!");
                                                    resStatus = RESPONES_STATE.ERR;
                                                }
                                                else
                                                {
                                                    UserUpdate.ID = Guid.NewGuid();
                                                    UserUpdate.Password = pbFunction.EncryptString("123");
                                                    UserUpdate.UserModified = DateTime.Now;
                                                    UserUpdate.LanguageId = 1066;
                                                    UserUpdate.Insert(UserUpdate);
                                                    BeanPermission setPer = new BeanPermission();
                                                    setPer.AssignTo = UserUpdate.ID;
                                                    setPer.TableRelated = "SurveyTable";
                                                    setPer.SurveyTableID = UserUpdate.ID;
                                                    setPer.IsSetting = true;
                                                    setPer.Permission = UserUpdate.Permission;
                                                    setPer.Created = setPer.Modified = DateTime.Now;
                                                    setPer.CreatedBy = setPer.ModifiedBy = CurrentUser.ID;
                                                    setPer.Insert(setPer);
                                                    resStatus = RESPONES_STATE.SUCCESS;
                                                }
                                                
                                            }
                                            
                                            break;
                                        }
                                    #endregion
                                    #region Change PassWord
                                    case "ChangePassWord":
                                        {
                                            try
                                            {
                                                PublicFunction pbFunction = new PublicFunction();
                                                var PostObj = new
                                                {
                                                    OldPass= "",
                                                    NewPass= "",
                                                    NewPassAgain= ""
                                                };
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                string strOldPass = pbFunction.EncryptString(PostObj.OldPass);
                                                string strNewPass = pbFunction.EncryptString(PostObj.NewPass);
                                                string strNewPassAgain = pbFunction.EncryptString(PostObj.NewPassAgain);
                                                if (CurrentUser.Password == strOldPass)
                                                {
                                                    if(strNewPassAgain == strNewPass)
                                                    {
                                                        DBUser.UpdateChangePass(CurrentUser.ID, strNewPass);
                                                        resStatus = RESPONES_STATE.SUCCESS;
                                                    }
                                                    else
                                                    {
                                                        retData = "Nhập lại mật khẩu mới không trùng khớp!";
                                                        resStatus = RESPONES_STATE.ERR;
                                                    }
                                                }
                                                else
                                                {
                                                    retData = "Mật khẩu cũ không trùng khớp!";
                                                    resStatus = RESPONES_STATE.ERR;
                                                }
                                            }
                                            catch
                                            {
                                                retData = "Có lỗi xảy ra trong quá trình lưu, liên hệ kĩ thuật để giải quyết!";
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            
                                            break;
                                        }
                                        #endregion
                                }
                            }
                            break;
                        #endregion

                        #region Notify
                        case "Notify":
                            {
                                switch (func)
                                {
                                    #region SetMenuNotify 
                                    case "SetMenuNotify":
                                        {
                                            string rowLimit = PAR(context, "rowLimit");
                                            if(!string.IsNullOrEmpty(rowLimit))
                                                retData = DBUser.GetListNotify(CurrentUser.ID.ToString(),rowLimit);
                                            else
                                                retData = DBUser.GetListNotify(CurrentUser.ID.ToString());
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region SetMenuNotifyAll 
                                    case "SetMenuNotifyAll":
                                        {
                                            retData = DBUser.GetListNotify(CurrentUser.ID.ToString(),"");
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region GetCountTask 
                                    case "GetCountTask":
                                        {
                                            int numT = DBUser.GetCountNotify(CurrentUser.ID.ToString());
                                            if (numT > 99)
                                                numT = 99;
                                            retData = new { NumTask = numT};
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion

                                }
                            }
                            break;
                        #endregion

                        #region GroupConfig 
                        case "GroupConfig":
                            {
                                switch (func)
                                {
                                    #region Get List Group
                                    case "GetListGroup":
                                        {
                                            BeanGroup menuSetting = new BeanGroup();
                                            retData = menuSetting.SelectAll();
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Delete Group
                                    case "DeleteGroup":
                                        {
                                            if (!string.IsNullOrEmpty(strPostData))
                                            {
                                                string strData = JsonConvert.DeserializeObject<string>(strPostData);
                                                BeanGroup menuBeanGroup = new BeanGroup();
                                                menuBeanGroup = menuBeanGroup.SelectByID(Convert.ToInt32(strData));
                                                menuBeanGroup.Delete(menuBeanGroup);
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Group  by IDs
                                    case "GetGroupByIDs":
                                        {
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanGroup Group = new BeanGroup();
                                                Group = Group.SelectByID(Guid.Parse(strIDs));
                                                retData = Group;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Insert Update Group 
                                    case "InsertUpdateGroup":
                                        {
                                            BeanGroup menuBeanGroup = new BeanGroup();
                                            BeanGroup BeanGroupUpdate = new BeanGroup();
                                            PublicFunction pbFunction = new PublicFunction();
                                            BeanGroupUpdate = JsonConvert.DeserializeObject<BeanGroup>(strPostData);
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanGroupUpdate.ID = Guid.Parse(strIDs);
                                                menuBeanGroup = menuBeanGroup.SelectByID(BeanGroupUpdate.ID);
                                                BeanGroupUpdate.TitleEN = pbFunction.ConvertTVKhongDauVietLien(BeanGroupUpdate.Title);
                                                BeanGroupUpdate.Created = menuBeanGroup.Created;
                                                BeanGroupUpdate.CreatedBy = menuBeanGroup.CreatedBy;
                                                BeanGroupUpdate.Modified = DateTime.Now;
                                                BeanGroupUpdate.ModifyBy = menuBeanGroup.ModifyBy;
                                                BeanGroupUpdate.Update(BeanGroupUpdate);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            else
                                            {
                                                BeanGroupUpdate.ID = Guid.NewGuid();
                                                BeanGroupUpdate.TitleEN = pbFunction.ConvertTVKhongDauVietLien(BeanGroupUpdate.Title);
                                                BeanGroupUpdate.Created = BeanGroupUpdate.Modified = DateTime.Now;
                                                BeanGroupUpdate.CreatedBy = BeanGroupUpdate.ModifyBy = CurrentUser.ID;
                                                BeanGroupUpdate.Insert(BeanGroupUpdate);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                        #endregion
                                }
                            }
                            break;
                        #endregion

                        #region MailTemplate 
                        case "MailTemplate":
                            {
                                switch (func)
                                {
                                    #region Get List MailTemplate
                                    case "GetListMailTemplate":
                                        {
                                            BeanMailTemplate MailTemplateSetting = new BeanMailTemplate();
                                            retData = MailTemplateSetting.SelectAll();
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Delete MailTemplate
                                    case "DeleteMailTemplate":
                                        {
                                            if (!string.IsNullOrEmpty(strPostData))
                                            {
                                                string strData = JsonConvert.DeserializeObject<string>(strPostData);
                                                BeanMailTemplate MailTemplateSetting = new BeanMailTemplate();
                                                MailTemplateSetting = MailTemplateSetting.SelectByID(Convert.ToInt32(strData));
                                                MailTemplateSetting.Delete(MailTemplateSetting);
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Group 
                                    case "GetMailTemplateByIDs":
                                        {
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanMailTemplate MailTemplateSetting = new BeanMailTemplate();
                                                MailTemplateSetting = MailTemplateSetting.SelectByID(Convert.ToInt32(strIDs));
                                                retData = MailTemplateSetting;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Insert Update Group 
                                    case "InsertUpdateMailTemplate":
                                        {
                                            BeanMailTemplate menuMailTemplate = new BeanMailTemplate();
                                            BeanMailTemplate BeanMailTemplateUpdate = new BeanMailTemplate();
                                            PublicFunction pbFunction = new PublicFunction();
                                            BeanMailTemplateUpdate = JsonConvert.DeserializeObject<BeanMailTemplate>(strPostData);
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanMailTemplateUpdate.ID = Convert.ToInt32(strIDs);
                                                menuMailTemplate = menuMailTemplate.SelectByID(BeanMailTemplateUpdate.ID);
                                                BeanMailTemplateUpdate.SubjectEN = BeanMailTemplateUpdate.Subject;
                                                BeanMailTemplateUpdate.Created = menuMailTemplate.Created;
                                                BeanMailTemplateUpdate.CreatedBy = menuMailTemplate.CreatedBy;
                                                BeanMailTemplateUpdate.Modified = DateTime.Now;
                                                BeanMailTemplateUpdate.ModifyBy = CurrentUser.ID;
                                                BeanMailTemplateUpdate.Update(BeanMailTemplateUpdate);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            else
                                            {
                                                BeanMailTemplateUpdate.SubjectEN = BeanMailTemplateUpdate.Subject;
                                                BeanMailTemplateUpdate.Created = BeanMailTemplateUpdate.Modified = DateTime.Now;
                                                BeanMailTemplateUpdate.CreatedBy = BeanMailTemplateUpdate.ModifyBy = CurrentUser.ID;
                                                BeanMailTemplateUpdate.Insert(BeanMailTemplateUpdate);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                        #endregion
                                }
                            }
                            break;
                        #endregion

                        #region Survey 
                        case "Survey":
                            {
                                SurveyController surveyController = new SurveyController();
                                string errMes = "";
                                switch (func)
                                {
                                    case "DissectionExcel":
                                        {
                                            #region DissectionExcel
                                            string checkBug = "";
                                            HttpPostedFile postedFile = null;
                                            #region Validate data

                                            if (HttpContext.Current.Request.Files.Count == 0)
                                            {
                                                errMess = new KeyValuePair<string, string>("199", "Không tìm thấy file đính kèm!");
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            postedFile = HttpContext.Current.Request.Files[0];
                                            #endregion
                                            try
                                            {
                                                BeanSurveyTable surveyTable = new BeanSurveyTable();
                                                BeanSurveyPage surveyPage = new BeanSurveyPage();
                                                List<BeanSurveyPage> lstsurveyPage = new List<BeanSurveyPage>();
                                                List<BeanSurveyQuestion> lstBeanSurveyQuestion = new List<BeanSurveyQuestion>();
                                                using (Stream stream = postedFile.InputStream)
                                                {
                                                    int stt = 1;
                                                    string strFormat = "Lỗi định dạng tại ô {0} tại phần {1}. Vui lòng kiểm tra lại file nhập liệu.";
                                                    ExcelPackage pkg = new ExcelPackage(stream);
                                                    var wsSource = pkg.Workbook.Worksheets["Survey"];
                                                    if (wsSource.Dimension.Columns > 0 && wsSource.Dimension.Rows > 0)
                                                    {
                                                        //surveyTable.ID = Guid.NewGuid();
                                                        surveyTable.SCID = 1;
                                                        surveyTable.IsCalScore = false;
                                                        surveyTable.AllowMultipleResponses = false;
                                                        //1. Thông tin Chi tiết phiếu  -- Rows 1-3
                                                        surveyTable.Title = wsSource.Cells[1, 3].Value + string.Empty;
                                                        checkBug = string.Format(strFormat, "C2", "'I. Thông tin Chi tiết phiếu'");
                                                        surveyTable.Description = wsSource.Cells[2, 3].Value + string.Empty;
                                                        checkBug = string.Format(strFormat, "C3", "'I. Thông tin Chi tiết phiếu'");
                                                        surveyTable.StartDate = Convert.ToDateTime(wsSource.Cells[3, 3].Value + string.Empty);
                                                        checkBug = string.Format(strFormat, "E3", "'I. Thông tin Chi tiết phiếu'");
                                                        if(!string.IsNullOrEmpty(wsSource.Cells[3, 5].Value + string.Empty))
                                                        {
                                                            surveyTable.DueDate =  Convert.ToDateTime(wsSource.Cells[3, 5].Value + string.Empty);
                                                        }
                                                        checkBug = "";
                                                        string tableID = surveyController.SaveSurveyTable(CurrentUser, surveyTable, null, null, 0, ref errMes);
                                                        surveyTable.ID = Guid.Parse(tableID);
                                                        //Page
                                                        surveyPage.Title = "Trang 1";
                                                        surveyPage.SurveyTableId = surveyTable.ID;
                                                        surveyPage.Index = 1;
                                                        surveyPage.Status = 1;
                                                        lstsurveyPage.Add(surveyPage);
                                                        //2. Thông tin Chi tiết câu hỏi  -- Rows 6-50
                                                        for (int row = 6; row <= wsSource.Dimension.Rows; row++)
                                                        {
                                                            BeanSurveyQuestion beanSurveyQuestion = new BeanSurveyQuestion();
                                                            if (row >= 6 && row <= 50)
                                                            {
                                                                if(!string.IsNullOrEmpty(wsSource.Cells[row, 2].Value + string.Empty))
                                                                {
                                                                    beanSurveyQuestion.SurveyTableId = surveyTable.ID;
                                                                    beanSurveyQuestion.AnsweredCount = 0;
                                                                    beanSurveyQuestion.Page = 1;
                                                                    beanSurveyQuestion.DisableDoAgain = false;
                                                                    beanSurveyQuestion.IsScoring = false;
                                                                    beanSurveyQuestion.ValueCount = "0";
                                                                    beanSurveyQuestion.Description = "";
                                                                    beanSurveyQuestion.OtherValueCount = "0";
                                                                    beanSurveyQuestion.Index = stt;
                                                                    checkBug = string.Format(strFormat, "C" + row.ToString(), "'II. Thông tin Chi tiết câu hỏi'");
                                                                    beanSurveyQuestion.Title = wsSource.Cells[row, 3].Value + string.Empty;
                                                                    checkBug = string.Format(strFormat, "D" + row.ToString(), "'II. Thông tin Chi tiết câu hỏi'");
                                                                    if(wsSource.Cells[row, 4].Value + string.Empty == "Có")
                                                                        beanSurveyQuestion.Required = true;
                                                                    else
                                                                        beanSurveyQuestion.Required = false;
                                                                    checkBug = string.Format(strFormat, "E" + row.ToString(), "'II. Thông tin Chi tiết câu hỏi'");
                                                                    if (!string.IsNullOrEmpty(wsSource.Cells[row, 5].Value + string.Empty))
                                                                    {
                                                                        string[] mangBr = (wsSource.Cells[row, 5].Value + string.Empty).Split(new string[] { "\n" }, StringSplitOptions.RemoveEmptyEntries);
                                                                        foreach (string item in mangBr)
                                                                        {
                                                                            string[] mangOption = item.Split(new string[] { ":" }, StringSplitOptions.RemoveEmptyEntries);
                                                                            beanSurveyQuestion.Options = @"{""AllowMultipleLine"":" + mangOption[1] + @",""OtherComment"":null,""ValidateAnswer"":null}";
                                                                            //switch (mangOption[0])
                                                                            //{
                                                                            //    case "AllowMultipleLine":
                                                                            //        {
                                                                                        
                                                                            //        }
                                                                            //        break;
                                                                            //    case "Multiple Textboxes":
                                                                            //        {

                                                                            //        }
                                                                            //        break;
                                                                            //    case "Radio / Choice / Dropdown":
                                                                            //        {

                                                                            //        }
                                                                            //        break;
                                                                            //    case "Date / Time":
                                                                            //        {

                                                                            //        }
                                                                            //        break;
                                                                            //}
                                                                        }
                                                                    }
                                                                    checkBug = string.Format(strFormat, "B" + row.ToString(), "'II. Thông tin Chi tiết câu hỏi'");
                                                                    switch (wsSource.Cells[row, 2].Value + string.Empty)
                                                                    {
                                                                        case "Single Textbox":
                                                                            {
                                                                                beanSurveyQuestion.SQTId = 1;
                                                                            }
                                                                            break;
                                                                        case "Multiple Textboxes":
                                                                            {

                                                                            }
                                                                            break;
                                                                        case "Radio / Choice / Dropdown":
                                                                            {

                                                                            }
                                                                            break;
                                                                        case "Date / Time":
                                                                            {

                                                                            }
                                                                            break;
                                                                    }
                                                                    lstBeanSurveyQuestion.Add(beanSurveyQuestion);
                                                                    stt++;
                                                                }
                                                            }
                                                        }
                                                        checkBug = "";
                                                    } 
                                                    retData = surveyController.SaveActive(CurrentUser, surveyTable, lstBeanSurveyQuestion, lstsurveyPage, 0, ref errMes);
                                                    resStatus = RESPONES_STATE.SUCCESS;
                                                }
                                            }
                                            catch (Exception ex)
                                            {
                                                if (!string.IsNullOrEmpty(checkBug))
                                                    errMess = new KeyValuePair<string, string>("109", checkBug);// iLCID == 1066 ? "Định dạng ngày tháng không đúng. Vui lòng nhập đúng định dạng như tài liệu mẫu." : "Datetime format is error. Please, enter correct Datetime like template format."
                                                else
                                                    errMess = new KeyValuePair<string, string>("199", "Có lỗi xảy ra trong quá trình xử lý. Vui lòng thông báo cho quản trị viên.");
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            #endregion
                                            break;
                                        }
                                    #region Get List User 
                                    case "GetListUserAndGroup":
                                        {
                                            retData = DBUser.Get_UserAndGroup(CurrentUser.ID.ToString());
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get GetSurvey Category 
                                    case "GetSurveyCategory":
                                        {
                                            BeanSurveyCategory SurveyCategory = new BeanSurveyCategory();
                                            retData = SurveyCategory.SelectAll();
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Insert Update SurveyTable 
                                    case "InsertUpdateSurveyTable":
                                        {
                                            try
                                            {
                                                var PostObj = new
                                                {
                                                    BeanSurveyQuestion = new List<BeanSurveyQuestion>(),
                                                    BeanSurveyTable = new BeanSurveyTable(),
                                                    BeanSurveyPage = new List<BeanSurveyPage>(),
                                                    RankDaily = false,
                                                    RankAll = false,
                                                    IsActive = 0
                                                };
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                BeanSurveyTable SurveyTable = new BeanSurveyTable();
                                                //var strSurveyTableID = PAR(context, "surveyTableID");
                                                //var isActive = PAR(context, PRA_KEYNAME.Active);
                                                //BeanSurveyTable BeanSurveyTableUpdate = PostObj.BeanSurveyTable;
                                                retData = surveyController.SaveSurveyTable(CurrentUser,PostObj.BeanSurveyTable, PostObj.BeanSurveyQuestion, PostObj.BeanSurveyPage, PostObj.IsActive,ref errMes);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch(Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Active Survey 
                                    case "Active":
                                        {
                                            try
                                            {
                                                var PostObj = new
                                                {
                                                    BeanSurveyQuestion = new List<BeanSurveyQuestion>(),
                                                    BeanSurveyTable = new BeanSurveyTable(),
                                                    BeanSurveyPage = new List<BeanSurveyPage>(),
                                                    RankDaily = false,
                                                    RankAll = false,
                                                    IsActive = 0
                                                };
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                BeanSurveyTable SurveyTable = new BeanSurveyTable();
                                                retData = surveyController.SaveActive(CurrentUser, PostObj.BeanSurveyTable, PostObj.BeanSurveyQuestion, PostObj.BeanSurveyPage, PostObj.IsActive, ref errMes);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region UnActive Survey 
                                    case "UnActive":
                                        {
                                            try
                                            {
                                                var PostObj = new
                                                {
                                                    BeanSurveyQuestion = new List<BeanSurveyQuestion>(),
                                                    BeanSurveyTable = new BeanSurveyTable(),
                                                    BeanSurveyPage = new List<BeanSurveyPage>(),
                                                    RankDaily = false,
                                                    RankAll = false,
                                                    IsActive = 0
                                                };
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                BeanSurveyTable SurveyTable = new BeanSurveyTable();
                                                retData = surveyController.SaveUnActive(PostObj.BeanSurveyTable, ref errMes);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Get Data
                                    case "GetDataSurvey":
                                        {
                                            try
                                            {
                                                bool RankDaily = false, RankAll = false;
                                                var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                                if (!string.IsNullOrEmpty(strIDs))
                                                {
                                                    bool isPerrmiss = surveyController.CheckPermissionSurvey(CurrentUser, strIDs);
                                                    if (isPerrmiss)
                                                    {
                                                        BeanSurveyTable SurveyTable = new BeanSurveyTable();
                                                        SurveyTable = SurveyTable.SelectByID(Guid.Parse(strIDs));
                                                        BeanSurveyQuestion SurveyQuestions = new BeanSurveyQuestion();
                                                        List<BeanSurveyQuestion> lstSurveyQuestions = new List<BeanSurveyQuestion>();
                                                        lstSurveyQuestions = SurveyQuestions.SelectAll().Where(s => s.SurveyTableId == Guid.Parse(strIDs)).OrderBy(s => s.Index).ToList();
                                                        BeanSurveyPage SurveyPage = new BeanSurveyPage();
                                                        List<BeanSurveyPage> lstSurveyPage = new List<BeanSurveyPage>();
                                                        lstSurveyPage = SurveyPage.SelectAll().Where(s => s.SurveyTableId == Guid.Parse(strIDs)).OrderBy(s => s.Index).ToList();

                                                        retData = new { BeanSurveyTable = SurveyTable, BeanSurveyQuestion = lstSurveyQuestions, BeanSurveyPage = lstSurveyPage, RankDaily = RankDaily, RankAll = RankAll, IsActive = SurveyTable.Status };
                                                        resStatus = RESPONES_STATE.SUCCESS;
                                                    }
                                                    else
                                                    {
                                                        retData = "AccessDenied";
                                                        resStatus = RESPONES_STATE.MESSAGE;
                                                    }
                                                }
                                                
                                            }
                                            catch(Exception ex)
                                            {
                                                retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Get Data Actived
                                    case "GetDataSurveyIsActive":
                                        {
                                            try
                                            {
                                                var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                                bool isPerrmiss = surveyController.CheckPermissionSurvey(CurrentUser, strIDs);
                                                if (isPerrmiss)
                                                {
                                                    BeanSurveyTable SurveyTable = new BeanSurveyTable();
                                                    SurveyTable = SurveyTable.SelectByID(Guid.Parse(strIDs));
                                                    BeanSurveyQuestion SurveyQuestions = new BeanSurveyQuestion();
                                                    List<BeanSurveyQuestion> lstSurveyQuestions = new List<BeanSurveyQuestion>();
                                                    lstSurveyQuestions = SurveyQuestions.SelectAll().Where(s => s.SurveyTableId == Guid.Parse(strIDs)).OrderBy(s => s.Index).ToList();
                                                    BeanSurveyPage SurveyPage = new BeanSurveyPage();
                                                    List<BeanSurveyPage> lstSurveyPage = new List<BeanSurveyPage>();
                                                    lstSurveyPage = SurveyPage.SelectAll().Where(s => s.SurveyTableId == Guid.Parse(strIDs)).OrderBy(s => s.Index).ToList();

                                                    BeanSurveyResponses SurveyResponses = new BeanSurveyResponses();
                                                    SurveyResponses = SurveyResponses.SelectAll().Where(s => s.SurveyTableId == Guid.Parse(strIDs) && s.UserId == CurrentUser.ID).FirstOrDefault();


                                                    BeanSurveyResponsesValue SurveyResponsesValue = new BeanSurveyResponsesValue();
                                                    List<BeanSurveyResponsesValue> lstSurveyResponsesValue = new List<BeanSurveyResponsesValue>();
                                                    if (SurveyResponses != null) 
                                                    {
                                                        lstSurveyResponsesValue = SurveyResponsesValue.SelectAll().Where(s => s.SurveyResponsesId == SurveyResponses.ID).OrderByDescending(s => s.Created).ToList();
                                                        
                                                    }
                                                        

                                                    retData = new { BeanSurveyTable = SurveyTable, BeanSurveyQuestion = lstSurveyQuestions, BeanSurveyPage = lstSurveyPage, BeanSurveyResponsesValue = lstSurveyResponsesValue, BeanSurveyResponses = SurveyResponses, IsActive = SurveyTable.Status};
                                                    resStatus = RESPONES_STATE.SUCCESS;
                                                }
                                                else
                                                {
                                                    retData = "AccessDenied";
                                                    resStatus = RESPONES_STATE.MESSAGE;
                                                }
                                            }
                                            catch (Exception ex)
                                            {
                                                retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Save Res Tempo 
                                    case "SaveResTempo":
                                        {
                                            try
                                            {
                                                var PostObj = new
                                                {
                                                    BeanSurveyQuestion = new List<BeanSurveyQuestion>(),
                                                    BeanSurveyTable = new BeanSurveyTable(),
                                                    BeanSurveyPage = new List<BeanSurveyPage>(),
                                                    BeanSurveyResponsesValue = new List<BeanSurveyResponsesValue>(),
                                                    BeanSurveyResponses = new BeanSurveyResponses()
                                                };
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                retData = surveyController.SaveResTempo(CurrentUser, PostObj.BeanSurveyTable, PostObj.BeanSurveyQuestion, PostObj.BeanSurveyResponsesValue, PostObj.BeanSurveyResponses, ref errMes);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Save Res
                                    case "SaveRes":
                                        {
                                            try
                                            {
                                                var PostObj = new
                                                {
                                                    BeanSurveyQuestion = new List<BeanSurveyQuestion>(),
                                                    BeanSurveyTable = new BeanSurveyTable(),
                                                    BeanSurveyPage = new List<BeanSurveyPage>(),
                                                    BeanSurveyResponsesValue = new List<BeanSurveyResponsesValue>(),
                                                    BeanSurveyResponses = new BeanSurveyResponses()
                                                };
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                retData = surveyController.SaveRes(CurrentUser, PostObj.BeanSurveyTable, PostObj.BeanSurveyQuestion, PostObj.BeanSurveyResponsesValue, PostObj.BeanSurveyResponses, ref errMes);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Get List Survey By UserID
                                    case "GetListSurveyByUserID":
                                        {
                                            try
                                            {
                                                retData = surveyController.GetListSurveyByUserID(CurrentUser, ref errMes);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Get Data Servey Statistical
                                    case "GetDataServeyStatistical":
                                        {
                                            try
                                            {
                                                var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                                if (!string.IsNullOrEmpty(strIDs))
                                                {
                                                    retData = surveyController.GetDataServeyStatistical(strIDs,CurrentUser.ID.ToString());
                                                    resStatus = RESPONES_STATE.SUCCESS;
                                                }

                                            }
                                            catch (Exception ex)
                                            {
                                                retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Export Excel Servey Statistical
                                    case "ExportExcel":
                                        {
                                            try
                                            {
                                                var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                                if (!string.IsNullOrEmpty(strIDs))
                                                {
                                                    int startRow = 4;
                                                    int STT = 1;
                                                    int ArrayTextBoxescount = 4;
                                                    int ArrayTextBoxesNumber = 0;
                                                    int ArrayChoicesNumber = 0;
                                                    int ArraymatrixNumber = 0;
                                                    BeanSurveyResponsesValue beanSurveyResponsesValue = new BeanSurveyResponsesValue();
                                                    List<BeanSurveyResponsesValue> lstbeanSurveyResponsesValueTemp = new List<BeanSurveyResponsesValue>();
                                                    List<BeanSurveyResponsesValue> lstbeanSurveyResponsesValue = new List<BeanSurveyResponsesValue>();
                                                    BeanSurveyTable surveyTable = new BeanSurveyTable();
                                                    surveyTable = surveyTable.SelectByID(Guid.Parse(strIDs));
                                                    BeanSurveyQuestion beanSurveyQuestions = new BeanSurveyQuestion();
                                                    List<BeanSurveyQuestion> lstBeanSurveyQuestions = new List<BeanSurveyQuestion>();
                                                    lstBeanSurveyQuestions = beanSurveyQuestions.SelectAll().Where(s => s.SurveyTableId == surveyTable.ID).ToList();
                                                    DataTable dataRes = surveyController.GetDataServeyStatistical(strIDs, CurrentUser.ID.ToString());
                                                    if (dataRes != null && dataRes.Rows.Count > 0)
                                                    {
                                                        List<DataDetail> lstDetail = new List<DataDetail>();
                                                        lstDetail = _db.ConvertToList<DataDetail>(dataRes);
                                                        lstDetail = lstDetail.OrderBy(s => s.FullName).ToList();
                                                        foreach (DataDetail item in lstDetail)
                                                        {
                                                            lstbeanSurveyResponsesValueTemp = beanSurveyResponsesValue.SelectAll().Where(s => s.SurveyResponsesId == item.ID).ToList();
                                                            if(beanSurveyResponsesValue != null)
                                                            {
                                                                lstbeanSurveyResponsesValue.AddRange(lstbeanSurveyResponsesValueTemp);
                                                            }
                                                        }
                                                        var excelApp = new excel.Application();
                                                        excelApp.Visible = false;
                                                        var workbook = excelApp.Workbooks.Add();

                                                        excel._Worksheet workSheet = (excel.Worksheet)excelApp.ActiveSheet;
                                                        workSheet.Name = "Export Data";
                                                        workSheet.Cells[1].Style.HorizontalAlignment = Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter;
                                                        workSheet.Cells[1].Style.VerticalAlignment = Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignCenter;
                                                        workSheet.Rows[1].WrapText = true;
                                                        workSheet.Rows[2].WrapText = true;
                                                        workSheet.Rows[3].WrapText = true;
                                                        var a = workSheet.Cells[1, 5];
                                                        workSheet.Rows[1].Style.Font.Size = 20;
                                                        workSheet.Cells[1, 1] = "STT";
                                                        workSheet.Range[workSheet.Cells[1, 1], workSheet.Cells[3, 1]].Merge();
                                                        workSheet.Cells[1, 2] = "ID Survey";
                                                        workSheet.Range[workSheet.Cells[1, 2], workSheet.Cells[3, 2]].Merge();
                                                        workSheet.Cells[1, 3] = "Ten";
                                                        workSheet.Range[workSheet.Cells[1, 3], workSheet.Cells[3, 3]].Merge();
                                                        workSheet.Cells[1, 4] = "Email";
                                                        workSheet.Range[workSheet.Cells[1, 4], workSheet.Cells[3, 4]].Merge();
                                                        
                                                        foreach (DataDetail itemID in lstDetail)
                                                        {
                                                            workSheet.Cells[startRow, 1] = STT;
                                                            workSheet.Cells[startRow, 2] = strIDs;
                                                            workSheet.Cells[startRow, 3] = itemID.FullName;
                                                            workSheet.Cells[startRow, 4] = itemID.Email;
                                                            startRow++;
                                                            STT++;
                                                        }
                                                        for (int j = 0; j < lstBeanSurveyQuestions.Count; j++)
                                                        {
                                                            switch (lstBeanSurveyQuestions[j].SQTId)
                                                            {
                                                                case 1:
                                                                    {
                                                                        int rowIndex = 4;
                                                                        ArrayTextBoxescount += 1;
                                                                        workSheet.Cells[1, ArrayTextBoxescount] = lstBeanSurveyQuestions[j].Title + string.Empty != null ? lstBeanSurveyQuestions[j].Title : "";
                                                                        workSheet.Range[workSheet.Cells[1, ArrayTextBoxescount], workSheet.Cells[3, ArrayTextBoxescount]].Merge();
                                                                        foreach (DataDetail itemID in lstDetail)
                                                                        {
                                                                            beanSurveyResponsesValue = lstbeanSurveyResponsesValue.Where(s => s.SurveyResponsesId == itemID.ID && s.SurveyQuestionId == lstBeanSurveyQuestions[j].ID).FirstOrDefault();
                                                                            if(beanSurveyResponsesValue != null)
                                                                            {
                                                                                workSheet.Cells[rowIndex, ArrayTextBoxescount] = beanSurveyResponsesValue.Value != null ? beanSurveyResponsesValue.Value : "";
                                                                                rowIndex++;
                                                                            }
                                                                            
                                                                        }
                                                                        
                                                                    }
                                                                    break;
                                                                case 2:
                                                                    {
                                                                        
                                                                        var arrayStaff = new { MultipleTextboxes = new JArray { new JArray { } } };
                                                                        arrayStaff = JsonConvert.DeserializeAnonymousType(lstBeanSurveyQuestions[j].Value, arrayStaff);
                                                                        workSheet.Cells[1, ArrayTextBoxescount + 1] = lstBeanSurveyQuestions[j].Title;
                                                                        workSheet.Range[workSheet.Cells[1, ArrayTextBoxescount + 1], workSheet.Cells[1, ArrayTextBoxescount + arrayStaff.MultipleTextboxes.Count]].Merge();
                                                                        if (arrayStaff.MultipleTextboxes != null && arrayStaff.MultipleTextboxes.Count > 0)
                                                                        {
                                                                            for (int i = 0; i < arrayStaff.MultipleTextboxes.Count; i++)
                                                                            {
                                                                                ArrayTextBoxescount += 1;
                                                                                workSheet.Cells[2, ArrayTextBoxescount] = arrayStaff.MultipleTextboxes[i]["Title"] != null ? arrayStaff.MultipleTextboxes[i]["Title"].ToString() : "";
                                                                                workSheet.Range[workSheet.Cells[2, ArrayTextBoxescount], workSheet.Cells[3, ArrayTextBoxescount]].Merge();
                                                                                int rowIndex = 4;
                                                                                foreach (DataDetail itemID in lstDetail)
                                                                                {
                                                                                    beanSurveyResponsesValue = lstbeanSurveyResponsesValue.Where(s => s.SurveyResponsesId == itemID.ID && s.SurveyQuestionId == lstBeanSurveyQuestions[j].ID).FirstOrDefault();
                                                                                    if (beanSurveyResponsesValue != null)
                                                                                    {
                                                                                        
                                                                                        var arrayValue = new { MultipleTextboxes = new JArray { new JArray { } } };
                                                                                        arrayValue = JsonConvert.DeserializeAnonymousType(beanSurveyResponsesValue.Value, arrayValue);
                                                                                        if (arrayValue.MultipleTextboxes != null && arrayValue.MultipleTextboxes.Count > 0)
                                                                                        {
                                                                                            for (int t = 0; t < arrayValue.MultipleTextboxes.Count; t++)
                                                                                            {
                                                                                                if(arrayStaff.MultipleTextboxes[i]["ID"] + string.Empty == arrayValue.MultipleTextboxes[t]["ID"] + string.Empty)
                                                                                                {
                                                                                                    workSheet.Cells[rowIndex, ArrayTextBoxescount] = arrayValue.MultipleTextboxes[i]["Value"] != null ? arrayValue.MultipleTextboxes[i]["Value"].ToString() : "";
                                                                                                    rowIndex++;
                                                                                                }
                                                                                                
                                                                                            }
                                                                                        }
                                                                                            
                                                                                    }

                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    break;
                                                                //case 3:
                                                                //    {
                                                                //        var arrayStaff = new { ArrayChoices = new JArray { new JArray { } } };
                                                                //        arrayStaff = JsonConvert.DeserializeAnonymousType(lstBeanSurveyQuestions[j]["Value"].ToString(), arrayStaff);
                                                                //        workSheet.Cells[1, ArrayTextBoxescount + 1] = lstBeanSurveyQuestions[j]["Title"] + string.Empty;
                                                                //        workSheet.Range[workSheet.Cells[1, ArrayTextBoxescount + 1], workSheet.Cells[1, ArrayTextBoxescount + arrayStaff.ArrayChoices.Count]].Merge();
                                                                //        if (arrayStaff.ArrayChoices != null && arrayStaff.ArrayChoices.Count > 0)
                                                                //        {
                                                                //            for (int i = 0; i < arrayStaff.ArrayChoices.Count; i++)
                                                                //            {
                                                                //                ArrayTextBoxescount += 1;
                                                                //                workSheet.Cells[2, ArrayTextBoxescount] = arrayStaff.ArrayChoices[i]["Title"] != null ? arrayStaff.ArrayChoices[i]["Title"].ToString() : "";
                                                                //                workSheet.Range[workSheet.Cells[2, ArrayTextBoxescount], workSheet.Cells[3, ArrayTextBoxescount]].Merge();
                                                                //            }
                                                                //        }
                                                                //        ArrayChoicesNumber = arrayStaff.ArrayChoices.Count;
                                                                //    }
                                                                //    break;
                                                                //case 6:
                                                                //    {
                                                                //        var arrayStaff = new { ColumnHeader = new string[] { }, RowHeader = new string[] { } };
                                                                //        arrayStaff = JsonConvert.DeserializeAnonymousType(lstBeanSurveyQuestions[j]["Options"].ToString(), arrayStaff);
                                                                //        workSheet.Cells[1, ArrayTextBoxescount + 1] = lstBeanSurveyQuestions[j]["Title"] + string.Empty;
                                                                //        workSheet.Range[workSheet.Cells[1, ArrayTextBoxescount + 1], workSheet.Cells[1, ArrayTextBoxescount + (arrayStaff.ColumnHeader.Length * arrayStaff.RowHeader.Length)]].Merge();
                                                                //        if (arrayStaff.ColumnHeader != null && arrayStaff.ColumnHeader.Length > 0)
                                                                //        {
                                                                //            for (int i = 0; i < arrayStaff.ColumnHeader.Length; i++)
                                                                //            {
                                                                //                workSheet.Cells[2, ArrayTextBoxescount + 1] = arrayStaff.ColumnHeader[i] != null ? arrayStaff.ColumnHeader[i] : "";
                                                                //                workSheet.Range[workSheet.Cells[2, ArrayTextBoxescount + 1], workSheet.Cells[2, ArrayTextBoxescount + arrayStaff.RowHeader.Length]].Merge();
                                                                //                for (int r = 0; r < arrayStaff.RowHeader.Length; r++)
                                                                //                {
                                                                //                    ArrayTextBoxescount += 1;
                                                                //                    workSheet.Cells[3, ArrayTextBoxescount] = arrayStaff.RowHeader[r] != null ? arrayStaff.RowHeader[r] : "";
                                                                //                }
                                                                //            }
                                                                //            ArraymatrixNumber = arrayStaff.ColumnHeader.Length * arrayStaff.RowHeader.Length;
                                                                //        }
                                                                //    }
                                                                //    break;
                                                                default:
                                                                    {

                                                                    }
                                                                    break;
                                                            }

                                                        }
                                                        object misValue = System.Reflection.Missing.Value;
                                                        workbook.SaveAs("C:\\Users\\HDs\\Desktop\\Khóa Luận Tốt Nghiệp\\Export-Excel_"+DateTime.Now.ToString("yyyyMMddHHmmss")+".xlsx");
                                                        workbook.Close(true, misValue, misValue);
                                                        excelApp.Quit();
                                                    }
                                                    
                                                    resStatus = RESPONES_STATE.SUCCESS;
                                                }

                                            }
                                            catch (Exception ex)
                                            {
                                                retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region Search Survey Detail
                                    case "SearchSurveyDetail":
                                        {
                                           
                                            try
                                            {
                                                var PostObj = new
                                                {
                                                    FullName = "",
                                                    Email = ""
                                                };
                                                var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                                PostObj = JsonConvert.DeserializeAnonymousType(strPostData, PostObj);
                                                var Todate = PAR(context, "ToDate");
                                                var Fromdate = PAR(context, "FromDate");
                                                if (!string.IsNullOrEmpty(strIDs))
                                                {
                                                    DataTable dataSearch = surveyController.GetDataServeyStatistical(strIDs, CurrentUser.ID.ToString());
                                                    if(dataSearch != null && dataSearch.Rows.Count > 0)
                                                    {
                                                        List<DataDetail> lstDetail = new List<DataDetail>();
                                                        lstDetail = _db.ConvertToList<DataDetail>(dataSearch);
                                                        if (!string.IsNullOrEmpty(PostObj.FullName))
                                                            lstDetail = lstDetail.Where(s => s.FullName.Contains(PostObj.FullName)).ToList();
                                                        if (!string.IsNullOrEmpty(PostObj.Email))
                                                            lstDetail = lstDetail.Where(s => s.Email.Contains(PostObj.Email)).ToList();
                                                        if (!string.IsNullOrEmpty(Fromdate))
                                                            lstDetail = lstDetail.Where(s => s.Created >= Convert.ToDateTime(Fromdate)).ToList();
                                                        if (!string.IsNullOrEmpty(Todate))
                                                            lstDetail = lstDetail.Where(s => s.Created <= Convert.ToDateTime(Todate)).ToList();
                                                        retData = lstDetail;
                                                    }
                                                    resStatus = RESPONES_STATE.SUCCESS;
                                                }
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                    #endregion
                                    #region GetDataReportSurvey
                                    case "GetDataReportSurvey":
                                        {
                                            string Type = PAR(context, "Type");
                                            string strDateFrom = PAR(context, "DateFrom");
                                            string strDateTo = PAR(context, "DateTo");
                                            string Workflow = PAR(context, "Workflow");
                                            string Department = PAR(context, "Department");
                                            int DateFrom = 0;
                                            int DateTo = 0;
                                            if (!string.IsNullOrEmpty(strDateFrom))
                                            {
                                                if (Type == "Month")
                                                {
                                                    string[] mang = strDateFrom.Split('/');
                                                    DateFrom = Convert.ToInt32(mang[1] + mang[0] + "01");
                                                }
                                                else if (Type == "Year")
                                                {
                                                    DateTime YearFrom = Convert.ToDateTime(strDateFrom + "-01-01");
                                                    DateFrom = Convert.ToInt32(YearFrom.ToString("yyyyMMdd"));
                                                }
                                                else
                                                {
                                                    string[] mang = strDateFrom.Split('/');
                                                    DateFrom = Convert.ToInt32(mang[2] + mang[1] + mang[0]);
                                                }
                                            }
                                            else
                                            {
                                                DateFrom = Convert.ToInt32(DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd").Replace("-", ""));
                                            }
                                            if (!string.IsNullOrEmpty(strDateTo))
                                            {
                                                if (Type == "Month")
                                                {
                                                    string[] mang = strDateTo.Split('/');
                                                    strDateTo = mang[1] + "-" + mang[0];
                                                    DateTime MonthTo = Convert.ToDateTime(strDateTo + "-01");
                                                    DateTo = Convert.ToInt32(MonthTo.AddMonths(1).AddMinutes(-1).ToString("yyyyMMdd"));
                                                }
                                                else if (Type == "Year")
                                                {
                                                    DateTime YearTo = Convert.ToDateTime(strDateTo + "-12-31");
                                                    DateTo = Convert.ToInt32(YearTo.ToString("yyyyMMdd"));
                                                }
                                                else
                                                {
                                                    string[] mang = strDateTo.Split('/');
                                                    DateTo = Convert.ToInt32(mang[2] + mang[1] + mang[0]);
                                                }
                                            }
                                            else
                                            {
                                                DateTo = Convert.ToInt32(DateTime.Now.ToString("yyyy-MM-dd").Replace("-", ""));
                                            }
                                            DataTable dtOpt = surveyController.DataReportSLADocument(Type, DateFrom + string.Empty, DateTo + string.Empty, CurrentUser.ID.ToString());
                                            List<ReportSLAList> dataDLSLA = new List<ReportSLAList>();
                                            List<ReportSLADocument> dataReportSLADocument = new List<ReportSLADocument>();
                                            if (dtOpt != null && dtOpt.Rows.Count > 0)
                                            {
                                                string category = "";
                                                int stt = 1;
                                                dataDLSLA = _db.ConvertToList<ReportSLAList>(dtOpt);
                                                foreach(ReportSLAList item in dataDLSLA)
                                                {
                                                    item.STT = stt;
                                                    ReportSLADocument itemReport = new ReportSLADocument();
                                                    if(item.Category != category)
                                                    {
                                                        category = item.Category;
                                                        itemReport.Category = item.Category;
                                                        itemReport.InProcess = dataDLSLA.Where(s=>s.Category == item.Category && s.Type =="inpro").Count();
                                                        itemReport.TotalItem = dataDLSLA.Where(s => s.Category == item.Category).Count();
                                                        itemReport.CompletedInTime = dataDLSLA.Where(s => s.Category == item.Category && s.Type == "dunghan").Count();
                                                        itemReport.CompletedOverTime = dataDLSLA.Where(s => s.Category == item.Category && s.Type == "TreHan").Count();
                                                        dataReportSLADocument.Add(itemReport);
                                                    }
                                                    stt++;
                                                }
                                            }
                                            retData = new { dataReport = dataReportSLADocument, dataGridDetail = dataDLSLA };
                                            resStatus = RESPONES_STATE.SUCCESS;
                                        }
                                        break;
                                    #endregion
                                    #region SendMail 
                                    case "SendMail":
                                        {
                                            try
                                            {
                                                //surveyController.Sentmail();
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            catch (Exception ex)
                                            {
                                                if (errMes != "")
                                                    retData = errMes;
                                                else
                                                    retData = ex.Message;
                                                resStatus = RESPONES_STATE.ERR;
                                            }
                                            break;
                                        }
                                        #endregion

                                }
                            }
                            break;
                        #endregion

                        #region Setting 
                        case "Setting":
                            {
                                switch (func)
                                {
                                    #region Get List Config
                                    case "GetListConfig":
                                        {
                                            BeanSetting menuSetting = new BeanSetting();
                                            retData = menuSetting.SelectAll();
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Delete Config
                                    case "DeleteConfig":
                                        {
                                            if (!string.IsNullOrEmpty(strPostData))
                                            {
                                                string strData = JsonConvert.DeserializeObject<string>(strPostData);
                                                BeanSetting menuBeanGroup = new BeanSetting();
                                                menuBeanGroup = menuBeanGroup.SelectByID(Convert.ToInt32(strData));
                                                menuBeanGroup.Delete(menuBeanGroup);
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Group by IDs 
                                    case "GetConfigByIDs":
                                        {
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanSetting Group = new BeanSetting();
                                                Group = Group.SelectByID(Convert.ToInt32(strIDs));
                                                retData = Group;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Insert Update Config 
                                    case "InsertUpdateConfig":
                                        {
                                            BeanSetting BeanConfigUpdate = new BeanSetting();
                                            PublicFunction pbFunction = new PublicFunction();
                                            BeanConfigUpdate = JsonConvert.DeserializeObject<BeanSetting>(strPostData);
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanConfigUpdate.ID = Convert.ToInt32(strIDs);
                                                BeanConfigUpdate.IsActive = true;
                                                BeanConfigUpdate.Update(BeanConfigUpdate);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            else
                                            {
                                                BeanConfigUpdate.IsActive = true;
                                                BeanConfigUpdate.Insert(BeanConfigUpdate);
                                                resStatus = RESPONES_STATE.SUCCESS;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Permission
                                    case "GetListPermission":
                                        {
                                            BeanPermissionList menuPermissionList = new BeanPermissionList();
                                            retData = menuPermissionList.SelectAll();
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Delete Permission
                                    case "DeletePermission":
                                        {
                                            if (!string.IsNullOrEmpty(strPostData))
                                            {
                                                string strData = JsonConvert.DeserializeObject<string>(strPostData);
                                                BeanPermissionList menuPermissionList = new BeanPermissionList();
                                                menuPermissionList = menuPermissionList.SelectByID(Convert.ToInt32(strData));
                                                menuPermissionList.Delete(menuPermissionList);
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Permission Check List
                                    case "GetListPermissionCheckList":
                                        {
                                            BeanPermission BeanPermissioncheck = new BeanPermission();
                                            BeanPermissionList BeanPermissionListcheck = new BeanPermissionList();
                                            List<MenuSettingModel> MenuSettingCheckList = new List<MenuSettingModel>();
                                            List<MenuSettingModel> MenuSettingCheckListChild = new List<MenuSettingModel>();
                                            MenuSettingModel MenuSetting = new MenuSettingModel();
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanPermissionListcheck = BeanPermissionListcheck.SelectByID(Guid.Parse(strIDs));
                                                MenuSettingCheckList = MenuSetting.SelectAll().Where(s => s.ParentId == null || s.ParentId == 0).ToList();
                                                MenuSettingCheckListChild = MenuSetting.SelectAll().Where(s => s.ParentId != null || s.ParentId > 0).ToList();
                                                #region Check quyền
                                                foreach(MenuSettingModel item in MenuSettingCheckList)
                                                {
                                                    var check = BeanPermissioncheck.SelectAll().Where(s => s.IsSetting == true && s.Permission == BeanPermissionListcheck.PermissionNameEN && s.RelatedID == item.ID && s.TableRelated == "Menu").FirstOrDefault();
                                                    if(check != null)
                                                    {
                                                        item.IsExist = true;
                                                    }
                                                }
                                                foreach (MenuSettingModel itemChild in MenuSettingCheckListChild)
                                                {
                                                    var check = BeanPermissioncheck.SelectAll().Where(s => s.IsSetting == true && s.Permission == BeanPermissionListcheck.PermissionNameEN && s.RelatedID == itemChild.ID && s.TableRelated == "Menu").FirstOrDefault();
                                                    if (check != null)
                                                    {
                                                        itemChild.IsExist = true;
                                                    }
                                                }
                                                #endregion
                                                for (int i = 0; i < MenuSettingCheckList.Count; i++)
                                                {
                                                    var bean = MenuSettingCheckListChild.Where(s => s.ParentId == MenuSettingCheckList[i].ID).ToList();
                                                    if (bean != null && bean.Count > 0)
                                                    {
                                                        MenuSettingCheckList[i].items = new List<MenuSettingModel>();
                                                        MenuSettingCheckList[i].items.AddRange(bean);
                                                    }
                                                }
                                                retData = new { Menu = MenuSettingCheckList, PermissionList = BeanPermissionListcheck };
                                            }
                                            else
                                            {
                                                MenuSettingCheckList = MenuSetting.SelectAll().Where(s => s.ParentId == null || s.ParentId == 0).ToList();
                                                MenuSettingCheckListChild = MenuSetting.SelectAll().Where(s => s.ParentId != null || s.ParentId > 0).ToList();
                                                for (int i = 0; i < MenuSettingCheckList.Count; i++)
                                                {
                                                    var bean = MenuSettingCheckListChild.Where(s => s.ParentId == MenuSettingCheckList[i].ID).ToList();
                                                    if (bean != null && bean.Count > 0)
                                                    {
                                                        MenuSettingCheckList[i].items = new List<MenuSettingModel>();
                                                        MenuSettingCheckList[i].items.AddRange(bean);
                                                    }
                                                }
                                                retData = MenuSettingCheckList;
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                    #endregion
                                    #region Get List Permission Check List
                                    case "InsUpdPermission":
                                        {
                                            BeanPermission BeanPermissioncheck = new BeanPermission();
                                            BeanPermissionList BeanPermissionListcheck = new BeanPermissionList();
                                            BeanPermissionList BeanPermissionListUpdate = new BeanPermissionList();
                                            PublicFunction pbFunction = new PublicFunction();
                                            BeanPermissionListUpdate = JsonConvert.DeserializeObject<BeanPermissionList>(strPostData);
                                            var strIDs = PAR(context, PRA_KEYNAME.IDs);
                                            if (!string.IsNullOrEmpty(strIDs))
                                            {
                                                BeanPermissionListUpdate.ID = Guid.Parse(strIDs);
                                                BeanPermissionListcheck = BeanPermissionListcheck.SelectByID(BeanPermissionListUpdate.ID);
                                                BeanPermissionListUpdate.IsActive = true;
                                                BeanPermissionListUpdate.Created = BeanPermissionListcheck.Created;
                                                BeanPermissionListUpdate.CreatedBy = BeanPermissionListcheck.CreatedBy;
                                                BeanPermissionListUpdate.Modified = DateTime.Now;
                                                BeanPermissionListUpdate.ModifiedBy = CurrentUser.ID;
                                                BeanPermissionListUpdate.Update(BeanPermissionListUpdate);
                                            }
                                            else
                                            {
                                                BeanPermissionListUpdate.ID = new Guid();
                                                BeanPermissionListUpdate.IsActive = true;
                                                BeanPermissionListUpdate.Created = BeanPermissionListUpdate.Modified = DateTime.Now;
                                                BeanPermissionListUpdate.CreatedBy = BeanPermissionListUpdate.ModifiedBy = CurrentUser.ID;
                                                BeanPermissionListUpdate.Insert(BeanPermissionListUpdate);
                                            }
                                            var strCheckList = PAR(context, "checklist");
                                            string[] checkList = strCheckList.Split(',');
                                            if(checkList.Length > 0)
                                            {
                                                List<BeanPermission> ModelPermission = new List<BeanPermission>();
                                                ModelPermission = BeanPermissioncheck.SelectAll().Where(s => s.Permission == BeanPermissionListUpdate.PermissionNameEN && s.IsSetting == true && s.TableRelated == "Menu").ToList();
                                                foreach (BeanPermission item in ModelPermission)
                                                {
                                                    BeanPermissioncheck.Delete(item);
                                                }
                                                foreach (string item in checkList)
                                                {
                                                    BeanPermissioncheck.RelatedID = Convert.ToInt32(item);
                                                    BeanPermissioncheck.TableRelated = "Menu";
                                                    BeanPermissioncheck.SurveyTableID = CurrentUser.ID;
                                                    BeanPermissioncheck.AssignTo = CurrentUser.ID;
                                                    BeanPermissioncheck.IsSetting = true;
                                                    BeanPermissioncheck.Permission = BeanPermissionListUpdate.PermissionNameEN;
                                                    BeanPermissioncheck.Created = BeanPermissioncheck.Modified = DateTime.Now;
                                                    BeanPermissioncheck.CreatedBy = BeanPermissioncheck.ModifiedBy = CurrentUser.ID;
                                                    BeanPermissioncheck.Insert(BeanPermissioncheck);
                                                }
                                            }
                                            resStatus = RESPONES_STATE.SUCCESS;
                                            break;
                                        }
                                        #endregion
                                        
                                }
                            }
                            break;
                        #endregion

                        #region download 
                        case "download":
                            {
                                switch (func)
                                {
                                    case "DownloadFile":
                                        {
                                            string FileName = "";
                                            string strPath = ConfigurationManager.AppSettings["PathExcelTemplate"] + string.Empty;
                                            FileStream fileStream = new FileStream(strPath, FileMode.Open);
                                            FileName = Path.GetFileNameWithoutExtension(fileStream.Name);
                                            WebClient webClient = new WebClient();
                                            webClient.DownloadFileAsync(new Uri(strPath), "C:\\Users\\HDs\\Downloads\\" + FileName);
                                            break;
                                        }

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
                if(!isDownload)
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
        public class DataChart
        {
            public string category { get; set; }
            public int value { get; set; }
        }
        public class DataDetail
        {
            public string FullName { get; set; }
            public string Email { get; set; }
            public int Score { get; set; }
            public Guid ID { get; set; }
            public DateTime? Modified { get; set; }
            public DateTime? Created { get; set; }
            public int Rank { get; set; }
        }
        class ReportSLADocument
        {
            public string Category { get; set; }
            public int InProcess { get; set; }
            public int CompletedInTime { get; set; }
            public int CompletedOverTime { get; set; }
            public int TotalItem { get; set; }
        }
        class ReportSLAList
        {
            public int STT { get; set; }
            public Guid ID { get; set; }
            public string Title { get; set; }
            public DateTime Created { get; set; }
            public DateTime? Modified { get; set; }
            public DateTime? Overdue { get; set; }
            public string Category { get; set; }
            public string Type { get; set; }
        }
    }
}