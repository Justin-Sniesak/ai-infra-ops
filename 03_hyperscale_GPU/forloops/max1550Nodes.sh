#!/bin/bash
for t in {1..100}; do
sed "s|name: max1550-node-0|name: max1550-node-$t|" kwokNodesMax1550.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
