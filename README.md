# CLI Utilities for Ubiquiti UniFi® Cloud Key REST API

This repository contains CLI commands and shell functions that work with the
REST API exposed by a Ubiquiti UniFi® Cloud Key.

## Usage

### Authentication

Copy `unifi_credentials_template.sh` to a file `unifi_credentials.sh` that
lives in your $PATH, and edit it to fill in the actual URL, username, and
password for your Cloud Key installation. You may wish to make this file
secure (`chmod 600 unifi_credentials.sh`).

### Command Line Tools

```
list_clients
```

Dump a list of network clients in JSON format.

```
track_client $name
```

Run forever, continuously polling for a client named $name, and print the
timestamp and an AP name whenever that client changes which AP it is connected
to (or if the client disconnects or reconnects from any AP). This is useful
for tracking a person's mobile phone through access points in a building.

### Shell Functions

```source unifi_functions.sh```

Use these shell functions interactively or to build further tools.

```unifi_login $baseurl $username $password```

Log in to a Cloud Key at $baseurl with the given credentials. This function
sets the following global variables in the current shell:

* UNIFI_BASEURL
* UNIFI_BASEURL_RESOLVED
* UNIFI_COOKIES

If the variable $ME or the function `warn()` are declared, these are used
for printing any error messages (if they are not declared, the library
declares sensible ones).

```unifi_fetch $endpoint```

Assuming `unifi_login()` has run successfully, fetch an API $endpoint,
for example:

```unifi_fetch status```

## Prerequisites

The shell functions should run in a POSIX compliant plain `sh`, and are tested
on Linux and macOS. The functions in `unifi_functions.sh` assume that `sed`,
`dig`, and `curl` commands are available in the current $PATH. The command
line tools require `jq` (https://stedolan.github.io/jq/).

## Author

Andrew Ho <andrew@zeuscat.com>

## License

Ubiquiti and UniFi® are registered trademarks of Ubiquiti Networks, Inc. in
the United States and other countries. Ubiquiti Networks, Inc. does not
sponsor, authorize or endorse this site.

The files in this repository are authored by Andrew Ho and are covered by
the following 3-clause BSD license:

    Copyright (c) 2020, Andrew Ho.
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    
    Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    
    Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    
    Neither the name of the author nor the names of its contributors may
    be used to endorse or promote products derived from this software
    without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
