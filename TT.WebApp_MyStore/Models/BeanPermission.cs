using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("Permission")]
	public class BeanPermission : DbBase<BeanPermission>
	{
		[Key]
		[DatabaseGenerated(DatabaseGeneratedOption.Identity)]
		public int ID { get; set; }
		public int? RelatedID { get; set; }
		public Guid SurveyTableID { get; set; }
		public string TableRelated { get; set; }
		public string Permission { get; set; }
		public Guid AssignTo { get; set; }
		public bool IsSetting { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifiedBy { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }

	}
}