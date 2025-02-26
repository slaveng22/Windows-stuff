# Install winget if it doesn't exist

if (winget)
{

  Write-Information "Winget is installed, moving on with the setup"
  
}

else
{
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
}

# Install software
$softwareList = @(
  "Microsoft.PowerShell"
  "Git.Git",
  "Neovim.Neovim",
  "junegunn.fzf",
  "sharkdp.fd",
  "cURL.cURL",
  "JesseDuffield.lazygit",
  "Chocolatey.Chocolatey",
  "voidtools.Everything",
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

    # Execute the Winget command
    Invoke-Expression $wingetCommand

    Write-Host "$packageId installed successfully."
  } catch
  {
    Write-Error "Failed to install $packageId $($_.Exception.Message)"
  }
}
# Install Nerd Fonts
choco install nerd-fonts-hack

# Install LazyVim
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim
Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force

Write-Host "Software installation completed."

# Copy config file
Copy-Item -Path .\dotfiles\Microsoft.PowerShell_profile.ps1 -Destination $env:USERPROFILE\Documents\PowerShell -Force
Copy-Item -Path .\dotfiles\settings.json -Destination $ENV:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState -Force
Copy-Item -Path .\dotfiles\.config\micro\* -Destination $ENV:USERPROFILE\.config\micro -Recurse -Force
Copy-Item -Path .\dotfiles\.config\fastfetch\config.jsonc -Destination $ENV:USERPROFILE\.config\fastfetch -Force
Copy-Item -Path .\dotfiles\.gitconfig -Destination $env:USERPROFILE -Force
Copi-Item -Path .\images\* -Destination $ENV:USERPROFILE\Pictures -Recurse -Force
