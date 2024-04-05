using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TT.WebApp_MyStore.Pages.Survey
{
    public partial class AddNewSurvey : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(Page.User.Identity.Name) || !Page.User.Identity.IsAuthenticated)
                Response.Redirect("/Pages/Login.aspx");
            string _lang = Context.Session["LanguageId"] != null && !string.IsNullOrEmpty(Context.Session["LanguageId"] + string.Empty) ? Context.Session["LanguageId"] + string.Empty : "1066";
            if (_lang == "1066")
            {
                lbTitle.InnerText = "Tiêu đề";
                lbSurveyCategory.InnerText = "Loại";
                lbFromDate.InnerText = "Ngày bắt đầu";
                lbToDate.InnerText = "Ngày kết thúc";
                lbMoTa.InnerText = "Mô tả";
                lbUserOnGroup.InnerText = "Đối tượng khảo sát";
                lbAllowMultipleResponses.InnerText = "Đánh giá nhiều lần";
                lbCalScore.InnerText = "Tính điểm";
                lbRankAll.InnerText = "Xem bảng xếp hạng tổng";
                lbRankDaily.InnerText = "Xem bảng xếp hạng theo ngày";
                lbUserSurvey.InnerText = "Người đánh giá";
                lbEmail.InnerText = "Email";
                lbSearchFromDate.InnerText = "Từ";
                lbSearchToDate.InnerText = "Đến";
                btnExportStatistical.Value = "Xuất Excel";
                btnSearchSurvey.Value = "Tìm kiếm";
            }
            else
            {
                lbTitle.InnerText = "Title";
                lbSurveyCategory.InnerText = "Category";
                lbFromDate.InnerText = "From";
                lbToDate.InnerText = "To";
                lbMoTa.InnerText = "Descript";
                lbUserOnGroup.InnerText = "User Survey";
                lbAllowMultipleResponses.InnerText = "Allow Multiple Responses";
                lbCalScore.InnerText = "Score";
                lbRankAll.InnerText = "Rank All";
                lbRankDaily.InnerText = "Rank Daily";
                lbUserSurvey.InnerText = "User Name";
                lbEmail.InnerText = "Email";
                lbSearchFromDate.InnerText = "FromDate";
                lbSearchToDate.InnerText = "ToDate";
                btnExportStatistical.Value = "Export Statistical";
                btnSearchSurvey.Value = "Search";
            }
        }
    }
}