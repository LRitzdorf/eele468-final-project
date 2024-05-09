#!/bin/sh
# Demo script to configure convolution processor with sane defaults

DEV_NODE=/sys/class/misc/convolution_processor

echo 0xFFFF > "$DEV_NODE/wetDryMix"
echo 0x3FFF > "$DEV_NODE/volume"
echo 1      > "$DEV_NODE/enable"
