<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>App Diagnostics</title>
    <style>
        body {
            font-family: Consolas, monospace;
            background: #f8f8f8;
            padding: 40px;
        }
        pre {
            background: #fff;
            padding: 20px;
            border: 1px solid #ccc;
            white-space: pre-wrap;
        }
        h2 {
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <h2>📋 IIS / ASP.NET Diagnostic Info</h2>
    <pre>
<%
    try
    {
        string scheme = Request.Url.Scheme;
        string host = Request.Url.Host;
        int port = Request.Url.Port;
        string appPath = Request.ApplicationPath;
        string fullUrl = scheme + "://" + host + ((port != 80 && port != 443) ? ":" + port : "") + appPath;

        if (!fullUrl.EndsWith("/")) fullUrl += "/";

        Response.Write("📌 Homepage URL:     " + fullUrl + "\n");
        Response.Write("📁 Physical Path:     " + Server.MapPath("~/") + "\n");
        Response.Write("🧑 Environment.User:  " + Environment.UserName + "\n");
        Response.Write("🔐 Identity:           " + System.Security.Principal.WindowsIdentity.GetCurrent().Name + "\n\n");

        Response.Write("🌐 Host:               " + host + "\n");
        Response.Write("🔗 Port:               " + port + "\n");
        Response.Write("📄 App Path:           " + appPath + "\n");
        Response.Write("🔗 Full Request URL:   " + Request.Url.ToString() + "\n");
        Response.Write("📑 Raw URL:            " + Request.RawUrl + "\n");
    }
    catch (Exception ex)
    {
        Response.Write("❌ ERROR: " + ex.ToString());
    }
%>
    </pre>
</body>
</html>
