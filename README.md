# nostalgiaTv-windows-docker

One-click launcher for [NostalgiaTV Server](https://hub.docker.com/r/purestream711/nostalgiatv-server) on Windows. It turns your Jellyfin, Plex or Emby library into a retro cable-TV experience, with a channel guide, commercials and CRT effects, all in your browser.

## Run it

1. Clone this repo:
   ```
   cd C:\Users\<you>\source\repos
   git clone https://github.com/stephenbeale/nostalgiaTv-windows-docker
   ```
   (or download the ZIP from GitHub), e.g. into `C:\Users\<you>\source\repos\nostalgiaTv-windows-docker`.
2. Double-click **`start.bat`**.

That's it. The script:

- offers to install Docker Desktop (via `winget`) if you don't have it,
- starts Docker Desktop if it isn't running,
- pulls the latest image (so every start is also an update),
- starts the server and opens **http://localhost:19850** when it's ready.

The server keeps running in the background and restarts by itself whenever Docker Desktop starts. To have it up whenever you log in, turn on *Docker Desktop → Settings → General → Start Docker Desktop when you sign in*.

| File | What it does |
|------|--------------|
| `start.bat` | Install, start, update and open in the browser |
| `stop.bat`  | Stop the server (settings are kept) |
| `logs.bat`  | Show live server logs |

## First-time setup in the browser

1. At http://localhost:19850, choose **Jellyfin** (or Plex/Emby) and sign in.
   - If Jellyfin runs **on this same PC**, use the server URL `http://host.docker.internal:8096`. `localhost` won't work from inside the container.
   - If it runs on another machine, use its LAN address, e.g. `http://192.168.1.50:8096`.
2. Choose your libraries and let the index build.
3. Go to `/configure` to adjust channels, commercials and themes.

## Extras

- **Other devices / TVs:** open `http://<this-pc-ip>:19850` from any device on your network. Windows Firewall may ask you to allow Docker the first time.
- **Use it as a tuner in Jellyfin/Plex/TiviMate:** M3U `http://<pc-ip>:19850/channels.m3u`, EPG `http://<pc-ip>:19850/xmltv.xml`.
- **Timezone:** defaults to `Europe/London`. To change it, create a `.env` file next to `docker-compose.yml` containing e.g. `TZ=America/New_York`, then run `start.bat` again.
- **Backups:** your settings live in the `data\` and `config\` folders. Back them up together.

## Licence

The launcher scripts in this repo are MIT licensed (see `LICENSE`). NostalgiaTV Server itself is a separate project by its own author, pulled from Docker Hub, and is not covered by this licence.
