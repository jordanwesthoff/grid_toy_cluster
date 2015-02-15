/*
PCP.C A parallel SCP
Copyright (C) 2005 Glen E. Gardner Jr.
glen.gardner@verizon.net

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

/* pcp.c by Glen E. Gardner, Jr. */
/* a simple program to use SCP or RCP to */
/* copy files among  multiple remote computers */

/* a file containing hostnames for the target machines is required */ 
/* this is a very dumb program, but it works. */


#include<stdlib.h>
#include<stdio.h>
#include<sys/types.h>
#include<unistd.h>
#include<string.h>


void parmsh(int argc,char **argv);
void outdata(int,char**,char *,int,int);
void parse(int,char**,char *,char *);

FILE *filein;
pid_t pid;

int i,j,n;
char head[2100];
char *string;


int main(int argc,char **argv)
{

if(argc<2)
{
printf("\npcp by Glen E. Gardner Jr.\n\n");
printf("use: pcp <source filename>  <destination filename>\n\n");
printf("Copies <source filename> on the originating host to\n");
printf("<destination filename> on all hosts listed in /etc/nodelist.\n\n");
printf("Launching with one argument only: pcp <filename>, copies the file\n");
printf("from the originating host to $HOME on all hosts listed in /etc/nodelist.\n");
printf("\nAll operations are concurrent and nonblocking. The prompt will\n");
printf("return immediately with no regard for child process status.\n\n");
exit(0);
}

parmsh(argc,argv);
}


void parmsh(int argc,char **argv)
{
/* printf("parallel!\n"); */
if((filein=fopen("/etc/nodelist","r"))!=NULL)
	{
	string=malloc(2048);
	while(fgets(string,2044,filein)!=NULL)
		{
		pid=fork();
		if(pid==0)
			{
			parse(argc,argv,string,head);
			return;
			}
		}
	}
}
	

void  parse(int argc,char **argv, char *string,char *head)
{
int n;
char head2[2400];
char *string2;
string2=malloc(2048);

strcpy(head2,"scp -rp ");
strcat(head2,argv[1]);
strcat(head2," ");
strcat(head2,string);
n=strlen(head2);
head2[n-1]='\0';
strcat(head2,":");
if(argc==2){strcat(head2,".");}else{strcat(head2,argv[2]);}
system(head2);
}





