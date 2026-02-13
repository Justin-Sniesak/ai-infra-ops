#!/bin/bash
for t in {1..100}; do
sed "s|name: mi325x-node-0|name: mi325x-node-$t|" kwokNodesMI325X.yaml | kubectl apply -f -
if (( $t % 25 == 0 )); then
    echo "Injected $t nodes...";
fi
done
