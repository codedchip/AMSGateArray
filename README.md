# Introduction
For some time, a group of Amstrad CPC enthusiasts have been working towards creating a replacement for the gate array chip. You can read all about their journey in the link below. I happend upon this because I had bought an Amstrad CPC 6128 and couldn't get it to work. Indications were pointing at the gate array and I thought it might be interesting to have a go at implementing some verilog for it, especially since so much prerequisite work had been done by others.

https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/gate-array-decapped!(https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/gate-array-decapped!)

TLDR; the gate array was decapped and Gerald on the forums produced schematics for it. A copy of those schematics can be found here:

https://github.com/codedchip/AMSGateArray/blob/master/Docs/40010-simplified_V03.pdf

The MiSTer project has a Amstrad CPC core which contains a verilog implementation of Gerald's schematics written by Gyorgy Szombathelyi:

https://github.com/MiSTer-devel/Amstrad_MiSTer/tree/master/rtl/GA40010

There was some speculation on the forum as to whether Gyorgy's code could be put onto a Xilinx CPLD, specifically the XC95288XL which has 5V tolerant I/O. With a suitable daughter board it ought to be possible to replace the gate array with such a device. There are several people working on reproducing the gate arrays in verilog (as well as on ARM). With that in mind I produced two reference boards, one for the pinout of the 40010 and a second for the pinout of the 40007. This repository has the schematics and gerber files for those boards as well as my own attempt at verilog for both chip implementations (at least the 40010 and a pin mapped 40007, so the same verilog for both that is).

Hopefully this is of some use to people either looking for a test platform for their own Gate Array implementations or who can build on my verilog implementation.

# Current status
- Initial 40010 verilog implementation has passed basic testing on a real Amstrad CPC 6128.
- Prototype boards have been produced for the 40010 pinout and the 40007 pinout. The verilog should theoretically work on both with just different pin constraints and perhaps some minor changes. I have not yet tested the 40007 as I don't have a CPC 464.
- The next step is to continue to refine the verilog code and test further. In particular I want to refine the clock domains in the code.

# My first attempt
For my first attempt at this I produced a very simple board which more or less wired up the XC95288XL to the pins of a DIP socket with a basic power supply and nothing else. My main goal was to determine if level shifting was required for output signals and to see if I could get some verilog to work. Since I wanted to learn verilog and FPGA programming in general I set about recreating Gerald's schematics for the Xilinx chip. I wrote verilog code for each page of the schematic in turn. Actually, this very nearly worked. I had a black screen but using an oscilloscope could see that the chip was "alive" and that all of the various signals were being produced. However, with a black screen troubleshooting was hard.

Next, I compared each main piece of functionality with the code in the MiSTer core by Gyorgy. In some cases I used that reference point to correct mistakes, and in other cases his impementation was just better, so I adapted it. However, still a black screen.

At this point I gave up for a while because I needed to create some new boards due to a bit of a mishap in testing. I couldn't get the Xilinx chips at all due to shortages so moved on to other things. Eventally, I got some new chips and tried again. Once again comparing the schematics to my code, I found that CCLK- the clock signal to the video generator- was inverted. Upon fixing that, this happened:

![First screen display](https://github.com/codedchip/AMSGateArray/blob/master/Docs/FirstScreen.jpg)

With basic testing on and Amstrad CPC 6128 it seems that the GA is working as it should. I can play games, use my Dandanator, and all of the mode commands and colour changing commands in basic that I know about seem to work. *Much* more extenstive testing is required though. I have found that level shifting isn't required. Tracing the output signals from the replacement gate array to the corresponding targets on the CPC motherboard shows that they are well within the TTL specification. I did create a prototype board using two TXS0108 level shifters allowing the 16 outputs to be shifted to 5V. However, the inclusion of those chips resulted in a routing nightmare on such a small board and required the use of more PCB layers, making the board more expensive.

# The boards
The boards are very simple designs, varying only in the pinout of the DIP-40 footprint and the corresponding power and ground connections. I have not incorporated level shifters for the reasons discussed above, however I have used a 3.6V regulator to power the CPLD to improve logic levels. This is still within the spec of the XC95288XL, but can easily be substituted with a 3.3V model as required. As mentioned earlier, I haven't had issues caused by any output signals being outside TTL specs and a high being represented as a low. Hopefully this remains the case through testing as the simpler board design results in much better routing and comfortably fits on two layers. Virtually all signal traces are on the bottom of the board, with all power and ground traces on the top. As I said, very simple stuff. On both boards I have routed the 16MHz clock and HSYNC to the GCLK pins on the CPLD as these signals are both essentially external clocks and that is best practice. However, I hope to remove the dependency on HSYNC for clocking in due course.

The purpose of these boards is for prototyping. However, I will look into miniturising as far as possible. This might mean simplifying the verilog to fit onto a smaller CPLD, using multiple interconnected CPLDs, or a combination of both. The immediate priority though is to test the verilog code. I need a working gate array for part of a bigger project where I would be free to surface mount the CPLD on a much larger board, so miniturising might not be my main concern.

## 40010
### Schematic
![Schematic](https://github.com/codedchip/AMSGateArray/blob/master/40010/Schematic.png)
### PCB
![Board](https://github.com/codedchip/AMSGateArray/blob/master/40010/PCB.png)
### Top view
![Front](https://github.com/codedchip/AMSGateArray/blob/master/40010/BoardFront.jpg)
### Bottom view
![Back](https://github.com/codedchip/AMSGateArray/blob/master/40010/BoardBack.jpg)

## 40007
### Schematic
![Schematic](https://github.com/codedchip/AMSGateArray/blob/master/40007/Schematic.png)
### PCB
![Board](https://github.com/codedchip/AMSGateArray/blob/master/40007/PCB.png)
### Top view
![Front](https://github.com/codedchip/AMSGateArray/blob/master/40007/BoardFront.jpg)
### Bottom view
![Back](https://github.com/codedchip/AMSGateArray/blob/master/40007/BoardBack.jpg)



