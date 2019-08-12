#include "System/Drivers/HDAudio";
#include "System/Drivers/VMSVGA";

#include "System/Drivers/Virtio";
#include "System/Drivers/Virtio-net";

#include "System/Fonts/Console";
#include "System/Fonts/WinTitle";
#include "System/Fonts/Smol";
#include "System/Fonts/Terminus";

#include "System/Libraries/Misc";
#include "System/Libraries/Display";
#include "System/Libraries/Mouse";
#include "System/Libraries/Graphics2D";
//#include "System/Libraries/JPEG";
#include "System/Libraries/uPNG";
#include "System/Libraries/GUI";

#include "/System/Programs/Tools/Terminal.exec/FixedWidthFont.HC";
#include "/System/Programs/Tools/Terminal.exec/Console.HC";

#include "System/Drivers/Net/NetFifo";
#include "System/Drivers/Net/NativeSocket";
#include "System/Drivers/Net/Socket";

// L2
#include "System/Drivers/Net/Ethernet";

// L3
#include "System/Drivers/Net/Arp";
#include "System/Drivers/Net/IPv4";

// L4
#include "System/Drivers/Net/Icmp";
#include "System/Drivers/Net/Tcp";
#include "System/Drivers/Net/Udp";

// L7
#include "System/Drivers/Net/Dhcp";
#include "System/Drivers/Net/Dns";

#include "System/Drivers/Net/Netcfg";
#include "System/Drivers/Net/NetHandlerTask";

#include "System/Drivers/VBoxGuest";

#include "System/WindowManager";

#include "System/Libraries/Debugger";

#include "System/Libraries/Speech/Reciter";
#include "System/Libraries/Speech/SAM";

// Zero all TOS Kernel callbacks for CTRL-ALT shortcuts
MemSet(keydev.fp_ctrl_alt_cbs, 0, 0xD0);

// Initialize the display
VMSVGA_Start(display.width, display.height, display.bpp);
SysFrameBufferInit;

// Clear the linear framebuffer
Fill2D(sys_fb);

// Set the wallpaper
EContext2D *test_wp = LoadPNG("System/Media/Wallpapers/Shiori.png");
EWMSetWallpaper(test_wp);
DelContext2D(test_wp);

// Test session info
wmgr->session->user = "user";
wmgr->session->hostname = "erythros-vm";
wmgr->session->id = 1;
wmgr->session->full_name = "Erythros User";

Copy("T:/System/Drivers/pci.ids", "B:/PciDevices.DD.Z");
ToDolDoc("B:/PciDevices.DD.Z");

// Start the window manager
//EWMTask;
CTask *ewm_task = Spawn(&EWMTask,,,5);