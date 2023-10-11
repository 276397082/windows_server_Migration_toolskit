Add-Type -AssemblyName System.Windows.Forms
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

$openFileDialog.Multiselect = $true
$openFileDialog.Filter = "CSV 文件 (*.csv)|*.csv"
$openFileDialog.FileName = ""
$result = $openFileDialog.ShowDialog()


 if ($result -eq 'OK') {


$users = Import-Csv -Path $openFileDialog.FileNames
$computerName = $env:COMPUTERNAME

# 创建用户并设置密码
foreach ($user in $users) {
    $username = $user.name
    $pwd = $user.Pwd
    $userPath = "WinNT://$computerName/$username,user"
    
    try {
        $userExists = [ADSI]::Exists($userPath)
    } catch {
        $userExists = $false
    }

    if (-not $userExists) {
        $user = ([ADSI]"WinNT://$computerName").Create("User", $username)
        $user.SetPassword($pwd)
        $user.UserFlags = 65536  # 设置密码永不过期
      

        
        $user.SetInfo()

        $group = ([ADSI]"WinNT://$computerName/Users,group")
        $group.Add("WinNT://$computerName/$username")
        
        Write-Host "已创建用户：$username" -ForegroundColor Yellow
    } else {
        Write-Host "用户已经存在：$username" -ForegroundColor Yellow
    }
}

 Write-Host "已创建完" -ForegroundColor Yellow
 pause
}