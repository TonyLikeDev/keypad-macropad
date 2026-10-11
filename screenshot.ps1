# Saves a PNG of the monitor the mouse cursor is on to Pictures\Screenshots and copies it to the clipboard. Run by keypad.ahk (S3).
Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class Dpi { [DllImport("user32.dll")] public static extern bool SetProcessDPIAware(); }'
[Dpi]::SetProcessDPIAware() | Out-Null   # must run before WinForms loads, or scaled screens come out cropped
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$b = [System.Windows.Forms.Screen]::FromPoint([System.Windows.Forms.Cursor]::Position).Bounds
$bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
[System.Drawing.Graphics]::FromImage($bmp).CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)

$dir = Join-Path ([Environment]::GetFolderPath('MyPictures')) 'Screenshots'
New-Item -ItemType Directory -Force $dir | Out-Null
$bmp.Save((Join-Path $dir ("Screenshot {0:yyyy-MM-dd HH-mm-ss}.png" -f (Get-Date))), [System.Drawing.Imaging.ImageFormat]::Png)
[System.Windows.Forms.Clipboard]::SetImage($bmp)   # also on the clipboard, ready to paste (needs -Sta, set in keypad.ahk)
[System.Media.SystemSounds]::Asterisk.Play()       # audible confirmation, there is no window
