# Final Project Report


## Introduction

This project involves the design and implementation of a "real-time convolution" (or "convolution playback") sound effect, within a programmable FPGA fabric.
In general, this system operates by recording an "impulse" into its memory, which is then multiply-accumulated with the live audio stream to perform a convolution.

The process of implementing this in the FPGA fabric, with a limited number of clock cycles to accomplish the required operations, posed a unique challenge: a new sample arrives every 2048 clock cycles, but we need to perform 48000 multiply-accumulate (MAC) operations for every such sample.
This was resolved by pipelining, such that each pipeline stage performs 2000 MACs before passing its partial result on to the next stage.


## Sound Effect

Implementing a convolution processor with real-time recording and convolution capability was not a simple task.
A section of the Simulink model for the "recording convolver" block is shown below:

![Recording convolution processor, constructed in Simulink](/figures/simulink_convolution.png)

As previously mentioned, the core of the recording convolver is a 24-stage pipeline of "convolution cores."
Before they can perform useful work, these cores must be loaded with recorded audio data.
This process is initiated when the `record` input (shown in the diagram above) rises, and stores 48000 samples (i.e. one second's worth) of the audio stream into RAM blocks inside each convolution core.

Once this recording is complete, the cores can perform their 2000 MAC operations on each streamed input sample, before passing that sample on to the next core in the pipeline.
At any given moment, then, every convolution core contains a set of 2000 input samples which are in the process of being convolved, in addition to its 2000 recorded impulse samples.
Together, these comprise the two arguments for convolution.

Also, it is worth noting that this system imposes a one-second (i.e. 48000-sample) delay for processing.
This should make intuitive sense, as it is performing convolution against a one-second impulse.

### Control Registers

The control registers provided by this system are as follows:
| Address | Function    | Description                             | Format | Default value |
|---------|-------------|-----------------------------------------|--------|---------------|
| `0x0`   | Wet/dry mix | Proportion of processed audio in output | UQ0.16 | `0xFF`        |
| `0x4`   | Volume      | Output volume control                   | UQ0.16 | `0x80`        |
| `0x8`   | Enable      | Effect enable                           | Bit    | `0x01`        |

These registers are implemented as a basic slave node on the DE10 SoC's lightweight Avalon bus, and are therefore mapped into the system's memory space.
Real-time control is achieved by writing to the relevant memory locations by way of a Linux device driver, the data for which can come from any source in userspace.
(In this case, this data actually comes from an ADC device driver, which is included in this repo along with the associated hardware module.
As a result, the ADC input potentiometers are used to achieve real-time audio parameter control.)


## Conclusions

In general, the implementation of this project (and specifically the recording convolution engine) turned out to be somewhat more difficult than I had anticipated.
This may simply be the result of my lack of Simulink experience, but the design of a digital system with clock-cycle precision in Simulink's graphical block-based format posed a significant challenge.
Fortunately, the provided debugging and signal logging tools were sufficient to ease this process somewhat, to the point that my first attempt at hardware implementation was successful.

Despite (or more likely, as a result of) this challenge, the project was a particularly fun one for me.
The process of designing a complex system from the ground up, implementing it using advanced tooling, and creating an associated device driver was a particularly engaging one.
It has been particularly satisfying to see my system come together over the past few weeks, going from an un-simulatable mess of logic to a functioning piece of hardware.

As a general rule, I tend to enjoy project-based courses, as they allow for improved student engagement and demand a higher level of competence than simply regurgitating information for an exam.
This course was no exception — and while the associated knowledge requirements sometimes challenged my classmates, helping them learn proved to be a very satisfying experience for me as well.
