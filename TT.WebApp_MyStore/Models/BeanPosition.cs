using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("Position")]
	public class BeanPosition : DbBase<BeanPosition>
	{
		[Key]
		public int ID { get; set; }
		public string PositionName { get; set; }
		public string PositionCode { get; set; }
		public bool? Status { get; set; }
		public DateTime Modified { get; set; }
		public DateTime Created { get; set; }
		public Guid ModifiedBy { get; set; }
		public Guid CreatedBy { get; set; }
	}
}
