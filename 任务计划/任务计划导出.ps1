Add-Type -AssemblyName System.Windows.Forms

# 创建一个文件夹浏览对话框
$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowserDialog.Description = "选择要保存的文件夹"
$folderBrowserDialog.ShowNewFolderButton = $true

# 如果用户选择了文件夹，则获取所选路径并导出任务计划
if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    $exportPath = $folderBrowserDialog.SelectedPath

    # 获取所有用户自己创建的任务计划
    $taskList = Get-ScheduledTask | Where-Object { $_.TaskPath -eq '\' }
   
    # 导出每个任务计划
    foreach ($task in $taskList) {
        $taskId = $task.TaskName
      
            $exportFile = Join-Path -Path $exportPath -ChildPath "$taskId.xml"
            schtasks.exe /QUERY /TN $taskId /XML > "$exportFile"
       
            Write-Host "任务计划已成功: $taskId"
        
        
    }

    Write-Host "所有任务计划已成功导出到: $exportPath"
}
