using CsvHelper;
using Microsoft.VisualBasic.ApplicationServices;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Core;
using System.Linq;
using System.Reflection.Emit;
using System.Web.Configuration;
using TT.WebApp_MyStore.Models;

namespace TT.WebApp_MyStore.Areas
{
    public class DbBase:DbContext
    {
        public DbSet<UserModel> User { get; set; }
        public DbSet<BeanNotify> Notify { get; set; }
        //public DbSet<RoleMasterModel> Role { get; set; }
        public DbSet<MenuSettingModel> MenuSettings{ get; set; }
        //public DbSet<MenuUsersModel> MenuUsers { get; set; }
        public DbSet<BeanGroup> Group { get; set; }
        public DbSet<BeanMailTemplate> BeanMailTemplate { get; set; }
        public DbSet<BeanSurveyCategory> BeanSurveyCategory { get; set; }
        public DbSet<BeanSurveyPage> BeanSurveyPage { get; set; }
        public DbSet<BeanSurveyQuestion> BeanSurveyQuestion { get; set; }
        public DbSet<BeanSurveyQuestionTemplate> BeanSurveyQuestionTemplate { get; set; }
        public DbSet<BeanSurveyQuestionType> BeanSurveyQuestionType { get; set; }
        public DbSet<BeanSurveyResponses> BeanSurveyResponses { get; set; }
        public DbSet<BeanSurveyResponsesValue> BeanSurveyResponsesValue { get; set; }
        public DbSet<BeanSurveyTable> BeanSurveyTable { get; set; }
        public DbSet<BeanPermission> BeanPermission { get; set; }
        public DbSet<BeanSetting> BeanSetting { get; set; }
        public DbSet<BeanPermissionList> BeanPermissionList { get; set; }
        public DbSet<BeanPosition> BeanPosition { get; set; }
    }

    public class DbBase<T> where T : class
    {
        public DbSet<T> DBBase { get; set; }

        public virtual List<T> SelectAll()
        {
            using (var context = new DbBase())
            {
                return context.Set<T>().ToList();
            }
        }
        public T SelectByID(object ID)
        {
            using (var context = new DbBase())
            {
                return context.Set<T>().Find(ID);
            }
        }

        public virtual void Insert(T entity)
        {
            using (var context = new DbBase())
            {
                context.Entry(entity).State = EntityState.Added;
                context.SaveChanges();
            }
        }

        public virtual void Update(T entity)
        {
            using (var context = new DbBase())
            {
                context.Entry(entity).State = EntityState.Modified;
                context.SaveChanges();
            }
        }

        public virtual void Delete(T entity)
        {
            using (var context = new DbBase())
            {
                context.Entry(entity).State = EntityState.Deleted;
                context.SaveChanges();
            }
        }
    }
}