# Send a Markdown-capable notification via ntfy
function notify
    set -l title $argv[1]
    set -l message $argv[2]

    curl -s \
        -H "Title: $title" \
        -H "X-Markdown: yes" \
        -d "$message" \
        ntfy.sh/wenbo-R2osKWmlKv7gQh2m > /dev/null 2>&1
end
