
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyQuestion")]
	public class BeanSurveyQuestion : DbBase<BeanSurveyQuestion>
	{
		[Key]
		public Guid ID { get; set; }
		public int SQTId { get; set; }
		public Guid SurveyTableId { get; set; }
		public string Title { get; set; }
		public string Description { get; set; }
		public string Value { get; set; }
		public string Options { get; set; }
		public short Status { get; set; }
		public int? Index { get; set; }
		public int? Page { get; set; }
		public int AnsweredCount { get; set; }
		public string OtherValueCount { get; set; }
		public string ValueCount { get; set; }
		public bool? Required { get; set; }
		public bool? DisableDoAgain { get; set; }
		public bool IsScoring { get; set; }
		public int? Score { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifiedBy { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
	}
}

