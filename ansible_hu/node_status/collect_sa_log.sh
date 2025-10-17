#!/bin/bash

NODES="grid[01-07],qx[301-320],nfs[11-13]"

DEST_BASE="/root/grid/ansible_hu/node_status"

for node in $(clush -w $NODES --nostdin --quiet 'hostname' 2>/dev/null); do
    echo "=== $node からログ取得中 ==="

    dest_dir="${DEST_BASE}/${node}"
    mkdir -p "$dest_dir"

    scp -r ${node}:/var/log/sa/* "$dest_dir"/ 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "  -> $node のログ取得完了"
    else
        echo "  !! $node のログ取得失敗"
    fi
done

echo "=== すべてのログ収集が完了しました ==="

