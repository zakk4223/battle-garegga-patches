# **Battle Garegga quality of life patches.**

Program rom patches for Battle Garegga that add some convenience and functionality:

 - Mahou guest characters unlocked.
 - ABC ship type selectable via start button
 - No rank carry over between credits. Rank starts at power on default
   every credit.
 - Item drop order reset to initial value every credit
 - Item non collected counts reset to initial values every credit
 - Quick reset: start+ABC resets to the copyright screen
 - Scoreboard display bug fixed. Top scores will show the proper letter
   instead of punctuation for 10M+
 - Autofire rate display. Bottom left and right display current autofire
   rate for respective player.
 - Rank display. Real time display of current game rank.
 - Rank change display: Per-frame display of rank change during the
   frame. This excludes per-frame rank adjustments and any rank changes
   due to shooting (normal and option).
 - Rank percentage display. Should line up with the rank percentage in
   the M2 port.
 - Per frame rank display.

Rank and rank change are shown in hexadecimal. Per frame is shown in decimal. This is because the M2 port shows the per-frame rank in decimal too; I wanted them to match up for less (personal) confusion.

## How to use

Extract the mame bgaregga rom set. Use your favorite IPS patch applier to patch prg0.bin and prg1.bin using the respective IPS files in this repo

Mame will complain about incorrect rom checksums. You can ignore this.

## Source

patch.s contains the assembly source to recreate this patch.  Use http://john.ccac.rwth-aachen.de:8000/as/ and https://www.mankier.com/1/p2bin to assemble it. You must combine prg0.bin and prg1.bin into a single interleaved binary. See build.sh for exact  command line arguments for various tools.


