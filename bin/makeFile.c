#include <stdio.h>
#include <string.h>
#include <stdint.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

//#define _LARGEFILE_SOURCE
//#define _LARGEFILE64_SOURCE
//#define _FILE_OFFSET_BITS 64
#define FILE_MODE (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
#define BUF_SIZE 1000*1000

void makeFile1G(FILE *fd){
	char buf[BUF_SIZE];
	int64_t k = 0;
	int64_t wsize=0;
	int64_t i=0,j=0;
	for(i=0; i<1024; i++){
		// produce buf
		memset(buf, 0, BUF_SIZE);
		for(j=0; j<BUF_SIZE; j++){
			buf[j] = (random()%256);
		}

		// write buf
		
		while(wsize<BUF_SIZE){
			k = fwrite(buf+wsize, 1, BUF_SIZE-wsize, fd);
			wsize += k;
		}
	}


}




int main(int argc, char **argv)
{
	char buf[BUF_SIZE];
	FILE *fd;
	int64_t count=0;
	int64_t tsize=0;
	int64_t rsize=0;
	int64_t i=0,j=0;
	int64_t wsize=0;
	int64_t k=0;
	int64_t t1=0;
	int64_t t2=0;
	int flag = 0;
	char g[10];
	int64_t gg = 0;
	int64_t n = 0;
	// usage: ./pd filename filesize
	if(argc!=3){
		printf("usage: ./pd filename filesize\n");
		return -1;
	}

	memset(buf, 0, BUF_SIZE);
	fd = fopen(argv[1], "wb");
	//int fdd = open("1",O_RDWR|O_CREAT|O_LARGEFILE, 0644);
	//fd = (FILE *)fdd;
	if(fd==NULL){
		printf("open %s failed\n", argv[1]);
	}
	//int64_t tmp = 1000000/(BUF_SIZE);
	//printf("tmp %llu\n", tmp);
	//tsize = atoi(argv[2]);
	int ii = 0;
	for(;argv[2][ii]!=0;ii++){
		printf("argv[2][%d] = %c\n", ii,argv[2][ii]);
	}
	
	printf("ii %d\n", ii);	
	if(ii>=10){
	flag = 1;
	ii-=9;
	for(n=0;n<ii;n++){
		g[n] = argv[2][n];
	}
	g[n] = 0;
	for(n=0;n<9;n++){
		argv[2][n] = argv[2][n+ii];
	}
	argv[2][n] = 0;
	}	

	printf("g %s\n", g);
	printf("argv[2] %s\n", argv[2]);
	gg = atoll(g);
	tsize = atoll(argv[2]);
	
	printf("gg %llu\n", gg);
	printf("tsize %llu\n", tsize);
	count = tsize / (BUF_SIZE);
	rsize = tsize - count*BUF_SIZE;	

	printf("tsize %llu  %llu gb %llu mb rsize %llu\n", tsize, gg,count, rsize);
	for(;gg>0&&flag;gg--){
		for(i=0; i<1024; i++){
		// produce buf
		memset(buf, 0, BUF_SIZE);
		for(j=0; j<BUF_SIZE; j++){
			buf[j] = (random()%256);
		}

		// write buf
		k = 0;
		wsize=0;
		while(wsize<BUF_SIZE){
			k = fwrite(buf+wsize, 1, BUF_SIZE-wsize, fd);
			wsize += k;
		}
	}
	}
	for(i=0; i<count; i++){
		// produce buf
		memset(buf, 0, BUF_SIZE);
		for(j=0; j<BUF_SIZE; j++){
			buf[j] = (random()%256);
		}

		// write buf
		k = 0;
		wsize=0;
		while(wsize<BUF_SIZE){
			k = fwrite(buf+wsize, 1, BUF_SIZE-wsize, fd);
			wsize += k;
		}
	}
	memset(buf, 0, BUF_SIZE);
	for(j=0; j<rsize; j++){
		buf[j] = (random()%256);
	}
	k = 0;
	wsize=0;
	while(wsize<rsize){
		k = fwrite(buf+wsize, 1, rsize-wsize, fd);
		wsize += k;
	}

	fclose(fd);
	return 0;
}

