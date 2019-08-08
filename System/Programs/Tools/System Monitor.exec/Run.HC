// Erythros System Monitor

F64 total_mem;
I64 free_mem;
U64 flags;
ETask *my_task=EWMGetTask(Fs);
my_task->title = "System Monitor";
my_task->icon = LoadPNG("/System/Media/Themes/Default/Icons/16/system_monitor.png");

EWMInitMenu(my_task, 3);

my_task->menu->items[0]->id = 1;
my_task->menu->items[0]->text = "File";
my_task->menu->items[1]->id = 2;
my_task->menu->items[1]->text = "Edit";
my_task->menu->items[2]->id = 3;
my_task->menu->items[2]->text = "Help";

flags = (EWIN_HAS_ICON | EWIN_HAS_TITLE | EWIN_HAS_MINBTN);
EWindow *my_win = EWMNewWindow(904, 142, 256, 96, "System Monitor", flags);
EWMAddWindow(my_task, my_win);
//my_win->resizable = TRUE;
my_win->icon = my_task->icon;
//EWMCenterWindow(my_win);
EWMShow(my_win);
my_win->x = display.width - my_win->width - 8;
my_win->y = 32;

EWidget *lbl_totalmem = EWMNewWidget(EWGT_LABEL, 12, 32, 192, 24);
EWMAddWidget(my_win, lbl_totalmem);

EWidget *lbl_freemem = EWMNewWidget(EWGT_LABEL, 128, 32, 192, 24);
EWMAddWidget(my_win, lbl_freemem);

EWidget *btn_dbg = EWMNewWidget(EWGT_BUTTON, 16, 56, -1);
btn_dbg->text = "Launch Debugger";
EWMAddWidget(my_win, btn_dbg);


wmgr->loading=FALSE;
while (1)
{
EWMCenterWidget(btn_dbg, my_win,,FALSE);
	if (btn_dbg->clicked)
	{
		btn_dbg->clicked=FALSE;
		Dbg;
	}
    // Update Free Memory
    total_mem = sys_code_bp->alloced_u8s;
	if (sys_data_bp)
	{
		total_mem += sys_data_bp->alloced_u8s;
	}
    StrPrint(lbl_totalmem->text, "Total Memory: %2.2f GB", total_mem/1073741824);

    free_mem = sys_code_bp->alloced_u8s-sys_code_bp->used_u8s;
	if (sys_data_bp)
	{
		free_mem += sys_data_bp->alloced_u8s-sys_data_bp->used_u8s;
	}
    //StrPrint(lbl_freemem->text,  "Free Memory:    %2.2f GB", free_mem/1073741824);
	StrPrint(lbl_freemem->text,  "Free Memory: 0x%08X", free_mem);

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

