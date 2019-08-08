// vim: set ft=c:

class memory_manager {
U8 *RAM;
U8 *VRAM;
U8 *OAM;

U8 w;
U16 t;
U16 x;
U16 y;

U16 VRAM_address;
U8 internal_buffer;
};

memory_manager MMU;

// Mapper #1 [MMC1]

// 5-bit buffer:
I64 MMC1_regBuffer = 0;
I64 MMC1_regBufferCounter = 0;
// Register 0:
I64 MMC1_mirroring = 0;
I64 MMC1_oneScreenMirroring = 0;
I64 MMC1_prgSwitchingArea = 1;
I64 MMC1_prgSwitchingSize = 1;
I64 MMC1_vromSwitchingSize = 0;
// Register 1:
I64 MMC1_romSelectionReg0 = 0;
// Register 2:
I64 MMC1_romSelectionReg1 = 0;
// Register 3:
I64 MMC1_romBankSelect = 0;

I64 MMC1_getRegNumber(U16 address)
{
	if (address >= 0x8000 && address <= 0x9fff) {
		return 0;
	} else if (address >= 0xa000 && address <= 0xbfff) {
		return 1;
	} else if (address >= 0xc000 && address <= 0xdfff) {
		return 2;
	} else {
		return 3;
	}
}

U0 MMC1_loadRomBank(I64 bank, U16 address)
{
	// Swap in the given PRG-ROM bank:
	MemCpy(MMU.RAM+address, cartridgebuffer+0x10+0x4000*(bank), 0x4000);
}

U0 MMC1_loadVromBank(I64 bank, U16 address)
{
	//Copy the ROM into the PPU's memory
	I64 bank4k = Floor(bank / 4) % numCHRROM;
	I64 bankoffset = (bank % 4) * 1024;
	MemCpy(MMU.VRAM+address, cartridgebuffer+0x10+(0x4000*numPRGROM)+(0x1000*(bankoffset)), 1024);
}

U0 MMC1_load1kVromBank(I64 bank, U16 address)
{
	//Copy the ROM into the PPU's memory
	MemCpy(MMU.VRAM+address, cartridgebuffer+0x10+(0x4000*numPRGROM)+(0x400*(bank)), 0x400);
}

U0 MMC1_load8kRomBank(I64 bank, U16 address)
{
	// Swap in the given PRG-ROM bank:
	MemCpy(MMU.RAM+address, cartridgebuffer+0x10+0x2000*(bank), 0x2000);
}

U0 MMC1_load32kRomBank(I64 bank, U16 address)
{
	// Swap in the given PRG-ROM bank:
	MemCpy(MMU.RAM+address, cartridgebuffer+0x10+0x4000*(bank), 0x8000);
}

U0 MMC1_load8kVromBank(I64 bank, U16 address)
{
	//Copy the ROM into the PPU's memory
	MemCpy(MMU.VRAM+address, cartridgebuffer+0x10+(0x4000*numPRGROM)+(0x1000*(bank)), 0x2000);
}

U0 MMC1_setReg(I64 _reg, I64 value)
{
	I64 tmp;
	switch (_reg) {
	case 0:
		// Mirroring:
		tmp = value & 3;
		if (tmp != MMC1_mirroring) {
			// Set mirroring:
			MMC1_mirroring = tmp;
			if ((MMC1_mirroring & 2) == 0) {
				// SingleScreen mirroring overrides the other setting:
				mirroringType = MIRR_SINGLE;
			} else if ((MMC1_mirroring & 1) != 0) {
				// Not overridden by SingleScreen mirroring.
				mirroringType = MIRR_HORZ;
			} else {
				mirroringType = MIRR_VERT;
			}
		}
		// PRG Switching Area;
		MMC1_prgSwitchingArea = (value >> 2) & 1;
		// PRG Switching Size:
		MMC1_prgSwitchingSize = (value >> 3) & 1;
		// VROM Switching Size:
		MMC1_vromSwitchingSize = (value >> 4) & 1;
		break;
	case 1:
		// ROM selection:
		MMC1_romSelectionReg0 = (value >> 4) & 1;
		// Check whether the cart has VROM:
		if (numCHRROM > 0) {
			// Select VROM bank at 0x0000:
			if (MMC1_vromSwitchingSize == 0) {
				// Swap 8kB VROM:
				if (MMC1_romSelectionReg0 == 0) {
					MMC1_load8kVromBank(value & 0xf, 0x0000);
				} else {
					MMC1_load8kVromBank(
					        Floor(numCHRROM / 2) + (value & 0xf),
					        0x0000
					        );
				}
			} else {
				// Swap 4kB VROM:
				if (MMC1_romSelectionReg0 == 0) {
					MMC1_loadVromBank(value & 0xf, 0x0000);
				} else {
					MMC1_loadVromBank(
					        Floor(numCHRROM / 2) + (value & 0xf),
					        0x0000
					        );
				}
			}
		}
		break;
	case 2:
		// ROM selection:
		MMC1_romSelectionReg1 = (value >> 4) & 1;
		// Check whether the cart has VROM:
		if (numCHRROM > 0) {
			// Select VROM bank at 0x1000:
			if (MMC1_vromSwitchingSize == 1) {
				// Swap 4kB of VROM:
				if (MMC1_romSelectionReg1 == 0) {
					MMC1_loadVromBank(value & 0xf, 0x1000);
				} else {
					MMC1_loadVromBank(
					        Floor(numCHRROM / 2) + (value & 0xf),
					        0x1000
					        );
				}
			}
		}
		break;
	default:
		// Select ROM bank:
		// -------------------------
		tmp = value & 0xf;
		I64 bank;
		I64 baseBank = 0;
		if (numPRGROM >= 32) {
			// 1024 kB cart
			if (MMC1_vromSwitchingSize == 0) {
				if (MMC1_romSelectionReg0 == 1) {
					baseBank = 16;
				}
			} else {
				baseBank =
				        (MMC1_romSelectionReg0 | (MMC1_romSelectionReg1 << 1)) << 3;
			}
		} else if (numPRGROM >= 16) {
			// 512 kB cart
			if (MMC1_romSelectionReg0 == 1) {
				baseBank = 8;
			}
		}
		if (MMC1_prgSwitchingSize == 0) {
			// 32kB
			bank = baseBank + (value & 0xf);
			MMC1_load32kRomBank(bank, 0x8000);
		} else {
			// 16kB
			bank = baseBank * 2 + (value & 0xf);
			if (MMC1_prgSwitchingArea == 0) {
				MMC1_loadRomBank(bank, 0xc000);
			} else {
				MMC1_loadRomBank(bank, 0x8000);
			}
		}
	}
}

U0 MMC1_Write(U16 address, U8 value)
{
	// See what should be done with the written value:
	if ((value & 128) != 0) {
		// Reset buffering:
		MMC1_regBufferCounter = 0;
		MMC1_regBuffer = 0;
		// Reset register:
		if (MMC1_getRegNumber(address) == 0) {
			MMC1_prgSwitchingArea = 1;
			MMC1_prgSwitchingSize = 1;
		}
	} else {
		// Continue buffering:
		//regBuffer = (regBuffer & (0xFF-(1<<regBufferCounter))) | ((value & (1<<regBufferCounter))<<regBufferCounter);
		MMC1_regBuffer =
		        (MMC1_regBuffer & (0xff - (1 << MMC1_regBufferCounter))) |
		        ((value & 1) << MMC1_regBufferCounter);
		MMC1_regBufferCounter++;
		if (MMC1_regBufferCounter == 5) {
			// Use the buffered value:
			MMC1_setReg(MMC1_getRegNumber(address), MMC1_regBuffer);
			// Reset buffer:
			MMC1_regBuffer = 0;
			MMC1_regBufferCounter = 0;
		}
	}
}

// Mapper #2 [UNROM]

U0 UNROM_Write(U16 address, U8 value)
{
	// Swap in the given PRG-ROM bank:
	MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10+0x4000*(value), 0x4000);
}


// Mapper #3 [CNROM]

U0 CNROM_Write(U16 address, U8 value)
{
	I64 bank = value & 3;
	//Copy the ROM into the PPU's memory
	MemCpy(MMU.VRAM, cartridgebuffer+0x10+(0x4000*numPRGROM)+(0x2000*(bank)), 0x2000);
}

// Mapper #4 [MMC3]

#define MMC3_CMD_SEL_2_1K_VROM_0000   0
#define MMC3_CMD_SEL_2_1K_VROM_0800   1
#define MMC3_CMD_SEL_1K_VROM_1000     2
#define MMC3_CMD_SEL_1K_VROM_1400     3
#define MMC3_CMD_SEL_1K_VROM_1800     4
#define MMC3_CMD_SEL_1K_VROM_1C00     5
#define MMC3_CMD_SEL_ROM_PAGE1        6
#define MMC3_CMD_SEL_ROM_PAGE2        7

I64 MMC3_command = NULL;
I64 MMC3_prgAddressSelect = NULL;
I64 MMC3_chrAddressSelect = NULL;
I64 MMC3_pageNumber = NULL;
I64 MMC3_irqCounter = NULL;
I64 MMC3_irqLatchValue = NULL;
I64 MMC3_irqEnable = NULL;
I64 MMC3_prgAddressChanged = FALSE;

U0 MMC3_executeCommand(I64 cmd, I64 arg) {
	switch (cmd)
	{
	case MMC3_CMD_SEL_2_1K_VROM_0000:
		// Select 2 1KB VROM pages at 0x0000:
		if (MMC3_chrAddressSelect == 0) {
			MMC1_load1kVromBank(arg, 0x0000);
			MMC1_load1kVromBank(arg + 1, 0x0400);
		} else {
			MMC1_load1kVromBank(arg, 0x1000);
			MMC1_load1kVromBank(arg + 1, 0x1400);
		}
		break;

	case MMC3_CMD_SEL_2_1K_VROM_0800:
		// Select 2 1KB VROM pages at 0x0800:
		if (MMC3_chrAddressSelect == 0) {
			MMC1_load1kVromBank(arg, 0x0800);
			MMC1_load1kVromBank(arg + 1, 0x0c00);
		} else {
			MMC1_load1kVromBank(arg, 0x1800);
			MMC1_load1kVromBank(arg + 1, 0x1c00);
		}
		break;

	case MMC3_CMD_SEL_1K_VROM_1000:
		// Select 1K VROM Page at 0x1000:
		if (MMC3_chrAddressSelect == 0) {
			MMC1_load1kVromBank(arg, 0x1000);
		} else {
			MMC1_load1kVromBank(arg, 0x0000);
		}
		break;

	case MMC3_CMD_SEL_1K_VROM_1400:
		// Select 1K VROM Page at 0x1400:
		if (MMC3_chrAddressSelect == 0) {
			MMC1_load1kVromBank(arg, 0x1400);
		} else {
			MMC1_load1kVromBank(arg, 0x0400);
		}
		break;

	case MMC3_CMD_SEL_1K_VROM_1800:
		// Select 1K VROM Page at 0x1800:
		if (MMC3_chrAddressSelect == 0) {
			MMC1_load1kVromBank(arg, 0x1800);
		} else {
			MMC1_load1kVromBank(arg, 0x0800);
		}
		break;

	case MMC3_CMD_SEL_1K_VROM_1C00:
		// Select 1K VROM Page at 0x1C00:
		if (MMC3_chrAddressSelect == 0) {
			MMC1_load1kVromBank(arg, 0x1c00);
		} else {
			MMC1_load1kVromBank(arg, 0x0c00);
		}
		break;

	case MMC3_CMD_SEL_ROM_PAGE1:
		if (MMC3_prgAddressChanged) {
			// Load the two hardwired banks:
			if (MMC3_prgAddressSelect == 0) {
				MMC1_load8kRomBank((numPRGROM - 1) * 2, 0xc000);
			} else {
				MMC1_load8kRomBank((numPRGROM - 1) * 2, 0x8000);
			}
			MMC3_prgAddressChanged = FALSE;
		}

		// Select first switchable ROM page:
		if (MMC3_prgAddressSelect == 0) {
			MMC1_load8kRomBank(arg, 0x8000);
		} else {
			MMC1_load8kRomBank(arg, 0xc000);
		}
		break;

	case MMC3_CMD_SEL_ROM_PAGE2:
		// Select second switchable ROM page:
		MMC1_load8kRomBank(arg, 0xa000);

		// hardwire appropriate bank:
		if (MMC3_prgAddressChanged) {
			// Load the two hardwired banks:
			if (MMC3_prgAddressSelect == 0) {
				MMC1_load8kRomBank((numPRGROM - 1) * 2, 0xc000);
			} else {
				MMC1_load8kRomBank((numPRGROM - 1) * 2, 0x8000);
			}
			MMC3_prgAddressChanged = FALSE;
		}
	}
};

U0 MMC3_Write(U16 address, U8 value)
{
	switch (address)
	{
	case 0x8000:
		// Command/Address Select register
		MMC3_command = value & 7;
		I64 tmp = (value >> 6) & 1;
		if (tmp != MMC3_prgAddressSelect) {
			MMC3_prgAddressChanged = TRUE;
		}
		MMC3_prgAddressSelect = tmp;
		MMC3_chrAddressSelect = (value >> 7) & 1;
		break;

	case 0x8001:
		// Page number for command
		MMC3_executeCommand(MMC3_command, value);
		break;

	case 0xa000:
		// Mirroring select
		if ((value & 1) != 0) {
			mirroringType = MIRR_HORZ;
		} else {
			mirroringType = MIRR_VERT;
		}
		break;

	case 0xa001:
		// SaveRAM Toggle
		// TODO
		//nes.getRom().setSaveState((value&1)!=0);
		break;

	case 0xc000:
		// IRQ Counter register
		MMC3_irqCounter = value;
		//nes.ppu.mapperIrqCounter = 0;
		break;

	case 0xc001:
		// IRQ Latch register
		MMC3_irqLatchValue = value;
		break;

	case 0xe000:
		// IRQ Control Reg 0 (disable)
		//irqCounter = irqLatchValue;
		MMC3_irqEnable = 0;
		break;

	case 0xe001:
		// IRQ Control Reg 1 (enable)
		MMC3_irqEnable = 1;
		break;

	default:
		// Not a MMC3 register.
		// The game has probably crashed,
		// since it tries to write to ROM..
		// IGNORE.
	}
}

U0 MMC3_clockIrqCounter()
{
	if (MMC3_irqEnable == 1) {
		MMC3_irqCounter--;
    	if (MMC3_irqCounter < 0)
		{
      	// Trigger IRQ:
      	mapper_request_irq=TRUE;
      	MMC3_irqCounter = MMC3_irqLatchValue;
    	}
	}
}

// Mapper #11 [Color Dreams]

U0 ColorDreams_Write(U16 address, U8 value)
{
	// Swap in the given PRG-ROM bank:
	I64 prgbank = ((value & 0xf) * 2) % numPRGROM;
	MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10+0x4000*(prgbank), 0x8000);
	if (numCHRROM > 0) {
		// Swap in the given VROM bank at 0x0000:
		I64 bank = ((value >> 4) * 2);
		MemCpy(MMU.VRAM, cartridgebuffer+0x10+(0x4000*numPRGROM)+(0x1000*(bank)), 0x2000);
	}
}

// Mapper #17 [FFE Copier]
U0 FFE_Write(U16 address, U8 value)
{
	switch (address)
	{
		case 0x4500://Config register
			break;
		case 0x4501://Disable IRQ
			break;
		case 0x4502://IRQ Counter low byte
			break;
		case 0x4503://IRQ Counter high byte
			break;
		case 0x4504...0x4507://Switch PRG bank
			I64 prgbank = address-0x4504;
			MemCpy(MMU.RAM+0x8000+(prgbank*0x2000), cartridgebuffer+0x10+0x2000*(prgbank), 0x2000);
			break;
		case 0x4510...0x451B://Switch CHR bank
			I64 chrbank = address-0x4510;
			MemCpy(MMU.VRAM+(chrbank*0x400), cartridgebuffer+0x10+(0x4000*numPRGROM)+(chrbank*0x400), 0x400);
			break;
		default:
			break;
	}
}

// Mapper #18 [Jaleco SS88006]

U8 SS88006_lo = 0;
Bool SS88006_loWrite = FALSE;
U8 SS88006_hi = 0;
Bool SS88006_hiWrite = FALSE;

U8 SS88006_irqctr;

U0 SS88006_Write(U16 address, U8 value)
{
	I64 bank;
	if (address & 1)
	{
		SS88006_hi = value << 4;
		SS88006_hiWrite = TRUE;
	}
	else
	{
		SS88006_lo = value;
		SS88006_loWrite = TRUE;
	}
	if (SS88006_loWrite && SS88006_hiWrite)
	{
		bank = SS88006_lo + SS88006_hi;
		switch (address)
		{
			case 0x8000...0x8001:
				MemCpy(MMU.RAM+0x8000, cartridgebuffer+0x10+0x2000*(bank), 0x2000);
				break;
			case 0x8002...0x8003:
				MemCpy(MMU.RAM+0xA000, cartridgebuffer+0x10+0x2000*(bank), 0x2000);
				break;
			case 0x9000...0x9001:
				MemCpy(MMU.RAM+0xC000, cartridgebuffer+0x10+0x2000*(bank), 0x2000);
				break;
			case 0xA000...0xA001:
				MemCpy(MMU.VRAM+0x0000, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			case 0xA002...0xA003:
				MemCpy(MMU.VRAM+0x0400, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			case 0xB000...0xB001:
				MemCpy(MMU.VRAM+0x0800, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			case 0xB002...0xB003:
				MemCpy(MMU.VRAM+0x0C00, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			case 0xC000...0xC001:
				MemCpy(MMU.VRAM+0x1000, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			case 0xC002...0xC003:
				MemCpy(MMU.VRAM+0x1400, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			case 0xD000...0xD001:
				MemCpy(MMU.VRAM+0x1800, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			case 0xD002...0xD003:
				MemCpy(MMU.VRAM+0x1C00, cartridgebuffer+0x10+(0x4000*numPRGROM)+(bank*0x400), 0x400);
				break;
			default:
				break;
		}
		SS88006_loWrite = FALSE;
		SS88006_hiWrite = FALSE;
	}
}