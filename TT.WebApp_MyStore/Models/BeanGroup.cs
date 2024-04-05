using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using TT.WebApp_MyStore.Areas;

namespace TT.WebApp_MyStore.Models
{

	[Table("Group")]
	public class BeanGroup : DbBase<BeanGroup>
	{
		[Key]
		public Guid ID { get; set; }
		public string TitleEN { get; set; }
		public string Title { get; set; }
		public bool? IsActive { get; set; }
		public string UserOnGroup { get; set; }
		public bool? IsManagerGroup { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifyBy { get; set; }
	}
}