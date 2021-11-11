#include <stdio.h>

__attribute__((always_inline)) int max(int a, int b)
{
    return a > b ? a : b;
}

__attribute__((always_inline)) int min(int a, int b)
{
    return a < b ? a : b;
}

int main()
{
    // dp_array[k][n] 代表有k + 1个鸡蛋，测试n层楼的最坏情况（尝试次数）
    int egg_sum, floor_sum;
    int** dp_array;

#ifdef EMBEDDED

    // input from embedded I/O
    // Memory mapping : 
    // 0x8000 0000  egg_sum
    // 0x8000 0004  floor_sum
    // 0x8000 0008  result
    // 0x0000 0000  addr of dp_array[0]
    // egg_sum * (floor_sum + 1) * 4 stack base of main
    __asm__ (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "addi $t1, $0, 0xffff\t\n"
        "sw $t1, 0x8($t0)\t\n" // display ffff when calc not done
        "lw %[egg_sum_reg], 0($t0)\t\n"
        "lw %[floor_sum_reg], 4($t0)\t\n"
        // "addi %[dp_array_reg], $0, 0xc\t\n"

        // initial memory from 0x0 to 0x0 + (egg_sum - 1) * 4
        "addi $t1, $0, 0\t\n" // $t1 is &dp_array[i]
        "sll $t3, %[egg_sum_reg], 2\t\n" // $t3 is egg_sum_reg * 4
        "sll $t4, %[floor_sum_reg], 2\t\n"
        "addi $t4, $t4, 0x4\t\n" // $t4 is sizeof(dp_array[i])
        "addi $t2, $t3, 0x0\t\n" // $t2 is dp_array[i]
        "COMPARE:\t\n"
        "beq $t1, $t3, FINISH_ASM\t\n"
        // "nop\t\n" delay slot will be added by compiler
        "sw $t2, 0x0($t1)\t\n"
        "addiu $t1, $t1, 0x4\t\n"
        "addu $t2, $t2, $t4\t\n"
        "j COMPARE\t\n"
        // "nop\t\n" delay slot will be added by compiler
        "FINISH_ASM:\t\n"
        "addi $s8, $t2, 0x0\t\n" // set s8 as stack pointer (GCC likes it)
        : // output
        [egg_sum_reg]"=r"(egg_sum),
        [floor_sum_reg]"=r"(floor_sum)
        : // input
        :
        "memory", "$t0", "$t1", "$t2", "$t3", "$t4" // destroy
    );

    dp_array = 0;
#else
    scanf("%d %d", &egg_sum, &floor_sum);

    dp_array = new int*[egg_sum];
    for (int i = 0; i < egg_sum; ++i) {
        dp_array[i] = new int[floor_sum + 1];
    }

#endif

    // DP start
    for (register int i = 0; i <= floor_sum; ++i) {
        dp_array[0][i] = i;
    }

    for (register int i = 0; i < egg_sum; ++i) {
        dp_array[i][0] = 0;
    }

    for (register int egg_idx = 1; egg_idx < egg_sum; ++egg_idx) {
        for (register int floor_idx = 1; floor_idx <= floor_sum; ++floor_idx) {

            register int lo = 1;
            register int hi = floor_idx;

            while (lo + 1 < hi) {
                register int middle = (lo + hi) / 2;
                register int t1 = dp_array[egg_idx - 1][middle - 1];
                register int t2 = dp_array[egg_idx][floor_idx - middle];

                if (t1 < t2) {
                    lo = middle;
                }
                else if (t1 > t2) {
                    hi = middle;
                }
                else {
                    lo = middle;
                    hi = middle;
                }
            }

            dp_array[egg_idx][floor_idx] = 1 + min(max(dp_array[egg_idx - 1][lo - 1], dp_array[egg_idx][floor_idx - lo]),
                                                   max(dp_array[egg_idx - 1][hi - 1], dp_array[egg_idx][floor_idx - hi]));
        }
    }

#ifdef EMBEDDED
    // output to I/O
    __asm__ volatile (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "sw %[result], 8($t0)\t\n"
        "END_TRAP:\t\n"
        "j END_TRAP\t\n"
        :
        : // input
        [result]"r"(dp_array[egg_sum - 1][floor_sum])
        : "$t0" // destroy
    );
#else
    printf("%d\n", dp_array[egg_sum - 1][floor_sum]);
#endif

    return 0;
}
