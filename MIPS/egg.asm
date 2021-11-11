  400780:       3c088000        lui     t0,0x8000
  400784:       2009ffff        addi    t1,zero,-1
  400788:       ad090008        sw      t1,8(t0)
  40078c:       8d030000        lw      v1,0(t0)
  400790:       8d020004        lw      v0,4(t0)
  400794:       20090000        addi    t1,zero,0
  400798:       00035880        sll     t3,v1,0x2
  40079c:       00026080        sll     t4,v0,0x2
  4007a0:       218c0004        addi    t4,t4,4
  4007a4:       216a0000        addi    t2,t3,0

004007a8 <COMPARE>:
  4007a8:       112b0006        beq     t1,t3,4007c4 <FINISH_ASM>
  4007ac:       00000000        nop
  4007b0:       ad2a0000        sw      t2,0(t1)
  4007b4:       25290004        addiu   t1,t1,4
  4007b8:       014c5021        addu    t2,t2,t4
  4007bc:       1000fffa        b       4007a8 <COMPARE>
  4007c0:       00000000        nop

004007c4 <FINISH_ASM>:
  4007c4:       215e0000        addi    s8,t2,0
  4007c8:       afc30004        sw      v1,4(s8)
  4007cc:       afc20008        sw      v0,8(s8)
  4007d0:       afc0000c        sw      zero,12(s8)
  4007d4:       00008025        move    s0,zero
  4007d8:       10000008        b       4007fc <FINISH_ASM+0x38>
  4007dc:       00000000        nop
  4007e0:       8fc2000c        lw      v0,12(s8)
  4007e4:       8c430000        lw      v1,0(v0)
  4007e8:       02001025        move    v0,s0
  4007ec:       00021080        sll     v0,v0,0x2
  4007f0:       00621021        addu    v0,v1,v0
  4007f4:       ac500000        sw      s0,0(v0)
  4007f8:       26100001        addiu   s0,s0,1
  4007fc:       8fc20008        lw      v0,8(s8)
  400800:       0050102a        slt     v0,v0,s0
  400804:       1040fff6        beqz    v0,4007e0 <FINISH_ASM+0x1c>
  400808:       00000000        nop
  40080c:       00008025        move    s0,zero
  400810:       10000008        b       400834 <FINISH_ASM+0x70>
  400814:       00000000        nop
  400818:       02001025        move    v0,s0
  40081c:       00021080        sll     v0,v0,0x2
  400820:       8fc3000c        lw      v1,12(s8)
  400824:       00621021        addu    v0,v1,v0
  400828:       8c420000        lw      v0,0(v0)
  40082c:       ac400000        sw      zero,0(v0)
  400830:       26100001        addiu   s0,s0,1
  400834:       8fc20004        lw      v0,4(s8)
  400838:       0202102a        slt     v0,s0,v0
  40083c:       1440fff6        bnez    v0,400818 <FINISH_ASM+0x54>
  400840:       00000000        nop
  400844:       24110001        li      s1,1
  400848:       1000008c        b       400a7c <FINISH_ASM+0x2b8>
  40084c:       00000000        nop
  400850:       24100001        li      s0,1
  400854:       10000084        b       400a68 <FINISH_ASM+0x2a4>
  400858:       00000000        nop
  40085c:       24120001        li      s2,1
  400860:       02009825        move    s3,s0
  400864:       1000002c        b       400918 <FINISH_ASM+0x154>
  400868:       00000000        nop
  40086c:       02531021        addu    v0,s2,s3
  400870:       00021fc2        srl     v1,v0,0x1f
  400874:       00621021        addu    v0,v1,v0
  400878:       00021043        sra     v0,v0,0x1
  40087c:       0040a025        move    s4,v0
  400880:       02201825        move    v1,s1
  400884:       3c023fff        lui     v0,0x3fff
  400888:       3442ffff        ori     v0,v0,0xffff
  40088c:       00621021        addu    v0,v1,v0
  400890:       00021080        sll     v0,v0,0x2
  400894:       8fc3000c        lw      v1,12(s8)
  400898:       00621021        addu    v0,v1,v0
  40089c:       8c430000        lw      v1,0(v0)
  4008a0:       02802025        move    a0,s4
  4008a4:       3c023fff        lui     v0,0x3fff
  4008a8:       3442ffff        ori     v0,v0,0xffff
  4008ac:       00821021        addu    v0,a0,v0
  4008b0:       00021080        sll     v0,v0,0x2
  4008b4:       00621021        addu    v0,v1,v0
  4008b8:       8c560000        lw      s6,0(v0)
  4008bc:       02201025        move    v0,s1
  4008c0:       00021080        sll     v0,v0,0x2
  4008c4:       8fc3000c        lw      v1,12(s8)
  4008c8:       00621021        addu    v0,v1,v0
  4008cc:       8c430000        lw      v1,0(v0)
  4008d0:       02141023        subu    v0,s0,s4
  4008d4:       00021080        sll     v0,v0,0x2
  4008d8:       00621021        addu    v0,v1,v0
  4008dc:       8c550000        lw      s5,0(v0)
  4008e0:       02d5102a        slt     v0,s6,s5
  4008e4:       10400004        beqz    v0,4008f8 <FINISH_ASM+0x134>
  4008e8:       00000000        nop
  4008ec:       02809025        move    s2,s4
  4008f0:       10000009        b       400918 <FINISH_ASM+0x154>
  4008f4:       00000000        nop
  4008f8:       02b6102a        slt     v0,s5,s6
  4008fc:       10400004        beqz    v0,400910 <FINISH_ASM+0x14c>
  400900:       00000000        nop
  400904:       02809825        move    s3,s4
  400908:       10000003        b       400918 <FINISH_ASM+0x154>
  40090c:       00000000        nop
  400910:       02809025        move    s2,s4
  400914:       02809825        move    s3,s4
  400918:       26420001        addiu   v0,s2,1
  40091c:       0053102a        slt     v0,v0,s3
  400920:       1440ffd2        bnez    v0,40086c <FINISH_ASM+0xa8>
  400924:       00000000        nop
  400928:       02201825        move    v1,s1
  40092c:       3c023fff        lui     v0,0x3fff
  400930:       3442ffff        ori     v0,v0,0xffff
  400934:       00621021        addu    v0,v1,v0
  400938:       00021080        sll     v0,v0,0x2
  40093c:       8fc3000c        lw      v1,12(s8)
  400940:       00621021        addu    v0,v1,v0
  400944:       8c430000        lw      v1,0(v0)
  400948:       02402025        move    a0,s2
  40094c:       3c023fff        lui     v0,0x3fff
  400950:       3442ffff        ori     v0,v0,0xffff
  400954:       00821021        addu    v0,a0,v0
  400958:       00021080        sll     v0,v0,0x2
  40095c:       00621021        addu    v0,v1,v0
  400960:       8c430000        lw      v1,0(v0)
  400964:       02201025        move    v0,s1
  400968:       00021080        sll     v0,v0,0x2
  40096c:       8fc4000c        lw      a0,12(s8)
  400970:       00821021        addu    v0,a0,v0
  400974:       8c440000        lw      a0,0(v0)
  400978:       02121023        subu    v0,s0,s2
  40097c:       00021080        sll     v0,v0,0x2
  400980:       00821021        addu    v0,a0,v0
  400984:       8c420000        lw      v0,0(v0)
  400988:       afc30020        sw      v1,32(s8)
  40098c:       afc20024        sw      v0,36(s8)
  400990:       8fc20024        lw      v0,36(s8)
  400994:       8fc40020        lw      a0,32(s8)
  400998:       8fc30020        lw      v1,32(s8)
  40099c:       0082202a        slt     a0,a0,v0
  4009a0:       0044180b        movn    v1,v0,a0
  4009a4:       02202025        move    a0,s1
  4009a8:       3c023fff        lui     v0,0x3fff
  4009ac:       3442ffff        ori     v0,v0,0xffff
  4009b0:       00821021        addu    v0,a0,v0
  4009b4:       00021080        sll     v0,v0,0x2
  4009b8:       8fc4000c        lw      a0,12(s8)
  4009bc:       00821021        addu    v0,a0,v0
  4009c0:       8c440000        lw      a0,0(v0)
  4009c4:       02602825        move    a1,s3
  4009c8:       3c023fff        lui     v0,0x3fff
  4009cc:       3442ffff        ori     v0,v0,0xffff
  4009d0:       00a21021        addu    v0,a1,v0
  4009d4:       00021080        sll     v0,v0,0x2
  4009d8:       00821021        addu    v0,a0,v0
  4009dc:       8c440000        lw      a0,0(v0)
  4009e0:       02201025        move    v0,s1
  4009e4:       00021080        sll     v0,v0,0x2
  4009e8:       8fc5000c        lw      a1,12(s8)
  4009ec:       00a21021        addu    v0,a1,v0
  4009f0:       8c450000        lw      a1,0(v0)
  4009f4:       02131023        subu    v0,s0,s3
  4009f8:       00021080        sll     v0,v0,0x2
  4009fc:       00a21021        addu    v0,a1,v0
  400a00:       8c420000        lw      v0,0(v0)
  400a04:       afc40018        sw      a0,24(s8)
  400a08:       afc2001c        sw      v0,28(s8)
  400a0c:       8fc2001c        lw      v0,28(s8)
  400a10:       8fc50018        lw      a1,24(s8)
  400a14:       8fc40018        lw      a0,24(s8)
  400a18:       00a2282a        slt     a1,a1,v0
  400a1c:       0085100a        movz    v0,a0,a1
  400a20:       afc30010        sw      v1,16(s8)
  400a24:       afc20014        sw      v0,20(s8)
  400a28:       8fc20014        lw      v0,20(s8)
  400a2c:       8fc40010        lw      a0,16(s8)
  400a30:       8fc30010        lw      v1,16(s8)
  400a34:       0044202a        slt     a0,v0,a0
  400a38:       0044180b        movn    v1,v0,a0
  400a3c:       02201025        move    v0,s1
  400a40:       00021080        sll     v0,v0,0x2
  400a44:       8fc4000c        lw      a0,12(s8)
  400a48:       00821021        addu    v0,a0,v0
  400a4c:       8c440000        lw      a0,0(v0)
  400a50:       02001025        move    v0,s0
  400a54:       00021080        sll     v0,v0,0x2
  400a58:       00821021        addu    v0,a0,v0
  400a5c:       24630001        addiu   v1,v1,1
  400a60:       ac430000        sw      v1,0(v0)
  400a64:       26100001        addiu   s0,s0,1
  400a68:       8fc20008        lw      v0,8(s8)
  400a6c:       0050102a        slt     v0,v0,s0
  400a70:       1040ff7a        beqz    v0,40085c <FINISH_ASM+0x98>
  400a74:       00000000        nop
  400a78:       26310001        addiu   s1,s1,1
  400a7c:       8fc20004        lw      v0,4(s8)
  400a80:       0222102a        slt     v0,s1,v0
  400a84:       1440ff72        bnez    v0,400850 <FINISH_ASM+0x8c>
  400a88:       00000000        nop
  400a8c:       8fc30004        lw      v1,4(s8)
  400a90:       3c023fff        lui     v0,0x3fff
  400a94:       3442ffff        ori     v0,v0,0xffff
  400a98:       00621021        addu    v0,v1,v0
  400a9c:       00021080        sll     v0,v0,0x2
  400aa0:       8fc3000c        lw      v1,12(s8)
  400aa4:       00621021        addu    v0,v1,v0
  400aa8:       8c430000        lw      v1,0(v0)
  400aac:       8fc20008        lw      v0,8(s8)
  400ab0:       00021080        sll     v0,v0,0x2
  400ab4:       00621021        addu    v0,v1,v0
  400ab8:       8c420000        lw      v0,0(v0)
  400abc:       3c088000        lui     t0,0x8000
  400ac0:       ad020008        sw      v0,8(t0)

00400ac4 <END_TRAP>:
  400ac4:       1000ffff        b       400ac4 <END_TRAP>
  400ac8:       00000000        nop