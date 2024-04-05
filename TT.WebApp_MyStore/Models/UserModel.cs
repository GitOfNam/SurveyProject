using CsvHelper.Configuration.Attributes;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;

namespace TT.WebApp_MyStore.Models
{
    [Table("PersonalProfile")]
    public class UserModel:DbBase<UserModel>
    {
        [Key]
		public Guid ID { get; set; }
		public string AccountName { get; set; }
		public string Password { get; set; }
		public string FullName { get; set; }
		public int DepartmentID { get; set; }
		public string Department { get; set; }
		public string Manager { get; set; }
		public bool Gender { get; set; }
		public DateTime? BirthDay { get; set; }
		public string Address { get; set; }
		public string Image { get; set; }
		public string Mobile { get; set; }
		public bool? IsRanking { get; set; }
		public string Email { get; set; }
		public string Position { get; set; }
		public byte[] ImagePath { get; set; }
		public string Permission { get; set; }
		public int UserStatus { get; set; }
		public bool? IsDeleted { get; set; }
		public DateTime UserModified { get; set; }
		public int? LanguageId { get; set; }
		public string KeyChangePass { get; set; }
	}
}