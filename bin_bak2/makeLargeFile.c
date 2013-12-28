#define _LARGEFILE_SOURCE
#define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64
 
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#define FILENAME "bigfile"
#define FILE_MODE (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
int main(int argc, char **argv)
{
  int fd, ret;
  off_t offset;
  int total = 0;
  if ( argc >= 2 )
  {
  total = atol(argv[1]);
  printf("total=%d\n", total);
  }
  
  
  fd = open(FILENAME, O_RDWR|O_CREAT|O_LARGEFILE, 0644);
  //fd = open(FILENAME, O_RDWR|O_CREAT, 0644);
  if (fd < 0) {
  perror(FILENAME);
  return -1;
  }
  offset = (off_t)total *1024ll*1024ll;
  printf("offset=%ld\n", offset);
  
  
  if (ftruncate64(fd, offset) < 0)
  //if (ftruncate(fd, offset) < 0)
  {
  printf("[%d]-ftruncate64 error: %s\n", errno, strerror(errno));
  close(fd);
  return 0;
  }
  close(fd);
  printf("OK\n");
  return 0;
}
