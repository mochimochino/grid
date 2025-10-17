#!/bin/bash

# 対象ノード一覧
NODES=(
  grid01
  grid02
  grid03
  grid07
)

DEST_BASE="/root/grid/ansible_hu/node_status"

for node in "${NODES[@]}"; do
    echo "=== $node からログ取得中 ==="

    dest_dir="${DEST_BASE}/${node}"
    mkdir -p "$dest_dir"

    # 転送コマンド
    scp -r "grdadmin@${node}.aligrid.hiroshima-u.ac.jp:/var/log/sa/"* "$dest_dir"/ 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "  -> $node のログ取得完了"
    else
        echo "  !! $node のログ取得失敗"
    fi
done

echo "=== すべてのログ収集が完了しました ==="

