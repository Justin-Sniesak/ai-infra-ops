#!/bin/bash
for t in {1..100}; do
sed "s|name: mi350x-node-0|name: mi350x-node-$t|" kwokNodesMI350X.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
