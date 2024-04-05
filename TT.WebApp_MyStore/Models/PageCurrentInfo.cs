using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TT.WebApp_MyStore.Models
{
    public class PageCurrentInfo
    {
        public int LanguageId { get; set; }
        public string StrDate { get; set; }
        public string StrDateTime { get; set; }
        public string StrDateSQL { get; set; }
        public string MenuParent { get; set; }
        public string MenuSelected { get; set; }
    }
}