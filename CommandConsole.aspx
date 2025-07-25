<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>File List (No CodeBehind)</title>
    <style>
        body {
            font-family: Arial;
            padding: 40px;
            background: #f4f4f4;
        }
        #fileList {
            background: white;
            padding: 20px;
            border-radius: 8px;
            max-width: 600px;
            margin: auto;
            box-shadow: 0px 0px 10px #ccc;
        }
        h2 {
            text-align: center;
        }
        ul {
            padding-left: 20px;
        }
    </style>
</head>
<body>
    <div id="fileList">
        <h2>Files in This Directory</h2>
        <ul>
            <%
                string path = Server.MapPath("./");
                string[] files = System.IO.Directory.GetFiles(path);

                foreach (string file in files)
                {
                    string fileName = System.IO.Path.GetFileName(file);
            %>
                    <li><%= fileName %></li>
            <%
                }
            %>
        </ul>
    </div>
</body>
</html>
