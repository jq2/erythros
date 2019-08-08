U0 updateKeyboard()
{
    I64 i;
    if (my_win != wmgr->active_win || !my_win->visible || wmgr->win_blurall)
    {
        for (i=0;i<8;i++)
        {
            gp_data[i]=0;
        }
        return;
    }
    if (KeyDown(SC_CURSOR_UP))
    {
        gp_data[4]=0x40;
    }
    else
    {
        gp_data[4]=0x00;
    }
    if (KeyDown(SC_CURSOR_DOWN))
    {
        gp_data[5]=0x40;
    }
    else
    {
        gp_data[5]=0x00;
    }
    if (KeyDown(SC_CURSOR_LEFT))
    {
        gp_data[6]=0x40;
    }
    else
    {
        gp_data[6]=0x00;
    }
    if (KeyDown(SC_CURSOR_RIGHT))
    {
        gp_data[7]=0x40;
    }
    else
    {
        gp_data[7]=0x00;
    }
	if (KeyDown(Char2ScanCode('x')))
	{
        gp_data[0]=0x40;
	}
    else
    {
        gp_data[0]=0x00;
    }
	if (KeyDown(Char2ScanCode('z')))
	{
        gp_data[1]=0x40;
	}
    else
    {
        gp_data[1]=0x00;
    }
    if (KeyDown(SC_TAB))
    {
        gp_data[2]=0x40;
    }
    else
    {
        gp_data[2]=0x00;
    }
    if (KeyDown(SC_ENTER))
    {
        gp_data[3]=0x40;
    }
    else
    {
        gp_data[3]=0x00;
    }
}

U0 updateKeyboard_()
{
        switch(sc)
        {

            // Reset (kbd only)
            case 0x13:
                kReset=0;
                break;
            case 0x13 + 0x80:
                if(!kReset) {
                  kReset=1;
                  StrCpy(DisplayMsg,"Reset");
                  DisplayMsgTicks=1;
                  initEmulator;
                };
                break;           

            // Set Display Size (kbd only)

            case 0x02 + 0x80:
                LCDScale=1;
                SetLCDScale;
                break;
            case 0x03 + 0x80:
                LCDScale=2;
                SetLCDScale;
                break;
            case 0x04 + 0x80:
                LCDScale=3;
                SetLCDScale;
                break;

            // Exit
            case 0x01:
                gp_data[10]=0x40;
                break;
            // LoadState
            case 0x06:
                gp_data[11]=0x40;
                break;
            // SaveState
            case 0x08:
                gp_data[9]=0x40;
                break;
            // ToggleSound
            case 0x10:
                gp_data[8]=0x40;
                break;
            // Exit(up)
            case 0x01 + 0x80:
                gp_data[10]=0x00;
                break;
            // LoadState(up)
            case 0x06 + 0x80:
                gp_data[11]=0x00;
                break;
            // SaveState(up)
            case 0x08 + 0x80:
                gp_data[9]=0x00;
                break;
            // ToggleSound(up)
            case 0x10 + 0x80:
                gp_data[8]=0x00;
                break;

            case 0x4D:
                gp_data[7]=0x40;
                break;
            case 0x4B:
                gp_data[6]=0x40;
                break;
            case 0x48:
                gp_data[4]=0x40;
                break;
            case 0x50:
                gp_data[5]=0x40;
                break;
            case 0x1F:
                gp_data[0]=0x40;
                break;
            case 0x1E:
                gp_data[1]=0x40;
                break;
            case 0x2A:
                gp_data[2]=0x40;
                break;
            case 0x1C:
                gp_data[3]=0x40;
                break;

            case 0x4D + 0x80:
                gp_data[7]=0x00;
                break;
            case 0x4B + 0x80:
                gp_data[6]=0x00;
                break;
            case 0x48 + 0x80:
                gp_data[4]=0x00;
                break;
            case 0x50 + 0x80:
                gp_data[5]=0x00;
                break;
            case 0x1F + 0x80:
                gp_data[0]=0x00;
                break;
            case 0x1E + 0x80:
                gp_data[1]=0x00;
                break;
            case 0x2A + 0x80:
                gp_data[2]=0x00;
                break;
            case 0x1C + 0x80:
                gp_data[3]=0x00;
                break;

            default:
                break;
        };
};
