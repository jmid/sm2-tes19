#include <stdio.h>
#include <stdlib.h>

int main()
{
  char *p = malloc(5);
  char a = p[3];   /* Reading uninitialized memory */
  printf("%c\n",a);
  return 0;
}
