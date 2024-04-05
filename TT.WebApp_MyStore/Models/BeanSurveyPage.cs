using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyPage")]
	public class BeanSurveyPage : DbBase<BeanSurveyPage>
	{
		[Key]
		public Guid ID { get; set; }
		public Guid SurveyTableId { get; set; }
		public string Title { get; set; }
		public short Status { get; set; }
		public int? Index { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifiedBy { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
		public string Options { get; set; }
	}
}
