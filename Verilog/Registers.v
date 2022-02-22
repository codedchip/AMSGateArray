// ===============================================================================
//
//  Amstrad CPC Gate Array for Xilinx X95288XL
//
//  Copyright (C) 2021 Darren Johnstone <darren@darrenjohnstone.scot>
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//  Acknowledgements:
//
//  Based on 40010-simplified_V03.pdf by Gerald 
//  (https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/gate-array-decapped!) 
//  
//  Partially based on the Amstrad MiSTer core by Gyorgy Szombathelyi
//  https://github.com/MiSTer-devel/Amstrad_MiSTer/tree/master/rtl/GA40010
// ===============================================================================
module Registers(input CLK_n,
                 input RESET,
                 input M1_n,
                 input A14,
                 input A15,
                 input IORQ_n,
                 input S0,
                 input S7,
                 input[7 : 0] D,
                 output[4 : 0] BORDER,
                 output IRQ_RESET,
                 output HROMEN,
                 output LROMEN,
                 output[1 : 0] MODE,
                 output[15 : 0] INKR0,
                 output[15 : 0] INKR1,
                 output[15 : 0] INKR2,
                 output[15 : 0] INKR3,
                 output[15 : 0] INKR4);
  reg[4 : 0] inksel;
  wire reg_sel = M1_n & A14 & ~A15 & ~IORQ_n & S0 & S7; // u401
  wire inksel_en = reg_sel & ~D[7] & ~D[6]; // u402
  wire border_en = reg_sel & ~D[7] & D[6] & inksel[4]; // u408
  wire reg_en = reg_sel & D[7] & ~D[6]; // u414
  // u420 
  // on the schematic the ~inksel[4] condition is missing, but this would mean border 
  // and ink potentially being selected at the same time
  wire ink_en = reg_sel & ~D[7] & D[6] & ~inksel[4];
  assign IRQ_RESET = reg_en & D[4];
  reg _hromen,
      _lromen,
      _mode0,
      _mode1;
  reg[4 : 0] _border;
  reg[15 : 0] _inkr0;
  reg[15 : 0] _inkr1;
  reg[15 : 0] _inkr2;
  reg[15 : 0] _inkr3;
  reg[15 : 0] _inkr4;
  // Move to clock domain
  always
    @(posedge CLK_n)
      begin
        // inksel branch
        if (inksel_en)
          inksel <= D[4 : 0];
        // border branch
        if (RESET)
          _border <= 5'b10000;
        else
          if (border_en)
            _border <= D[4 : 0];
        // register branch
        if (RESET)
          { _hromen, _lromen, _mode1, _mode0 } <= 0;
        else
          if (reg_en)
            { _hromen, _lromen, _mode1, _mode0 } <= D[3 : 0];
        // ink branch
        if (ink_en)
          begin
            _inkr0[inksel[3 : 0]] <= D[0];
            _inkr1[inksel[3 : 0]] <= D[1];
            _inkr2[inksel[3 : 0]] <= D[2];
            _inkr3[inksel[3 : 0]] <= D[3];
            _inkr4[inksel[3 : 0]] <= D[4];
          end
      end
  assign INKR0 = _inkr0;
  assign INKR1 = _inkr1;
  assign INKR2 = _inkr2;
  assign INKR3 = _inkr3;
  assign INKR4 = _inkr4;
  assign BORDER = _border;
  assign HROMEN = _hromen;
  assign LROMEN = _lromen;
  assign MODE[0] = _mode0;
  assign MODE[1] = _mode1;
endmodule
