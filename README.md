# erythros
An operating system based on TempleOS

![Erythros](https://raw.githubusercontent.com/obecebo/erythros/master/preview.png?)

This is a work in progress - more information will be added as it becomes available.

# details

Erythros is an experimental "OS" project that runs on top of an unmodified TempleOS environment. It does not perform any modifications to the underlying TempleOS Kernel or Compiler, so it can even be launched from the TempleOS standard distro live CD environment, if desired.

# supported hardware

- Intel HD Audio
- VMware SVGA II graphics adapter
- VirtualBox Guest (Mouse integration, bidirectional clipboard)
- Virtio-net

# planned (future) hardware support
- virtio-scsi
- etc.

# usage

Clone the repo, create a RedSea ISO.C disk image using [RedSeaExplorer](https://checksum.fail/files/RedSeaExplorer-0.6.zip) for Windows or [redseafs](https://github.com/obecebo/redseafs) for Linux, execute `Cd("T:/"); #include "Run";` from Adam task.
