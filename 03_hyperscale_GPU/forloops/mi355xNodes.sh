#!/bin/bash
for t in {1..100}; do
sed "s|name: mi355x-node-0|name: mi355x-node-$t|" kwokNodesMI355X.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
