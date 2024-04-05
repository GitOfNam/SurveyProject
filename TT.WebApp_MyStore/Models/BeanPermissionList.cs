
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("PermissionList")]
	public class BeanPermissionList : DbBase<BeanPermissionList>
	{
		[Key]
		[DatabaseGenerated(DatabaseGeneratedOption.Identity)]
		public Guid ID { get; set; }
		public string PermissionName { get; set; }
		public string PermissionNameEN { get; set; }
		public bool IsActive { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifiedBy { get; set; }
	}
}
