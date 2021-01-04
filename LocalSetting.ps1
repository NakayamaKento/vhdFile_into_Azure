#ローカルマシンをAzure VMにあげる準備
#管理者権限の Powershell で実行する
#参考 https://docs.microsoft.com/ja-jp/azure/virtual-machines/windows/prepare-for-upload-vhd-image

#静的な固定ルートを削除
route print
#固定ルートがあれば以下のコマンドで削除
route delete  #osインストール直後はいらない


#Windoes での各種設定
netsh winhttp reset proxy

diskpart
#開いたコマンド内で以下を実行
    san policy=onlineall
    exit

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation’ -name “RealTimeIsUniversal” -Value 1 -Type DWord -force
Set-Service -Name w32time -StartupType Automatic

powercfg /setactive SCHEME_MIN

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment’ -name “TEMP” -Value “%SystemRoot%\TEMP” -Type ExpandString -force

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment’ -name “TMP” -Value “%SystemRoot%\TEMP” -Type ExpandString -force


Get-Service -Name BFE, Dhcp, Dnscache, IKEEXT, iphlpsvc, nsi, mpssvc, RemoteRegistry |
  Where-Object StartType -ne Automatic |
    Set-Service -StartupType Automatic

Get-Service -Name Netlogon, Netman, TermService |
  Where-Object StartType -ne Manual |
    Set-Service -StartupType Manual


Get-Service -Name BFE, Dhcp, Dnscache, IKEEXT, iphlpsvc, nsi, mpssvc, RemoteRegistry |
    Where-Object StartType -ne Automatic |
      Set-Service -StartupType Automatic
  
Get-Service -Name Netlogon, Netman, TermService |
    Where-Object StartType -ne Manual |
      Set-Service -StartupType Manual

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp’ -name “PortNumber” -Value 3389 -Type DWord -force





Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp’ -name “LanAdapter” -Value 0 -Type DWord -force



Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp’ -name “UserAuthentication” -Value 1 -Type DWord -force

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp’ -name “SecurityLayer” -Value 1 -Type DWord -force

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp’ -name “fAllowSecProtocolNegotiation” -Value 1 -Type DWord -force



Set-ItemProperty -Path ‘HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services’ -name “KeepAliveEnable” -Value 1 -Type DWord -force

Set-ItemProperty -Path ‘HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services’ -name “KeepAliveInterval” -Value 1 -Type DWord -force

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp’ -name “KeepAliveTimeout” -Value 1 -Type DWord -force



Set-ItemProperty -Path ‘HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services’ -name “fDisableAutoReconnect” -Value 0 -Type DWord -force

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp’ -name “fInheritReconnectSame” -Value 1 -Type DWord -force

Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp’ -name “fReconnectSame” -Value 0 -Type DWord -force


Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp’ -name “MaxInstanceCount” -Value 4294967295 -Type DWord -force



#以下のコマンドは削除対象がなければエラーが出力
Remove-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp’ -name “SSLCertificateSHA1Hash” -force


Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True


Set-NetFirewallRule -DisplayName "ファイルとプリンターの共有 (エコー要求 - ICMPv4 受信)" -Enabled True
Set-NetFirewallRule -DisplayGroup "リモート デスクトップ" -Enabled True
Set-NetFirewallRule -DisplayName "ファイルとプリンターの共有 (エコー要求 - ICMPv4 受信)" -Enabled True

 が
Chkdsk /f

bcdedit /set “{bootmgr}” integrityservices enable
bcdedit /set “{default}” device partition=C:
bcdedit /set “{default}” integrityservices enable
bcdedit /set “{default}” recoveryenabled Off
bcdedit /set “{default}” osdevice partition=C:
bcdedit /set “{default}” bootstatuspolicy IgnoreAllFailures



bcdedit /set “{bootmgr}” displaybootmenu yes
bcdedit /set “{bootmgr}” timeout 5
bcdedit /set “{bootmgr}” bootems yes
bcdedit /ems “{current}” ON
bcdedit /emssettings EMSPORT:1 EMSBAUDRATE:115200



# Set up the guest OS to collect a kernel dump on an OS crash event
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name CrashDumpEnabled -Type DWord -Force -Value 2
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name DumpFile -Type ExpandString -Force -Value "%SystemRoot%\MEMORY.DMP"
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name NMICrashDump -Type DWord -Force -Value 1

# Set up the guest OS to collect user mode dumps on a service crash event
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps'
if ((Test-Path -Path $key) -eq $false) {(New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -Name LocalDumps)}
New-ItemProperty -Path $key -Name DumpFolder -Type ExpandString -Force -Value 'C:\CrashDumps'
New-ItemProperty -Path $key -Name CrashCount -Type DWord -Force -Value 10
New-ItemProperty -Path $key -Name DumpType -Type DWord -Force -Value 2
Set-Service -Name WerSvc -StartupType Manual



winmgmt /verifyrepository

#以下のコマンドで3389が使われていないことを確認
netstat -anob


#最後に再起動をかけておく