/*
PSH.C A parallel SSH 
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



/* psh.c by Glen E. Gardner, Jr. */
/* a simple program to use SSH or RSH to */
/* send commands to multiple remote computers */

/* a file containing hostnames for the target machines is required */ 
/* this is a very dumb program, but it works. */
/* TODO:  the option to fork might be nice. */


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
printf("\npsh by Glen E. Gardner Jr.\n\n");
printf("use: psh <command string>\n\n");
printf("Executes the string <command string> on all\n");
printf("hosts listed in /etc/nodelist in an iterative,\n");
printf("blocking fashion.\n\n");
printf("psh -p <command string>\n\n");
printf("Will execute the command string concurrently\n");
printf("on all hosts listed in /etc/nodelist.\n");
printf("stdout is redirected to the file: psh_out.txt\n");
printf("in the users $HOME on the originating host.\n");
printf("Fork is used. The prompt will not block, and returns immediately\n");
printf("regardless of the process state on any or all host machines.\n\n");
exit(0);
}

strcpy(head,argv[1]);
system("touch $HOME/psh_out.txt");
if(strcmp(head,"-p")==0){system("rm $HOME/psh_out.txt");parmsh(argc,argv);exit(0);}

if((filein=fopen("/etc/nodelist","r"))!=NULL)
	{
	string=malloc(2048);
	while(fgets(string,2044,filein)!=NULL)
		{
		parse(argc,argv,string,head);
		outdata(argc,argv,head,1,1);
		}
	}
}


void parmsh(int argc,char **argv)
{

int j;

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
			outdata(argc,argv,head,2,2);
			fflush(stdout);
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

n=strlen(string);

strcpy(head2,"ssh ");
strcat(head2,string);
n=strlen(head2);
head2[n-1]=32;
strcpy(head,head2);
strcpy(string,string2);
}


void outdata(int argc,char **argv,char *head,int index,int mode)
{
int i;
char head2[2400];

strcpy(head2,head);
for(i=index;i<argc;i++)
	{
	strcat(head2," ");
	strcat(head2,argv[i]);
	}
strcat(head2," ");
if(mode==2)strcat(head2,">> $HOME/psh_out.txt");
if(mode==1)printf("\n%s\n",head2);
system(head2);
//if(mode==1)printf("\n\n\n");
}



