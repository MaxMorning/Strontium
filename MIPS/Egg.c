#include <stdio.h>

int main()
{
    int strength_cnt, floor_sum;

#ifdef EMBEDDED

    // input from embedded I/O
    // Memory mapping : 
    // 0x8000 0000  in  strength_cnt
    // 0x8000 0004  in  floor_sum
    // 0x8000 0008  out toss_cnt
    // 0x8000 000c  out egg_cnt 
    // 0x8000 0010  out is_egg_break
    __asm__ (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "addi $t1, $0, 0xffff\t\n"
        "sw $t1, 0x10($t0)\t\n" // LED display ffff when calc not done
        "lw %[strength_cnt_reg], 0($t0)\t\n"
        "lw %[floor_sum_reg], 4($t0)\t\n"
        
        "FINISH_ASM:\t\n"
        "addi $s8, $zero, 0x0\t\n" // set s8 as stack pointer (GCC likes it)
        : // output
        [strength_cnt_reg]"=r"(strength_cnt),
        [floor_sum_reg]"=r"(floor_sum)
        : // input
        :
        "memory", "$t0", "$t1" // destroy
    );

#else
    scanf("%d %d", &strength_cnt, &floor_sum);

#endif
    register int toss_cnt = 0;
    register int egg_cnt = 0;
    register int is_egg_break = 0;
    //  binary search
    register int left = 0;
    register int right = floor_sum;


    while (left < right) {
        register int middle = (left + right) >> 1;
        ++toss_cnt;

        if (middle <= strength_cnt) {
            right = middle;
            is_egg_break = 0;
        }
        else {
            left = middle + 1;
            ++egg_cnt;
            is_egg_break = 1;
        }
    }

#ifdef EMBEDDED
    // output to I/O
    __asm__ volatile (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "sw %[toss_cnt_reg], 8($t0)\t\n"
        "sw %[egg_cnt_reg], 0xc($t0)\t\n"
        "sw %[is_egg_break_reg], 0x10($t0)\t\n"
        "END_TRAP:\t\n"
        "j END_TRAP\t\n"
        :
        : // input
        [toss_cnt_reg]"r"(toss_cnt),
        [egg_cnt_reg]"r"(egg_cnt),
        [is_egg_break_reg]"r"(is_egg_break)
        : "$t0" // destroy
    );
#else
    printf("Toss: %d, Egg: %d, IsBreak: %d\n", toss_cnt, egg_cnt, is_egg_break);
#endif

    return 0;
}
