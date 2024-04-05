
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyQuestionType")]
	public class BeanSurveyQuestionType : DbBase<BeanSurveyQuestionType>
	{
		[Key]
		public int ID { get; set; }
		public string Title { get; set; }
		public string Description { get; set; }
		public short Status { get; set; }
		public bool IsUsingBranching { get; set; }
		public bool IsQuestionControl { get; set; }
		public int? Index { get; set; }
		public DateTime? Modified { get; set; }
		public DateTime? Created { get; set; }
		public string DefaultOptions { get; set; }
	}
}