#include <stdio.h>
#include <stdlib.h>

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
    // 0x8000 0000  m
    // 0x8000 0004  d[m]
    // 0x0000 0000  addr of a[0]
    __asm__ (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "addi $t1, $0, 0xffff\t\n"
        "sw $t1, 0x4($t0)\t\n" // display ffff when calc not done
        "lw %[m_cnt], 0($t0)\t\n"

        "addi $s8, %[m_cnt], 0x0\t\n"
        "sll $s8, $s8, 4\t\n" // set s8 as stack pointer (GCC likes it)
        : // output
        [m_cnt]"=r"(m)
        : // input
        :
        "memory", "$t0", "$t1" // destroy
    );
    a = 0;
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
        b[i] = b[i - 1] + 3 * i;
    }

    for (register int i = 0; i <= 19 && i < m; ++i) {
        c[i] = a[i];
        d[i] = b[i];
    }

    for (register int i = 20; i <= 39 && i < m; ++i) {
        c[i] = a[i] + b[i];
    }

    for (register int i = 40; i < m && i < m; ++i) {
        c[i] = a[i] * b[i];
    }

    for (register int i = 20; i <= 39 && i < m; ++i) {
        d[i] = a[i] * c[i];
    }

    for (register int i = 40; i < m; ++i) {
        d[i] = c[i] * b[i];
    }

#ifdef EMBEDDED
    // output to I/O
    __asm__ volatile (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "sw %[result], 4($t0)\t\n"
        "END_TRAP:\t\n"
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
