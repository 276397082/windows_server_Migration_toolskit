Add-Type -AssemblyName System.Windows.Forms

# 获取本机IP地址
$localIP = $([System.Net.Dns]::GetHostAddresses(($env:COMPUTERNAME)) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }).IPAddressToString

# 获取共享文件夹列表 
$folders = Get-WmiObject -Class Win32_Share -ComputerName $localIP | Where-Object { $_.Type -eq 0 } | Select-Object Name,Path 
 Write-Host "获取共享文件夹列表 "  -ForegroundColor Yellow
# 弹出文件保存对话框，让用户选择保存权限信息的文件路径
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveFileDialog.FileName="0share_permissions.csv"
$saveFileDialog.Filter = "CSV 文件 (*.csv)|*.csv"
$saveFileDialog.Title = "保存权限信息"
$result = $saveFileDialog.ShowDialog()
try {
if ($result -eq 'OK') {
    $shareCsvPath = $saveFileDialog.FileName
    $selectedFolderPath = [System.IO.Path]::GetDirectoryName($saveFileDialog.FileName)
    #$shareCsvPath = Join-Path -Path $selectedFolderPath -ChildPath '0share_permissions.csv'
    $securityCsvPath = Join-Path -Path $selectedFolderPath -ChildPath '1security_permissions.csv'
    $usersCsvPath = Join-Path -Path $selectedFolderPath -ChildPath '2share_users.csv'
    if(Test-Path $shareCsvPath) {
        Remove-Item $shareCsvPath
    }
    if(Test-Path $securityCsvPath) {
        Remove-Item $securityCsvPath
    }
    if(Test-Path $usersCsvPath) {
        Remove-Item $usersCsvPath
    }
    Write-Host "开始导出 "  -ForegroundColor Yellow
    # 导出权限到 CSV 文件
    $folders | ForEach-Object {
        $folder = $_.Name
        
        $Path=$_.Path
        Write-Host "获取目录安全权限：$Path "   -ForegroundColor Yellow
        $securityACLs = Get-Acl -Path "$path" | Select-Object -ExpandProperty Access | Where-Object { $_.IdentityReference -notlike "NT AUTHORITY\*" }
        Write-Host "导出目录安全权限：$Path "  -ForegroundColor Yellow
        $securityACLs | Select-Object @{Name="Folder";Expression={$folder}},@{Name="Path";Expression={$Path}}, FileSystemRights, AccessControlType, IdentityReference,IsInherited,InheritanceFlags, PropagationFlags|  Export-Csv -Path $securityCsvPath  -Append -NoTypeInformation -Encoding UTF8
        
        $securityACLsfolders = Get-ChildItem -Path $Path -Directory
        $securityACLsfolders |  ForEach-Object {
            $subname=$_.Name
            $subpath=$_.FullName
            Write-Host "获取子目录安全权限：$subpath "   -ForegroundColor Yellow
            #$securityACLs = Get-Acl -Path "\\$localIP\$($folder.Replace(':','$'))" | Select-Object -ExpandProperty Access | Where-Object { $_.IdentityReference -notlike "NT AUTHORITY\*" }
            #$securityACLs = Get-Acl -Path "$subpath" | Select-Object -ExpandProperty Access | Where-Object { $_.IdentityReference -notlike "NT AUTHORITY\*" }
            $securityACLs = Get-Acl -Path "$subpath" | Select-Object -ExpandProperty Access  
              
            Write-Host "导出子目录安全权限：$subpath "  -ForegroundColor Yellow
            $securityACLs | Select-Object @{Name="Folder";Expression={$subname}},@{Name="Path";Expression={$subpath}}, FileSystemRights, AccessControlType, IdentityReference,IsInherited,InheritanceFlags, PropagationFlags|  Export-Csv -Path $securityCsvPath  -Append -NoTypeInformation -Encoding UTF8
            #$shareACLs | Select-Object  AccountName | Where-Object { $_.AccountName -notlike '*administrator*'  -and $_ -notlike '*BUILTIN*' } | Export-Csv -Path $usersCsvPath   -Append -NoTypeInformation -Encoding UTF8
        }

        # $shareACLs = Get-SmbShareAccess -Name $folder -CimSession $localIP | Select-Object ShareName, AccountName, AccessControlType, AccessRights
        Write-Host "获取目录共享权限：$folder "  -ForegroundColor Yellow
        $shareACLs = Get-SmbShareAccess -Name $folder | Select-Object Name, ScopeName, AccountName, AccessControlType, AccessRight
        Write-Host "导出目录共享权限：$folder "  -ForegroundColor Yellow
        $shareACLs | Select-Object @{Name="Folder";Expression={$folder}},@{Name="Path";Expression={$Path}}, Name, ScopeName, AccountName, AccessControlType, AccessRight | Export-Csv -Path $shareCsvPath  -Append -NoTypeInformation -Encoding UTF8
        
 
        $shareACLs | ForEach-Object {
        $accountName = $_.AccountName
        $aaa=$accountName.Split('\')[-1]
      
        # 获取用户所在的组
         Write-Host "导出用户权限：$aaa "  -ForegroundColor Yellow
        $userGroups = Get-WmiObject -Class Win32_GroupUser | Where-Object { $_.PartComponent -match [regex]::Escape($aaa) } | ForEach-Object {
            $groupPath = $_.GroupComponent -replace '^Win32_Group.Domain="\w+",Name="', '' -replace '"$'
            $groupName = $groupPath.Split('=')[2].Trim('"')
            $groupName
             $userSID = (New-Object System.Security.Principal.NTAccount($aaa)).Translate([System.Security.Principal.SecurityIdentifier]).Value
        }
    
        [PSCustomObject] @{
            AccountName = $accountName
            GroupName = $userGroups -join ","
            SID = $userSID
        }
    } | Where-Object { $_.AccountName -notlike '*administrator*' -and $_.AccountName -notlike '*BUILTIN*' } | Export-Csv -Path $usersCsvPath -Append -NoTypeInformation -Encoding UTF8
        
        }



    
     Write-Host "成功"
    
}
} catch{

    Write-Host "出现错误: $_"
    

}
pause
    
