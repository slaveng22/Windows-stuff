# Install winget if it doesn't exist
$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx

# get latest download url
$URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
  Select-Object -ExpandProperty "assets" |
  Where-Object "browser_download_url" -Match '.msixbundle' |
  Select-Object -ExpandProperty "browser_download_url"

# download
Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing

# install
Add-AppxPackage -Path "Setup.msix" -ForceApplicationShutdown

# delete file
Remove-Item "Setup.msix"

# Install software
$softwareList = @(
  "Microsoft.WindowsTerminal",
  "Microsoft.PowerShell",
  "Git.Git",
  "junegunn.fzf",
  "JesseDuffield.lazygit",
  "voidtools.Everything",
  "VSCodium.VSCodium",
  "Mozilla.Firefox",
  "Microsoft.PowerToys",
  "OpenWhisperSystems.Signal",
  "7zip.7zip",
  "zyedidia.micro",
  "Flameshot.Flameshot",
  "MartiCliment.UniGetUI",
  "Bitwarden.Bitwarden",
  "dbeaver.dbeaver",
  "Obsidian.Obsidian",
  "WinSCP.WinSCP",
  "Insecure.Nmap",
  "TheDocumentFoundation.LibreOffice"
    
)

foreach ($packageId in $softwareList)
{
  $packageId = $packageId.Trim()

  Write-Progress -Activity "This might take a while, please be patient. Be ZEN!" -Status "Installing defined software..."
    
  try
  {
        
    winget install -e --id $packageId --source winget --silent --accept-source-agreements --accept-package-agreements

    Write-Host "$packageId installed successfully."
  } catch
  {
    Write-Error "Failed to install $packageId $($_.Exception.Message)"
  }
}

Write-Host "Software installation completed."

# Copy config file
Copy-Item -Path .\dotfiles\Microsoft.PowerShell_profile.ps1 -Destination $env:USERPROFILE\Documents\PowerShell -Force
Copy-Item -Path .\dotfiles\settings.json -Destination $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState -Force
Copy-Item -Path .\dotfiles\.config\micro\* -Destination $env:USERPROFILE\.config\micro -Recurse -Force
Copy-Item -Path .\dotfiles\.config\fastfetch\config.jsonc -Destination $env:USERPROFILE\.config\fastfetch -Force
Copy-Item -Path .\dotfiles\.gitconfig -Destination $env:USERPROFILE -Force
Copy-Item -Path .\images\* -Destination $env:USERPROFILE\Pictures -Recurse -Force
git clone git@github.com:slaveng22/WorkMadeEasy_Module.git
Copy-Item -Path .\WorkMadeEasy_Module\WorkMadeEasy -Destination $env:USERPROFILE\Documents\PowerShell\Modules\WorkMadeEasy -Recurse -Force
Unblock-File -Path $env:USERPROFILE\Documents\PowerShell\Modules\WorkMadeEasy\WorkMadeEasy.psd1
Unblock-File -Path $env:USERPROFILE\Documents\PowerShell\Modules\WorkMadeEasy\WorkMadeEasy.psm1
