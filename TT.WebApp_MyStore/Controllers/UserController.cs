using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Models;
using System.Web.Mvc;
using System;
using System.Net.Mail;
using System.Net;

namespace TT.WebApp_MyStore.Controllers
{
    public class UserController:Controller
    {
        CmmFunc _db = new CmmFunc();
        public object MenuSettingsGetAll(int LanguageId,UserModel curUser)
        {
            List<Parameter> lstParam = new List<Parameter>();
            lstParam.Add(new Parameter("languageId", DbType.Int32, LanguageId + ""));
            DataTable data = _db.QueryStoreTable("Bos_MySQL_MenuSettings_GetAll", lstParam);
            List<MenuSettingModel> MenuSetting = new List<MenuSettingModel>();
            List<MenuSettingModel> MenuAll = new List<MenuSettingModel>();
            List<MenuSettingModel> res = new List<MenuSettingModel>();
            
            MenuSetting = _db.ConvertToList<MenuSettingModel>(data);
            foreach (MenuSettingModel item in MenuSetting)
            {
                var resData = MenuSetting.Where(s => s.ParentId == item.ID).ToList();
                item.Items = resData;
                if (item.ParentId == 0 || item.ParentId == null)
                    MenuAll.Add(item);
            }
            BeanPermission ModelPermission = new BeanPermission();
            foreach(MenuSettingModel itemChild in MenuAll)
            {
                var isExist = ModelPermission.SelectAll().Where(s => s.Permission == curUser.Permission && s.IsSetting == true && s.TableRelated == "Menu" && s.RelatedID == itemChild.ID).FirstOrDefault();
                if(isExist != null)
                {
                    if (itemChild.Items.Count > 0)
                    {
                        List<MenuSettingModel> resItems = new List<MenuSettingModel>();
                        foreach (MenuSettingModel itemsChild in itemChild.Items)
                        {
                            var isExistitem = ModelPermission.SelectAll().Where(s => s.Permission == curUser.Permission && s.IsSetting == true && s.TableRelated == "Menu" && s.RelatedID == itemsChild.ID).FirstOrDefault();
                            if(isExistitem != null)
                            {
                                resItems.Add(itemsChild);
                            }
                        }
                        itemChild.Items = resItems;
                    }
                    res.Add(itemChild);
                }
            }
            return res;
        }
        public List<BeanNotify> GetListNotify(string userID,string limit = "")
        {
            List<BeanNotify> beanNotifies = new List<BeanNotify>();
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("AccountID", DbType.String, userID));
                if(!string.IsNullOrEmpty(limit))
                    lstParam.Add(new Parameter("RowLimit", DbType.Int32, limit));
                DataTable data = _db.QueryStoreTable("NamNT_GetLstNotifyByUser", lstParam);
                beanNotifies = _db.ConvertToList<BeanNotify>(data);
                if(beanNotifies.Count > 0)
                {
                    foreach(BeanNotify item in beanNotifies)
                    {
                        TimeSpan ts = DateTime.Now - item.Created;

                        if (Math.Round(ts.TotalDays,2) < 1)
                        {
                            if(Math.Round(ts.TotalHours, 2) <1)
                            {
                                if(Math.Round(ts.TotalMinutes, 2) <= 5)
                                    item.strTime = "Vừa xong";
                                else
                                    item.strTime = ts.TotalMinutes.ToString("00") + " phút trước";
                            }
                            else
                                item.strTime = ts.TotalHours.ToString("00") + " giờ trước";
                        }
                        else
                        {
                            if(Math.Round(ts.TotalDays, 2) <= 1)
                                item.strTime = "Hôm qua";
                            else
                                item.strTime = Math.Round(ts.TotalDays, 0).ToString("00") + " ngày trước";
                        }
                        if(item.Overdue != null)
                        {
                            TimeSpan tsOver = DateTime.Now - (DateTime)item.Overdue;
                            if(Math.Round(tsOver.TotalMinutes, 2) > 0)
                            {
                                item.isOverDue = true;
                            }
                        }
                    }
                    
                }
                
            }
            catch(Exception ex)
            {

            }
            return beanNotifies;
        }
        public int GetCountNotify(string userID)
        {
            int numTask = 0;
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("AccountID", DbType.String, userID));
                DataTable data = _db.QueryStoreTable("NamNT_GetCountNotifyByUser", lstParam);
                if(data != null)
                {
                    numTask = Convert.ToInt32(data.Select()[0]["numTask"]);
                }
            }
            catch (Exception ex)
            {

            }
            return numTask;
        }
        public DataTable GetCountChart(string userID)
        {
            DataTable DTdata = null;
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("UserID", DbType.String, userID));
                DTdata = _db.QueryStoreTable("GetCountChart", lstParam);
            }
            catch (Exception ex)
            {

            }
            return DTdata;
        }
        public DataTable GetListUser()
        {
            DataTable Dt = new DataTable();
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                Dt = _db.QueryStoreTable("NamNT_GetListUser", lstParam);
            }
            catch (Exception ex)
            {

            }
            return Dt;
        }
        public DataTable Get_UserAndGroup(string UserID)
        {
            DataTable Dt = new DataTable();
            Dt.Columns.Add("ID");
            Dt.Columns.Add("Title");
            try
            {
                UserModel user = new UserModel();
                List<UserModel> lstUser = user.SelectAll().Where(a => a.ID != Guid.Parse(UserID)).ToList();
                BeanGroup group = new BeanGroup();
                List<BeanGroup> lstGroup = group.SelectAll().Where(a => a.UserOnGroup.Contains(UserID)).ToList();
                if(lstUser.Count > 0)
                {
                    foreach(UserModel itemModel in lstUser)
                    {
                        DataRow row = Dt.NewRow();
                        row["ID"] = itemModel.ID;
                        row["Title"] =itemModel.AccountName;
                        Dt.Rows.Add(row);
                    }
                }
                if (lstGroup.Count > 0)
                {
                    foreach (BeanGroup item in lstGroup)
                    {
                        DataRow row = Dt.NewRow();
                        row["ID"] = item.ID;
                        row["Title"] = item.Title;
                        Dt.Rows.Add(row);
                    }
                }

            }
            catch (Exception ex)
            {

            }
            return Dt;
        }
        public void UpdateChangePass(Guid UserID,string newPass)
        {
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("UserID", DbType.String, UserID.ToString()));
                lstParam.Add(new Parameter("NewPass", DbType.String, newPass));
                _db.QueryStore("UpdatePassWord", lstParam);

            }
            catch (Exception ex)
            {

            }
        }
        public void Sentmail(string TitleMail, string MailTo, string link)
        {
            try
            {
                BeanMailTemplate beanMail = new BeanMailTemplate();
                beanMail = beanMail.SelectAll().Where(s => s.Title == TitleMail).FirstOrDefault();
                if (beanMail != null)
                {
                    var smtpClient = new SmtpClient("smtp.gmail.com")
                    {
                        Port = 587,
                        Credentials = new NetworkCredential("tiennamhcm@gmail.com", "midoxrfsxcdubnsl"),
                        EnableSsl = true,
                        DeliveryMethod = SmtpDeliveryMethod.Network
                    };
                    string strBodyMail = GetContentMail(beanMail.ThamSoBody, beanMail.Body, link);
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
        public string GetContentMail(string paramBody, string strBody, string value)
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
    }
}