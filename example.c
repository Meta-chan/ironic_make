#include <stdio.h>

int main()
{
	printf("Hello World from %i-bit application\n", sizeof(void*) == 8 ? 64 : 32);
	getc(stdin);
	return 0;
}