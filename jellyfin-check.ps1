# Checks that NostalgiaTV can reach each saved Jellyfin/Emby server, and explains
# why not. Run by start.bat after the server is up. Only warns; changes nothing.
# Exit 0 = all reachable (or nothing to check), 1 = at least one warning shown.
param([Parameter(Mandatory)][string]$ServersFile)

if (-not (Test-Path $ServersFile)) { exit 0 }
try { $servers = Get-Content $ServersFile -Raw | ConvertFrom-Json }
catch { exit 0 }

# This PC's LAN IPv4 (same rule as jellyfin-address.ps1: adapter with a gateway).
$myIp = Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
    Select-Object -First 1 |
    ForEach-Object { $_.IPv4Address.IPAddress } |
    Select-Object -First 1
$localHosts = @('localhost', '127.0.0.1', 'host.docker.internal') +
    (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress

# Ask the container itself, since that's what fetches the streams.
function Test-FromContainer([string]$baseUrl) {
    $py = "import sys,urllib.request as u; u.urlopen(sys.argv[1].rstrip('/')+'/System/Info/Public',timeout=4)"
    docker exec nostalgiatv-server python -c $py $baseUrl *> $null
    return $LASTEXITCODE -eq 0
}

$warned = $false
foreach ($s in $servers.PSObject.Properties.Value) {
    if ($s.backendType -ne 'jelly' -or -not $s.baseUrl) { continue }
    try { $uri = [uri]$s.baseUrl } catch { continue }
    $port = $uri.Port
    $isLocal = $localHosts -contains $uri.Host

    $ok = Test-FromContainer $s.baseUrl
    # Jellyfin on this PC may still be starting just after a reboot: give it 30s.
    if (-not $ok -and $isLocal) {
        Write-Host "Waiting for Jellyfin ($($s.name))..."
        $clock = [Diagnostics.Stopwatch]::StartNew()
        while (-not $ok -and $clock.Elapsed.TotalSeconds -lt 30) {
            Start-Sleep -Seconds 5
            $ok = Test-FromContainer $s.baseUrl
        }
    }
    if ($ok) { continue }

    $warned = $true
    $listening = [bool](Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
    Write-Host ""
    Write-Host "WARNING: NostalgiaTV can't reach Jellyfin server '$($s.name)' at $($s.baseUrl)" -ForegroundColor Yellow
    Write-Host "         Videos won't play (502 Bad Gateway) until this is fixed."
    if ($isLocal -and -not $listening) {
        Write-Host "  Jellyfin isn't running on this PC (nothing listening on port $port)."
        Write-Host "  Start it (Services app -> Jellyfin Server -> Start, or open the Jellyfin tray app)."
    }
    elseif (-not $isLocal -and $listening -and $myIp) {
        Write-Host "  Jellyfin is running on this PC, but this PC's address is now $myIp."
        Write-Host "  If '$($s.name)' is this PC, its address has changed. In NostalgiaTV go to"
        Write-Host "  Settings -> Servers -> $($s.name) -> Edit and set: http://${myIp}:$port"
        Write-Host "  To stop it changing again, reserve this PC's IP in your router (DHCP reservation)."
    }
    elseif ($isLocal) {
        Write-Host "  Something is listening on port $port, but it isn't answering like Jellyfin."
        Write-Host "  Open $($s.baseUrl) in your browser to check, and restart Jellyfin if it doesn't load."
    }
    else {
        Write-Host "  Check that the machine at $($uri.Host) is switched on and Jellyfin is running there."
    }
}
if ($warned) { exit 1 }
exit 0
