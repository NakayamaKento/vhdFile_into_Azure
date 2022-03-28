#sysprep してない vhd を Disk に直接アップロードする
# https://docs.microsoft.com/ja-jp/azure/virtual-machines/windows/disks-upload-vhd-to-managed-disk-powershell

######## 変更するパラメータ

$souceVHDfile = "./XXXX.vhd"
$diskname = "XXXXos"
$Region = "japaneast"
$ResourceGroup = "XXXX"

########

$vhdSizeBytes = (Get-Item $souceVHDfile).length

$diskconfig = New-AzDiskConfig -SkuName 'Standard_LRS' -OsType 'Windows' -UploadSizeInBytes $vhdSizeBytes -Location $Region -CreateOption 'Upload' -HyperVGeneration V1

New-AzDisk -ResourceGroupName $ResourceGroup -DiskName $diskname -Disk $diskconfig 


$diskSas = Grant-AzDiskAccess -ResourceGroupName $ResourceGroup -DiskName $diskname -DurationInSecond 86400 -Access 'Write'

$disk = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $diskname

./AzCopy copy $souceVHDfile $diskSas.AccessSAS --blob-type PageBlob

Revoke-AzDiskAccess -ResourceGroupName $ResourceGroup -DiskName $diskname


#ここまでが vhd -> Disk の作成