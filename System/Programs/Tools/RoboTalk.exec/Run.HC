// Narrator text to speech program

U8 *n_buffer=CAlloc(1024);

EAudioStream *snd_speech = CAlloc(sizeof(EAudioStream));
snd_speech->rate = 48000;
snd_speech->bits = 16;
snd_speech->channels = 2;

U64 flags;
ETask *my_task=EWMGetTask(Fs);
my_task->title = "RoboTalk";
my_task->icon = LoadPNG("icon_16.png");

my_task->menu->selected=-1;
my_task->menu->items=CAlloc(sizeof(U64)*3);
my_task->menu->items[0]=CAlloc(sizeof(EMenuItem));
my_task->menu->items[1]=CAlloc(sizeof(EMenuItem));
my_task->menu->items[2]=CAlloc(sizeof(EMenuItem));

my_task->menu->items[0]->id = 1;
my_task->menu->items[0]->text = "File";
my_task->menu->items[1]->id = 2;
my_task->menu->items[1]->text = "Edit";
my_task->menu->items[2]->id = 3;
my_task->menu->items[2]->text = "Help";

my_task->menu->size = 3;

EContextMenu *file_menu = EWMNewContextMenu;
file_menu->task=my_task;
file_menu->width=96;
EWMAddContextMenuItem(file_menu, 1, "New");
EWMAddContextMenuHorizRule(file_menu);
EWMAddContextMenuItem(file_menu, 2, "Open",, WMGR_CMD_TASK_CB);
EWMAddContextMenuItem(file_menu, 3, "Save");
EWMAddContextMenuItem(file_menu, 4, "Save As...");
my_task->menu->items[0]->menu = file_menu;

EContextMenu *edit_menu = EWMNewContextMenu;
edit_menu->task=my_task;
edit_menu->width=96;
EWMAddContextMenuItem(edit_menu, 5, "Cut");
EWMAddContextMenuItem(edit_menu, 6, "Copy");
EWMAddContextMenuItem(edit_menu, 7, "Paste");
my_task->menu->items[1]->menu = edit_menu;

EContextMenu *help_menu = EWMNewContextMenu;
help_menu->task=my_task;
help_menu->width=96;
EWMAddContextMenuItem(help_menu, 8, "About...",, WMGR_CMD_TASK_CB);
my_task->menu->items[2]->menu = help_menu;

flags = (EWIN_HAS_ICON | EWIN_HAS_TITLE | EWIN_HAS_MINBTN);
EWindow *my_win = EWMNewWindow(320, 142, 418, 120, "Narrator", flags);
EWMCenterWindow(my_win);
EWMAddWindow(my_task, my_win);
//my_win->resizable = TRUE;
my_win->icon = my_task->icon;
EWMShow(my_win);

EWidget *ctx_robot = EWMNewWidget(EWGT_CONTEXT2D, 12, 32);
ctx_robot->ctx=LoadPNG("robot.png");
EWMAddWidget(my_win, ctx_robot);

EWidget *inp_text = EWMNewWidget(EWGT_INPUT, 56, 35, 256);
EWMAddWidget(my_win, inp_text);

EWidget *btn_speak = EWMNewWidget(EWGT_BUTTON, 322, 34,,,  "Speak");
EWMAddWidget(my_win, btn_speak);
inp_text->text_action_wgt=btn_speak;

EWidget *hs_pitch = EWMNewWidget(EWGT_HSLIDER, 56, 72, 128);
EWMAddWidget(my_win, hs_pitch);
hs_pitch->x_scroll=(hs_pitch->width/2)-1;
EWidget *lbl_pitch = EWMNewWidget(EWGT_LABEL, 16, 72,64,, "Pitch");
EWMAddWidget(my_win, lbl_pitch);

EWidget *hs_speed = EWMNewWidget(EWGT_HSLIDER, 216+52, 72, 128);
EWMAddWidget(my_win, hs_speed);
hs_speed->x_scroll=(hs_speed->width/2)-1;

EWidget *lbl_speed = EWMNewWidget(EWGT_LABEL, 216+12, 72,64,, "Speed");
EWMAddWidget(my_win, lbl_speed);

EWidget *chk1 = EWMNewWidget(EWGT_CHECKBOX, 16, 94);
EWMAddWidget(my_win, chk1);

EWidget *lbl_lpfd = EWMNewWidget(EWGT_LABEL, 36, 94,192,, "Add LPF & Distortion");
EWMAddWidget(my_win, lbl_lpfd);

I64 lpf_pos;
wmgr->loading=FALSE;
EWMSetWidgetFocus(my_win, inp_text);
while (1)
{
    sam_pitch = 128-hs_pitch->x_scroll;
    sam_speed = (72*2)-(hs_speed->x_scroll);
    if (sam_pitch<10) { sam_pitch = 10; }; 

	if (btn_speak->clicked)
	{
		btn_speak->clicked=FALSE;

		MemSet(n_buffer, 0x9D, 1024);
		StrPrint(n_buffer, inp_text->text);
		n_buffer[StrLen(n_buffer)]='[';

		SAM_TextToPhonemes(n_buffer);
		SAM_SetInput(n_buffer);
		SAM_RenderSpeech;

        if (chk1->checked)
        {
            lpf_pos=0;
            U32 SmoothDataINT;
            U32 SmoothDataFP; 
            I64 FP_Shift = 2;
            I64 LOF = 8;
            while(lpf_pos<sam_audio_len*12){
                sam_audio_buf(U16*)[lpf_pos] <<= FP_Shift;
                SmoothDataFP = (SmoothDataFP<< LOF)-SmoothDataFP; 
                SmoothDataFP += sam_audio_buf(U16*)[lpf_pos];
                SmoothDataFP >>= LOF;
                SmoothDataINT = SmoothDataFP>> FP_Shift;
                sam_audio_buf(U16*)[lpf_pos]=SmoothDataINT;
                lpf_pos++;
            }
        }

		snd_speech->buf=sam_audio_buf;
		snd_speech->size=sam_audio_len*5.5;
		EWMSetAudioStream(snd_speech);
	}

	if (my_win && my_win->msg_close)
	{
		EWMDelWindow(my_win);
		my_win=NULL;
	}

	if (!my_win)
	{
		EWMDelTask(my_task);
		Exit;
	}
	Sleep(1);
}