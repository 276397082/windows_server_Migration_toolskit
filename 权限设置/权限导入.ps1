Add-Type -AssemblyName System.Windows.Forms
Add-Type -Assembly System.Threading.Tasks


# 弹出文件选择对话框，让用户选择多个文件



$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

$openFileDialog.Multiselect = $true
$openFileDialog.Filter = "CSV 文件 (*.csv)|*.csv"
$openFileDialog.FileName = "0share_permissions.csv"
$result = $openFileDialog.ShowDialog()


    if ($result -eq 'OK') {
        $shareCsvPath = $openFileDialog.FileNames
        $selectedFolderPath=[System.IO.Path]::GetDirectoryName($shareCsvPath)
        $securityCsvPath = Join-Path -Path $selectedFolderPath -ChildPath '1security_permissions.csv'
        $usersCsvPath = Join-Path -Path $selectedFolderPath -ChildPath '2share_users.csv' 
        if ([System.IO.Path]::GetFileName($shareCsvPath).Equals("0share_permissions.csv")){
            
              Write-Output '读取文件成功'     
            
         }else {
            Write-Output '选择错误'
            exit 200
         }
           
    } else {

     Write-Output '取消选择'
        exit 200
        
    }
    

# 导入CSV文件并去除重复的账户名（除administrator）
$shareusers = Import-Csv -Path $usersCsvPath | Where-Object { $_.AccountName -notlike '*administrator*' }| Select-Object -Property AccountName, GroupName,SID  -Unique 
$userPassword = "dell@123456"
$computerName = $env:COMPUTERNAME

# 组装用户路径前缀
$userPathPrefix = "WinNT://$computerName/"

# 创建计数器，用于统计已创建的用户数量
$createdUserCount = 0

foreach ($account in $shareusers) {
    $aaa = $account.AccountName.Split('\')[-1]
    $bbb = $account.GroupName
    $ccc = $account.SID
    
    $userPath = $userPathPrefix + $aaa + ",user"
    
    try {
        # 直接尝试创建用户，如果用户已经存在会抛出异常
        # 用户不存在，进行创建操作
        $user = ([ADSI]"WinNT://$computerName").Create("User", $aaa)
        $user.SetPassword($userPassword)
        $user.UserFlags = 65536  # 设置密码永不过期
        $user.SetInfo()

        $group = ([ADSI]"WinNT://$computerName/$bbb,group")
        $group.Add("WinNT://$computerName/$aaa")
        Write-Host "已创建用户：$aaa" -ForegroundColor Yellow

        # 更新已创建用户数量
        $createdUserCount++
        
        
    } catch {
       # 如果能成功执行到这里，表示用户已经存在
        Write-Host "用户已经存在：$aaa"  -ForegroundColor Yellow
    }
}

# 输出已创建的用户数量
Write-Host "总共创建用户数：$createdUserCount" -ForegroundColor Yellow


# 导入CSV文件并去除重复的账户名（除administrator）在这段代码中，执行速度较慢的原因可能是每次循环都使用了[ADSI]::Exists()方法来检查用户是否存在，以及使用了Write-Host打印消息。优化可以通过上面的方式改进
$shareusers = Import-Csv -Path $usersCsvPath | Where-Object { $_.AccountName -notlike '*administrator*' }| Select-Object -Property AccountName, GroupName,SID  -Unique
#$userPassword = ConvertTo-SecureString "dell@123456" -AsPlainText -Force
#$userPassword = "dell@123456"
#$computerName = $env:COMPUTERNAME
## 创建用户并设置密码
#foreach ($account in $shareusers) {

#    $aaa=$account.AccountName.Split('\')[-1]
#    #$aaa='test'
#    $bbb=$account.GroupName
#    $ccc=$account.SID
#     $userPath = "WinNT://$computerName/$aaa,user"
#    try {
#        
#        $userExists = [ADSI]::Exists($userPath)
#
#    } catch {
#
#        $userExists = $false
#    }
#
#    if (-not $userExists) {
#
#        $user = ([ADSI]"WinNT://$computerName").Create("User", $aaa) 
#        $user.SetPassword($userPassword)
#        $user.UserFlags = 65536  # 设置密码永不过期
#        $user.SetInfo()
#    
#        $group = ([ADSI]"WinNT://$computerName/$bbb,group")
#        $group.Add("WinNT://$computerName/$aaa")
#        Write-Host "已创建用户：$aaa"  -ForegroundColor Yellow
#    } else {
#        Write-Host "用户已经存在：$aaa"  -ForegroundColor Yellow
#    }
#}
# 导入CSV文件并去除重复的账户名（除administrator）在这段代码中，执行速度较慢的原因可能是每次循环都使用了[ADSI]::Exists()方法来检查用户是否存在，以及使用了Write-Host打印消息。优化可以通过上面的方式改进

        Write-Host "读取：$shareCsvPath" -ForegroundColor Yellow
        Write-Host ""
        $shareP=Import-Csv -Path $shareCsvPath | Select-Object -Property Folder,Path,Name,ScopeName,AccountName,AccessControlType,AccessRight 
        # 使用哈希表来记录已经创建的路径
        $createdPaths = @{}



        
        # 设置安全权限
        Write-Host "读取： $securityCsvPath " -ForegroundColor Yellow
        $securityACLs=Import-Csv -Path $securityCsvPath | Select-Object -Property Folder,Path,FileSystemRights, AccessControlType, IdentityReference,IsInherited,InheritanceFlags, PropagationFlags
        #$securityACLs = $securityPermissions | Where-Object { $_.Path -eq $folderPath }
        $ftemp=""

        $permissionGroups = $securityACLs | Group-Object -Property Path, FileSystemRights ,IsInherited 
        $accessRule = $null  # 在循环外部先创建一个空对象
        foreach ($group in $permissionGroups) {
            $path = $group.Group[0].Path
            if (!(Test-Path -PathType Container -Path $path)) {
                Write-Host "路径不存在，跳过： $path" -ForegroundColor Red
                Write-Host ""
                continue
            }
            $IdentityReference= $group.Group[0].IdentityReference
            $fileSystemRights = $group.Group[0].FileSystemRights
            $InheritanceFlags= $group.Group[0].InheritanceFlags
            $PropagationFlags= $group.Group[0].PropagationFlags
            $AccessControlType= $group.Group[0].AccessControlType
        
        #    if ($accessRule -eq $null) {
        #        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $fileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
        #
        # #      $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference,$FileSystemRights,$InheritanceFlags,$PropagationFlags,$AccessControlType)
        #    } else {
        #        $accessRule.FileSystemRights = $fileSystemRights
        #    }
            $acl = Get-Acl -Path $path
            if ($ftemp -ne $path) {
                $acl = New-Object System.Security.AccessControl.DirectorySecurity
                $ftemp=$path
            }

            $group.Group | ForEach-Object {
                $identityReference = $_.IdentityReference
                $accessControlType = $_.AccessControlType
                $inheritanceFlags = $_.InheritanceFlags
                $propagationFlags = $_.PropagationFlags
                $IsInherited=$_.IsInherited
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identityReference, $fileSystemRights, $inheritanceFlags, $propagationFlags, $accessControlType)
                #继承
                $acl.SetAccessRuleProtection($IsInherited, $true)
                
                if ($identityReference -like "S-*") {
                    continue
                }
                $acl.AddAccessRule($accessRule)
            }
            
            Write-Host "设置安全权限：$fileSystemRights 对 $path" -ForegroundColor Yellow
            Write-Host ""
            $acl | Set-Acl -Path $path
            
            Write-Host "设置安全权限完成：$fileSystemRights 对 $path"  -ForegroundColor Green
            Write-Host ""
        }

         
 #      $securityACLs | ForEach-Object {
 #          $permission = $_
 #          $Folder=$permission.Folder
 #          $Path=$permission.Path
 #          $FileSystemRights=$permission.FileSystemRights
 #          $AccessControlType=$permission.AccessControlType
 #          $c = $permission.IdentityReference.Split('\')
 #         
 #          if ($c.Length -gt 1 -and  $c[0] -ne "BUILTIN") {
 #              $e="$computerName\"+$c[1]
 #          } else {
 #               $e=$permission.IdentityReference
 #          }
 #          $IdentityReference=$e
 #          $IsInherited=$permission.IsInherited
 #          $InheritanceFlags=$permission.InheritanceFlags
 #          $PropagationFlags=$permission.PropagationFlags
 #
 #     
 #
 #      $acl = Get-Acl -Path $Path
 #      $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference,$FileSystemRights,$InheritanceFlags,$PropagationFlags,$AccessControlType)
 #      
 #      $acl.AddAccessRule($rule)
 #      Write-Host "设置安全权限：$identityReference 对 $Path：$fileSystemRights" -ForegroundColor Yellow
 #      # 原来的方法太慢了
 #      #Set-Acl -Path $Path -AclObject $acl
 #      $acl | Set-Acl -Path $Path
 #      
 #      
 #      Write-Host "设置安全权限完成：$identityReference 对 $Path：$fileSystemRights"
 #      }



# 设置共享文件夹及权限
#$shareP.Path | Get-Unique
# 保存上一次循环的路径
foreach ($sharefolderPath in $shareP) {
    
    $sharePath=$sharefolderPath.Path
    #$sharePath="D:\环境安全月短视频"
    $shareName = $sharefolderPath.Name
    $shareScopeName = $sharefolderPath.ScopeName
    $shareAccountName = $sharefolderPath.AccountName.Split('\')[-1]
    $shareAccessControlType = $sharefolderPath.AccessControlType
    $shareAccessRight = $sharefolderPath.AccessRight

    $sharefolderExists = Test-Path -Path $sharePath
    if ($sharefolderExists) {
        # 设置共享文件夹
        # 去重判断，如果该路径已经创建过共享目录，则跳过创建
        if (!$createdPaths.ContainsKey($sharePath)) {
            # 创建共享目录
            # 检查共享是否存在
            if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
                # 共享不存在，创建共享
                New-SmbShare -Name $shareName -Path $sharePath 
                Write-Host "共享已创建:$shareName" -ForegroundColor Green
                # 将路径添加到已创建路径的哈希表中
                $createdPaths[$sharePath] = $true
            } else {
                Write-Host "共享已存在:$shareName" -ForegroundColor Yellow
                # 将路径添加到已创建路径的哈希表中
                $createdPaths[$sharePath] = $true
            }
            

          
            
        } else {
            Write-Host "路径 $sharePath 已经创建过共享目录" -ForegroundColor Green
        }


    
           #配置共享访问权限
            Write-Host "设置共享访问权限：$shareAccessRight" -ForegroundColor Yellow
           #Grant-SmbShareAccess 命令用于向已创建的 SMB 共享授予访问权限。它允许您为指定的共享目录添加一个或多个用户或组，并分配特定的访问权限，如读取、写入、完全控制等。
           #Set-SmbShare  命令用于修改已存在的 SMB 共享的属性。它允许您更改共享的选项和配置，如共享的名字、路径、描述以及其他设置。通过 Set-SmbShare，您可以更新共享的配置而无需重新创建共享。
           Grant-SmbShareAccess -Name $shareName -AccountName $shareAccountName -AccessRight $shareAccessRight -Confirm:$false
   
           $everyoneExists = Get-SmbShareAccess -Name $shareName | Where-Object { $_.AccountName -eq "Everyone" }
   
           if ($everyoneExists) {
               Revoke-SmbShareAccess -Name $shareName -AccountName "Everyone" -Force
               Write-Host "已删除 everyone 权限:$shareName"  -ForegroundColor Yellow
           } 
   
           # 配置共享访问权限
           
           #$scope = New-SmbShareAccess -ScopeName $shareScopeName -AccessRight $shareAccessRight -AccountName $shareAccountName
           #Set-SmbShare -Name $name -FolderEnumerationMode AccessBased -FolderEnumerationModeOptions $scope


    } else {
        Write-Host "文件夹不存在：$folderPath"  -ForegroundColor Yellow
    }
}


pause
