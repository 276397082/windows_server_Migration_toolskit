Add-Type -AssemblyName System.Windows.Forms

$name="administrator"
$pwd="NET@admin459"

# 创建一个文件夹浏览对话框
$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowserDialog.Description = "选择要保存的文件夹"
$folderBrowserDialog.ShowNewFolderButton = $true

# 如果用户选择了文件夹，则获取所选路径并导出任务计划
if ($folderBrowserDialog.ShowDialog() -eq 'OK') {



$folderPath =  $folderBrowserDialog.SelectedPath

# 获取文件夹中的所有任务计划文件
$taskFiles = Get-ChildItem -Path $folderPath -Filter '*.xml' -File
# 获取当前用户的安全标识 (SID)
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$currentSid = $currentUser.User.Value

# 导入每个任务计划
foreach ($taskFile in $taskFiles) {
    Write-Host "导入任务计划: $($taskFile.Name)"
      $taskName = $taskFile.BaseName
      # 检查任务计划是否已存在

        $existingTask = SCHTASKS /QUERY /TN "$taskName" 2>$null

        if ($LASTEXITCODE -eq 0) {
        # 如果任务计划已存在，则先删除它
        $deleteCommand = "SCHTASKS /DELETE /TN '$taskName' /F"
        Invoke-Expression -Command $deleteCommand
        Write-Host "已删除现有的任务计划: $taskName"
        }
    #$importCommand = "schtasks.exe /CREATE   /TN `$taskName /XML `"$($taskFile.FullName)`" /RU administrator"
     $importCommand = "SCHTASKS /CREATE /TN '$taskName' /XML '$($taskFile.FullName)' /RU $name /RP $pwd"  
    Invoke-Expression -Command $importCommand 
    Write-Host "任务计划已成功导入到B服务器: $($taskFile.BaseName)"

    
}

Write-Host "所有任务计划导入完成。"
}