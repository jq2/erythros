// vim: set ft=c:

U8 *rom_filename=NULL;
Bool rom_select=FALSE;

CTask *draw_task=NULL;
CTask *emu_task=NULL;

CSprite *vid;

EContext2D *flip_ctx0 = NewContext2D(256,240,display.bpp);
EContext2D *flip_ctx1 = NewContext2D(512,480,display.bpp);

CDC *game_dc=DCNew(256,240); // Flattened 8-bit device context
CDC *game_dc0=DCNew(256,240); // 8x8 sprites/backgrounds
CDC *game_dc1=DCNew(256,240); // 8x16 sprite overlay

Bool fit_screen = TRUE;

I64 vgafr_cnt=cnts.jiffies;

I64 scnt_a=cnts.jiffies;
I64 scnt_b=0;

while (cnts.jiffies<scnt_a+16)
{
  scnt_b++;
}

scnt_a=scnt_b;
scnt_b=0;


I64 RoundUp(I64 numToRound, I64 multiple)
{
	if (multiple == 0)
	{
		return numToRound;
	}
	I64 remainder = numToRound % multiple;
	if (remainder == 0)
	{
		return numToRound;
	}
	return numToRound + multiple - remainder;
}

Bool reset = FALSE;
Bool quit = FALSE;
Bool paused = FALSE;
U8 cycles=0;
U8 loop=0;
U8 frame_finished=0;
I64 frame_count;
U8 tmp_str[256];

U8 *cartridgebuffer=NULL;

I64 numPRGROM;
I64 numCHRROM;
I64 controlByte1;
I64 controlByte2;
I64 numRAM;
I64 trainer;
I64 mapper;
I64 mirroringType;

Bool papu_request_irq = FALSE;
Bool mapper_request_irq = FALSE;

#define MIRR_HORZ       0
#define MIRR_VERT       1
#define MIRR_SINGLE     2

#include "Gamepad";
#include "Joypad";
#include "Mappers";
#include "PAPU";
#include "MMU";
#include "CPU";
#include "PPU";
#include "Audio";

initMMU();

U8 *system_state=MAlloc(0x200FD);

/*
U0 SaveInitSystemState()
{
	MemCpy(system_state, MMU.RAM, 0xFFFF);
	MemCpy(system_state+0xFFFF, MMU.VRAM, 0xFFFF);
	MemCpy(system_state+(0xFFFF*2), MMU.OAM, 0xFF);
	FileWrite("E:/Home/Src/templenes/State.BIN.Z",system_state,0x200FD);
}
*/

U0 LoadInitSystemState()
{
	if (system_state)
	{
		//Free(system_state);
	}
	system_state=FileRead("E:/Home/Src/templenes/State.BIN.Z");
	MemCpy(MMU.RAM, system_state, 0xFFFF);
	MemCpy(MMU.VRAM, system_state+0xFFFF, 0xFFFF);
	MemCpy(MMU.OAM, system_state+(0xFFFF*2), 0xFF);
	MemCpy(system_state+0xFFFF, MMU.VRAM, 0xFFFF);
	MemCpy(system_state+(0xFFFF*2), MMU.OAM, 0xFF);
	//Free(system_state);
	system_state=NULL;
}

U0 resetSystem()
{
	reset6502;
	//initalize the PPU
	initPPU2C02(&PPU_state);
	//initalize the Joypad
	initJoypad(&NES_Joypad);
	//initialize the pAPU
	if (SND_BUF_LEN>0)
	{
		PAPU_reset(&PAPU);
	}
}

U0 handleCmdButtons()
{
	if (!(my_win != wmgr->active_win || !my_win->visible || wmgr->win_blurall))
	{
		if (KeyDown(Char2ScanCode('r')))
		{
			resetSystem;
		}
	}
}

U0 DC2Context2D(EContext2D *ctx, CDC *dc, U32 *pal, I64 scale)
{
	I64 x,y,sx,sy;
	for (y=0;y<dc->height;y++)
	{
		for (x=0;x<dc->width;x++)
		{
			for (sy=0;sy<scale;sy++)
			{
				for (sx=0;sx<scale;sx++)
				{
					Plot2D(ctx, (x*scale)+sx, (y*scale)+sy, pal[GrPeek(dc,x,y)]);
				}
			}
		}
	}
}

U0 doScreenUpdate()
{
	if (MMU.RAM[0x2000] & (1 << 5) != 0)
	{
		GrBlot(game_dc0, 0, -8, game_dc1);
		DCFill(game_dc1);
	}
	GrBlot(game_dc, 0, -8, game_dc0);
	
	switch (vid_scale)
	{
		case 2:
			DC2Context2D(flip_ctx1, game_dc, ppu_colors, vid_scale);
			MemCpy(game_ctx1->ctx->fb, flip_ctx1->fb, 512*480*(display.bpp/8) );
			break;
		default:
			DC2Context2D(flip_ctx0, game_dc, ppu_colors, vid_scale);
			MemCpy(game_ctx0->ctx->fb, flip_ctx0->fb, 256*240*(display.bpp/8) );
			break;
	}
}

U0 drawScreen()
{
	while (1)
	{


		if( frame_finished )
		{
			frame_count += 1;
			doScreenUpdate;
		}
		if ( paused )
		{
			doScreenUpdate;
		}
	}
}

U0 initCart(U8 *rom_filename)
{
	cartridgebuffer = FileRead(rom_filename);

	//if the file is not an iNES-file, abort
	if(cartridgebuffer[0] != 'N' || cartridgebuffer[1] != 'E' || cartridgebuffer[2] != 'S' || cartridgebuffer[3] != 0x1a) {
		PrintErr("File is not an iNES-file.\n");
		return;
	}
	CDirEntry *tmp_de = FilesFind(rom_filename);
	StrPrint(my_win->title, &tmp_de->name);
	DirTreeDel(tmp_de);

	mirroringType = MIRR_HORZ;
	numPRGROM = cartridgebuffer[4];
	numCHRROM = cartridgebuffer[5];
	controlByte1 = cartridgebuffer[6];
	controlByte2 = cartridgebuffer[7];
	numRAM = cartridgebuffer[8];

	trainer = (controlByte1 & (1 << 2));

	if (controlByte1 & 1)
	{
		mirroringType = MIRR_VERT;
	}

	mapper = ( (controlByte2 & 0xF0) | ((controlByte1 & 0xF0) >> 4));

	switch (mapper)
	{
	case 0:
		//Copy the ROM into the CPU's memory
		MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10, numPRGROM*0x4000);
		if(numPRGROM == 1) {
			MemCpy(MMU.RAM+0xC000, cartridgebuffer+0x10, numPRGROM*0x4000);
		}
		//Copy the ROM into the PPU's memory
		MemCpy(MMU.VRAM, cartridgebuffer+0x10+0x4000*numPRGROM, 0x2000*numCHRROM);
		break;
	case 1:// MMC1
	case 2:// UNROM
		//Load first PRG ROM bank
		MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10, 0x4000);
		//and last PRG ROM bank
		MemCpy(MMU.RAM+0xC000, cartridgebuffer+0x10+0x4000*(numPRGROM-1), 0x4000);
		//Copy the ROM into the PPU's memory
		if (numCHRROM)
		{
			MemCpy(MMU.VRAM, cartridgebuffer+0x10+0x4000*numPRGROM, 0x2000*numCHRROM);
		}
		break;
	case 3:// CNROM
		//Copy the ROM into the CPU's memory
		MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10, numPRGROM*0x4000);
		if(numPRGROM == 1) {
			MemCpy(MMU.RAM+0xC000, cartridgebuffer+0x10, numPRGROM*0x4000);
		}
		//Copy the ROM into the PPU's memory
		MemCpy(MMU.VRAM, cartridgebuffer+0x10+0x4000*numPRGROM, 0x2000);
		break;
	case 4:// MMC3
		MMC1_load8kRomBank((numPRGROM - 1) * 2, 0xc000);
		MMC1_load8kRomBank((numPRGROM - 1) * 2 + 1, 0xe000);
		MMC1_load8kRomBank(0, 0x8000);
		MMC1_load8kRomBank(1, 0xa000);
		//Copy the ROM into the PPU's memory
		MemCpy(MMU.VRAM, cartridgebuffer+0x10+0x4000*numPRGROM, 0x2000);
		break;
	case 11:// Color Dreams
		//Load first PRG ROM bank
		MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10, 0x8000);
		//Copy the ROM into the PPU's memory
		MemCpy(MMU.VRAM, cartridgebuffer+0x10+0x4000*numPRGROM, 0x2000);
		break;
	case 17:// FFE Copier
		//Load first PRG ROM bank
		MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10, 0x8000);
		//Copy the ROM into the PPU's memory
		MemCpy(MMU.VRAM, cartridgebuffer+0x10+0x4000*numPRGROM, 0x2000);
		break;
	case 18:// Jaleco SS88006
		//Load first/last PRG ROM bank
		MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10, 0x4000);
		MemCpy(MMU.RAM+0xC000, cartridgebuffer+0x10+(0x4000*(numPRGROM-1)), 0x4000);
		//Copy the ROM into the PPU's memory
		MemCpy(MMU.VRAM, cartridgebuffer+0x10+0x4000*numPRGROM, 0x2000);
		break;
	default:
		PrintErr("iNES mapper not supported.\n");
		//Free(cartridgebuffer);
		return;
		break;
	}

}

I64 TempleNES(U8 *rom_file)
{
	DCFill(game_dc0,63);
	DCFill(game_dc1);
	Fill2D(flip_ctx0, BLACK);
	Fill2D(flip_ctx1, BLACK);

	I64 vg_ctr=cnts.jiffies;
	I64 vc_ctr=0;
	initCart(rom_file);

	//initalize the CPU
	reset6502;

	//initalize the PPU
	initPPU2C02(&PPU_state);

	//initalize the Joypad
	initJoypad(&NES_Joypad);

	//initialize the pAPU
	if (SND_BUF_LEN>0)
	{
		initPAPU(&PAPU);
	}

	draw_task = Spawn(&drawScreen,,,1);

	start_buf_num=snd_obuf_num;
	fp_old_fill_buf=fp_snd_fill_buf;
	fp_snd_fill_buf=&AudioFillBuf;

	while(!quit) {
		//emulate CPU and PPU

		frame_finished = 0;

		if( paused == 0) {
			if (mapper_request_irq)
			{
				irq6502;
				mapper_request_irq = FALSE;
			}
			if (papu_request_irq)
			{
				irq6502;
				papu_request_irq = FALSE;
			}
			exec6502(1);
			cycles = ticktable[opcode];
			vc_ctr += cycles;
			if (SND_BUF_LEN>0)
			{
				PAPU_clockFrameCounter(&PAPU, cycles);
			}
			loop = cycles*3;
			while( loop != 0 )
			{
				frame_finished |= PPUcycle(&PPU_state);
				loop -= 1;
			}
		}
		if (reset)
		{
			resetSystem;
			reset = FALSE;
		}
		handleCmdButtons;
		handleInput(&NES_Joypad);
		if (vc_ctr>29829)
		{
			while (cnts.jiffies<vg_ctr+16)
			{
			}
			vc_ctr=0;
			vg_ctr=cnts.jiffies;
		}
	}

	quit = FALSE;
	fp_snd_fill_buf=fp_old_fill_buf;
	Kill(draw_task);
	DocClear;
	//Free(cartridgebuffer);
	return 0;
}

/*
start_buf_num=snd_obuf_num;
fp_old_fill_buf=fp_snd_fill_buf;
*/