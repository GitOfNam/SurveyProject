
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;
namespace TT.WebApp_MyStore.Models
{
	[Table("Setting")]
	public class BeanSetting : DbBase<BeanSetting>
	{
		[Key]
		public int ID { get; set; }
		public string Descript { get; set; }
		public string Title { get; set; }
		public string Value { get; set; }
		public bool? IsActive { get; set; }
	}
}