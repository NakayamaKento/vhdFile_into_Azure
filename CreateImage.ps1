######## 変更するパラメータ

$diskname = "XXXXos"
$Region = "japaneast"
$ResourceGroup = "XXXX"
$imageName = 'XXXX'

$disk = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $diskname

$imageConfig = New-AzImageConfig `
   -Location $Region `
   -HyperVGeneration V2
$imageConfig = Set-AzImageOsDisk `
   -Image $imageConfig `
   -OsState Generalized `
   -OsType Windows `
   -ManagedDiskId $disk.Id

$image = New-AzImage `
   -ImageName $imageName `
   -ResourceGroupName $ResourceGroup `
   -Image $imageConfig