return {
  upload_hosts = {
    {
      url   = "https://litterbox.catbox.moe/resources/internals/api.php",
      field = "fileToUpload",
      extra = "-F 'reqtype=fileupload' -F 'time=1h'"
    },
    {
      url   = "https://catbox.moe/user/api.php",
      field = "fileToUpload",
      extra = "-F 'reqtype=fileupload' --http1.1"
    },
  },
}
