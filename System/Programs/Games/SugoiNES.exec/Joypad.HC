// vim: set ft=c:

class Joypad {
U8 pointer;
U8 button_status[8];
U8 previous_write;
};

Joypad NES_Joypad;

U0 initJoypad(Joypad *joypad) {
	joypad->pointer = 0;
	I64 i;
	for(i=0; i<8; ++i) {
		joypad->button_status[i] = 0;
	}
	joypad->previous_write = 0;
}

U0 handleInput(Joypad *joypad) {
	I64 i;
	for(i=0; i<8; ++i) {
		joypad->button_status[i] = 0;
	}
	if (my_win != wmgr->active_win || !my_win->visible || wmgr->win_blurall)
	{
		return;
	}
	//if (KeyDown(SC_ALT) || gp_data[0])
	if (KeyDown(Char2ScanCode('x')) || gp_data[0])
	{
		joypad->button_status[0] = 1; //A
	}
	//if (KeyDown(SC_CTRL) || gp_data[1])
	if (KeyDown(Char2ScanCode('z')) || gp_data[1])
	{
		joypad->button_status[1] = 1; //B
	}
	if (KeyDown(SC_TAB) || gp_data[2])
	{
		joypad->button_status[2] = 1; //SELECT
	}
	if (KeyDown(SC_ENTER) || gp_data[3])
	{
		joypad->button_status[3] = 1; //START
	}
	if (KeyDown(SC_CURSOR_UP) || gp_data[4])
	{
		joypad->button_status[4] = 1; //UP
	}
	if (KeyDown(SC_CURSOR_DOWN) || gp_data[5])
	{
		joypad->button_status[5] = 1; //DOWN
	}
	if (KeyDown(SC_CURSOR_LEFT) || gp_data[6])
	{
		joypad->button_status[6] = 1; //LEFT
	}
	if (KeyDown(SC_CURSOR_RIGHT) || gp_data[7])
	{
		joypad->button_status[7] = 1; //RIGHT
	}
}

U0 writeJoypad(Joypad *joypad, U8 data) {
	if( joypad->previous_write == 1 && data == 0) {
		joypad->pointer = 0;
	}
	joypad->previous_write = data;
}

U8 getNextButton(Joypad *joypad) {
	U8 retval = joypad->button_status[ joypad->pointer++ ];
	joypad->pointer = joypad->pointer % 8;
	return retval;
}