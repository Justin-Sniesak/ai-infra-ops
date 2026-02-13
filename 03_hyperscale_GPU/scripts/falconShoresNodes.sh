#!/bin/bash
for t in {1..100}; do
sed "s|name: falconshores-node-0|name: falconshores-node-$t|" kwokNodesFalconShores.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
