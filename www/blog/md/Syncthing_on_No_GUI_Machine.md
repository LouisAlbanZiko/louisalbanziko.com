# Introduction
Taken from the [syncthing website](https://syncthing.net):
> Syncthing is a continuous file synchronization program. It synchronizes files between two or more computers in real time, safely protected from prying eyes. Your data is your data alone and you deserve to choose where it is stored, whether it is shared with some third party, and how it's transmitted over the internet.

So, instead of synchronizing your files using some cloud service which stores them on their server, syncthing allows you to sync files between your devices directly.

A problem which can arise with this approach is that the files only get synched when both devices are on. If you modify some files on device A and turn it off before turning on device B, the modified files will not be present on device B.

To resolve this issue you could install Syncthing on a device which you always leave on like a home server or rasperrypi.

This article will guide you through how to set this up on a linux no GUI machine and how to access the web GUI from another device as that is allowed by default.

# Installation

### Debian

As sudo, run the following:
```
curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
apt update && apt upgrade
apt install syncthing
```

[Ref](https://apt.syncthing.net/)

### Other System

Download the latest release from the [Syncthing Github](https://github.com/syncthing/syncthing/releases).

Unpack the archive and put the extracted folder into a directory where you install programs (`/opt` for example).

Then create a link in a directory included in `PATH` to the syncthing executable.


# Run On Startup
We can use as Systemd service to run syncthing on startup. Syncthing provides a service file which we can use:
```
curl https://raw.githubusercontent.com/syncthing/syncthing/refs/heads/main/etc/linux-systemd/system/syncthing%40.service >> /etc/systemd/system/syncthing.service
```

The service runs as the `syncthing` user which we need to create:
```
useradd -r -s /bin/false -m syncthing
```

We can now enable and start the service:
```
systemctl enable syncthing@syncthing
systemctl start syncthing@syncthing
```

[Ref](https://docs.syncthing.net/v1.0.0/users/autostart.html#using-systemd)

# Enable web GUI access from other machines
By default the socket for the Web GUI on listens on localhost. To change that we need change the address to listen to in the configuration.

The config should be at: `/home/syncthing/.config/syncthing/config.xml`
Find the following line:
```
<address>127.0.0.1:8384</address>
```
And change the IP address to:
```
<address>0.0.0.0:8384</address>
```

Restart the service:
```
systemctl restart syncthing@syncthing
```

You should now be able access the Web GUI from a browser in your network using the IP of the machine followed by the port number. Example: `http://192.168.0.12:8384`.

[Ref](https://docs.syncthing.net/users/faq.html#how-do-i-access-the-web-gui-from-another-computer)

# Setup login to GUI
There should be no GUI login yet which is insecure since we set the listening address to `0.0.0.0:8384` meaning any machine in your network can access the GUI.

To add a login go to Settings>GUI>GUI Authentication User & Password.

