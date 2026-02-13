#!/bin/bash
for t in {1..100}; do
sed "s|name: b580-node-0|name: b580-node-$t|" kwokNodesB580.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
