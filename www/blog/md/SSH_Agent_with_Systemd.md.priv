# SSH-Agent

SSH-Agent makes using `ssh` more convenient by managing your ssh-keys. The manual usage of SSH-Agent is to eval the output of `ssh-agent` and then use `ssh-add` to add the keys to it:
```
eval $(ssh-agent)
ssh-add ~/.ssh/id_github
ssh-add ~/.ssh/id_raspberrypi
# repeat for all required keys
```
We use `eval` because `ssh-agent` outputs the environment variables it uses to stdout. Thus by using eval `ssh-add` and `ssh` can access those variables.

A common way to use `ssh-agent` is to add the above code to your `.bashrc`. This however will run ssh-agent every time you open a terminal session which I found wasteful. A solution is to run it as a systemd service.

# Systemd

Systemd is a system and service manager for Linux.
For our purposes, systemd allows us to define a service which will be run on startup or login of a certain user.
Using it we can add a service file for SSH-Agent and have it run on startup.


# Running as a Systemd Service

Service files for the user are located at `~/.config/systemd/user/`.
Create the file `ssh-agent.service` under that directory and the following text to it:
```
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
```

This is the line which defines the command to run:
```
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK
```
As you can see, we don't use `eval` in this case. That is because `eval` will only set the variables for the specific shell session which it is running. If we open a terminal and try to use `ssh-add -l` to list the ssh-keys, it will fail telling us it cannot connect to SSH-Agent.

To remedy this we need to set the required environment variables manually both in the service file for SSH-Agent and globally so that it is available to terminal sessions.
- In the service file (it's already present):

      Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket

- In your shell profile script (could be `~/.profile` depending on your shell):

      SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

`%t` and `${XDG_RUNTIME_DIR}` are equivalent in this case.
`%t` refers to a temporary directory which systemd can use for running processes and `${XDG_RUNTIME_DIR}` is the equivalent environment variable.
[Man page of systemd](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html#:~:text=%22%25t%22,for%20user%20managers)


We can now enable and start the service using the following commands:
```
systemctl --user daemon-reload
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service
```

If everything is correct you can open a new terminal session and `ssh-add -l` which will connect succesfully and report that no keys have been added.

# Adding the keys on startup

The ssh-keys are usually stored in `~/.ssh/` and start with `id_` unless you specified a different directory and filename when creating them. If we assume the above we can add them using the following bash script:
```
for filename in ~/.ssh/id_*; do
    if [[ $filename != *.pub ]]; then
        ssh-add $filename;
    fi;
done
```
We also add the check `$filename != *.pub` to exclude the public keys which we shouldn't add.

We can run this script as a systemd service by creating a new file at `~/.config/systemd/user/ssh-add.service`.
```
[Unit]
Description=Add SSH keys to ssh-agent
After=ssh-agent.service
Requires=ssh-agent.service

[Service]
Type=oneshot
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/bash -c 'for filename in ~/.ssh/id_*; do if [[ $filename != *.pub ]]; then ssh-add $filename; fi; done'

[Install]
WantedBy=default.target
```

If you enable the service using:
```
systemctl --user daemon-reload
systemctl --user enable ssh-add.service
systemctl --user start ssh-add.service
```

If you open a new terminal and run `ssh-add -l` to list the keys then the keys you have under `~/.ssh/` should be listed.

There is a problem however. If you reboot your system and run `ssh-add -l` again, no keys will be listed.

# The Socket problem

To make sure that `ssh-add.service` runs after `ssh-agent.service` we specify `After=ssh-agent.service` and `Requires=ssh-agent.service` in the `ssh-add.service` file. This however is not enough.

SSH-Agent takes some time to open the listening socket so when `ssh-add.service` runs the socket isn't open and the keys don't get added. So we need to wait for the socket to open before adding the keys.

With bash we can check if the socket exists by using the `test` command and sleep the thread for some time and check again:
```
while ! test -S $SSH_AUTH_SOCK; do
    sleep 0.1;
done;
```

Let's add this to the service file:
```
[Unit]
Description=Add SSH keys to ssh-agent
After=ssh-agent.service
Requires=ssh-agent.service

[Service]
Type=oneshot
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/bash -c 'while ! test -S $SSH_AUTH_SOCK; do sleep 0.1; done; for filename in ~/.ssh/id_*; do if [[ $filename != *.pub ]]; then ssh-add $filename; fi; done'

[Install]
WantedBy=default.target
```

Now if you reboot and run `ssh-add -l` it should list your ssh-keys.


# Recap

Service file at `~/.config/systemd/user/ssh-agent.service`:
```
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
```

Service file at `~/.config/systemd/user/ssh-add.service`:
```
[Unit]
Description=Add SSH keys to ssh-agent
After=ssh-agent.service
Requires=ssh-agent.service

[Service]
Type=oneshot
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/bash -c 'while ! test -S $SSH_AUTH_SOCK; do sleep 0.1; done; for filename in ~/.ssh/id_*; do if [[ $filename != *.pub ]]; then ssh-add $filename; fi; done'

[Install]
WantedBy=default.target
```

Environment variable in profile file:
```
SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
```

Enable the services:
```
systemctl --user daemon-reload
systemctl --user enable ssh-agent.service
systemctl --user enable ssh-add.service
```

After reboot the keys should be loaded automatically.

