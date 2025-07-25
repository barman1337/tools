using System;
using System.IO;

namespace YourNamespace
{
    public partial class ListFiles : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string directoryPath = Server.MapPath("~/"); // root of the web app
            string[] files = Directory.GetFiles(directoryPath);

            string html = "<ul>";
            foreach (string filePath in files)
            {
                string fileName = Path.GetFileName(filePath);
                html += $"<li>{fileName}</li>";
            }
            html += "</ul>";

            LiteralFiles.Text = html;
        }
    }
}
