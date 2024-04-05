using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using TT.WebApp_MyStore.Areas;

namespace TT.WebApp_MyStore.Models
{
	[Table("MailTemplate")]
	public class BeanMailTemplate : DbBase<BeanMailTemplate>
    {
		[Key]
		[DatabaseGenerated(DatabaseGeneratedOption.Identity)]
		public int ID { get; set; }
		public string Title { get; set; }
		public string Subject { get; set; }
		public string SubjectEN { get; set; }
		public string ThamSoSubject { get; set; }
		public string Body { get; set; }
		public string ThamSoBody { get; set; }
		public string Module { get; set; }
		public DateTime? Created { get; set; }
		public Guid CreatedBy { get; set; }
		public DateTime? Modified { get; set; }
		public Guid ModifyBy { get; set; }
	}
}