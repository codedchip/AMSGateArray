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
//  Further built by reference to the Amstrad MiSTer core by Gyorgy Szombathelyi
//  https://github.com/MiSTer-devel/Amstrad_MiSTer/tree/master/rtl/GA40010
// ===============================================================================
module SequenceDecoder(input CLK_n,
                       input[7 : 0] S,
                       input RD_n,
                       input IORQ_n,
                       output PHI_n,
                       output RAS_n,
                       output READY,
                       output CASAD_n,
                       output CPU_n,
                       output CCLK,
                       output MWE_n,
                       output s244E_n);
  reg _phi_n;
  reg _ras_n;
  reg _casad_n;
  reg _ready;
  always
    @(posedge CLK_n)
      begin
        _phi_n <= (S[1] ^ S[3]) | (S[5] ^ S[7]);
        _ras_n <= (S[6] | ~S[2]) & S[0];
      end
  always
    @(negedge CLK_n)
      begin
        _casad_n <= _ras_n;
        _ready <= (~_ras_n & _ready) | (S[3] & ~S[6]);
      end
  assign PHI_n = _phi_n;
  assign RAS_n = _ras_n;
  assign CASAD_n = _casad_n;
  assign CPU_n = ~(S[1] & ~S[7]);
  assign CCLK = ~(S[2] | S[5]);
  assign MWE_n = ~(S[0] & S[5] & RD_n);
  assign s244E_n = ~(S[2] & S[3] & ~IORQ_n);
  assign READY = _ready;
endmodule
