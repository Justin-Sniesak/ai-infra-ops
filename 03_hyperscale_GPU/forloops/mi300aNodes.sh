#!/bin/bash
for t in {1..100}; do
sed "s|name: mi300a-node-0|name: mi300a-node-$t|" kwokNodesMI300A.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
