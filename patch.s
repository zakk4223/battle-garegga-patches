	CPU 68000
	PADDING OFF
	ORG	$000000
	BINCLUDE "original_combined.bin"


FREE_OFFSET = $52430




	ORG $2C
	dc.l linef_dispatch_z
; Don't adjust the default rank by some previous value
; Basically, don't mess with the rank when a credit is started
	ORG $39A
	nop

; This jumps to custom code for Start+ABC quick restart
	ORG $8C0
	jmp quick_reset 

	ORG $9A2 
	dc.w $F0BB
; Reset passed items count
	ORG $B86
	clr.l ($109CB8) ; reset $109CB8 count (unknown and already present in code), small shot count ($109CB9 already present in code), small bomb count ($109CBA) and option count ($109CBB)
	clr.b ($109CBC) ; reset medal count ($109CBC)
; Reset item drop state
	ORG $BEE
	clr.b ($109CB4) ; re-initialize enemy kill count for item drop
	nop
	nop
	clr.b ($109CB5) ; reset dropped item to initial value
	nop
	nop

; After the upper part of the screen info text is copied, copy ours
	ORG $11E4
	jmp custom_values_display
	trap #4
	rts

	ORG $33B8
	dc.l rank_adjust_z

; Make sure guest ships are available when continuing
	ORG $711E
	andi.w #$F0,d0

; Enable guest characters
	ORG $F854
	st ($10A6A7)
	move.b #$F2,d0

; Fix high score table
	ORG $10CA6
	jmp high_score_format_patch
        ORG $10CD8
	move.b (a6,d1), d1

; Ignore the stage edit dip (accessible via C+Start)
	ORG $12D18
	andi.w #$7, d0

; Jump to our custom rom/ram test code
	ORG $159CA
	jmp test_rom_ram_0

	ORG $15C32
	bra $15B08


; The extent of the JAM!
	ORG $1620D
	dc.b $4A
	dc.b $41
	dc.b $4D
	dc.b $21
	dc.b 0

	ORG $293A2
	dc.w $F0B9
	ORG $29410
	dc.w $F0B9

	ORG $2BC44
	dc.w $F0B9

        ORG $2BD0C; Gain option shot rank
        dc.w $F0B9

        ORG $2BD3C ;Miyamoto option shot rank
        dc.w $F0B9

	ORG $2BD7C
	dc.w $F0B9

	ORG $51B30
	andi.w #$F0,d1
	bne select_abc_start 

	ORG FREE_OFFSET
select_abc_start:
	andi.w #$70,d1 ; start -> ABC select
	jmp $51B4C
	dc.b 0
	dc.b $FF
	dc.b 0
	dc.b $FF
	dc.b 0
	dc.b $FF
; only show rom check if P1 start is held down (possibly bugged on real hardware?)
test_rom_ram_0:
	tst.b ($10CA34)
	bne test_rom_ram_0_return
	move.b ($10009E),d1
	andi.w #$F0,d1
	cmpi.b #$80,d1
	bne test_rom_ram_0_return
	jmp $159D2
test_rom_ram_0_return:
	jmp $159C8
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
        dc.b 0
        dc.b $FF
; Reset when P1 start+ABC is pressed
; TODO also when P2 is pressed?
quick_reset:
	move.b ($101679),d1
	andi.b #$F0,d1
	cmpi.b #$F0,d1
	beq return_to_copyright_main
	jsr $984
	jsr $9AC
	jmp $8C8
return_to_copyright_main:
	jmp $310
        dc.b 0
        dc.b $FF
copy_to_txtmem_tail:
	dc.b $A0
	dc.b $2C
	trap #$F
	dc.w $4E49
	trap #4
	rts
; Convert a number to base-10 ASCII and write it to text ram
; IN
; d1: The number to display
; d0: The 'format code' to use for the digits
; a5: Start address of output string
; After return, a5 will point to the character AFTER the end of the displayed
; string
write_ascii_to_txt:
	clr.w d2
	clr.w d3
ascii_loop_start:
	divu #$A,d1
	addq.b #1,d2
	move.l d1,d3
	swap d3
	addi.b #$30,d3
	eor.w d0,d3
	move.w d3, -(sp)
	swap d1
	clr.w d1
	swap d1
	tst.w d1
	bne ascii_loop_start
	bra copy_loop_start
copy_loop_head:
	move.w (sp)+,d3
	move.w d3,(a5)
	lea $80(a5),a5
copy_loop_start:
	dbf d2,copy_loop_head
	rts

write_asciihex_to_txt:
	clr.w d3
        clr.w d2
        clr.w d4
        tst.l d1
        beq value_is_zero
write_hex_start:
        move.b d1,d3
        and.b #$F,d3 
        addq.b #1,d2
        lsr.l #4,d1
write_hex_resume:
        cmp.b #$9,d3
        bgt add_hex
        addi.b #$30,d3
        bra after_hex
add_hex:
	addi.b #$37,d3
after_hex:
	or.w d0,d3
        move.w d3, -(sp)
        cmp.b #$8,d2
        bne write_hex_start 
purge_loop_head:
        move.w (sp)+,d3
        cmp.b #$30, d3
        bne purge_done
purge_loop_start:
        dbf d2,purge_loop_head
        rts
purge_done:
        move.w d3, -(sp)
        bra copy_loop_start
value_is_zero:
        moveq #$0,d3
        or.w d0,d3
        move.w d3,(a5)
        rts
digit_is_zero:
        btst #$F,d4
        beq write_hex_start
        bra write_hex_resume
; After the main program writes a bunch of the txt hud (scores, etc)
; There's a jump here. This writes autofire rates and rank display
custom_values_display:
        btst #3, ($21c035)
        beq custom_values_end
	lea ($500004),a5
        lea autofire_lookup_table,a4
	move.w #$C400,d0
	clr.l d1
	move.b ($10167C),d1 ; P1 Autofire rate TODO: lookup table for Hz
	tst.b d1
        beq player_2_af
        move.b (a4,d1),d1
	jsr write_ascii_to_txt
player_2_af:
	lea ($500E04),a5
	clr.l d1
	move.b ($101774),d1 ; P2 Autofire
	tst.b d1
        beq rank_display
        move.b (a4,d1),d1
	jsr write_ascii_to_txt
; Overall rank. This is a big number that normally overflows a DIV 10
; operation. Divide by 1000 first, then convert+print the quotient first
; then the remainder
rank_display:
	lea ($500648),a5
        btst #1, ($10a6b2)
        bne change_rank_disp
        btst #2, ($10a6b2)
        bne change_rank_disp
        bra start_rank_disp
change_rank_disp:
        lea ($500646),a5
start_rank_disp:
	clr.l d1
	move.l ($10C9D2),d1 
        jsr write_asciihex_to_txt
        clr.l d1
        move.l ($10C9D6),d1
        lea ($500044),a5
	jsr write_ascii_to_txt
; Calculate rank percentage
        tst ($10C9D2)
        beq copy_to_txtmem_tail 
        move.l #$F00000,d1
        sub.l ($10C9D2),d1
        move.l #$F00000,d3 
        sub.l #$200000, d3
        divu #1000,d3
        swap d3
        clr.w d3
        swap d3 
        divu d3,d1
        swap d1
        clr.w d1
        swap d1
        divu #10,d1
; d1[0-15].d1[16-32]
        lea ($500046), a5
        move.l d1,d4 
        swap d1
        clr.w d1
        swap d1
        jsr write_ascii_to_txt
        swap d4
        move.w d4,d1 
        move.w #$C42E,(a5)
        lea $80(a5), a5
        jsr write_ascii_to_txt
        move.w #$C425,(a5)
        lea $80(a5),a5
        move.w #$0000,(a5)
        lea $80(a5),a5
        move.w #$0000,(a5)
        move.l ($100D92),d1
        jsr write_rank_adjust  
custom_values_end:
        jmp copy_to_txtmem_tail
autofire_lookup_table:
	dc.b 60
	dc.b 30
	dc.b 20
	dc.b 15
	dc.b 12
	dc.b 10
	dc.b 8 
        dc.b 0
linef_dispatch_z:
	movem.l d7/a4,-(sp)
	movea.l $A(sp),a4
        move.w (a4),d7
        swap d7
	move.w (a4)+, d7
	move.l a4,$A(sp)
	andi.w #$FFC,d7
        lea $3300,a4
        movea.l (a4,d7.w),a4
	jsr (a4)
	movem.l (sp)+,d7/a4
	move sr,(sp)
	rte
rank_adjust_z:
        andi.l #$30000,d7
        bne sub_rank_adj
        add.l d0, ($100D92)
        clr.w ($100D88)
sub_rank_adj:
	sub.l d0,($10C9D2)
	move.l ($10C9D2),d0
	cmp.l ($10C9DA),d0
	bcs below_min_rank
	cmp.l ($10C9DE),d0
	bcs rank_adjust_rts
	move.l ($10C9DE),($10C9D2)
        rts
below_min_rank:
	move.l ($10C9DA),($10C9D2)
rank_adjust_rts:
        andi.l #$20000,d7
        beq real_adj_rts
        addq.w #1,($100D88)
        cmp.w #120,($100D88)
        beq rank_display_expired
real_adj_rts:
        rts
write_rank_adjust:
        move.l ($100D92),d1
        clr.l ($100D92)
        tst.l d1
        bne rank_write_not_zero
        rts
rank_write_not_zero:
        lea ($500646),a5
        btst #1, ($10a6b2)
        bne change_rank_adj
        btst #6, ($10a6b2)
        bne change_rank_adj
        bra start_rank_adj
change_rank_adj:
        lea ($500644),a5
start_rank_adj:
        cmp.l #$FFFFFFFF,d1
        beq clear_rank_digits
        move.w #$C400,d0
        tst.l d1
        bpl rank_pos
        neg.l d1
        move.w #$CC00,d0
rank_pos:       
        cmp.l ($100D82), d1
        bne clear_rank_digits
        move.w ($100D86),d0
        eor.w #$C00,d0
clear_rank_digits:
        move.w #$0000,(a5)
        move.w #$0000,$80(a5)
        move.w #$0000,$100(a5)
        move.w #$0000,$180(a5)
        move.w #$0000,$200(a5)
        move.w #$0000,$280(a5)
        move.w #$0000,$300(a5)
        move.w #$0000,$380(a5)
        move.w #$0000,$400(a5)
        cmp.l #$FFFFFFFF, d1
        beq clear_rank_rts 
        cmp.l #$0,d1
        beq clear_rank_rts
        move.l d1,($100D82)
        move.w d0, ($100D86)
       ; clr.w ($100D88)
        jsr write_asciihex_to_txt
clear_rank_rts:
	rts
rank_display_expired:
	clr.w ($100D88)
        clr.l ($100D82)
	move.l #$FFFFFFFF, ($100D92)
	rts
high_score_format_patch:
        movem.l d0-a6,-(sp)
        lea $2c7c, a6
	moveq #0,d5
	jmp $10CAC


