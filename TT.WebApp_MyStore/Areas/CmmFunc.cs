using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Web.Security;
using System.Web.UI;

namespace TT.WebApp_MyStore.Models
{
    public class CmmFunc:Control
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["DbBase"].ConnectionString);
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
                if(prop.DefaultValue != null)
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

        //public void ExportExcel(string strFileTemplate, DataTable dataTable, int iRowDetail, int iRow, string strColChar, string strColName, string extension = ".xlsx", string fileName = "")
        //{
        //    try
        //    {
        //        var templateFilePath = ServerMapPath("/Scripts/ExcelTemplate/" + strFileTemplate + ".xlsx");
        //        HttpRequest request = HttpContext.Current.Request;
        //        byte[] fileBinary;
        //        using (Stream stream = File.OpenRead(templateFilePath))
        //        {
        //            ExcelPackage pkg = new ExcelPackage(stream);
        //            var wsSource = pkg.Workbook.Worksheets["Sheet1"];
        //            string[] arrChar = strColChar.Split(';');
        //            string[] arrCol = strColName.Split(';');

        //            if (dataTable != null && dataTable.Rows.Count > 0)
        //            {
        //                foreach (DataRow item in dataTable.Rows)
        //                {
        //                    for (int i = 0; i < arrChar.Length; i++)
        //                    {
        //                        if (iRow > iRowDetail)
        //                        {
        //                            wsSource.Cells[arrChar[i] + iRowDetail].Copy(wsSource.Cells[arrChar[i] + iRow]);
        //                        }

        //                        //if (arrCol[i].Equals("StorageCode") || arrCol[i].Equals("Title"))
        //                        //{
        //                        //    wsSource.Cells[arrChar[i] + iRow].Hyperlink = new Uri(request.Url.Scheme + @"://" + request.Url.Authority + item["Url"]);
        //                        //    wsSource.Cells[arrChar[i] + iRow].Style.Font.UnderLine = true;
        //                        //    wsSource.Cells[arrChar[i] + iRow].Style.Font.Color.SetColor(ColorTranslator.FromHtml("#049BEB"));
        //                        //}

        //                        //if (arrCol[i].Equals("EffectiveEndDate") || arrCol[i].Equals("IssueDate") || arrCol[i].Equals("EffectiveStartDate") || arrCol[i].Equals("PublishDate"))
        //                        //    wsSource.Cells[arrChar[i] + iRow].Value = !string.IsNullOrEmpty(item[arrCol[i]] + string.Empty) ? DateTime.Parse(item[arrCol[i]] + string.Empty, CultureInfo.CurrentUICulture, DateTimeStyles.None).ToString("dd/MM/yyyy") : string.Empty;
        //                        //else if (arrCol[i].Equals("Version"))
        //                        //{
        //                        //    if (!string.IsNullOrEmpty(item[arrCol[i]] + string.Empty))
        //                        //    {
        //                        //        string strVersion = (!string.IsNullOrEmpty(item[arrCol[i]] + string.Empty) || item[arrCol[i]] + string.Empty != "0") ? (Int32.Parse(item[arrCol[i]] + string.Empty) / 100) + "." + (Int32.Parse(item[arrCol[i]] + string.Empty) % 100) : string.Empty;
        //                        //        if (!string.IsNullOrEmpty(strVersion))
        //                        //            wsSource.Cells[arrChar[i] + iRow].Value = strVersion;
        //                        //    }
        //                        //    else
        //                        //    {
        //                        //        wsSource.Cells[arrChar[i] + iRow].Value = item[arrCol[i]] + string.Empty;
        //                        //    }
        //                        //}
        //                        //else if (arrCol[i].Equals("StorageCode") || arrCol[i].Equals("Code"))
        //                        //{
        //                        //    wsSource.Cells[arrChar[i] + iRow].Value = (item[arrCol[i]] + string.Empty).Replace("Ð", "Đ");
        //                        //}
        //                        //else
        //                            wsSource.Cells[arrChar[i] + iRow].Value = item[arrCol[i]] + string.Empty;
        //                    }

        //                    iRow++;
        //                }
        //            }
        //            pkg.Save();
        //            fileBinary = ReadToEnd(pkg.Stream);
        //        }

        //        if (fileBinary != null)
        //        {
        //            if (string.IsNullOrEmpty(fileName))
        //                fileName = DateTime.Today.Year + "." + DateTime.Today.Month.ToString("00") + "." + DateTime.Today.Day.ToString("00") + " ExportExcel";

        //            HttpResponse response = HttpContext.Current.Response;
        //            response.Clear();
        //            response.Charset = string.Empty;
        //            response.BinaryWrite(fileBinary);
        //            response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        //            response.AddHeader("Content-Disposition", "attachment;filename=\"" + fileName + extension + "\"");
        //            response.Flush();
        //            response.End();
        //        }
        //    }
        //    catch{}
        //}

        public static string ServerMapPath(string path)
        {
            string retValue = path.TrimStart('/');
            if (path.IndexOf(":", StringComparison.Ordinal) < 0 && !path.StartsWith("\\\\"))
            {
                retValue = HttpContext.Current.Server.MapPath("~/" + retValue);
            }
            return retValue;
        }

        private byte[] ReadToEnd(Stream stream)
        {
            long originalPosition = 0;

            if (stream.CanSeek)
            {
                originalPosition = stream.Position;
                stream.Position = 0;
            }

            try
            {
                byte[] readBuffer = new byte[4096];

                int totalBytesRead = 0;
                int bytesRead;

                while ((bytesRead = stream.Read(readBuffer, totalBytesRead, readBuffer.Length - totalBytesRead)) > 0)
                {
                    totalBytesRead += bytesRead;

                    if (totalBytesRead == readBuffer.Length)
                    {
                        int nextByte = stream.ReadByte();
                        if (nextByte != -1)
                        {
                            byte[] temp = new byte[readBuffer.Length * 2];
                            System.Buffer.BlockCopy(readBuffer, 0, temp, 0, readBuffer.Length);
                            System.Buffer.SetByte(temp, totalBytesRead, (byte)nextByte);
                            readBuffer = temp;
                            totalBytesRead++;
                        }
                    }
                }

                byte[] buffer = readBuffer;
                if (readBuffer.Length != totalBytesRead)
                {
                    buffer = new byte[totalBytesRead];
                    System.Buffer.BlockCopy(readBuffer, 0, buffer, 0, totalBytesRead);
                }
                return buffer;
            }
            finally
            {
                if (stream.CanSeek)
                {
                    stream.Position = originalPosition;
                }
            }
        }

        public UserModel getDataLogin()
        {
            UserModel CurrentUser = new UserModel();
            UserModel Current = new UserModel();
            try
            {
                if (String.IsNullOrEmpty(HttpContext.Current.User.Identity.Name) || !HttpContext.Current.User.Identity.IsAuthenticated)
                    return null;

                FormsIdentity formsIdentity = HttpContext.Current.User.Identity as FormsIdentity;
                FormsAuthenticationTicket ticket = formsIdentity.Ticket;
                CurrentUser = JsonConvert.DeserializeAnonymousType(ticket.UserData, CurrentUser);
                if (CurrentUser != null)
                {
                    Current.ID = CurrentUser.ID;
                    Current = Current.SelectByID(Current.ID);
                }
            }
            catch { }
            return Current;
        }
    }
}