using CsvHelper.Configuration.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TT.WebApp_MyStore.Areas;

namespace TT.WebApp_MyStore.Models
{
    [Table("RoleMaster")]
    public class RoleMasterModel:DbBase<RoleMasterModel>
    {
        [Key]
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public string RoleUrl { get; set; }
        public DateTime? Created { get; set; }
        public string CreateBy { get; set; }
        public DateTime? Modified { get; set; }
        public string ModifiBy { get; set; }

        [NotMapped]
        public List<UserModel> Users { get; set; }
    }
}