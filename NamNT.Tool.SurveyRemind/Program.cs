using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web.UI.WebControls;

namespace NamNT.Tool.SurveyRemind
{
    class Program
    {
        static DBConnect _db = new DBConnect();
        static int IsFunc = 1;
        static void Main(string[] args)
        {
            #region Get config
            Program pro = new Program
            {
               
            };
            #endregion
            pro.Execute();

        }
        private void Execute()
        {

            try
            {
                IsFunc = Convert.ToInt32(ConfigurationManager.AppSettings["IsFunc"] + string.Empty);
                if (IsFunc == 1)
                    SentMailWarningNearDue();
                else if (IsFunc == 2)
                    SentMailWarningOverDue();
            }
            catch (Exception ex)
            {
            }
        }
        static void SentMailWarningNearDue()
        {
            
            try
            {
                DataTable beanMail = GetMailTemplateByTitle("MailTemplate_NearOverdue");
                if (beanMail != null && beanMail.Rows.Count > 0)
                {
                    DataRow beanMailRow = beanMail.Rows[0];
                    DataTable Data = GetNearOverDueDate();
                    List<beanSurveyRemind> lstSurveyRemind = _db.ConvertToList<beanSurveyRemind>(Data);
                    if (lstSurveyRemind != null && lstSurveyRemind.Count > 0)
                    {
                        List<string> lstEmail = lstSurveyRemind.Select(x => x.Email).Distinct().ToList();
                        foreach (var item in lstEmail)
                        {
                            string bodyVieccanxuly = "";
                            string strBodyMail = "";
                            List<beanSurveyRemind> distinctVlue = null;
                            distinctVlue = lstSurveyRemind.Where(s => s.Email == item).ToList();
                            if (distinctVlue.Count > 0)
                            {
                                bodyVieccanxuly += @"<table style='border-collapse: collapse;border: 1px black solid;padding: 5px;width: 100%'><tr style='background-color: darkgray;border-collapse: collapse;border: 1px black solid;padding: 5px;width: 100%'><th style='width: 30px;border: 1px black solid;padding: 5px;'>STT</th><th style='border: 1px black solid;padding: 5px;'>Khảo sát</th><th style='border: 1px black solid;padding: 5px;'>Ngày bắt đầu</th><th style='border: 1px black solid;padding: 5px;'>Hạn hoàn tất</th></tr>";
                                for (int i = 0; i < distinctVlue.Count; i++)
                                {
                                    int dem = i + 1;
                                    bodyVieccanxuly += @"<tr style='border-collapse: collapse;border: 1px black solid;padding: 5px;width: 100%'><td style='border: 1px black solid;padding: 5px;text-align: center;'>" + dem + @"</td><td style='border: 1px black solid;padding: 5px;'><span>" + distinctVlue[i].Title + @"</span></td><td style='border: 1px black solid;padding: 5px;'>" + distinctVlue[i].StartDate.ToString("dd/MM/yyyy") + @"</td><td style='border: 1px black solid;padding: 5px;'>" + distinctVlue[i].DueDate.ToString("dd/MM/yyyy") + @"</td></tr>";
                                }
                                bodyVieccanxuly += @"</table>";
                                strBodyMail = ConvertBodyMail(beanMailRow["ThamSoBody"] + string.Empty, beanMailRow["Body"] + string.Empty, bodyVieccanxuly, distinctVlue.Count.ToString());
                            }
                            Sentmail(beanMailRow["Subject"] + string.Empty, strBodyMail, item);
                        }
                    }
                }

            }
            catch (Exception ex)
            {
                
            }
        }
        static void SentMailWarningOverDue()
        {
            try
            {
                DataTable beanMail = GetMailTemplateByTitle("MailTemplate_Overdue");
                if (beanMail != null && beanMail.Rows.Count > 0)
                {
                    DataRow beanMailRow = beanMail.Rows[0];
                    DataTable Data = GetOverDueDate();
                    List<beanSurveyRemind> lstSurveyRemind = _db.ConvertToList<beanSurveyRemind>(Data);
                    if (lstSurveyRemind != null && lstSurveyRemind.Count > 0)
                    {
                        List<string> lstEmail = lstSurveyRemind.Select(x => x.Email).Distinct().ToList();
                        foreach (var item in lstEmail)
                        {
                            string bodyVieccanxuly = "";
                            string strBodyMail = "";
                            List<beanSurveyRemind> distinctVlue = null;
                            distinctVlue = lstSurveyRemind.Where(s => s.Email == item).ToList();
                            if (distinctVlue.Count > 0)
                            {
                                bodyVieccanxuly += @"<table style='border-collapse: collapse;border: 1px black solid;padding: 5px;width: 100%'><tr style='background-color: darkgray;border-collapse: collapse;border: 1px black solid;padding: 5px;width: 100%'><th style='width: 30px;border: 1px black solid;padding: 5px;'>STT</th><th style='border: 1px black solid;padding: 5px;'>Khảo sát</th><th style='border: 1px black solid;padding: 5px;'>Ngày bắt đầu</th><th style='border: 1px black solid;padding: 5px;'>Hạn hoàn tất</th></tr>";
                                for (int i = 0; i < distinctVlue.Count; i++)
                                {
                                    int dem = i + 1;
                                    bodyVieccanxuly += @"<tr style='border-collapse: collapse;border: 1px black solid;padding: 5px;width: 100%'><td style='border: 1px black solid;padding: 5px;text-align: center;'>" + dem + @"</td><td style='border: 1px black solid;padding: 5px;'><span>" + distinctVlue[i].Title + @"</span></td><td style='border: 1px black solid;padding: 5px;'>" + distinctVlue[i].StartDate.ToString("dd/MM/yyyy") + @"</td><td style='border: 1px black solid;padding: 5px;'>" + distinctVlue[i].DueDate.ToString("dd/MM/yyyy") + @"</td></tr>";
                                }
                                bodyVieccanxuly += @"</table>";
                                strBodyMail = ConvertBodyMail(beanMailRow["ThamSoBody"] + string.Empty, beanMailRow["Body"] + string.Empty, bodyVieccanxuly, distinctVlue.Count.ToString());
                            }
                            Sentmail(beanMailRow["Subject"] + string.Empty, strBodyMail, item);
                            string strNumOverDue = GetSettingByTitle("OverNum");
                            DateTime ToDay = DateTime.Now.AddDays(Convert.ToInt32(strNumOverDue));
                            for (int i = 0; i < distinctVlue.Count; i++)
                            {
                                UpdateOverDue(distinctVlue[i].ID + string.Empty, ToDay);
                            } 
                        }
                    }
                }

            }
            catch (Exception ex)
            {

            }
        }
        static void Sentmail(string strSubjectMail,string strBodyMail, string MailTo)
        {
            try
            {
                var smtpClient = new SmtpClient("smtp.gmail.com")
                {
                    Port = 587,
                    Credentials = new NetworkCredential("tiennamhcm@gmail.com", "midoxrfsxcdubnsl"),
                    EnableSsl = true,
                    DeliveryMethod = SmtpDeliveryMethod.Network
                };
                MailMessage mail = new MailMessage();
                //Setting From , To and CC
                mail.From = new MailAddress("tiennamhcm@gmail.com", strSubjectMail);
                mail.To.Add(new MailAddress(MailTo));
                mail.Body = strBodyMail;
                mail.IsBodyHtml = true;
                smtpClient.Send(mail);
            }
            catch (Exception ex)
            {

            }
        }
        static DataTable GetNearOverDueDate()
        {
            
            DataTable vlue = null;
            DateTime ToDay = DateTime.Now;
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("NearOverDateNum", DbType.Int32, ToDay.ToString("yyyyMMdd")));
                vlue = _db.QueryStoreTable("NamNT_GetNearOverDue", lstParam);
            }
            catch (Exception ex)
            {

            }
            return vlue;
        }
        static DataTable GetOverDueDate()
        {

            DataTable vlue = null;
            DateTime ToDay = DateTime.Now;
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("OverDateNum", DbType.Int32, ToDay.ToString("yyyyMMdd")));
                vlue = _db.QueryStoreTable("NamNT_GetOverDue", lstParam);
            }
            catch (Exception ex)
            {

            }
            return vlue;
        }
        static void UpdateOverDue(string tableID,DateTime ToDay)
        {
            DataTable vlue = null;
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("OverDateNum", DbType.Int32, ToDay.ToString("yyyyMMdd")));
                lstParam.Add(new Parameter("SurveyTableID", DbType.Guid, tableID));
                vlue = _db.QueryStoreTable("NamNT_UpdateNumOverDue", lstParam);
            }
            catch (Exception ex)
            {

            }
        }
        static DataTable GetMailTemplateByTitle(string title)
        {

            DataTable vlue = null;
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("TitleMail", DbType.String, title));
                vlue = _db.QueryStoreTable("NamNT_GetMailTemplate", lstParam);
            }
            catch (Exception ex)
            {

            }
            return vlue;
        }
        static string GetSettingByTitle(string title)
        {

            string vlue = "";
            try
            {
                List<Parameter> lstParam = new List<Parameter>();
                lstParam.Add(new Parameter("Title", DbType.String, title));
                DataTable datavlue = _db.QueryStoreTable("NamNT_GetSettingsByTitle", lstParam);
                if(datavlue != null && datavlue.Rows.Count > 0)
                {
                    vlue = datavlue.Rows[0]["Value"] + string.Empty;
                }
            }
            catch (Exception ex)
            {

            }
            return vlue;
        }
        static string ConvertBodyMail(string paramBody, string strBody, string Mail, string Socongviec)
        {
            string str = strBody;
            string[] arrParam = paramBody.Split(new string[] { ";#" }, StringSplitOptions.None);
            if (arrParam.Length > 0)
            {

                string[] arrValue = new string[arrParam.Length];
                for (int i = 0; i < arrParam.Length; i++)
                {
                    if (arrParam[i].Trim().ToLower() == "socongviecquahan")
                    {
                        arrValue[i] = Socongviec;
                    }
                    else if (arrParam[i].ToLower().Contains("vieccanxuly"))
                    {
                        arrValue[i] = Mail;
                    }
                    str = str.Replace("{" + i + "}", arrValue[i]);
                    str = str.Replace("&#123;" + i + "&#125;", arrValue[i]);
                }
            }
            return str;
        }
    }
    public class beanSurveyRemind
    {
        public Guid ID { get; set; }
        public string Title { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime StartDate { get; set; }
        public Guid AssignTo { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public int sl { get; set; }
    }
}
