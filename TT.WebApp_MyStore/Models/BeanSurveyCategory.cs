using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("SurveyCategory")]
	public class BeanSurveyCategory : DbBase<BeanSurveyCategory>
	{
		[Key]
		[DatabaseGenerated(DatabaseGeneratedOption.Identity)]
		public int ID { get; set; }
		public string Title { get; set; }
		public string TitleEN { get; set; }
		public short Status { get; set; }
		public short? Index { get; set; }
		public DateTime? Modified { get; set; }
		public DateTime? Created { get; set; }
	}
}