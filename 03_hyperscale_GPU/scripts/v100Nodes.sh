#!/bin/bash
for t in {1..100}; do
sed "s|name: v100-node-0|name: v100-node-$t|" kwokNodesV100.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
