# nostalgiaTv-windows-docker

Run **NostalgiaTV** on a Windows PC with one double-click.

## What is this?

[NostalgiaTV Server](https://hub.docker.com/r/purestream711/nostalgiatv-server) turns your own Jellyfin, Plex or Emby library into a 1990s-style cable TV experience. Instead of picking something to watch, you flick through channels with a scrolling TV guide, scheduled shows, ad breaks and CRT effects, all in your browser.

NostalgiaTV Server is normally set up by hand with Docker commands. This repo does all of that for you:

- installs Docker Desktop if you don't have it,
- starts the server and keeps it up to date,
- offers to open it in your browser when it's ready.

You don't need to know anything about Docker.

## Prerequisites

### Your PC

| Requirement | Details |
|-------------|---------|
| **Windows 10 (22H2 or later) or Windows 11, 64-bit** | Check in **Settings → System → About**. |
| **8 GB RAM** recommended (4 GB minimum) | Docker Desktop uses about 2 GB by itself. |
| **About 3 GB of free disk space** | For Docker Desktop and the NostalgiaTV server. Your media isn't copied, so it needs no extra space. |
| **Virtualisation turned on** | Docker needs this. Check in **Task Manager → Performance → CPU**, where it should say *Virtualization: Enabled*. If it says *Disabled*, turn on *Intel VT-x* / *AMD-V* (sometimes called *SVM*) in your PC's BIOS. Most modern PCs have it on already. |
| **Administrator rights** | Needed once, to install Docker Desktop. |
| **Internet connection** | Needed for the first download (about 1 GB) and for updates. |

### Software

| Requirement | Details |
|-------------|---------|
| **Docker Desktop** | `start.bat` installs it for you, using `winget`, which comes with Windows 10/11. You can also install it yourself from [docker.com](https://www.docker.com/products/docker-desktop/). It needs **WSL 2**, which its installer sets up. If it asks you to, run `wsl --install` in an admin terminal and restart. |
| **Git** (optional) | Only needed if you want to `git clone` the repo. Otherwise, download the ZIP from GitHub. |

### Your media

| Requirement | Details |
|-------------|---------|
| **A Jellyfin, Plex or Emby server** | Already set up with your films and TV, on this PC or another machine on your network. NostalgiaTV streams from it; it doesn't play files directly. |
| **A login for that server** | NostalgiaTV signs in to your media server with this account, so it needs access to the libraries you want on TV. |
| **The server's address** | e.g. `http://192.168.1.50:8096` for Jellyfin, or `http://host.docker.internal:8096` if it's on this PC. |

To watch on other devices (TV, phone, another PC), they must be on the **same home network** as this PC.

## Quick start

1. **Get the files.** Either:
   - clone the repo:
     ```
     cd C:\Users\<you>\source\repos
     git clone https://github.com/stephenbeale/nostalgiaTv-windows-docker
     ```
   - or click **Code → Download ZIP** on GitHub and unzip it anywhere.
2. **Double-click `start.bat`.**
3. When it asks *Open NostalgiaTV in your browser now?*, press **Y** (or wait 30 seconds) and your browser opens at **http://localhost:19850**.

### First run only: installing Docker

If Docker Desktop isn't installed, `start.bat` offers to install it for you.

1. Press **Y** to install it.
2. **Restart your PC** when the install finishes.
3. Open **Docker Desktop** from the Start menu once, and accept its terms.
4. Double-click `start.bat` again.

You only have to do this once.

## Setting up your channels

1. At http://localhost:19850, choose your media server (**Jellyfin**, **Plex** or **Emby**) and sign in.
   - **Jellyfin on this same PC:** use the server address `http://host.docker.internal:8096`. `localhost` won't work, because the server runs inside Docker.
   - **Jellyfin on another machine:** use its network address, e.g. `http://192.168.1.50:8096`.
   - **Not sure of the address?** Double-click `jellyfin-address.bat` on the PC running Jellyfin. It finds Jellyfin's port and the PC's IPv4 address, prints e.g. `http://192.168.1.100:8096`, and copies it to the clipboard.
2. Choose which libraries to include. Wait a minute or two while it indexes them.
3. Open the **Watch** page and start channel-surfing.
4. To customise channels, ad breaks, themes and profiles, use the mode switcher in the top bar to go to **Configure** (`/configure`).

### Tip: copying the Quick Connect code (untested)

The Quick Connect screen comes from the NostalgiaTV image, so this repo can't change it. If the code is shown one digit per line, you can make a bookmark whose address (URL) is the line below. Click it on that screen to copy the code.

```
javascript:(()=>{const d=[];for(const l of document.body.innerText.split('\n')){const t=l.trim();if(/^\d$/.test(t))d.push(t);else if(d.length>=4)break;else d.length=0;}const c=d.join('');if(!c)return alert('No code found');navigator.clipboard?navigator.clipboard.writeText(c).then(()=>alert('Copied '+c)):prompt('Copy this:',c);})()
```

**Not yet tried on the live page**; the logic has only been checked on pasted text. Browsers only allow clipboard access on `localhost` or https, so over a LAN address (e.g. `http://192.168.1.50:19850`) it shows a box to copy from instead.

## Day-to-day use

| File | What it does |
|------|--------------|
| `start.bat` | Starts NostalgiaTV, updates it to the latest version and offers to open your browser. Safe to run at any time. |
| `stop.bat`  | Stops NostalgiaTV. Your channels and settings are kept. |
| `logs.bat`  | Shows what the server is doing. Useful if something isn't working. |

Once started, NostalgiaTV keeps running in the background and comes back by itself whenever Docker Desktop starts. To have it always available, turn on **Docker Desktop → Settings → General → Start Docker Desktop when you sign in**. After that, just bookmark http://localhost:19850.

### Opening it later, or starting Docker Desktop directly

If you open Docker Desktop yourself (or it starts when you sign in), NostalgiaTV starts automatically, but `start.bat` doesn't run, so you won't get the browser prompt. You can:

- go to http://localhost:19850, or
- open the **Containers** tab in Docker Desktop and click the **19850:19850** port link, or
- run `start.bat` to get the prompt (and the latest version).

**Updating:** every time you run `start.bat`, it downloads the latest version.

## Watching on other devices

- **Another PC, phone or tablet:** open `http://<this-pc-ip>:19850` in a browser. To find the PC's IP address, run `ipconfig` and look for the *IPv4 Address*. Windows Firewall may ask you to allow Docker the first time; click **Allow**.
- **A smart TV or Fire Stick:** NostalgiaTV also acts as a TV tuner. In TiviMate, Jellyfin Live TV, Plex DVR or any IPTV app, add:
  - Playlist (M3U): `http://<this-pc-ip>:19850/channels.m3u`
  - Guide (XMLTV): `http://<this-pc-ip>:19850/xmltv.xml`
- **NostalgiaTV Android app:** this server also works as the app's *Docker Mode* backend. In the app, go to **Settings → Admin → Docker Mode** and enter `http://<this-pc-ip>:19850`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Docker did not start after 3 minutes" | Open Docker Desktop from the Start menu and wait for it to say *Engine running*, then run `start.bat` again. |
| Browser shows "can't reach this page" | The server may still be starting. Wait 30 seconds and refresh. If that doesn't work, run `logs.bat` and look for errors. |
| Can't connect to Jellyfin | If Jellyfin is on this PC, use `http://host.docker.internal:8096`, not `localhost`. Otherwise, check that the address opens Jellyfin in your browser. |
| Times in the guide are wrong | See *Timezone* under Settings below. |
| Profile or channels missing | Check your profile is in `%LOCALAPPDATA%\NostalgiaTV\config\profiles`. If you used an older version, your data may still be in `data\` and `config\` next to `start.bat`; see *Upgrading from an older version* under Settings. |
| Port 19850 already in use | Something else is using that port. Change the left-hand number in `docker-compose.yml` (e.g. `"19851:19850"`) and use that number in the browser address instead. |

## Settings

- **Timezone:** defaults to UK time (`Europe/London`). To change it, create a file called `.env` in this folder containing one line, e.g. `TZ=America/New_York`. Then run `start.bat`.
- **Your data:** channels, profiles and settings are stored in `%LOCALAPPDATA%\NostalgiaTV` (paste that into File Explorer's address bar), not in this folder. That means any copy of this folder uses the same profiles and channels. To back up, copy that whole folder. To keep it somewhere else, add a line like `NTV_DATA_DIR=D:\NostalgiaTV` to `.env`.
- **Upgrading from an older version:** the first time `start.bat` runs, it copies the `data\`, `config\` and `logos\` folders from here to `%LOCALAPPDATA%\NostalgiaTV`. It only does this if that folder doesn't already hold a profile. The old folders are left as a backup; delete them once you're happy. Run it the first time from the folder that holds your real data.

## Uninstalling

1. Run `stop.bat`.
2. Delete this folder, and `%LOCALAPPDATA%\NostalgiaTV` too if you don't want to keep your channels and profiles.
3. Optionally, remove the image in **Docker Desktop → Images** (`purestream711/nostalgiatv-server`), or uninstall Docker Desktop.

## Licence

The launcher scripts in this repo are MIT licensed (see `LICENSE`). NostalgiaTV Server is a separate project by its own author, downloaded from Docker Hub, and isn't covered by this licence.
