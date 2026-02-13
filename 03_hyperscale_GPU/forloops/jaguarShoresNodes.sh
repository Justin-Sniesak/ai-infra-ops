#!/bin/bash
for t in {1..100}; do
sed "s|name: jaguarshores-node-0|name: jaguarshores-node-$t|" kwokNodesJaguarShores.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
