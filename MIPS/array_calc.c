#include <stdio.h>

int main()
{
    int m;
    int* a;
    int* b;
    int* c;
    int* d;
#ifdef EMBEDDED

    // input from embedded I/O
    // Memory mapping : 
    // 0x8000 0000  m
    // 0x8000 0004  d[m]
    // 0x0000 0000  addr of a[0]
    __asm__ (
        "lui $t0, 0x8000\t\n" // t0 is the base addr of I/O
        "addi $t1, $0, 0xffff\t\n"
        "sw $t1, 0x8($t0)\t\n" // display ffff when calc not done
        "lw %[m_cnt], 0($t0)\t\n"

        "addi $s8, $t2, 0x0\t\n" // set s8 as stack pointer (GCC likes it)
        : // output
        [m_cnt]"=r"(m),
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

    a = malloc(m * sizeof(int));
    b = malloc(m * sizeof(int));
    c = malloc(m * sizeof(int));
    d = malloc(m * sizeof(int));

#endif

    a[0] = 0;
    b[0] = 1;

    for (int i = 1; i < m; ++i) {
        a[i] = a[i - 1] + i;
        b[i] = b[i - 1] + 3 * i;
    }

    for (int i = 0; i <= 19; ++i) {
        c[i] = a[i];
        d[i] = b[i];
    }

    for (int i = 20; i <= 39; ++i) {
        c[i] = a[i] + b[i];
    }

    for (int i = 40; i < m; ++i) {
        c[i] = a[i] * b[i];
    }

    for (int i = 20; i <= 39; ++i) {
        d[i] = a[i] * c[i];
    }

    for (int i = 40; i < m; ++i) {
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
    printf("%d\n", d[m - 1]);

    free(d);
    free(c);
    free(b);
    free(a);
#endif

    return 0;
}
