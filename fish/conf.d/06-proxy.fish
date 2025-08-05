# List of candidate ports
set candidate_ports 7899 7890 7891 17890
set PROXY_PORT ""

for port in $candidate_ports
    if nc -z -w 0.001 localhost $port >/dev/null 2>&1
        set PROXY_PORT $port
        break
    end
end

if test -n "$PROXY_PORT"
    set -gx ALL_PROXY "http://127.0.0.1:$PROXY_PORT"
    set -gx HTTP_PROXY $ALL_PROXY
    set -gx HTTPS_PROXY $ALL_PROXY
end

