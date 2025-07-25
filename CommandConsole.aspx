<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListFiles.aspx.cs" Inherits="YourNamespace.ListFiles" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Directory File List</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f0f0f0;
            padding: 40px;
        }
        #fileList {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            width: 500px;
            margin: auto;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
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
    <form id="form1" runat="server">
        <div id="fileList">
            <h2>Files in Current Directory</h2>
            <asp:Literal ID="LiteralFiles" runat="server" />
        </div>
    </form>
</body>
</html>
