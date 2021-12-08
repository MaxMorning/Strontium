#include <stdio.h>
#include <stdlib.h>
//#define EMBEDDED

#ifdef EMBEDDED
#define SAVE_LATEST_RESULT(result) \
                                   __asm__ (                            \
                                        "sw %[r_result], 0($zero)\t\n"  \
                                   :                                    \
                                   :                                    \
                                   [r_result]"r"(result)                \
                                   :                                    \
                                   )

#else
#define SAVE_LATEST_RESULT(result)  // Do nothing under x86-64
#endif
int main()
{
    register int m;
    register int* a;
    register int* b;
    register int* c;
    register int* d;
#ifdef EMBEDDED

    // input from embedded I/O
    // Memory mapping :
    // 0x8000 0000  input m
    // 0x8000 0004  d[m - 1]
    // 0x8000 0008  display latest result in 7 seg
    // 0x0000 0004  addr of a[0]
    // 7# register in CP0 saves the value of t0
    // 22# register saves origin epc
    // 20# register in CP0 saves the status of trap
    // 0 means not in trap, otherwise means in trap
    __asm__ (
        "SYSTEM_BOOT:\t\n"
        "j PROGRAM_INIT\t\n" // delay slot will be add by GCC

        "EXCEPTION_PROCESS:\t\n" // exception process codes
        "mtc0 $t0, $7\t\n" // save content
        "mfc0 $t0, $13\t\n" // get exception code
        "addi $t0, $t0, -32\t\n"
        "beq $t0, $zero, EXC_RET\t\n"
        // this exception is caused by out interruption
        "mfc0 $t0, $20\t\n"
        "beq $t0, $zero, SELF_TRAP\t\n"
        // here to exit trap
        // restore epc
        "mfc0 $t0, $22\t\n"
        "mtc0 $t0, $14\t\n"
        
        "mtc0 $zero, $20\t\n"
        "j EXC_RET\t\n"
        // here to trap
        "SELF_TRAP:\t\n"
        // display latest result
        "mtc0 $t1, $21\t\n"
        "lui $t1, 0x8000\t\n"
        "lw $t0, 0($zero)\t\n"
        "sw $t0, 8($t1)\t\n"
        "mfc0 $t1, $21\t\n"

        // save epc
        "mfc0 $t0, $14\t\n"
        "mtc0 $t0, $22\t\n"

        "addi $t0, $zero, 1\t\n"
        "mtc0 $t0, $20\t\n"
        "mtc0 $t0, $12\t\n" // enable interruption
        "mfc0 $t0, $7\t\n"
        // self trap
        "S_TRAP:\t\n"
        "j S_TRAP\t\n"

        "EXC_RET:\t\n"
        "mfc0 $t0, $7\t\n"
        "eret\t\n"
        "nop\t\n"

        "PROGRAM_INIT:\t\n" // start program initial
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "addi $t1, $0, 0xffff\t\n"
        "sw $t1, 0x4($t0)\t\n" // display ffff when calc not done
        "lw %[m_cnt], 0($t0)\t\n"

        "addi $s8, %[m_cnt], 0x0\t\n"
        "sll $s8, $s8, 4\t\n"
        "addi $s8, $s8, 4\t\n"// set s8 as stack pointer (GCC likes it)
        "END_INIT:\t\n"
        : // output
        [m_cnt]"=r"(m)
        : // input
        :
        "memory", "$t0", "$t1" // destroy
    );
    a = (int*)4;
    b = a + m;
    c = b + m;
    d = c + m;
#else
    scanf("%d", &m);

    a = static_cast<int *>(malloc(m * sizeof(int)));
    b = static_cast<int *>(malloc(m * sizeof(int)));
    c = static_cast<int *>(malloc(m * sizeof(int)));
    d = static_cast<int *>(malloc(m * sizeof(int)));

#endif

    a[0] = 0;
    b[0] = 1;

    for (register int i = 1; i < m; ++i) {
        a[i] = a[i - 1] + i;
        SAVE_LATEST_RESULT(a[i]);

        b[i] = b[i - 1] + 3 * i;
        SAVE_LATEST_RESULT(b[i]);
    }

    for (register int i = 0; i <= 19 && i < m; ++i) {
        c[i] = a[i];
        SAVE_LATEST_RESULT(c[i]);

        d[i] = b[i];
        SAVE_LATEST_RESULT(d[i]);
    }

    for (register int i = 20; i <= 39 && i < m; ++i) {
        c[i] = a[i] + b[i];
        SAVE_LATEST_RESULT(c[i]);
    }

    for (register int i = 40; i < m && i < m; ++i) {
        c[i] = a[i] * b[i];
        SAVE_LATEST_RESULT(c[i]);
    }

    for (register int i = 20; i <= 39 && i < m; ++i) {
        d[i] = a[i] * c[i];
        SAVE_LATEST_RESULT(d[i]);
    }

    for (register int i = 40; i < m; ++i) {
        d[i] = c[i] * b[i];
        SAVE_LATEST_RESULT(d[i]);
    }

#ifdef EMBEDDED
    // output to I/O
    __asm__ volatile (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "sw %[result], 4($t0)\t\n"
        "END_TRAP:\t\n"
        "j END_TRAP\t\n"
        "j END_TRAP\t\n"
        :
        : // input
        [result]"r"(d[m - 1])
        : "$t0" // destroy
    );
#else
    for (int i = 0; i < m; ++i) {
        printf("%d: a\t%d\t\tb\t%d\t\tc\t%d\t\td\t%d\t\t\n", i, a[i], b[i], c[i], d[i]);
    }
    printf("%d\n", d[m - 1]);

    free(d);
    free(c);
    free(b);
    free(a);
#endif

    return 0;
}
