using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Controllers
{
    public class SurveyController : Controller
    {
        CmmFunc _db = new CmmFunc();
        public string SaveSurveyTable(UserModel CurrentUser, BeanSurveyTable BeanSurveyTableUpdate, List<BeanSurveyQuestion> beanSurveyQuestions, List<BeanSurveyPage> beanSurveyPage, int IsActive, ref string errMess)
        {
            string SVID = "";
            try
            {
                if (BeanSurveyTableUpdate.ID != null && BeanSurveyTableUpdate.ID != Guid.Empty)
                {
                    BeanSurveyTable SurveyTable = BeanSurveyTableUpdate.SelectByID(BeanSurveyTableUpdate.ID);
                    BeanSurveyTableUpdate.Modified = DateTime.Now;
                    BeanSurveyTableUpdate.ModifiedBy = CurrentUser.ID;
                    if(BeanSurveyTableUpdate.DueDate != null)
                    {
                        BeanSetting beanSetting = new BeanSetting();
                        int nearOverNum = 0;
                        int overNum = 0;
                        beanSetting = beanSetting.SelectAll().Where(s => s.Title == "NearOverNum").FirstOrDefault();
                        if (beanSetting != null)
                        {
                            nearOverNum = Convert.ToInt32(Convert.ToDateTime(BeanSurveyTableUpdate.DueDate).AddDays(Convert.ToInt32(beanSetting.Value)).ToString("yyyyMMdd"));
                            BeanSurveyTableUpdate.NearOverDateNum = nearOverNum;
                        }
                        beanSetting = beanSetting.SelectAll().Where(s => s.Title == "OverNum").FirstOrDefault();
                        if (beanSetting != null)
                        {
                            overNum = Convert.ToInt32(Convert.ToDateTime(BeanSurveyTableUpdate.DueDate).AddDays(Convert.ToInt32(beanSetting.Value)).ToString("yyyyMMdd"));
                            BeanSurveyTableUpdate.OverDateNum = overNum;
                        }
                    }
                    else
                    {
                        BeanSurveyTableUpdate.OverDateNum = 0;
                        BeanSurveyTableUpdate.NearOverDateNum = 0;
                    }
                    //Cập nhật giá trị cũ
                    BeanSurveyTableUpdate.CreatedBy = SurveyTable.CreatedBy;
                    BeanSurveyTableUpdate.Created = SurveyTable.Created;
                    BeanSurveyTableUpdate.DesignModified = SurveyTable.DesignModified;
                    BeanSurveyTableUpdate.Update(BeanSurveyTableUpdate);

                    SVID = BeanSurveyTableUpdate.ID.ToString();
                }
                else
                {
                    BeanSurveyTableUpdate.ID = Guid.NewGuid();
                    BeanSurveyTableUpdate.Status = Convert.ToInt16(IsActive);
                    if (BeanSurveyTableUpdate.DueDate != null)
                    {
                        BeanSetting beanSetting = new BeanSetting();
                        List<BeanSetting> lstBeanSetting = new List<BeanSetting>();
                        int nearOverNum = 0;
                        int overNum = 0;
                        beanSetting = beanSetting.SelectAll().Where(s => s.Title == "NearOverNum").FirstOrDefault();
                        if (beanSetting != null)
                        {
                            nearOverNum = Convert.ToInt32(Convert.ToDateTime(BeanSurveyTableUpdate.DueDate).AddDays(Convert.ToInt32(beanSetting.Value)).ToString("yyyyMMdd"));
                            BeanSurveyTableUpdate.NearOverDateNum = nearOverNum;
                        }
                        beanSetting = beanSetting.SelectAll().Where(s => s.Title == "OverNum").FirstOrDefault();
                        if (beanSetting != null)
                        {
                            overNum = Convert.ToInt32(Convert.ToDateTime(BeanSurveyTableUpdate.DueDate).AddDays(Convert.ToInt32(beanSetting.Value)).ToString("yyyyMMdd"));
                            BeanSurveyTableUpdate.OverDateNum = overNum;
                        }
                    }
                    else
                    {
                        BeanSurveyTableUpdate.OverDateNum = 0;
                        BeanSurveyTableUpdate.NearOverDateNum = 0;
                    }
                    BeanSurveyTableUpdate.Modified = BeanSurveyTableUpdate.Created = BeanSurveyTableUpdate.DesignModified = DateTime.Now;
                    BeanSurveyTableUpdate.ModifiedBy = BeanSurveyTableUpdate.CreatedBy = CurrentUser.ID;
                    BeanSurveyTableUpdate.Insert(BeanSurveyTableUpdate);

                    SVID = BeanSurveyTableUpdate.ID.ToString();
                }

            }
            catch (Exception ex)
            {
                errMess = ex.Message;
            }
            return SVID;
        }
        public string SaveResTempo(UserModel CurrentUser, BeanSurveyTable BeanSurveyTableUpdate, List<BeanSurveyQuestion> beanSurveyQuestions, List<BeanSurveyResponsesValue> beanSurveyResponsesValue, BeanSurveyResponses beanSurveyResponses, ref string errMess)
        {
            string SVID = "";
            bool existsRes = false;
            BeanSurveyResponses surveyResponses = new BeanSurveyResponses();
            BeanSurveyResponsesValue surveyResponsesValue = new BeanSurveyResponsesValue();
            try
            {
                if (BeanSurveyTableUpdate.ID != null && BeanSurveyTableUpdate.ID != Guid.Empty)
                {
                    if (beanSurveyResponses != null && beanSurveyResponses.ID != Guid.Empty)
                    {
                        beanSurveyResponses.Modified = DateTime.Now;
                        beanSurveyResponses.ModifiedBy = CurrentUser.ID;
                        beanSurveyResponses.Update(beanSurveyResponses);
                    }
                    else
                    {
                        beanSurveyResponses = new BeanSurveyResponses();
                        beanSurveyResponses.ID = Guid.NewGuid();
                        beanSurveyResponses.SurveyTableId = BeanSurveyTableUpdate.ID;
                        beanSurveyResponses.UserId = CurrentUser.ID;
                        beanSurveyResponses.Score = null;
                        beanSurveyResponses.Modified = beanSurveyResponses.Created = DateTime.Now;
                        beanSurveyResponses.ModifiedBy = beanSurveyResponses.CreatedBy = CurrentUser.ID;
                        beanSurveyResponses.Insert(beanSurveyResponses);
                    }
                    if (beanSurveyQuestions.Count > 0)
                    {
                        foreach (BeanSurveyQuestion itemQuestion in beanSurveyQuestions)
                        {
                            if (beanSurveyResponsesValue != null && beanSurveyResponsesValue.Count > 0)
                            {
                                BeanSurveyResponsesValue itemResponsesValue = beanSurveyResponsesValue.Where(s => s.SurveyQuestionId == itemQuestion.ID).FirstOrDefault();
                                if (itemResponsesValue.ID != null && itemResponsesValue.ID != Guid.Empty && itemResponsesValue.SurveyResponsesId == beanSurveyResponses.ID)
                                {
                                    itemResponsesValue.Modified = DateTime.Now;
                                    itemResponsesValue.ModifiedBy = CurrentUser.ID;
                                    itemResponsesValue.Update(itemResponsesValue);
                                }
                                else
                                {
                                    itemResponsesValue.ID = Guid.NewGuid();
                                    itemResponsesValue.UserID = CurrentUser.ID;
                                    itemResponsesValue.SurveyResponsesId = beanSurveyResponses.ID;
                                    itemResponsesValue.Score = null;
                                    itemResponsesValue.OtherValue = "";
                                    itemResponsesValue.Modified = itemResponsesValue.Created = DateTime.Now;
                                    itemResponsesValue.ModifiedBy = itemResponsesValue.CreatedBy = CurrentUser.ID;
                                    itemResponsesValue.Insert(itemResponsesValue);
                                }
                            }
                        }
                    }
                }

            }
            catch (Exception ex)
            {
                errMess = ex.Message;
            }
            return SVID;
        }

        public string SaveRes(UserModel CurrentUser, BeanSurveyTable BeanSurveyTableUpdate, List<BeanSurveyQuestion> beanSurveyQuestions, List<BeanSurveyResponsesValue> beanSurveyResponsesValue, BeanSurveyResponses beanSurveyResponses, ref string errMess)
        {
            string SVID = "";
            bool existsRes = false;
            BeanSurveyResponses surveyResponses = new BeanSurveyResponses();
            BeanSurveyResponsesValue surveyResponsesValue = new BeanSurveyResponsesValue();
            BeanNotify ModelNotify = new BeanNotify();
            try
            {
                if (BeanSurveyTableUpdate.ID != null && BeanSurveyTableUpdate.ID != Guid.Empty)
                {
                    if (beanSurveyResponses != null && beanSurveyResponses.ID != Guid.Empty)
                    {
                        beanSurveyResponses.Modified = DateTime.Now;
                        beanSurveyResponses.ModifiedBy = CurrentUser.ID;
                        beanSurveyResponses.Update(beanSurveyResponses);
                    }
                    else
                    {
                        beanSurveyResponses = new BeanSurveyResponses();
                        beanSurveyResponses.ID = Guid.NewGuid();
                        beanSurveyResponses.SurveyTableId = BeanSurveyTableUpdate.ID;
                        beanSurveyResponses.UserId = CurrentUser.ID;
                        beanSurveyResponses.Score = null;
                        beanSurveyResponses.Modified = beanSurveyResponses.Created = DateTime.Now;
                        beanSurveyResponses.ModifiedBy = beanSurveyResponses.CreatedBy = CurrentUser.ID;
                        beanSurveyResponses.Insert(beanSurveyResponses);
                    }
                    if (beanSurveyQuestions.Count > 0)
                    {
                        foreach (BeanSurveyQuestion itemQuestion in beanSurveyQuestions)
                        {
                            if (beanSurveyResponsesValue != null && beanSurveyResponsesValue.Count > 0)
                            {
                                BeanSurveyResponsesValue itemResponsesValue = beanSurveyResponsesValue.Where(s => s.SurveyQuestionId == itemQuestion.ID).FirstOrDefault();
                                if (itemResponsesValue.ID != null && itemResponsesValue.ID != Guid.Empty && itemResponsesValue.SurveyResponsesId == beanSurveyResponses.ID)
                                {
                                    itemResponsesValue.Modified = DateTime.Now;
                                    itemResponsesValue.ModifiedBy = CurrentUser.ID;
                                    itemResponsesValue.Update(itemResponsesValue);
                                }
                                else
                                {
                                    itemResponsesValue.ID = Guid.NewGuid();
                                    itemResponsesValue.UserID = CurrentUser.ID;
                                    itemResponsesValue.SurveyResponsesId = beanSurveyResponses.ID;
                                    itemResponsesValue.Score = null;
                                    itemResponsesValue.OtherValue = "";
                                    itemResponsesValue.Modified = itemResponsesValue.Created = DateTime.Now;
                                    itemResponsesValue.ModifiedBy = itemResponsesValue.CreatedBy = CurrentUser.ID;
                                    itemResponsesValue.Insert(itemResponsesValue);
                                }
                            }
                            UpdateCountValueSurvey(itemQuestion.ID);
                        }
                    }
                    BeanNotify Notify = ModelNotify.SelectAll().Where(s => s.RelatedID == BeanSurveyTableUpdate.ID && s.AssignTo == CurrentUser.ID).FirstOrDefault();
                    if (Notify != null)
                    {
                        Notify.Status = 1;
                        Notify.Modified =DateTime.Now;
                        Notify.Update(Notify);
                    }
                }

            }
            catch (Exception ex)
            {
                errMess = ex.Message;
            }
            return SVID;
        }
        public string SaveActive(UserModel CurrentUser, BeanSurveyTable BeanSurveyTableUpdate, List<BeanSurveyQuestion> beanSurveyQuestions, List<BeanSurveyPage> beanSurveyPage, int IsActive, ref string errMess)
        {
            string SVID = "";
            try
            {
                if (BeanSurveyTableUpdate.ID != null && BeanSurveyTableUpdate.ID != Guid.Empty)
                {
                    BeanSurveyTable SurveyTable = BeanSurveyTableUpdate.SelectByID(BeanSurveyTableUpdate.ID);
                    BeanSurveyTableUpdate.Modified = DateTime.Now;
                    BeanSurveyTableUpdate.ModifiedBy = CurrentUser.ID;
                    BeanSurveyTableUpdate.Status = Convert.ToInt16(IsActive);
                    if (BeanSurveyTableUpdate.DueDate != null)
                    {
                        BeanSetting beanSetting = new BeanSetting();
                        List<BeanSetting> lstBeanSetting = new List<BeanSetting>();
                        int nearOverNum = 0;
                        int overNum = 0;
                        beanSetting = beanSetting.SelectAll().Where(s => s.Title == "NearOverNum").FirstOrDefault();
                        if (beanSetting != null)
                        {
                            nearOverNum = Convert.ToInt32(Convert.ToDateTime(BeanSurveyTableUpdate.DueDate).AddDays(Convert.ToInt32(beanSetting.Value)).ToString("yyyyMMdd"));
                            BeanSurveyTableUpdate.NearOverDateNum = nearOverNum;
                        }
                        beanSetting = beanSetting.SelectAll().Where(s => s.Title == "OverNum").FirstOrDefault();
                        if (beanSetting != null)
                        {
                            overNum = Convert.ToInt32(Convert.ToDateTime(BeanSurveyTableUpdate.DueDate).AddDays(Convert.ToInt32(beanSetting.Value)).ToString("yyyyMMdd"));
                            BeanSurveyTableUpdate.OverDateNum = overNum;
                        }
                    }
                    else
                    {
                        BeanSurveyTableUpdate.OverDateNum = 0;
                        BeanSurveyTableUpdate.NearOverDateNum = 0;
                    }
                    //Cập nhật giá trị cũ
                    BeanSurveyTableUpdate.CreatedBy = SurveyTable.CreatedBy;
                    BeanSurveyTableUpdate.Created = SurveyTable.Created;
                    BeanSurveyTableUpdate.DesignModified = SurveyTable.DesignModified;
                    BeanSurveyTableUpdate.Update(BeanSurveyTableUpdate);

                    SVID = BeanSurveyTableUpdate.ID.ToString();
                    if (beanSurveyPage.Count > 0)
                    {
                        foreach (BeanSurveyPage itemPage in beanSurveyPage)
                        {
                            if (itemPage.ID != null && itemPage.ID != Guid.Empty)
                            {
                                BeanSurveyPage SurveyPage = itemPage.SelectByID(itemPage.ID);
                                itemPage.SurveyTableId = BeanSurveyTableUpdate.ID;
                                itemPage.Status = Convert.ToInt16(IsActive);
                                itemPage.Modified = DateTime.Now;
                                itemPage.ModifiedBy = CurrentUser.ID;
                                //Cập nhật giá trị cũ
                                itemPage.CreatedBy = SurveyPage.CreatedBy;
                                itemPage.Created = SurveyPage.Created;
                                itemPage.Update(itemPage);
                            }
                            else
                            {
                                itemPage.ID = Guid.NewGuid();
                                itemPage.SurveyTableId = BeanSurveyTableUpdate.ID;
                                itemPage.Status = Convert.ToInt16(IsActive);
                                itemPage.Modified = itemPage.Created = DateTime.Now;
                                itemPage.ModifiedBy = itemPage.CreatedBy = CurrentUser.ID;
                                itemPage.Insert(itemPage);
                            }
                        }
                    }
                    if (beanSurveyQuestions.Count > 0)
                    {
                        foreach (BeanSurveyQuestion itemQuestion in beanSurveyQuestions)
                        {
                            if (itemQuestion.ID != null && itemQuestion.ID != Guid.Empty)
                            {
                                BeanSurveyQuestion SurveyQuestion = itemQuestion.SelectByID(itemQuestion.ID);
                                if (itemQuestion.SurveyTableId == null || itemQuestion.SurveyTableId == Guid.Empty)
                                    itemQuestion.SurveyTableId = BeanSurveyTableUpdate.ID;
                                if (itemQuestion.SQTId != 1)
                                {
                                    var arrayStaff = new { MultipleTextboxes = new JArray { new JArray { } } };
                                    arrayStaff = JsonConvert.DeserializeAnonymousType(itemQuestion.Value, arrayStaff);
                                    if (arrayStaff.MultipleTextboxes != null && arrayStaff.MultipleTextboxes.Count > 0)
                                    {
                                        for (int i = 0; i < arrayStaff.MultipleTextboxes.Count; i++)
                                        {
                                            if (string.IsNullOrEmpty(arrayStaff.MultipleTextboxes[i]["ID"] + string.Empty))
                                            {
                                                arrayStaff.MultipleTextboxes[i]["ID"] = Guid.NewGuid();
                                            }
                                        }
                                    }
                                    itemQuestion.Value = JsonConvert.SerializeObject(arrayStaff);
                                }
                                else
                                    itemQuestion.Value = null;
                                itemQuestion.Modified = DateTime.Now;
                                itemQuestion.Status = Convert.ToInt16(IsActive);
                                itemQuestion.ModifiedBy = CurrentUser.ID;
                                //Cập nhật giá trị cũ
                                itemQuestion.CreatedBy = SurveyQuestion.CreatedBy;
                                itemQuestion.Created = SurveyQuestion.Created;
                                itemQuestion.Update(itemQuestion);
                            }
                            else
                            {
                                itemQuestion.ID = Guid.NewGuid();
                                if (itemQuestion.SurveyTableId == null || itemQuestion.SurveyTableId == Guid.Empty)
                                    itemQuestion.SurveyTableId = BeanSurveyTableUpdate.ID;
                                if (itemQuestion.SQTId != 1)
                                {
                                    var arrayStaff = new { MultipleTextboxes = new JArray { new JArray { } } };
                                    arrayStaff = JsonConvert.DeserializeAnonymousType(itemQuestion.Value, arrayStaff);
                                    if (arrayStaff.MultipleTextboxes != null && arrayStaff.MultipleTextboxes.Count > 0)
                                    {
                                        for (int i = 0; i < arrayStaff.MultipleTextboxes.Count; i++)
                                        {
                                            if (string.IsNullOrEmpty(arrayStaff.MultipleTextboxes[i]["ID"] + string.Empty))
                                            {
                                                arrayStaff.MultipleTextboxes[i]["ID"] = Guid.NewGuid();
                                            }
                                        }
                                    }
                                    itemQuestion.Value = JsonConvert.SerializeObject(arrayStaff);
                                }
                                else
                                    itemQuestion.Value = null;
                                itemQuestion.Status = Convert.ToInt16(IsActive);
                                itemQuestion.Modified = itemQuestion.Created = DateTime.Now;
                                itemQuestion.ModifiedBy = itemQuestion.CreatedBy = CurrentUser.ID;
                                itemQuestion.Insert(itemQuestion);
                            }
                        }
                    }
                    if(IsActive != 0)
                    {
                        SetPermissionSurvey(CurrentUser, BeanSurveyTableUpdate.ID, BeanSurveyTableUpdate.Permission);
                        SetNotify(CurrentUser, BeanSurveyTableUpdate, BeanSurveyTableUpdate.Permission);
                    }
                }
                else
                {
                    errMess = "Bạn chưa nhập thông tin chung!";
                    SVID = BeanSurveyTableUpdate.ID.ToString();
                }


            }
            catch (Exception ex)
            {
                errMess = ex.Message;
            }
            return SVID;
        }
        public string SaveUnActive(BeanSurveyTable BeanSurveyTableUpdate, ref string errMess)
        {
            string SVID = "";
            try
            {
                if (BeanSurveyTableUpdate.ID != null && BeanSurveyTableUpdate.ID != Guid.Empty)
                {
                    List<Parameter> lstParam = new List<Parameter>();
                    lstParam.Add(new Parameter("tableID", DbType.String, BeanSurveyTableUpdate.ID.ToString()));
                    lstParam.Add(new Parameter("Status", DbType.Int16, "0"));
                    _db.QueryStore("Update_UnActive", lstParam);
                    BeanNotify ModelNotify = new BeanNotify();
                    List<BeanNotify> Notify = ModelNotify.SelectAll().Where(s => s.RelatedID == BeanSurveyTableUpdate.ID).ToList();
                    if (Notify != null && Notify.Count > 0)
                    {
                        RemoveNotify(Notify);

                    }
                    BeanPermission ModelPermission = new BeanPermission();
                    List<BeanPermission> Permission = ModelPermission.SelectAll().Where(s => s.SurveyTableID == BeanSurveyTableUpdate.ID).ToList();
                    if (Permission != null && Permission.Count > 0)
                    {
                        RemovePermission(Permission);

                    }

                }
                else
                {
                    errMess = "Bạn chưa nhập thông tin chung!";
                    SVID = BeanSurveyTableUpdate.ID.ToString();
                }


            }
            catch (Exception ex)
            {
                errMess = ex.Message;
            }
            return SVID;
        }
        public List<UserModel> getlstUserSurvey(string strPermission,bool isNotify = false)
        {
            List<UserModel> result = new List<UserModel>();
            UserModel userModel = new UserModel();
            BeanSetting beanSetting = new BeanSetting();
            BeanGroup beanGroup = new BeanGroup();
            try
            {
                if (string.IsNullOrEmpty(strPermission))
                {
                    beanSetting = beanSetting.SelectAll().Where(s => s.Title == "GroupDefaultSurvey").FirstOrDefault();
                    beanGroup = beanGroup.SelectAll().Where(s => s.Title == beanSetting.Value).FirstOrDefault();
                    strPermission = beanGroup.UserOnGroup;
                }
                if (!isNotify)
                {
                    beanSetting = beanSetting.SelectAll().Where(s => s.Title == "GroupMonitor").FirstOrDefault();
                    beanGroup = beanGroup.SelectAll().Where(s => s.Title == beanSetting.Value).FirstOrDefault();
                    strPermission += beanGroup.UserOnGroup;
                }
                string[] arrUser = strPermission.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                if (arrUser.Length > 0)
                {
                    foreach (string item in arrUser)
                    {
                        UserModel useritem = userModel.SelectByID(Guid.Parse(item));
                        if (useritem != null)
                            result.Add(useritem);
                        else
                        {
                            BeanGroup group = new BeanGroup();
                            group = group.SelectByID(Guid.Parse(item));
                            if (!string.IsNullOrEmpty(group.UserOnGroup) && group.UserOnGroup != null)
                            {
                                List<UserModel> userOnGroup = getlstUserInGroup(group.UserOnGroup);
                                if (userOnGroup.Count > 0)
                                {
                                    result.AddRange(userOnGroup);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {

            }
            result = result.Distinct().ToList();
            return result;
        }
        public List<UserModel> getlstUserInGroup(string strUserOnGroup)
        {
            List<UserModel> result = new List<UserModel>();
            UserModel userModel = new UserModel();
            try
            {
                if (!string.IsNullOrEmpty(strUserOnGroup))
                {
                    string[] arrUser = strUserOnGroup.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                    if (arrUser.Length > 0)
                    {
                        foreach (string item in arrUser)
                        {
                            try
                            {
                                UserModel useritem = userModel.SelectByID(Guid.Parse(item));
                                result.Add(useritem);
                            }
                            catch
                            {

                            }
                        }
                    }
                }

            }
            catch (Exception ex)
            {

            }
            return result;
        }
        public void SetPermissionSurvey(UserModel CurrentUser, Guid guidSurveyTableID, string strPermission)
        {
            List<BeanPermission> Permission = new List<BeanPermission>();
            BeanPermission BeanPermissionUpdate = new BeanPermission();
            UserModel userModel = new UserModel();
            try
            {
                Permission = BeanPermissionUpdate.SelectAll().Where(s => s.SurveyTableID == guidSurveyTableID).ToList();
                if (Permission != null && Permission.Count > 0)
                {
                    RemovePermission(Permission);

                }
                List<UserModel> lstUser = getlstUserSurvey(strPermission);
                foreach (UserModel item in lstUser)
                {
                    BeanPermission ModelPermission = new BeanPermission();
                    ModelPermission.SurveyTableID = guidSurveyTableID;
                    ModelPermission.IsSetting = false;
                    ModelPermission.Permission = "";
                    ModelPermission.AssignTo = item.ID;
                    ModelPermission.Modified = ModelPermission.Created = DateTime.Now;
                    ModelPermission.ModifiedBy = ModelPermission.CreatedBy = CurrentUser.ID;
                    ModelPermission.Insert(ModelPermission);
                }
            }
            catch (Exception ex)
            {

            }
        }
        public void RemovePermission(List<BeanPermission> Permission)
        {
            try
            {
                BeanPermission ModelPermission = new BeanPermission();
                foreach (BeanPermission item in Permission)
                {
                    ModelPermission.Delete(item);
                }
            }
            catch (Exception)
            {

            }
        }
        public List<BeanSurveyTable> GetListSurveyByUserID(UserModel CurrentUser, ref string errMess)
        {
            List<BeanSurveyTable> beanSurveyTable = new List<BeanSurveyTable>();
            BeanSurveyResponses modelSurveyResponses = new BeanSurveyResponses();
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("UserID", DbType.String, CurrentUser.ID.ToString()));
                DataTable data = _db.QueryStoreTable("GetSurveyByUserID", lstParam);
                beanSurveyTable = _db.ConvertToList<BeanSurveyTable>(data);
                if (beanSurveyTable != null && beanSurveyTable.Count > 0)
                {
                    foreach (BeanSurveyTable item in beanSurveyTable)
                    {
                        //if (CurrentUser.Permission == "Admin")
                        //    item.CountSurvey = modelSurveyResponses.SelectAll().Where(s => s.SurveyTableId == item.ID).ToList().Count();
                        //else
                        //    item.CountSurvey = modelSurveyResponses.SelectAll().Where(s => s.SurveyTableId == item.ID && s.UserId == CurrentUser.ID).ToList().Count();
                        item.CountSurvey = modelSurveyResponses.SelectAll().Where(s => s.SurveyTableId == item.ID).ToList().Count();
                        item.isComplete = item.Status >= 1;
                    }
                }
            }
            catch (Exception ex)
            {
                errMess = ex.Message;
            }
            return beanSurveyTable;
        }
        public void SetNotify(UserModel CurrentUser, BeanSurveyTable BeanSurveyTable, string strPermission)
        {
            List<BeanNotify> Notify = new List<BeanNotify>();
            BeanNotify BeanNotifyUpdate = new BeanNotify();
            UserModel userModel = new UserModel();
            try
            {
                Notify = BeanNotifyUpdate.SelectAll().Where(s => s.RelatedID == BeanSurveyTable.ID).ToList();
                if (Notify != null && Notify.Count > 0)
                {
                    RemoveNotify(Notify);

                }
                List<UserModel> lstUser = getlstUserSurvey(strPermission,true);
                foreach (UserModel item in lstUser)
                {
                    BeanNotify ModelNotify = new BeanNotify();
                    ModelNotify.RelatedID = BeanSurveyTable.ID;
                    ModelNotify.LinkUrl = "/Pages/Survey/ToDoSurvey.aspx?IDs=" + BeanSurveyTable.ID.ToString();
                    ModelNotify.Active = true;
                    ModelNotify.OnlyViews = false;
                    ModelNotify.Status = 0;
                    ModelNotify.Title = BeanSurveyTable.Title;
                    ModelNotify.Category = "Khảo  sát";
                    ModelNotify.AssignTo = item.ID;
                    ModelNotify.Created = DateTime.Now;
                    ModelNotify.Overdue = BeanSurveyTable.DueDate;
                    ModelNotify.CreatedBy = CurrentUser.ID;
                    ModelNotify.Insert(ModelNotify);
                }
            }
            catch (Exception ex)
            {

            }
        }
        public void RemoveNotify(List<BeanNotify> Notify)
        {
            try
            {
                BeanNotify ModelNotify = new BeanNotify();
                foreach (BeanNotify item in Notify)
                {
                    ModelNotify.Delete(item);
                }
            }
            catch (Exception)
            {

            }
        }
        public bool CheckPermissionSurvey(UserModel CurrentUser, string strTableID)
        {
            bool result = true;
            try
            {
                BeanSurveyTable ModelBeanSurveyTable = new BeanSurveyTable();
                BeanSurveyTable ModelBeanSurvey = ModelBeanSurveyTable.SelectAll().Where(s => s.ID == Guid.Parse(strTableID) && s.CreatedBy == CurrentUser.ID).FirstOrDefault();
                BeanPermission ModelPermission = new BeanPermission();
                BeanPermission CurrPermission = ModelPermission.SelectAll().Where(s => s.SurveyTableID == Guid.Parse(strTableID) && s.AssignTo == CurrentUser.ID).FirstOrDefault();

                result = CurrPermission != null || ModelBeanSurvey != null || CurrentUser.Permission == "Admin" || CurrentUser.Permission == "GiamSat"; 
            }
            catch (Exception)
            {

            }
            return result;
        }
        public void UpdateCountValueSurvey(Guid QuestionID) {
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("surveyQuestion", DbType.String, QuestionID.ToString()));
                _db.QueryStore("UpdateCountValueSurvey", lstParam);

            }
            catch(Exception ex)
            {

            }
        }
        public DataTable GetDataServeyStatistical(string strSurveyTable,string UserID)
        {
            DataTable data = null;
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("SurveyTableID", DbType.String, strSurveyTable));
                lstParam.Add(new Parameter("UserID", DbType.String, UserID));
                data = _db.QueryStoreTable("GetDataSurveyResponseByTableID", lstParam);

            }
            catch (Exception ex)
            {

            }
            return data;
        }
        public void Sentmail(string TitleMail,string MailTo,string link)
        {
            try
            {
                BeanMailTemplate beanMail = new BeanMailTemplate();
                beanMail = beanMail.SelectAll().Where(s => s.Title == TitleMail).FirstOrDefault();
                if(beanMail != null)
                {
                    var smtpClient = new SmtpClient("smtp.gmail.com")
                    {
                        Port = 587,
                        Credentials = new NetworkCredential("tiennamhcm@gmail.com", "midoxrfsxcdubnsl"),
                        EnableSsl = true,
                        DeliveryMethod = SmtpDeliveryMethod.Network
                    };
                    string strBodyMail = GetContentMail(beanMail.Body,beanMail.ThamSoBody,link);
                    MailMessage mail = new MailMessage();
                    //Setting From , To and CC
                    mail.From = new MailAddress("tiennamhcm@gmail.com", beanMail.Subject);
                    mail.To.Add(new MailAddress(MailTo));
                    mail.Body = strBodyMail;
                    mail.IsBodyHtml = true;
                    smtpClient.Send(mail);
                }
            }
            catch (Exception ex)
            {

            }
        }
        public string GetContentMail(string paramBody,string strBody,string value)
        {
            string str = strBody;
            string[] arrParam = paramBody.Split(new string[] { ";#" }, StringSplitOptions.None);
            if (arrParam.Length > 0)
            {
                string[] arrValue = new string[arrParam.Length];
                for (int i = 0; i < arrParam.Length; i++)
                {
                    if (arrParam[i].Trim().ToLower() == "link")
                    {
                        arrValue[i] = value;
                    }
                    str = str.Replace("{" + i + "}", arrValue[i]);
                    str = str.Replace("&#123;" + i + "&#125;", arrValue[i]);
                }
            }
            return str;
        }
        public DataTable DataReportSLADocument(string Type = "Day", string DateFrom = "", string DateTo = "", string UserID = "")
        {
            List<Parameter> para = new List<Parameter>();
            para.Add(new Parameter("@UserID", DbType.String, UserID));
            para.Add(new Parameter("@Type", DbType.String, Type));
            if (!string.IsNullOrEmpty(DateFrom))
                para.Add(new Parameter("@DateFrom",DbType.Int32, DateFrom));
            if (!string.IsNullOrEmpty(DateTo))
                para.Add(new Parameter("@DateTo", DbType.Int32, DateTo));
            DataTable dtOpt = _db.QueryStoreTable("GetDataReportSurvey", para);
            return dtOpt;
        }
    }
}