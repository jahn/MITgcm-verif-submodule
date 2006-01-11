/* 
**
** $Header$
** $Name$
**
*/

/*  Decode and write files */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "files.h"

int main(int argc, char** argv)
{
    FILE * fout;
    int ii, jj;

    for (ii=0; ii<n_flist; ii++) {
	printf("  decoding:  \"%s\"\n", flist[ii].name);

	fout = fopen(flist[ii].name, "w");
	if (!fout) {
	    printf("    WARNING:  cannot fopen() \"%s\" for writing\n",
		   flist[ii].name);
	    continue;
	}

	for (jj=0; jj<flist[ii].ndat; jj++) {
	    fprintf(fout,"%c",(unsigned char)(flist[ii].dat[jj]) );
	}
	fclose(fout);
    }

    return 0;
}

