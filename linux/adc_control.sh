#!/bin/bash
# Demo script to adjust convolution processor parameters in real time, based on
# ADC readings

ADC_DEV_NODE=/sys/class/misc/adc_platform
CONV_DEV_NODE=/sys/class/misc/convolution_processor
LOOP_DELAY=0.1


# Enable the first two ADC channels in single-ended mode
echo 0x03 > "$ADC_DEV_NODE/config_single"

# Enable the convolution processor
echo 1 > "$CONV_DEV_NODE/enable"

# Prepare to catch interrupts
interrupted=false
trap ctrl_c INT
function ctrl_c() { interrupted=true; }


# Main control loop
echo "Control loop running; interrupt to exit..."
while [ $interrupted = false ]
do
    # Both register sets are fixed-point, but use different numbers of
    # fractional bits: 12 for the ADC, versus 16 for the convolution processor.
    # To compensate for this, we simply multiply the ADC sample values by 2**4.
    echo $(($(<"$ADC_DEV_NODE/ch_single_0") * 2**4)) > "$CONV_DEV_NODE/wetDryMix"
    echo $(($(<"$ADC_DEV_NODE/ch_single_1") * 2**4)) > "$CONV_DEV_NODE/volume"
    # ...don't you just love doing math in shell scripts?

    # Also, let's not eat the CPU for breakfast
    sleep "$LOOP_DELAY"
done


# Clean up
echo 0 > "$CONV_DEV_NODE/enable"

exit 0
