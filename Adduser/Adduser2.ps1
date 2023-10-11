Add-Type -AssemblyName System.Windows.Forms
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

$openFileDialog.Multiselect = $true
$openFileDialog.Filter = "CSV 文件 (*.csv)|*.csv"
$openFileDialog.FileName = ""
$result = $openFileDialog.ShowDialog()
$computerName = $env:COMPUTERNAME

 if ($result -eq 'OK') {

 $users = Import-Csv -Path $openFileDialog.FileNames
# 从密码文件中读取密码


# 创建用户并设置密码、全名和描述
foreach ($user in $users) {
    $username = $user.name
    $fname= $user.fname
    $des= $user.des
    $pwd = $user.Pwd
   
    $domain = $computerName
    $userPath = "WinNT://$computerName/$username,user"

    try {
        $userExists = [ADSI]::Exists($userPath)
    } catch {
        $userExists = $false
    }

    if (-not $userExists) {
        $newUser = New-Object System.DirectoryServices.DirectoryEntry("WinNT://$computerName")
        $userEntry = $newUser.Children.Add($username, "user")
        
        # 设置密码
        $userEntry.Invoke("SetPassword", $pwd)

        # 获取UserFlags属性值
        $userFlags = $userEntry.Properties["UserFlags"].Value
        # 设置密码永不过期
        $userFlags = $userFlags -bor 0x10000
        $userEntry.Properties["UserFlags"].Value = $userFlags

        # 设置全名
        $userEntry.Properties["FullName"].Value = $fname
        
        # 设置描述
        $userEntry.Properties["Description"].Value = $des
        
        $userEntry.Invoke("SetInfo")

        $group = ([ADSI]"WinNT://$computerName/Users,group")
        $group.Add("WinNT://$computerName/$username")

        Write-Host "已创建用户：$username" -ForegroundColor Yellow
    } else {
        Write-Host "用户已经存在：$username" -ForegroundColor Yellow
    }
}
pause
}