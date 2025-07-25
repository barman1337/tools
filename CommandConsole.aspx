<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>Directory Browser</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 40px;
        }
        #container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px #ccc;
        }
        h2 { margin-bottom: 10px; }
        a { text-decoration: none; color: blue; }
        ul { list-style: none; padding-left: 0; }
        li { margin-bottom: 5px; }
        .folder { font-weight: bold; }
        .file { color: gray; }
        form { margin-top: 20px; }
        input[type="text"] { width: 80%; padding: 5px; }
        button { padding: 5px 10px; }
    </style>
</head>
<body>
    <div id="container">
        <h2>Simple File Browser</h2>

<%
    string root = Server.MapPath("~/"); // fallback default
    string baseDir = Request.QueryString["path"] ?? root;

    if (!System.IO.Directory.Exists(baseDir))
    {
        Response.Write("<p style='color:red;'>Directory not found: " + Server.HtmlEncode(baseDir) + "</p>");
        baseDir = root;
    }

    Response.Write("<p><strong>Current Directory:</strong> " + Server.HtmlEncode(baseDir) + "</p>");
%>

        <form method="get">
            <input type="text" name="path" value="<%= baseDir %>" />
            <button type="submit">Go</button>
        </form>

        <h3>Folders</h3>
        <ul>
<%
    foreach (string dir in System.IO.Directory.GetDirectories(baseDir))
    {
        string name = System.IO.Path.GetFileName(dir);
        string encodedPath = Server.UrlEncode(dir);
%>
            <li class="folder">
                📁 <a href="?path=<%= encodedPath %>"><%= name %></a>
            </li>
<%
    }
%>
        </ul>

        <h3>Files</h3>
        <ul>
<%
    foreach (string file in System.IO.Directory.GetFiles(baseDir))
    {
        string name = System.IO.Path.GetFileName(file);
%>
            <li class="file">📄 <%= name %></li>
<%
    }
%>
        </ul>
    </div>
</body>
</html>
