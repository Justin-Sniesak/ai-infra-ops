#!/bin/bash
for t in {1..100}; do
sed "s|name: b200-node-0|name: b200-node-$t|" kwokNodesB200.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
