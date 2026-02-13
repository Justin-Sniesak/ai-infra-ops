#!/bin/bash
for t in {1..100}; do
sed "s|name: l4-node-0|name: l4-node-$t|" kwokNodesL4.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
