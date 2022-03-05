# Introduction
For reasons that I can't quite remember, during the Covid lockdown I bought a broken Amstrad CPC 6128 and restored it. I had to buy a new gate array chip though, and that wasn't cheap or easy to find.

In a wave of misplaced inspiration, I then undertook to recreate the Amstrad CPC 6128 from schematics. That project is coming along well, and since I'm working from schematics I can make changes to the system as I see fit with the goal of creating a slightly more modern CPC but still being true to the original design. This has been done before of course, but I wanted to do it my way and to open source the results.

During the course of this little hobby project, I realised two things:

1) I didn't want to pull apart a perfectly good CPC to harvest the gate array, and,
2) if I could control the gate array and be free to change it's implementation then lots of possibilities opened up.

So, I decided I needed to be able to recreate the gate array and understand how it worked. Fortunately, lots of other people have been working towards that too. Just as well, because otherwise I'd have no chance.

# Other people's work
Fortunately for me, it seems that for some time a group of Amstrad CPC enthusiasts have been working towards creating a replacement for the hard to find gate array chip. You can read all about their journey in the link below.

[https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/gate-array-decapped!](https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/gate-array-decapped!)

TLDR; the gate array was decapped and Gerald on the forums produced schematics for it. A copy of those schematics can be found here:

https://github.com/codedchip/AMSGateArray/blob/master/Docs/40010-simplified_V03.pdf

The MiSTer project has an Amstrad CPC core which contains a verilog implementation of Gerald's schematics written by Gyorgy Szombathelyi:

https://github.com/MiSTer-devel/Amstrad_MiSTer/tree/master/rtl/GA40010

There was some speculation on the forum as to whether Gyorgy's code could be put onto a Xilinx CPLD, specifically the XC95288XL which has 5V tolerant I/O. With a suitable daughter-board it ought to be possible to replace the gate array with such a device. There are several people working on reproducing the gate arrays in verilog (as well as on ARM). With that in mind I produced two reference boards, one for the pinout of the 40010 and a second for the pinout of the 40007. This repository has the schematics and gerber files for those boards as well as my own attempt at verilog for both chip implementations (at least the 40010 and a pin mapped 40007, so the same verilog for both that is).

Hopefully this is of some use to people either looking for a test platform for their own implementation, or who can build on my verilog effort, which is in turn built on other people's work.

# My first attempt
For my first attempt at this I produced a very simple board which more or less wired up the XC95288XL to the pins of a DIP socket with a basic power supply and nothing else. My main goal was to determine if level shifting was required for output signals and to see if I could get some verilog to work. Since I wanted to learn verilog and FPGA programming in general I set about recreating Gerald's schematics for the Xilinx chip. I wrote verilog code for each page of the schematic in turn. Actually, this very nearly worked. I had a black screen but using an oscilloscope could see that the chip was "alive" and that all of the various signals were being produced. However, with a black screen troubleshooting was hard.

Next, I compared each main piece of functionality with the code in the MiSTer core by Gyorgy. In some cases I used that reference point to correct mistakes, and in other cases his impementation was just better, so I adapted it. However, still a black screen.

At this point I gave up for a while because I needed to create some new boards due to a bit of a mishap in testing. I couldn't get the Xilinx chips at all due to shortages so moved on to other things. Eventally, I got some new chips and tried again. Once again comparing the schematics to my code, I found that CCLK- the clock signal to the video generator- was inverted. Upon fixing that, this happened:

![First screen display](https://github.com/codedchip/AMSGateArray/blob/master/Docs/FirstScreen.jpg)

# Current status
- Having physical boards where changes to the verilog can be quickly checked in real hardware is proving invaluable.
- Initial 40010 verilog implementation has passed basic testing on a real Amstrad CPC 6128.
- Prototype boards have been produced for the 40010 pinout and the 40007 pinout. The verilog should theoretically work on both with just different pin constraints and perhaps some minor changes. I have not yet tested the 40007 as I don't have a CPC 464.
- The next step is to continue to refine the verilog code and test further.
- ~~At this time there is still some asynchronous logic, particularly in vsync and casgen. Although I haven't seen any evidence of it, this might cause timing glitches. Conversion of these sections to something more appropriate is a work in progress.~~
- ~~There is also one place left (irqack) where a combinatorial loop is present. I'll remove this if it still exists after converting that part to be more synchronous.~~

# Testing
With basic testing on an Amstrad CPC 6128 it seems that the GA is working as it should. I can play games, use my Dandanator, and all of the mode commands and colour changing commands in basic that I know about seem to work. *Much* more extenstive testing is required though. 

I've been pointed towards demos as a good way of testing out the gate array. Although they are normally using tricks of the CRTC, I hope that running them will help flush out any bugs. Here are the demos I have tested so far, I'll update this list as I go. "Pass" means that to my eyes the demo looks exactly the same when using the replacement gate array as with a real one. These tests are based on [this forum post](https://mametesters.org/view.php?id=6061).

| Demo           | URL                                       | Platform   | Result |
|----------------|-------------------------------------------|------------|--------|
| Batman Forever | http://www.pouet.net/prod.php?which=56761 | 6128/40010 CPLD/CRTC 1/512Kb | Pass |
| Still Rising   | http://www.pouet.net/prod.php?which=61177 | 6128/40010 CPLD/CRTC 1 | Pass |
| From Scratch   | http://www.pouet.net/prod.php?which=53596 | 6128/40010 CPLD/CRTC 1 | Pass |
| Phortem        | http://www.pouet.net/prod.php?which=61465 | 6128/40010 CPLD/CRTC 1 | Pass |
| Wolfenstrad    | http://www.pouet.net/prod.php?which=58887 | 6128/40010 CPLD/CRTC 1 | Pass |
| DTC            | http://www.pouet.net/prod.php?which=20226 | 6128/40010 CPLD/CRTC 1 | Pass |
| Yet Another Plasma!   | http://www.pouet.net/prod.php?which=60660 | 6128/40010 CPLD/CRTC 1 | Pass |
| Wake Up! (final)  | http://www.pouet.net/prod.php?which=59073 | 6128/40010 CPLD/CRTC 1 |  Pass |
| Pheelone   | http://www.pouet.net/prod.php?which=53498 | 6128/40010 CPLD/CRTC 1 | Pass |

# The boards
The boards are very simple designs, varying only in the pinout of the DIP-40 footprint and the corresponding power and ground connections. I have not incorporated level shifters for the reasons discussed above, however I have used a 3.6V regulator to power the CPLD to improve logic levels. This is still within the spec of the XC95288XL, but can easily be substituted with a 3.3V model as required. As mentioned earlier, I haven't had issues caused by any output signals being outside TTL specs and a high being represented as a low. Hopefully this remains the case through testing as the simpler board design results in much better routing and comfortably fits on two layers. Virtually all signal traces are on the bottom of the board, with all power and ground traces on the top. As I said, very simple stuff. On both boards I have routed the 16MHz clock and HSYNC to the GCLK pins on the CPLD as these signals are both essentially external clocks and that is best practice. However, I hope to remove the dependency on HSYNC for clocking in due course.

The purpose of these boards is for prototyping. They are probably larger than they need to be, even with the large CPLD. That's partly to keep to two layers for cost, but mostly priorities. However, I will look into miniturising as far as possible. This might mean simplifying the verilog to fit onto a smaller CPLD, using multiple interconnected CPLDs, or a combination of both. The immediate priority though is to test the verilog code. I need a working gate array for my CPC project, where I will be free to surface mount the CPLD on a much larger board, so miniturising might not be my main concern.

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



