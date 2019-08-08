// vim: set ft=c:

#define GP_TX_PORT 0x0378
#define GP_RX_PORT 0x0379

#define GP_SNES_DELAY 0

#define GP_SNES_POWER 0xFC
#define GP_SNES_CLOCK 0x01
#define GP_SNES_LATCH 0x02

U8 gp_data[16];
MemSet(&gp_data,0,16);
I64 gp_ctr;

U0 updateGamepad()
{
	return;
	OutU8(GP_TX_PORT,GP_SNES_POWER|GP_SNES_CLOCK|GP_SNES_LATCH);
	Sleep(GP_SNES_DELAY*2);
	OutU8(GP_TX_PORT,GP_SNES_POWER|GP_SNES_CLOCK);
	gp_ctr=0;
	while (gp_ctr<12)
	{
		Sleep(GP_SNES_DELAY);
		OutU8(GP_TX_PORT,GP_SNES_POWER);
		gp_data[gp_ctr]=InU8(GP_RX_PORT)^0x7F;
		Sleep(GP_SNES_DELAY);
		OutU8(GP_TX_PORT,GP_SNES_POWER|GP_SNES_CLOCK);
		gp_ctr++;
	}
}