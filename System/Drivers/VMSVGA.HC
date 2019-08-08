class CVMSVGAInfo
{
U16 io_base;
U16 width;
U16 height;
U16 bpp;
U64 fb;
};

#define VBE_IOPORT_INDEX        0x01CE
#define VBE_IOPORT_DATA         0x01CF
#define VBE_XRES                1
#define VBE_YRES                2
#define VBE_BPP                 3
#define VBE_ENABLE              4

#define VMSR_FB                 13

CVMSVGAInfo svga;
MemSet(&svga, 0, sizeof(CVMSVGAInfo));

U16 VBE_RegRead(U16 index)
{
	OutU16(VBE_IOPORT_INDEX, index);
	return InU16(VBE_IOPORT_DATA);
}

U0 VBE_RegWrite(U16 index, U16 val)
{
	OutU16(VBE_IOPORT_INDEX, index);
	OutU16(VBE_IOPORT_DATA, val);
}

U32 VMSVGA_RegRead(I64 index)
{
	OutU32(svga.io_base, index);
	return InU32(svga.io_base+1);
}

U0 VMSVGA_RegWrite(I64 index, U32 val)
{
	OutU32(svga.io_base, index);
	OutU32(svga.io_base+1, val);
}

U0 GetVideoRegVals()
{
	svga.width              = VBE_RegRead(VBE_XRES);
	svga.height     = VBE_RegRead(VBE_YRES);
	svga.bpp        = VBE_RegRead(VBE_BPP);
	svga.fb         = VMSVGA_RegRead(VMSR_FB);
}

U0 SetVideoRegVals()
{
	VBE_RegWrite(VBE_ENABLE, 0);
	VBE_RegWrite(VBE_XRES, svga.width);
	VBE_RegWrite(VBE_YRES, svga.height);
	VBE_RegWrite(VBE_BPP, svga.bpp);
	VBE_RegWrite(VBE_ENABLE, 1);
}

U0 VMSVGA_Start(I64 w=1024,I64 h=768,I64 bpp=24)
{
	switch (bpp)
	{
	case 24:
		break;
	default:
		"\nInvalid bpp. (must be 24)\n";
		return;
		break;
	}
	I64 j;
	//Scan for device
	j=PCIClassFind(0x030000,0);
	if (j<0)
	{
		"\nVMSVGA device not found.\n";
		return;
	}
	svga.io_base=PCIReadU16(j.u8[2],
	                        j.u8[1],j.u8[0],0x10) & ~(0x0F);
	if (!svga.io_base)
	{
		"\nError reading base I/O address.\n";
		return;
	}
	GetVideoRegVals;
	svga.width=w;
	svga.height=h;
	svga.bpp=bpp;
	LBts(&sys_winmgr_task->task_flags,TASKf_SUSPENDED);
	//Raw(ON);
	SetVideoRegVals;
}