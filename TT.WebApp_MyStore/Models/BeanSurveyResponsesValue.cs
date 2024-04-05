
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyResponsesValue")]
	public class BeanSurveyResponsesValue : DbBase<BeanSurveyResponsesValue>
	{
		[Key]
		public Guid ID { get; set; }
		public Guid SurveyResponsesId { get; set; }
		public Guid SurveyQuestionId { get; set; }
		public Guid UserID { get; set; }
		public string Value { get; set; }
		public bool Skipped { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifiedBy { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
		public string OtherValue { get; set; }
		public bool Status { get; set; }
		public short? Score { get; set; }
	}
}