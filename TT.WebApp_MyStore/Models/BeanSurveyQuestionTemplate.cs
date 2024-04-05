
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyQuestionTemplate")]
	public class BeanSurveyQuestionTemplate : DbBase<BeanSurveyQuestionTemplate>
	{
		[Key]
		public string ID { get; set; }
		public int SQTId { get; set; }
		public int? SCId { get; set; }
		public string Title { get; set; }
		public string Description { get; set; }
		public string Value { get; set; }
		public bool Required { get; set; }
		public string Formula { get; set; }
		public string FormulaMessage { get; set; }
		public int? Index { get; set; }
		public string Options { get; set; }
		public bool DisableDoAgain { get; set; }
		public DateTime? Modified { get; set; }
		public string ModifiedBy { get; set; }
		public DateTime? Created { get; set; }
		public string CreatedBy { get; set; }
	}
}