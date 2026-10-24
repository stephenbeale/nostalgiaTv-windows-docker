# Prints the address to type into NostalgiaTV for a Jellyfin server on this PC.
# Combines the two manual steps: netstat (which port is Jellyfin listening on?)
# and ipconfig (what is this PC's IPv4 address?).

# --- 1. Port: ask the Jellyfin process what it's listening on (netstat) -------
$ports = Get-Process -Name jellyfin* -ErrorAction SilentlyContinue |
    ForEach-Object { Get-NetTCPConnection -State Listen -OwningProcess $_.Id -ErrorAction SilentlyContinue } |
    Select-Object -ExpandProperty LocalPort -Unique

# Jellyfin's default HTTP port wins if it's in the list; otherwise take the lowest.
if ($ports -contains 8096) { $port = 8096 }
elseif ($ports) { $port = ($ports | Sort-Object)[0] }
# No jellyfin process (e.g. Jellyfin itself runs in Docker): is anything on 8096?
elseif (Get-NetTCPConnection -State Listen -LocalPort 8096 -ErrorAction SilentlyContinue) { $port = 8096 }
else {
    Write-Host "Jellyfin doesn't seem to be running on this PC (nothing listening on port 8096)."
    Write-Host "Start Jellyfin and try again, or use the address of the machine it runs on."
    exit 1
}

# --- 2. IPv4: the connected adapter with a default gateway (ipconfig) ---------
# The gateway filter skips Docker/WSL/VPN virtual adapters.
$ip = Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
    Select-Object -First 1 |
    ForEach-Object { $_.IPv4Address.IPAddress } |
    Select-Object -First 1

if (-not $ip) {
    Write-Host "Couldn't find this PC's IPv4 address. Run ipconfig and look for 'IPv4 Address'."
    exit 1
}

# --- 3. Output -----------------------------------------------------------------
$address = "http://${ip}:$port"
Write-Host ""
Write-Host "Jellyfin server address:  $address"
Write-Host "  (also works from NostalgiaTV in Docker: http://host.docker.internal:$port)"
Write-Host ""
try {
    Set-Clipboard -Value $address
    Write-Host "Copied to the clipboard."
} catch {}
