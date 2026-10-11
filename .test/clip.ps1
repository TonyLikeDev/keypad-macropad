param([string]$Mode)
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$state = Join-Path $PSScriptRoot 'clip_state.txt'
switch ($Mode) {
  'save' {
    if ([Windows.Forms.Clipboard]::ContainsText()) { [IO.File]::WriteAllText($state, [Windows.Forms.Clipboard]::GetText()); 'saved text clipboard (' + (Get-Item $state).Length + ' bytes)' }
    elseif ([Windows.Forms.Clipboard]::ContainsImage()) { 'clipboard holds an image: cannot restore it' ; Set-Content $state '' }
    else { 'clipboard was empty or other format'; Set-Content $state '' }
  }
  'check' {
    if ([Windows.Forms.Clipboard]::ContainsImage()) { $i = [Windows.Forms.Clipboard]::GetImage(); "clipboard now holds an image: $($i.Width) x $($i.Height)"; $i.Dispose() } else { 'clipboard has NO image' }
  }
  'restore' {
    $t = [IO.File]::ReadAllText($state)
    if ($t.Length -gt 0) { [Windows.Forms.Clipboard]::SetText($t); 'restored your text clipboard' } else { [Windows.Forms.Clipboard]::Clear(); 'clipboard cleared (was empty or not text)' }
    Remove-Item $state
  }
}
