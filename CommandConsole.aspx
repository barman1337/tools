<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommandConsole.aspx.cs" Inherits="YourNamespace.CommandConsole" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Local Command Console</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f5f5f5;
            padding: 40px;
        }
        #consoleBox {
            width: 600px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 0px 10px #ccc;
        }
        textarea {
            width: 100%;
            height: 300px;
            margin-top: 10px;
            font-family: Consolas, monospace;
            background: #000;
            color: #0f0;
            padding: 10px;
            resize: none;
        }
        input[type="text"] {
            width: 80%;
            padding: 8px;
        }
        button {
            padding: 8px 12px;
            background: #007bff;
            color: white;
            border: none;
            cursor: pointer;
            margin-left: 5px;
        }
    </style>
</head>
<body>
    <div id="consoleBox">
        <h2>OS Command Console</h2>
        <input type="text" id="commandInput" placeholder="Enter command e.g. ipconfig" />
        <button onclick="runCommand()">Run</button>
        <textarea id="outputBox" readonly></textarea>
    </div>

    <script>
        function runCommand() {
            const cmd = document.getElementById("commandInput").value;
            fetch("CommandConsole.aspx/RunCommand", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ cmd: cmd })
            })
            .then(response => response.json())
            .then(data => {
                document.getElementById("outputBox").value = data.d;
            })
            .catch(error => {
                document.getElementById("outputBox").value = "Error: " + error;
            });
        }
    </script>
</body>
</html>
