using CsvHelper.Configuration.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;

namespace TT.WebApp_MyStore.Models
{
    [Table("MenuUsers")]
    public class MenuUsersModel : DbBase<MenuUsersModel>
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public string Title { get; set; }
        public string TitleEN { get; set; }
        public int? ParentId { get; set; }
        public string Code { get; set; }
        public bool? Expanded { get; set; }
        public string Url { get; set; }
        public string Icon { get; set; }
        public int? Index { get; set; }
        public int? Status { get; set; }
        public DateTime? Created { get; set; }
        public string CreateBy { get; set; }
        public DateTime? Modified { get; set; }
        public string ModifiBy { get; set; }

        [NotMapped]
        public List<MenuUsersModel> Items { get; set; }
    }
}