#!/bin/bash
for t in {1..100}; do
sed "s|name: a100-node-0|name: a100-node-$t|" kwokNodesA100.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
