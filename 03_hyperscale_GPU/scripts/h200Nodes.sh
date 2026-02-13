#!/bin/bash
for t in {1..100}; do
sed "s|name: h200-node-0|name: h200-node-$t|" kwokNodesH200.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
