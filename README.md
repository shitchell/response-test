# response-test
Various scripts that can be used in conjunction or individually. Meant to provide a challenge phrase to a user and execute a command based on the response.

## response-test.sh
Prompts the user with a challenge phrase $CHALLENGE, then reads a response. For security's sake, the correct response is stored as an md5 hash $RESPONSE_HASH. If the md5 hash of the user's response matches the predefined md5 hash, then $COMMAND_SUCCESS is executed, else $COMMAND_FAILURE is executed.

Each piece can be set via command line arguments. Examples:

##### *Prompts the user with "1 + 1" and tries to go easy on them if they don't enter "2"*
    response-test.sh -c "1 + 1 = " -m 26ab0db90d72e28ad0ba1e22ee510510 -s "Yay you can math" -f "Aww, you tried, buddy!"

##### *The shadow knows...*
    response-text.sh \ 
      -c "The sun is shining... " \ 
      -m bba672abfde9120d8cc000bb113ffb50 \ 
      -f "echo 'You clearly need this' && mplayer The_Shadow_1994.mp4"

##### *Potentially deny access to the shell*
    response-text.sh -c "$ " -f "kill -9 $PPID 2>/dev/null && exit 0"


## console-test.sh
systemd implements an $INVOCATION_ID for all processes it spawns, including TTYs. Since the web interface login to my webserver provided by my VPS host acts as a TTY, checking for both $INVOCATION_ID and $SHELL seems to accurately detect when a shell is a (pseudo) TTY.


## lolsh.sh ##
Pseudo, mock shell that imitates /bin/sh. Except that all entered commands are met with "$cmd: command not found". The user may type these 4 things:

User Types | Action
------------ | -------------
sh | Increments $SHELL_DEPTH
/bin/sh | Increments $SHELL_DEPTH
^D | Decrements $SHELL_DEPTH
exit | Decrements $SHELL_DEPTH

All signals are trapped so that the user can't kill the "shell". If and when $SHELL_DEPTH is less than or equal to 0, it kills the parent process (or whatever PID was passed as a command line parameter) and exits the program. Meant to be used in conjunction with response-test.sh as a frustrating, confusing shadowban-esque consequence for failed responses.
