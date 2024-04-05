using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;

namespace TT.WebApp_MyStore.Models
{
	[Table("Notify")]
	public class BeanNotify : DbBase<BeanNotify>
	{
		[Key]
		[DatabaseGenerated(DatabaseGeneratedOption.Identity)]
		public int ID { get; set; }
		public bool? OnlyViews { get; set; }
		public int? Status { get; set; }
		public string Title { get; set; }
		public string LinkUrl { get; set; }
		public Guid AssignTo { get; set; }
		public string Category { get; set; }
		public Guid RelatedID { get; set; }
		public Guid CreatedBy { get; set; }
		
		public bool Active { get; set; }
		public DateTime Created { get; set; }
		public DateTime? Overdue { get; set; }
		public DateTime? Modified { get; set; }

		[NotMapped]
		public string NguoiTao { get; set; }
		[NotMapped]
		public string strTime { get; set; }
		[NotMapped]
		public bool isOverDue { get; set; }
	}
}