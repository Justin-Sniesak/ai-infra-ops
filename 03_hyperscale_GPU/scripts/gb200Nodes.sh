#!/bin/bash
for t in {1..100}; do
sed "s|name: gb200-node-0|name: gb200-node-$t|" kwokNodesGB200.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
