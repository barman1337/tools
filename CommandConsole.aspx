<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>Check Admin Rights & App Identity</title>
    <style>
        body {
            font-family: Consolas, monospace;
            background: #f0f0f0;
            padding: 40px;
        }
        #resultBox {
            background: #fff;
            color: #000;
            width: 100%;
            height: 400px;
            padding: 10px;
            white-space: pre;
            font-size: 14px;
            border: 1px solid #ccc;
            overflow: auto;
        }
        .highlight {
            color: green;
            font-weight: bold;
        }
        .notadmin {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h2>Check Admin Status & IIS App Identity</h2>

    <div id="resultBox">
<%
    try
    {
        string userName = Environment.UserName;
        string identityName = System.Security.Principal.WindowsIdentity.GetCurrent().Name;

        Response.Write("✔️ Environment.UserName: " + userName + "\n");
        Response.Write("✔️ WindowsIdentity:      " + identityName + "\n\n");

        string command = @"C:\Windows\System32\whoami.exe";
        string args = "/groups";

        System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
        psi.FileName = command;
        psi.Arguments = args;
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardError = true;
        psi.UseShellExecute = false;
        psi.CreateNoWindow = true;

        using (System.Diagnostics.Process process = System.Diagnostics.Process.Start(psi))
        {
            string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();
            process.WaitForExit();

            bool isAdmin = output.ToLower().Contains("builtin\\administrators") && output.ToLower().Contains("enabled");

            string fullOutput = output + (string.IsNullOrWhiteSpace(error) ? "" : "\n[ERROR]\n" + error);
            Response.Write("\n🧾 whoami /groups output:\n\n");
            Response.Write(Server.HtmlEncode(fullOutput));

            Response.Write("\n\n🔍 Admin Status:\n");
            if (isAdmin)
            {
                Response.Write("<span class='highlight'>✅ User IS in the Administrators group</span>");
            }
            else
            {
                Response.Write("<span class='notadmin'>❌ User is NOT in the Administrators group</span>");
            }
        }
    }
    catch (Exception ex)
    {
        Response.Write("<span style='color:red'>ERROR:</span><br/>" + Server.HtmlEncode(ex.ToString()));
    }
%>
    </div>
</body>
</html>
