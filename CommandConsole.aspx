<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test WHOAMI Command</title>
    <style>
        body {
            font-family: Consolas, monospace;
            background: #f0f0f0;
            padding: 40px;
        }
        #outputBox {
            background: #ffffff;
            color: #000000;
            width: 100%;
            height: 200px;
            padding: 10px;
            font-size: 14px;
            border: 1px solid #ccc;
            white-space: pre;
            overflow: auto;
        }
    </style>
</head>
<body>
    <h2>Test OS Command Output: <code>whoami</code></h2>
    <div id="outputBox">
<%
    try
    {
        string command = "whoami";
        System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
        psi.FileName = command;
        psi.Arguments = "";
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardError = true;
        psi.UseShellExecute = false;
        psi.CreateNoWindow = true;

        using (System.Diagnostics.Process process = System.Diagnostics.Process.Start(psi))
        {
            string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();
            process.WaitForExit();

            string fullOutput = output + (string.IsNullOrWhiteSpace(error) ? "" : "\n[ERROR]\n" + error);
            Response.Write(Server.HtmlEncode(fullOutput));
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
