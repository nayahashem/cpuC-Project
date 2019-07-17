#include <stdio.h>

#define C1 6
#define C2 6
#define C3 6
#define C6 C2*C3
#define C8 C1*C1

void main()
{
    int weight[C1*C8] = {0};
    int in_layer[8*C6] = {0};
    int place=0, r, k, l, m, n;

    for(r=0; r<C1; r++)
    {
        printf("\n");
        for(k=0; k<C1; k++)
            {
                //printf("\n");
                for(l=0; l<C1; l++)
                    {
                        place = r*C8+k*C1+l;
                        weight[place] = r+1;
                        printf("%d ", weight[place]);
                    }
            }
    }

    printf("\n\n\n");

    for(m=0; m<C3*8; m++)
    {
        printf("\n");
        if(m%6 == 0) printf("\n\n");
        for(n=0; n<C2; n++)
        {
            in_layer[m*C2+n] = 1;
            printf("%d ", in_layer[m*C2+n]);
        }
    }


}
