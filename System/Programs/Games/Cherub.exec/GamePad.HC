U0 updateGamePad()
{
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
  };
};
