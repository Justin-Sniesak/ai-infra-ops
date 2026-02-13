#!/bin/bash
for t in {1..100}; do
sed "s|name: t4-node-0|name: t4-node-$t|" kwokNodesT4.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
