
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyResponses")]
	public class BeanSurveyResponses : DbBase<BeanSurveyResponses>
	{
		[Key]
		public Guid ID { get; set; }
		public Guid UserId { get; set; }
		public Guid SurveyTableId { get; set; }
		public short? Score { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifiedBy { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
	}
}