# response-test
Various scripts that can be used in conjunction or individually. Meant to provide a challenge phrase to a user and execute a command based on the response.

![But Why](https://i.giphy.com/media/1M9fmo1WAFVK0/giphy.webp)

A few months ago I sold a phone on eBay. Even though I factory reset it, someone managed to recover whatever they needed off of it to get past the **2 factor authentication** protecting my Google account. They had access to all of the passwords I'd saved through Google, which included the login for my VPS host. That host offers a web based console with which you can login as if from a physical TTY (which means it ignores any sshd rules about disabling remote root login). So a quick email to reset my root password (another feature of the host), and they were happily on my VPS with full root access. I have no idea what they did; as soon as I got on and tried to lock them out, they took notice. They deleted everything. My stupid ass didn't have a full backup.

So enter the response-test suite.

* console-test checks environment variables and the output of $(tty) to detect whether or not a session is coming from a physical TTY. If so, a program is run
* response-test provides a challenge phrase and executes a program based on the success of the response
* lolsh imitates /bin/sh. Except typing "ls" results in "ls: command not found". And typing "whoami" results in "whoami: command not found". Shit, I forgot to add any commands at all except for "sh" and "exit" (which do nothing except increment/decrement a $SHELL_DEPTH variable respectively). All signals are trapped, so there's no easy killing or backgrounding or escape. Once $SHELL_DEPTH reaches 0, the program exits and kills the session leaving the user hopefully confused, frustrated, and imagining that something is simply very broken with the server.

## Installation

    git clone https://github.com/shitchell/response-test.git
    cd response-test
    sudo ./install.sh

## response-test
Prompts the user with a challenge phrase $CHALLENGE, then reads a response. For security's sake, the correct response is stored as an md5 hash $RESPONSE_HASH. If the md5 hash of the user's response matches the predefined md5 hash, then $COMMAND_SUCCESS is executed, else $COMMAND_FAILURE is executed.

Each piece can be set via command line arguments. Examples:

#### *Prompts the user with "1 + 1" and tries to go easy on them if they don't enter "2"*
    response-test -c "1 + 1 = " -m 26ab0db90d72e28ad0ba1e22ee510510 -s "Yay you can math" -f "Aww, you tried, buddy!"

#### *The shadow knows...*
    response-text \ 
      -c "The sun is shining... " \ 
      -m bba672abfde9120d8cc000bb113ffb50 \ 
      -f "echo 'You clearly need this' && mplayer The_Shadow_1994.mp4"

#### *Potentially deny access to the shell*
    response-text -c "$ " -f "kill -9 $PPID 2>/dev/null && exit 0"


## console-test
systemd implements an $INVOCATION_ID for all processes it spawns, including TTYs. Since the web interface login to my webserver provided by my VPS host acts as a TTY, checking for both $INVOCATION_ID and $SHELL seems to accurately detect when a shell is a (pseudo) TTY.


## lolsh
[![asciicast](https://asciinema.org/a/S0JX1KGOvMeigNVdTHVG3liXx.svg)](https://asciinema.org/a/S0JX1KGOvMeigNVdTHVG3liXx)

Pseudo, mock shell that imitates /bin/sh. Except that all entered commands are met with "$cmd: command not found". The user may type these 4 things:

Typed | Result
------------ | -------------
sh | Increments $SHELL_DEPTH
/bin/sh | Increments $SHELL_DEPTH
^D | Decrements $SHELL_DEPTH
exit | Decrements $SHELL_DEPTH

Typing "sh" or "/bin/sh" also calls "sleep 0.5" for a slight delay giving an appearance of legitimately spawning a new subshell. All signals are trapped so that the user can't kill the "shell". If and when $SHELL_DEPTH is less than or equal to 0, it kills the parent process (or whatever PID was passed as a command line parameter) and exits the program. Meant to be used in conjunction with response-test as a frustrating, confusing shadowban-esque consequence for failed responses. If the challenge phrase used by response-text is suitably subtle, a failed response combined with lolsh will give the appearance of successfully logging in to a very broken system rather than being locked out.
