using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Controllers
{
    public class AdminController:Controller
    {
        CmmFunc _db = new CmmFunc();
        public object MenuSettingsGetAll(int LanguageId)
        {
            List<Parameter> lstParam = new List<Parameter>();
            lstParam.Add(new Parameter("languageId", DbType.Int32, LanguageId + ""));
            DataTable data = _db.QueryStoreTable("Bos_MySQL_MenuSettings_GetAll", lstParam);
            List<MenuSettingModel> MenuSetting = new List<MenuSettingModel>();
            List<MenuSettingModel> res = new List<MenuSettingModel>();
            MenuSetting = _db.ConvertToList<MenuSettingModel>(data);
            foreach(MenuSettingModel item in MenuSetting)
            {
                var resData= MenuSetting.Where(s => s.ParentId == item.ID).ToList();
                item.Items = resData;
                if(item.ParentId == 0 || item.ParentId == null)
                    res.Add(item);
            }
            return res;
        }
    }
}