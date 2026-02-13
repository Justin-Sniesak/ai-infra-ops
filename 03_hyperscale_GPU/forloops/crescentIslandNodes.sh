#!/bin/bash
for t in {1..100}; do
sed "s|name: crescent-node-0|name: crescent-node-$t|" kwokNodesCrescentIsland.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
