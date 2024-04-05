using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace TT.WebApp_MyStore.Commons
{
    public class PublicFunction
    {
        #region function
        public string ConvertTVKhongDauVietLien(string str)
        {
            string[] a = { "à", "á", "ạ", "ả", "ã", "â", "ầ", "ấ", "ậ", "ẩ", "ẫ", "ă", "ằ", "ắ", "ặ", "ẳ", "ẵ" };
            string[] aUpper = { "À", "Á", "Ạ", "Ả", "Ã", "Â", "Ầ", "Ấ", "Ậ", "Ẩ", "Ẫ", "Ă", "Ằ", "Ắ", "Ặ", "Ẳ", "Ẵ" };
            string[] e = { "è", "é", "ẹ", "ẻ", "ẽ", "ê", "ề", "ế", "ệ", "ể", "ễ" };
            string[] eUpper = { "È", "É", "Ẹ", "Ẻ", "Ẽ", "Ê", "Ề", "Ế", "Ệ", "Ể", "Ễ" };
            string[] i = { "ì", "í", "ị", "ỉ", "ĩ" };
            string[] iUpper = { "Ì", "Í", "Ị", "Ỉ", "Ĩ" };
            string[] o = { "ò", "ó", "ọ", "ỏ", "õ", "ô", "ồ", "ố", "ộ", "ổ", "ỗ", "ơ", "ờ", "ớ", "ợ", "ở", "ỡ" };
            string[] oUpper = { "Ò", "Ó", "Ọ", "Ỏ", "Õ", "Ô", "Ồ", "Ố", "Ộ", "Ổ", "Ỗ", "Ơ", "Ờ", "Ớ", "Ợ", "Ở", "Ỡ" };
            string[] u = { "ù", "ú", "ụ", "ủ", "ũ", "ư", "ừ", "ứ", "ự", "ử", "ữ" };
            string[] uUpper = { "Ù", "Ú", "Ụ", "Ủ", "Ũ", "Ư", "Ừ", "Ứ", "Ự", "Ử", "Ữ" };
            string[] y = { "ỳ", "ý", "ỵ", "ỷ", "ỹ" };
            string[] yUpper = { "Ỳ", "Ý", "Ỵ", "Ỷ", "Ỹ" };
            str = str.Replace("đ", "d");
            str = str.Replace("Đ", "D");
            foreach (string a1 in a)
            {
                str = str.Replace(a1, "a");
            }
            foreach (string a1 in aUpper)
            {
                str = str.Replace(a1, "A");
            }
            foreach (string e1 in e)
            {
                str = str.Replace(e1, "e");
            }
            foreach (string e1 in eUpper)
            {
                str = str.Replace(e1, "E");
            }
            foreach (string i1 in i)
            {
                str = str.Replace(i1, "i");
            }
            foreach (string i1 in iUpper)
            {
                str = str.Replace(i1, "I");
            }
            foreach (string o1 in o)
            {
                str = str.Replace(o1, "o");
            }
            foreach (string o1 in oUpper)
            {
                str = str.Replace(o1, "O");
            }
            foreach (string u1 in u)
            {
                str = str.Replace(u1, "u");
            }
            foreach (string u1 in uUpper)
            {
                str = str.Replace(u1, "U");
            }
            foreach (string y1 in y)
            {
                str = str.Replace(y1, "y");
            }
            foreach (string y1 in yUpper)
            {
                str = str.Replace(y1, "Y");
            }
            return str.Replace(" ", "");
        }
        public string ConvertTVKhongDau(string str)
        {
            string[] a = { "à", "á", "ạ", "ả", "ã", "â", "ầ", "ấ", "ậ", "ẩ", "ẫ", "ă", "ằ", "ắ", "ặ", "ẳ", "ẵ" };
            string[] aUpper = { "À", "Á", "Ạ", "Ả", "Ã", "Â", "Ầ", "Ấ", "Ậ", "Ẩ", "Ẫ", "Ă", "Ằ", "Ắ", "Ặ", "Ẳ", "Ẵ" };
            string[] e = { "è", "é", "ẹ", "ẻ", "ẽ", "ê", "ề", "ế", "ệ", "ể", "ễ" };
            string[] eUpper = { "È", "É", "Ẹ", "Ẻ", "Ẽ", "Ê", "Ề", "Ế", "Ệ", "Ể", "Ễ" };
            string[] i = { "ì", "í", "ị", "ỉ", "ĩ" };
            string[] iUpper = { "Ì", "Í", "Ị", "Ỉ", "Ĩ" };
            string[] o = { "ò", "ó", "ọ", "ỏ", "õ", "ô", "ồ", "ố", "ộ", "ổ", "ỗ", "ơ", "ờ", "ớ", "ợ", "ở", "ỡ" };
            string[] oUpper = { "Ò", "Ó", "Ọ", "Ỏ", "Õ", "Ô", "Ồ", "Ố", "Ộ", "Ổ", "Ỗ", "Ơ", "Ờ", "Ớ", "Ợ", "Ở", "Ỡ" };
            string[] u = { "ù", "ú", "ụ", "ủ", "ũ", "ư", "ừ", "ứ", "ự", "ử", "ữ" };
            string[] uUpper = { "Ù", "Ú", "Ụ", "Ủ", "Ũ", "Ư", "Ừ", "Ứ", "Ự", "Ử", "Ữ" };
            string[] y = { "ỳ", "ý", "ỵ", "ỷ", "ỹ" };
            string[] yUpper = { "Ỳ", "Ý", "Ỵ", "Ỷ", "Ỹ" };
            str = str.Replace("đ", "d");
            str = str.Replace("Đ", "D");
            foreach (string a1 in a)
            {
                str = str.Replace(a1, "a");
            }
            foreach (string a1 in aUpper)
            {
                str = str.Replace(a1, "A");
            }
            foreach (string e1 in e)
            {
                str = str.Replace(e1, "e");
            }
            foreach (string e1 in eUpper)
            {
                str = str.Replace(e1, "E");
            }
            foreach (string i1 in i)
            {
                str = str.Replace(i1, "i");
            }
            foreach (string i1 in iUpper)
            {
                str = str.Replace(i1, "I");
            }
            foreach (string o1 in o)
            {
                str = str.Replace(o1, "o");
            }
            foreach (string o1 in oUpper)
            {
                str = str.Replace(o1, "O");
            }
            foreach (string u1 in u)
            {
                str = str.Replace(u1, "u");
            }
            foreach (string u1 in uUpper)
            {
                str = str.Replace(u1, "U");
            }
            foreach (string y1 in y)
            {
                str = str.Replace(y1, "y");
            }
            foreach (string y1 in yUpper)
            {
                str = str.Replace(y1, "Y");
            }
            return str;
        }
        #endregion
        #region Encrypt/DeEncryptcrypt
        string key = ConfigurationManager.AppSettings["KeyCrypt"];
        public string EncryptString(string plainText)
        {
            byte[] iv = new byte[16];
            byte[] array;

            using (Aes aes = Aes.Create())
            {
                aes.Key = Encoding.UTF8.GetBytes(key);
                aes.IV = iv;

                ICryptoTransform encryptor = aes.CreateEncryptor(aes.Key, aes.IV);

                using (MemoryStream memoryStream = new MemoryStream())
                {
                    using (CryptoStream cryptoStream = new CryptoStream((Stream)memoryStream, encryptor, CryptoStreamMode.Write))
                    {
                        using (StreamWriter streamWriter = new StreamWriter((Stream)cryptoStream))
                        {
                            streamWriter.Write(plainText);
                        }

                        array = memoryStream.ToArray();
                    }
                }
            }

            return Convert.ToBase64String(array);
        }

        public string DecryptString(string cipherText)
        {
            byte[] iv = new byte[16];
            byte[] buffer = Convert.FromBase64String(cipherText);

            using (Aes aes = Aes.Create())
            {
                aes.Key = Encoding.UTF8.GetBytes(key);
                aes.IV = iv;
                ICryptoTransform decryptor = aes.CreateDecryptor(aes.Key, aes.IV);

                using (MemoryStream memoryStream = new MemoryStream(buffer))
                {
                    using (CryptoStream cryptoStream = new CryptoStream((Stream)memoryStream, decryptor, CryptoStreamMode.Read))
                    {
                        using (StreamReader streamReader = new StreamReader((Stream)cryptoStream))
                        {
                            return streamReader.ReadToEnd();
                        }
                    }
                }
            }
        }
        #endregion
    }
}