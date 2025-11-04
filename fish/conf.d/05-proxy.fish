if type -q nc
    # List of candidate ports commonly used by local proxies
    set -l candidate_ports 7899 7890 7891 17890
    set -l proxy_port ""

    for port in $candidate_ports
        if nc -z -w 1 localhost $port >/dev/null 2>&1
            set proxy_port $port
            break
        end
    end

    if test -n "$proxy_port"
        set -gx PROXY_PORT $proxy_port
        set -gx ALL_PROXY "http://127.0.0.1:$proxy_port"
        set -gx HTTP_PROXY $ALL_PROXY
        set -gx HTTPS_PROXY $ALL_PROXY
    end
end
