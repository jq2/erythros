// vim: set ft=c:

//struct for sprites on the scanline (for secondary OAM)
class PPUsprite {
U8 shifts_remaining;
U8 sprite_index;
U8 byte2;

U8 shift_register_0;
U8 shift_register_1;
U8 shift_register_2;
U8 shift_register_3;
U8 attribute;
U8 x;
};

//struct to store the state of the PPU
class PPU2C02state {
U8 odd_frame;
U16 scanline;
U16 dot;

U8 nmi_occurred;

//PPU register values
U8 nmi_output;
U8 sprite_zero_hit;

//more accurate ppu
U16 nametable_base;

U16 bitmap_shift_0_latch;
U16 bitmap_shift_1_latch;
U16 bitmap_shift_2_latch;
U16 bitmap_shift_3_latch;

U16 bitmap_shift_0;
U16 bitmap_shift_1;
U16 bitmap_shift_2;
U16 bitmap_shift_3;

U16 AT_shift_0_latch;
U16 AT_shift_1_latch;
U16 AT_shift_0;
U16 AT_shift_1;

U16 AT_shift_2_latch;
U16 AT_shift_3_latch;
U16 AT_shift_2;
U16 AT_shift_3;

U8 num_sprites;
PPUsprite sprites[8];
};

PPU2C02state PPU_state;

U0 initMMU() {
	MemSet(&PPU_state,0,sizeof(PPU2C02state));

	MMU.RAM = MAlloc(0xFFFF);
	MMU.VRAM = MAlloc(0xFFFF);
	MMU.OAM = MAlloc(0xFF);

	MemSet( MMU.OAM, 0xFF, 0xFF );

	MMU.internal_buffer = 0;
	MMU.VRAM_address = 0;

	MMU.w = 0;
	MMU.t = 0;
}

U0 writeVRAM(U16 address, U8 value) {

	if (address > 0x2FFF && address < 0x3F00)
	{ //Nametable mirror
		address -= 0x1000;
	}

	if (mirroringType == MIRR_HORZ)
	{
		if (address > 0x23FF && address < 0x2800)
		{
			address -= 0x400;
		}
		if (address > 0x2BFF && address < 0x3000)
		{
			address -= 0x400;
		}
	}

	if (mirroringType == MIRR_VERT)
	{
		if (address > 0x1FFF && address < 0x3000)
		{
			address &= 0x27FF;
		}
	}

	MMU.VRAM[address] = value;
	if( address == 0x3F10 || address == 0x3F14 || address == 0x3F18 || address == 0x3F1C ) {
		address -= 0x10;
	}
	address &= 0x3FFF;
	MMU.VRAM[address] = value;
}

U8 readVRAM(U16 address) {

	if (address > 0x2FFF && address < 0x3F00)
	{ //Nametable mirror
		address -= 0x1000;
	}

	if (mirroringType == MIRR_HORZ)
	{
		if (address > 0x23FF && address < 0x2800)
		{
			address -= 0x400;
			return MMU.VRAM[address];
		}
		if (address > 0x2BFF && address < 0x3000)
		{
			address -= 0x400;
			return MMU.VRAM[address];
		}
	}

	if (mirroringType == MIRR_VERT)
	{
		if (address > 0x1FFF && address < 0x3000)
		{
			address &= 0x27FF;
			return MMU.VRAM[address];
		}
	}

	if( address == 0x3F10 || address == 0x3F14 || address == 0x3F18 || address == 0x3F1C ) {
		address -= 0x10;
	}
	address &= 0x3FFF;
	return MMU.VRAM[address];
}

U0 writeSPRRAM(U8 address, U8 value) {
	MMU.OAM[address] = value;
}
U8 readSPRRAM(U8 address) {
	return MMU.OAM[address];
}

U8 writeRAM(U16 address, U8 value) {
	U16 val;
	while(address >= 0x2008 && address < 0x4000) {
		address -= 8;
	}
	while(address >= 0x0800 && address < 0x2000) {
		address -= 0x0800;
	}

	if( (address >= 0x2000 && address <= 0x2007 && value != 0) || address == 0x4014 ) {
		if( address == 0x2003 ) {
			//assert(1 == 0);
		}
	}

	//PPUMASK
	if(address == 0x2000) {
		val = value&3;
		MMU.t &= 0xF3FF;
		MMU.t |= (val << 10);
		PPU_state.nmi_output = ((value & (1<<7)) >> 7);
	}

	//OAMDATA
	else if(address == 0x2004) {
		MMU.OAM[0x2003] = value;
		MMU.OAM[0x2003] += 1;
	}

	//PPUSCROLL
	else if(address == 0x2005) {
		if( MMU.w == 0 ) {
			MMU.t &= ~31; // 31 = 11111b
			MMU.t |= ((value&248) >> 3);
			MMU.x = (value & 7);
		}
		else {
			//t: CBA..HG FED..... = d: HGFEDCBA
			MMU.t &= 3103; //3103 = 0000110000011111b
			val = value;
			MMU.t |= ((val & 7) << 12); //CBA
			MMU.t |= ((val & 248) << 2); //HGFED
		}
		MMU.w ^= 1;
	}

	//PPUADDR
	else if(address == 0x2006) {
		if( MMU.w == 0 ) {
			MMU.t &= 0x00FF;
			val = value;
			val <<= 8;
			MMU.t |= val;
		}
		else {
			MMU.t &= 0xFF00;
			MMU.t |= value;
			MMU.VRAM_address = MMU.t;
		}
		MMU.w ^= 1;
		//MMU.VRAM_address = ((MMU.VRAM_address << 8) | value);
	}

	//PPUDATA
	else if(address == 0x2007) {
		writeVRAM( (MMU.VRAM_address&0x3FFF), value );
		if( (MMU.RAM[0x2000] & 4) == 0 ) {
			MMU.VRAM_address += 1;
		}
		else {
			MMU.VRAM_address += 32;
		}
	}

	//OAMDMA
	else if(address == 0x4014) {
		I64 i;
		for(i=0; i<=0xFF; ++i) {
			writeSPRRAM(i, MMU.RAM[(value << 8)|i] );
		}
		return 513 + PPU_state.odd_frame; //I think?
	}

	//PAPU
	if ((address > 0x3FFF && address < 0x4016) || address == 0x4017)
	{
		if (SND_BUF_LEN>0)
		{
			PAPU_writeReg(&PAPU, address, value);
		}
	}

	//Joypad 1
	else if(address == 0x4016) {
		writeJoypad(&NES_Joypad, value);
	}

	else if(address > 0x44FF && address < 0x451D && mapper==17) {
		FFE_Write(address, value);
	}

	else if (mapper == 18 && ((address > 0x7FFF && address < 0x8004) ||
		(address > 0x8FFF && address < 0x9002) || 
		(address > 0x9FFF && address < 0xA004) ||
		(address > 0xAFFF && address < 0xB004) ||
		(address > 0xBFFF && address < 0xC004) ||
		(address > 0xCFFF && address < 0xD004)))
	{
		SS88006_Write(address, value);
	}

	else if(address > 0x7FFF) {
		switch (mapper)
		{
		case 1:
			MMC1_Write(address, value);
			return 0;
			break;
		case 2:
			UNROM_Write(address, value);
			return 0;
			break;
		case 3:
			CNROM_Write(address, value);
			return 0;
			break;
		case 4:
			MMC3_Write(address, value);
			return 0;
			break;
		case 11:
			ColorDreams_Write(address, value);
			return 0;
			break;
		default:
			break;
		}
	}

	MMU.RAM[address] = value;
	return 0;
}

U8 readRAM(U16 address) {

	while(address >= 0x2008 && address < 0x4000) {
		address -= 8; //handle mirroring
	}
	while(address >= 0x0800 && address < 0x2000) {
		address -= 0x0800; //handle mirroring
	}

	U8 retVal = MMU.RAM[address];

	//PPUSTATUS
	if(address == 0x2002) {
		MMU.w = 0;
		retVal = ((PPU_state.sprite_zero_hit << 6) | (PPU_state.nmi_occurred << 7));
		PPU_state.nmi_occurred = 0;
		if(PPU_state.scanline == 241 && PPU_state.dot == 1) {
			retVal = (PPU_state.sprite_zero_hit << 6);
		}
	}

	//OAMDATA
	if(address == 0x2004) {
		return MMU.OAM[0x2003];
	}

	//PPUDATA
	else if(address == 0x2007) {
		//emulate 1 byte delay
		if( MMU.VRAM_address <= 0x3EFF ) {
			retVal = MMU.internal_buffer;
			MMU.internal_buffer = readVRAM( MMU.VRAM_address&0x3FFF );
		}
		else{
			MMU.internal_buffer = readVRAM( MMU.VRAM_address&0x3FFF );
			retVal = MMU.internal_buffer;
		}
		//increment address
		if( (MMU.RAM[0x2000] & 4) == 0 ) {
			MMU.VRAM_address += 1;
		}
		else {
			MMU.VRAM_address += 32;
		}
	}

	//Joypad 1
	else if(address == 0x4016) {
		retVal = getNextButton(&NES_Joypad);
	}

	//PAPU
	if ((address > 0x3FFF && address < 0x4016))
	{
		if (SND_BUF_LEN>0)
		{
			return PAPU_readReg(&PAPU, address);
		}
	}
	return retVal;
}

U0 dumpRAM() {
	U16 address = 0;
	U16 count = 0;
	"\nDump of RAM:\n";
	for( address=0x3F00; address<=0x3F20; ++address) {
		if( count % 16 == 0 ) {
			"\n%X: ", address;
		}
		"%X, ", MMU.VRAM[address];
		count += 1;
	}
	"\n";
}

U0 dumpSPRRAM() {
	U16 address = 0;
	U16 count = 0;
	"Dump of SPRRAM:\n";
	for( address=0; address<=0xFF; ++address) {
		if( count % 16 == 0 ) {
			"\n%X: ", address;
		}
		"%X, ", MMU.OAM[address];
		count += 1;
	}
	"\n";
}

U0 dumpVRAM() {
	"Dump of interesting VRAM:\n";
	U16 count = 0;
	U16 address = 0;
	for( address=0x2000; address<0x23FF; ++address) {
		if( count % 16 == 0 ) {
			"\n%X: ", address;
		}
		"%X, ", MMU.VRAM[address];
		count += 1;
	}
}