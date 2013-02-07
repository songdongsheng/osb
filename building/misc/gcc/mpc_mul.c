#include <stdio.h>
#include <stdlib.h>
#include <mpc.h>

int main (void)
{
    mpc_t x, y, z;
    int inexact;

    mpc_init2 (x, 8);
    mpc_init2 (y, 8);
    mpc_init2 (z, 8);

    mpc_set_si_si (x, 4, 3, MPC_RNDNN);
    mpc_set_si_si (y, 1, -2, MPC_RNDNN);
    inexact = mpc_mul (z, x, y, MPC_RNDNN);
    if (MPC_INEX_RE(inexact) || MPC_INEX_IM(inexact)) {
        fprintf (stderr, "Error: (4+3*I)*(1-2*I) should be exact with prec=8\n");
        exit (1);
    }

    return 0;
}
