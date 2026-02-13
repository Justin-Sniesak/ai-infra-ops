#!/bin/bash
for t in {1..100}; do
sed "s|name: mi300x-node-0|name: mi300x-node-$t|" kwokNodesMI300X.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
