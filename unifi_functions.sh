# unifi_functions.sh - functions to work with Ubiquiti UniFi Cloud Key REST API
# Andrew Ho (andrew@zeuscat.com)
#
# Usage:
#     source unifi.sh
#     unifi_login http://unifi-cloudkey-gen2:8443 "$username" "$password"
#     unifi_fetch status
#
# Reserved globals set by unifi_login() and used by unifi_fetch():
#     UNIFI_BASEURL
#     UNIFI_BASEURL_RESOLVED
#     UNIFI_COOKIES
#
# If global function warn() is declared, it is used to print error messages.
# If global variable ME is set, it is used to preface printed error messages.
#
# Assumes that curl and dig utilities are available in the current $PATH.
#
# For a basic overview of the UniFi Cloud Key REST API, see:
# https://ubntwiki.com/products/software/unifi-controller/api

# Error reporting inherits or sets $ME and warn()
(set | grep '^ME=' > /dev/null) || ME=`basename -- "$0"`
(set | grep '^warn \?()' > /dev/null) || warn() { echo "$ME: $@" 1>&2; }

# For heirloom Bourne shell without local, make local a noop
(type local | grep 'builtin$' > /dev/null) || local() { return 0; }

# URL to UniFi Cloud Key without path, example: http://unifi-cloudkey-gen2:8443
UNIFI_BASEURL=

# URL to UniFi Cloud Key with short hostname resolved to IP address
UNIFI_BASEURL_RESOLVED=

# HTTP cookies for passing to UniFi Cloud Key
UNIFI_COOKIES=

# Given URL and login credentials, log in and set globals
unifi_login() {
    UNIFI_BASEURL="$1"
    [ -z "$UNIFI_BASEURL" ] && warn 'missing required URL argument' && return 1
    local username
    username="$2"
    if [ -z "$username" ]; then
        # If username is not passed and we are running interactively, prompt
        if [ -t 0 ] && [ -t 2 ]; then
            printf 'username: ' 1>&2
            read username
        fi
        [ -z "$username" ] && warn 'missing required username argument' && return 1
    fi
    local password
    password="$3"
    if [ -z "$password" ]; then
        # If password is not passed and we are running interactively, prompt
        if [ -t 0 ] && [ -t 2 ]; then
            printf 'password: ' 1>&2
            stty -echo
            read password
            stty echo
            printf '\n' 1>&2
        fi
        [ -z "$password" ] && warn 'missing required password argument' && return 1
    fi

    # Resolve hostname to IP address via default gateway if necessary
    # (for example, if this script runs on a server using a public DNS server)
    local hostport
    # TODO: heirloom sed requires '\{0,1\}' (no backslash on comma) for single optional atom
    hostport=`echo "$UNIFI_BASEURL" | sed 's,^https\{0\,1\}://,,; s,^.*\@,,; s,/.*$,,'`
    [ -z "$hostport" ] && warn 'could not extract host:port from URL: $UNIFI_BASEURL' && return 1
    local hostname
    hostname=`echo "$hostport" | sed 's/:[1-9][0-9]*$//'`
    [ -z "$hostname" ] && warn 'could not extract hostname from URL: $UNIFI_BASEURL' && return 1
    local ip
    ip=`dig +short "$hostname"`
    if [ -z "$ip" ]; then
        # Hostname did not resolve locally, ask gateway to resolve it
        local gateway
        # TODO: macOS doesn't ship with ip command, fall back to netstat -rn
        gateway=`ip route | awk '/^default via/ { print $3 }'`
        [ -z "$gateway" ] && warn 'could not determine default gateway' && return 1
        local ip
        ip=`dig +short "@$gateway" "$hostname." "$hostname.localdomain." | tail -1`
        [ -z "$ip" ] && warn "could not resolve short hostname: $hostname" && return 1
        # TODO: make sed command safer
        UNIFI_BASEURL_RESOLVED=`echo "$UNIFI_BASEURL" |
                                     sed "s,^\\(https\\?://\\)$hostname,\\1$ip,"`
    else
        # Hostname resolved fine locally, so just use it as is
        UNIFI_BASEURL_RESOLVED="$UNIFI_BASEURL"
    fi

    local postbody
    postbody="{\"username\":\"$username\",\"password\":\"$password\"}"
    UNIFI_COOKIES=`curl -iks -d "$postbody" "$UNIFI_BASEURL_RESOLVED/api/login" |
                        sed -n 's/^Set-Cookie: //p' |
                        sed 's/;.*$//' |
                        paste -sd ';' -`
}

unifi_fetch() {
    [ -z "$UNIFI_BASEURL_RESOLVED" ] && warn 'missing UniFi Cloud Key URL from unifi_login()' && return 1
    [ -z "$UNIFI_COOKIES" ] && warn 'missing UniFi Cloud Key login cookies set by unifi_login()' && return 1
    local endpoint
    endpoint="$1"
    [ -z "$endpoint" ] && warn 'missing required API endpoint path argument' && return 1
    # Chop optional leading slash (allow both /status and status)
    endpoint=`echo "$endpoint" | sed 's,^/,,'`

    curl -ks -b "$UNIFI_COOKIES" "$UNIFI_BASEURL_RESOLVED/$endpoint"
}
