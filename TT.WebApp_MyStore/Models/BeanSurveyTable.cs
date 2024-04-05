
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyTable")]
	public class BeanSurveyTable : DbBase<BeanSurveyTable>
	{
		[Key]
		public Guid ID { get; set; }
		public int SCID { get; set; }
		public string Title { get; set; }
		public short Status { get; set; }
		public int NearOverDateNum { get; set; }
		public int OverDateNum { get; set; }
		public DateTime StartDate { get; set; }
		public DateTime? DueDate { get; set; }
		public string Permission { get; set; }
		public bool? IsCalScore { get; set; }
		public string Description { get; set; }
		public bool AllowMultipleResponses { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifiedBy { get; set; }
		public DateTime? DesignModified { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
		[NotMapped]
		public int CountSurvey { get; set; } = 0;
		[NotMapped]
		public bool design { get; set; } = false;
		[NotMapped]
		public bool isComplete { get; set; }
		[NotMapped]
		public bool collect { get; set; } = false;
		[NotMapped]
		public bool analyze { get; set; } = false;

	}
}