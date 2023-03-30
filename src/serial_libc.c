#include <asm/termbits.h>
#include <sys/ioctl.h>

int serial_init(int fd, int baud_rate) {
   struct termios2 config;

   // Set a custom baud-rate
   ioctl(fd, TCGETS2, &config);
   config.c_cflag &= ~CBAUD;
   config.c_cflag |= BOTHER;
   config.c_ispeed = baud_rate;
   config.c_ospeed = baud_rate;

   return ioctl(fd, TCSETS2, &config);
}
