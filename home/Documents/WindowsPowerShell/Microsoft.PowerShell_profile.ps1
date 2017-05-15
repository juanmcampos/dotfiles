# Scoop: pshazz
try { $null = gcm pshazz -ea stop; pshazz init } catch { }
set-psreadlineoption -t parameter darkblue
set-psreadlineoption -t operator darkblue
set-psreadlineoption -t string darkgreen

# Explorer helper, quick terminal->explorer
function Open-Here { explorer.exe . }
Set-Alias -Name open -Value explorer.exe -Option AllScope
Set-Alias -Name here -Value Open-Here -Option AllScope

# Override LS with GNU LS
function Get-ChildItem-Gnu { ls.exe -F --show-control-chars --color=auto -I"navdb.csv" -I"NTUSER*" -I"ntuser*" -I"Application\ Data*" -I"Local\ Settings*" -I"My\ Documents*" -I"NetHood*" -I"PrintHood*" -I"Recent*" -I"SendTo*" -I"Templates*" -I"Cookies*" -I"3D\ Objects" -I"iCloudDrive*" -I"Thumbs.db" -I"「开始」菜单" $args }
function Get-ChildItem-Gnu-Ll { ls -lh $args }
function Get-ChildItem-Gnu-La { ll -A }
Set-Alias -Name ls -Value Get-ChildItem-Gnu -Option AllScope
Set-Alias -Name ll -Value Get-ChildItem-Gnu-Ll -Option AllScope
Set-Alias -Name la -Value Get-ChildItem-Gnu-La -Option AllScope

# Git Alias
function Git-Diff { git diff }
function Git-Status { git status }
Set-Alias -Name gdf -Value Git-Diff -Option AllScope
Set-Alias -Name gst -Value Git-Status -Option AllScope