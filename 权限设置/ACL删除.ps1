            $acl = Get-Acl -Path "E:\IS部内使用1"
            $acl = New-Object System.Security.AccessControl.DirectorySecurity
            $acl | Set-Acl -Path "E:\IS部内使用1"
            
            
            
            $acl = Get-Acl -Path $path
            $acl.Access

            $acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier]) 
            $ruleToRemove = $acl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier]) | Where-Object {$_.IdentityReference -like "*"}

            $ruleToRemove | ForEach-Object {
                $acl.RemoveAccessRule($_)
            }
            
            $acl.Access