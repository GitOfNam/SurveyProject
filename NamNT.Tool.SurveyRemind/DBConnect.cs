using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI.WebControls;

namespace NamNT.Tool.SurveyRemind
{
    public class DBConnect
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["DbBase"]+ string.Empty);
        public void QueryStr(string query)
        {
            if (con.State == ConnectionState.Closed)
            {
                con.Open();
            }
            SqlCommand cmd = new SqlCommand(query, con);
            cmd.ExecuteNonQuery();
            con.Close();
        }

        public void QueryStore(string store, List<Parameter> parameters)
        {
            if (con.State == ConnectionState.Closed)
            {
                con.Open();
            }
            SqlCommand cmd = new SqlCommand(store, con);
            cmd.CommandType = CommandType.StoredProcedure;
            foreach (var prop in parameters)
            {
                if (prop.DefaultValue != null)
                {
                    var param = cmd.CreateParameter();
                    param.ParameterName = prop.Name;
                    param.DbType = prop.DbType;
                    param.Value = prop.DefaultValue;
                    cmd.Parameters.Add(param);
                }
            }
            cmd.ExecuteNonQuery();
            con.Close();
        }

        public DataTable QueryStrTable(string query)
        {
            if (con.State == ConnectionState.Closed)
            {
                con.Open();
            }
            SqlCommand cmd = new SqlCommand(query, con);
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            DataTable table = new DataTable();
            adapter.Fill(table);
            return table;
        }

        public DataTable QueryStoreTable(string store, List<Parameter> parameters)
        {
            if (con.State == ConnectionState.Closed)
            {
                con.Open();
            }
            SqlCommand cmd = new SqlCommand(store, con);
            cmd.CommandType = CommandType.StoredProcedure;
            foreach (var prop in parameters)
            {
                if (prop.DefaultValue != null)
                {
                    var param = cmd.CreateParameter();
                    param.ParameterName = prop.Name;
                    param.DbType = prop.DbType;
                    param.Value = prop.DefaultValue;
                    cmd.Parameters.Add(param);
                }
            }
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            DataTable table = new DataTable();
            adapter.Fill(table);
            return table;
        }

        public List<T> ConvertToList<T>(DataTable dt)
        {
            var columnNames = dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName.ToLower()).ToList();
            var properties = typeof(T).GetProperties();
            return dt.AsEnumerable().Select(row => {
                var obj = Activator.CreateInstance<T>();
                foreach (var pro in properties)
                {
                    if (columnNames.Contains(pro.Name.ToLower()))
                    {
                        try
                        {
                            Guid o;
                            bool isValid = Guid.TryParse(row[pro.Name] + "", out o);
                            if (isValid)
                            {
                                pro.SetValue(obj, Guid.Parse(row[pro.Name] + ""));
                            }
                            else
                                pro.SetValue(obj, row[pro.Name]);
                        }
                        catch (Exception ex)
                        { }
                    }
                }
                return obj;
            }).ToList();
        }

    }
}
