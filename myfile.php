<?php
// Define the allowed User-Agent for security (optional, you can remove if not needed)
$allowed_user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:92.0) Gecko/20100101 Firefox/92.0";

// Check the User-Agent of the request (optional, you can remove if not needed)
if ($_SERVER['HTTP_USER_AGENT'] !== $allowed_user_agent) {
    die("Access denied");
}

// Handle file upload
if (isset($_FILES['file'])) {
    $upload_dir = __DIR__ . "/uploads/";  // Upload directory
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir);  // Create directory if it doesn't exist
    }

    $target_file = $upload_dir . basename($_FILES["file"]["name"]);

    // Move the uploaded file to the target directory
    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
        echo "The file " . htmlspecialchars(basename($_FILES["file"]["name"])) . " has been uploaded.";
    } else {
        echo "Sorry, there was an error uploading your file.";
    }
}
?>

<form method="post" enctype="multipart/form-data">
    Select file to upload:
    <input type="file" name="file" id="file">
    <input type="submit" value="Upload File" name="submit">
</form>
