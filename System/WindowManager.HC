#define BG_COL_DEFAULT        0x28609900

#define WMGR_WIN_MIN_HEIGHT     40
#define WMGR_WIN_MIN_WIDTH      180
#define WMGR_WIN_MIN_Y              24

EContext2D *tb_ctrl_power = LoadPNG("System/Media/Themes/Default/Icons/16/cog.png");

EContext2D *tb_ctrl_sound_normal = LoadPNG("System/Media/Themes/Default/Icons/16/sound.png");
EContext2D *tb_ctrl_sound_low = LoadPNG("System/Media/Themes/Default/Icons/16/sound_low.png");
EContext2D *tb_ctrl_sound_none = LoadPNG("System/Media/Themes/Default/Icons/16/sound_none.png");
EContext2D *tb_ctrl_sound_mute = LoadPNG("System/Media/Themes/Default/Icons/16/sound_mute.png");
EContext2D *tb_ctrl_sound = tb_ctrl_sound_normal;

EContext2D *tb_ctrl_net = LoadPNG("System/Media/Themes/Default/Icons/16/network_ethernet.png");

extern U0 EWMDelContextMenu(EContextMenu *cmenu);

U0 EWMDelContextMenuItem(EContextMenuItem *item)
{
	EContextMenuItem *prev=item->prev;
	EContextMenuItem *next=item->next;
	prev->next=next;
	next->prev=prev;
	if (item->submenu)
	{
		EWMDelContextMenu(item->submenu);
	}
	Free(item);
}

I64 EWMGetContextMenuLength(EContextMenu *cmenu)
{ // Get Length of All items (including horiz rules.)
	I64 len=0;
	EContextMenuItem *tmp = cmenu->items;
	while (tmp->next)
	{
		len++;
		tmp=tmp->next;
	}
	return len;
}

I64 EWMGetContextMenuHeight(EContextMenu *cmenu)
{
	I64 height=6;
	EContextMenuItem *tmp = cmenu->items;
	while (tmp->next)
	{
		if (tmp->id == WMGR_CMENU_HRZ_RULE)
		{
			height += 4;
		}
		else
		{
			height += 24;
		}
		tmp=tmp->next;
	}
	return height;
}

U0 EWMDelContextMenu(EContextMenu *cmenu)
{
	while (cmenu->items->next)
	{
		EWMDelContextMenuItem(cmenu->items->next);
	}
	Free(cmenu->items);
	Free(cmenu);
}

EContextMenu *EWMNewContextMenu()
{ // Initialize empty context menu.
	EContextMenu *cmenu=CAlloc(sizeof(EContextMenu));
	cmenu->items=CAlloc(sizeof(EContextMenuItem));
	cmenu->hover=-1;
	cmenu->selected=-1;
	return cmenu;
}

EContextMenuItem *EWMAddContextMenuItem(EContextMenu *cmenu, I64 id, U8 *text, EContextMenu *menu=NULL, U64 callback=NULL, U8 *path=NULL)
{
	EContextMenuItem *tmp = cmenu->items;
	EContextMenuItem *new=CAlloc(sizeof(EContextMenuItem));
	while (tmp->next)
	{
		tmp=tmp->next;
	}
	new->id=id;
	new->text=text;
	new->wmgr_callback=callback;
	new->path=path;
	tmp->next=new;
	new->prev=tmp;
	return new;
}

U0 EWMAddContextMenuHorizRule(EContextMenu *cmenu)
{
	EWMAddContextMenuItem(cmenu, WMGR_CMENU_HRZ_RULE, "");
}

U0 EWMNewMenu(ETask *task)
{ // Initialize empty menu for task.
	task->menu=CAlloc(sizeof(EMenu));
	task->menu->hover=-1;
	task->menu->selected=-1;
}

U0 EWMNewTask(U8 *exec_path)
{ // Add task to end of linked list.
	wmgr->loading=TRUE;
	U8 *exec_full_path=CAlloc(1024);
	StrPrint(exec_full_path, "%s/Run.HC", exec_path);
	if (!FileFind(exec_full_path))
	{
		return;
	}
	ETask *task = CAlloc(sizeof(ETask));
	ETask *tmp = wmgr->tasks;
	while (tmp->next)
	{
		tmp=tmp->next;
	}
	tmp->next=task;
	task->prev=tmp;
	EWMNewMenu(task);
	task->tos_task=User("Cd(\"%s\");\n#include \"Run\";\n", exec_path);
	Free(exec_full_path);
}

U0 EWMDelTask(ETask *task)
{ // Delete task without cleanup.
	ETask *prev=task->prev;
	ETask *next=task->next;
	prev->next=next;
	next->prev=prev;
	Kill(task->tos_task);
	Free(task);
}

U0 EWMHide(EWindow *win)
{
	if (win)
	{
		win->visible = FALSE;
	}
}

U0 EWMShow(EWindow *win)
{
	if (win)
	{
		win->visible = TRUE;
	}
}

ETask *EWMGetTask(U64 tos_task)
{
	ETask *tmp = wmgr->tasks->next;
	while (tmp)
	{
		if (tmp->tos_task==tos_task)
		{
			return tmp;
		}
		tmp=tmp->next;
	}
	return NULL;
}

U0 EWMAddWindow(ETask *task, EWindow *win)
{ // Add window to end of linked list.
	win->parent_task=task;
	EWindow *tmp = wmgr->windows;
	while (tmp->next)
	{
		tmp=tmp->next;
	}
	tmp->next=win;
	win->prev=tmp;
	wmgr->win_blurall=FALSE;
	//wmgr->refresh_taskmenu=TRUE;
}

U0 EWMDelWidget(EWidget *wgt)
{
	EWidget *prev=wgt->prev;
	EWidget *next=wgt->next;
	prev->next=next;
	next->prev=prev;
	MemSet(wgt, 0, sizeof(EWidget));
	Free(wgt);
}

U0 EWMAddWidget(EWindow *win, EWidget *wgt)
{ // Add widget to end of linked list.
	EWidget *tmp = win->widgets;
	while (tmp->next)
	{
		tmp=tmp->next;
	}
	tmp->next=wgt;
	wgt->prev=tmp;
}

U0 EWMUpdateOFSDirTree(EWindow *win, U8 *str)
{
	I64 i;
	EWidget *wgt=win->widgets->next;
	for (i=0; i<7; i++)
	{
		wgt=wgt->next;
	}
	StrPrint(wgt->text, str);
	wgt=wgt->next;
	wgt->x_scroll=0;
	wgt->refresh=TRUE;
	wgt=wgt->next;
	wgt->x_scroll=0;
}

EWindow *EWMOpenDialog(ETask *task, U8 *title="Open File", U8 *fmask="All files (*.*)|*.*")
{ // Create Open File dialog for task.

	EWindow *tmp_w = EWMNewWindow(-1, -1, 470, 320, CAlloc(1024), EWIN_HAS_TITLE);
	//tmp_w->modal = TRUE;
	EWMShow(tmp_w);
	EWMCenterWindow(tmp_w);
	StrPrint(tmp_w->title, title);

	EWidget *open_btn = EWMNewWidget(EWGT_BUTTON, tmp_w->width-112, tmp_w->height-70, 96,, "Open");
	EWMAddWidget(tmp_w, open_btn);
	EWidget *cancel_btn = EWMNewWidget(EWGT_BUTTON, tmp_w->width-112, tmp_w->height-44, 96,, "Cancel");
	EWMAddWidget(tmp_w, cancel_btn);

	EWidget *fn_label = EWMNewWidget(EWGT_LABEL, 16, tmp_w->height-67, 192, 28, "File name:");
	EWMAddWidget(tmp_w, fn_label);
	EWidget *ft_label = EWMNewWidget(EWGT_LABEL, 16, tmp_w->height-41, 192, 28, "File type:");
	EWMAddWidget(tmp_w, ft_label);

	EWidget *fn_input = EWMNewWidget(EWGT_INPUT, 88, tmp_w->height-69, tmp_w->width-228,, "");
	fn_input->text_action_wgt = open_btn;
	EWMAddWidget(tmp_w, fn_input);

	EWidget *ft_dropdown = EWMNewWidget(EWGT_DROPDOWN, 88, tmp_w->height-42, tmp_w->width-228,, fmask);
	EWMAddWidget(tmp_w, ft_dropdown);

	EWidget *dn_label = EWMNewWidget(EWGT_LABEL, 16, 40, 192, 28, "Look in:");
	EWMAddWidget(tmp_w, dn_label);
	EWidget *dn_dropdown = EWMNewWidget(EWGT_DROPDOWN, 88, 38, tmp_w->width-228);
	EWMAddWidget(tmp_w, dn_dropdown);

	EWidget *fp_filepicker = EWMNewWidget(EWGT_FILEPICKER, 16, 66, tmp_w->width-32, tmp_w->height-148);
	fp_filepicker->text_action_wgt = fn_input;
	fp_filepicker->dbl_click_wgt = open_btn;
	EWMAddWidget(tmp_w, fp_filepicker);

	EWidget *fp_hscroll = EWMNewWidget(EWGT_HSCROLLBAR, -1, -1, -1, -1);
	fp_hscroll->parent_wgt = fp_filepicker;
	EWMAddWidget(tmp_w, fp_hscroll);

	StrPrint(ofs_dirsel, "*:%s|1", task->tos_task->cur_dir);
	ofs_dirsel[0]=Fs->cur_dv->drv_let;
	EWMUpdateOFSDirTree(tmp_w, ofs_dirsel);

	EWMAddWindow(task, tmp_w);
	return tmp_w;
}

U0 EWMSetOFSFileOptions(EWindow *win, EContextMenu *cmenu)
{
	win->widgets->next->next->next->next->next->next->context_menu = cmenu;
}

U8 *EWMGetOFSTextTarget(EWindow *win)
{
	return win->widgets->next->next->next->next->next->text;
}

U0 EWMSetWidgetFocus(EWindow *win, EWidget *wgt)
{
	EWidget *tmp=win->widgets->next;
	while (tmp)
	{
		if (tmp==wgt)
		{
			tmp->focused=TRUE;
		}
		else
		{
			tmp->focused=FALSE;
		}
		tmp=tmp->next;
	}
}

U0 EWMFreeWindow(EWindow *win)
{
	EWidget *tmp=win->widgets->next;
	while (tmp)
	{
		EWMDelWidget(tmp);
		tmp=tmp->next;
	}
	if (win->ctx)
	{
		DelContext2D(win->ctx);
	}
	//Free(win->title);
	MemSet(win, 0, sizeof(EWindow));
	Free(win);
}

U0 EWMSetActiveWindow(EWindow *win)
{
	win->visible=TRUE;
	wmgr->win_blurall=FALSE;
	wmgr->show_taskmenu = FALSE;
	wmgr->refresh_taskmenu=TRUE;
	if (win==wmgr->active_win)
	{
		return;
	}
	EWindow *prev=win->prev;
	EWindow *next=win->next;
	prev->next=next;
	next->prev=prev;
	//EWindow *loop_win = wmgr->windows->next;
	EWindow *loop_win = wmgr->windows;//Fixes page fault when only 1 window in list.
	while (loop_win->next)
	{
		loop_win = loop_win->next;
	}
	loop_win->next = win;
	win->prev = loop_win;
	win->next = NULL;
	wmgr->active_win=win;
}

I64 EWMGetWindowIndex(ETask *task, EWindow *win)
{ // Get numeric id of window, excluding modals.
	I64 i=0;
	EWindow *tmp = wmgr->windows->next;
	while (tmp)
	{
		if (tmp==win && !tmp->modal)
		{
			return i;
		}
		i++;
		tmp = tmp->next;
	}
	return -1;
}

U0 EWMFocusWindowByIndex(ETask *task, I64 index)
{ // Focus window by numeric id, excluding modals.
	I64 i=0;
	EWindow *tmp = wmgr->windows->next;
	while (tmp)
	{
		if (tmp->parent_task==task && !tmp->modal)
		{
			i++;
		}
		if (i==index)
		{
			EWMSetActiveWindow(tmp);
			break;
		}
		tmp = tmp->next;
	}
	wmgr->win_blurall=FALSE;
	wmgr->show_taskmenu=FALSE;
}

U0 EWMDelWindow(EWindow *win)
{ // Delete window from linked list.
	if (win==wmgr->active_win)
	{
		wmgr->active_win=NULL;
	}
	EWindow *prev=win->prev;
	EWindow *next=win->next;
	prev->next=next;
	next->prev=prev;
	EWMFreeWindow(win);
	wmgr->win_blurall=TRUE;
	wmgr->show_taskmenu=FALSE;
	//wmgr->refresh_taskmenu=TRUE;
}


U0 AddConsole(EConsole *consoles, EConsole *con)
{
	if (!consoles)
	{
		return;
	}
	while (consoles->next)
	{
		consoles=consoles->next;
	}
	consoles->next=con;
}


U0 DelConsole(EConsole *con)
{
	EConsole *prev=con->prev;
	EConsole *next=con->next;
	prev->next=next;
	next->prev=prev;
	con->win=NULL;
	if (con->ch_buf) { DCDel(con->ch_buf); };
	if (con->fg_buf) { Free(con->fg_buf); };
	if (con->bg_buf) { Free(con->bg_buf); };
	if (con->stdin) { FifoU8Del(con->stdin); };
	if (con->stdout) { FifoU8Del(con->stdout); };
	if (con->stderr) { FifoU8Del(con->stderr); };
	Free(con);
}

EConsole *NewConsole(EWindow *win, EWidget *wgt)
{
	I64 _i;

	EConsole *con=CAlloc(sizeof(EConsole));
	
	con->win=win;
	con->wgt=wgt;
	
	con->ch_buf=DCNew(display.width, 1024);
	con->fg_buf=CAlloc(display.width*1024);
	con->bg_buf=CAlloc(display.width*1024);
	con->fg_color=0xFFFFFF00;
	con->bg_color=0;
	con->bg_hilight=0xBBB9D500;
	con->fg_hilight=0;
	DCFill(con->ch_buf, 0);
	for (_i=0;_i<display.width*128;_i++)
	{
		con->fg_buf[_i]=0xFFFFFF00;
		con->bg_buf[_i]=0x00000000;
	}
	
	con->stdin=FifoU8New(1024);
	con->stdout=FifoU8New(1024);
	con->stderr=FifoU8New(1024);

	con->hl_x1=-1;
	con->hl_x2=-1;
	con->hl_y1=-1;
	con->hl_y2=-1;
	
	return con;
}

U0 EWMSetMousePointer(I64 cur=ms_cur_default)
{ // Set the on-screen mouse pointer.
	wmgr->pointer = cur;
	switch (cur)
	{
		case ms_cur_input:
			wmgr->pointer_xofs = 0;
			wmgr->pointer_yofs = -6;
			break;
		default:
			wmgr->pointer_xofs = 0;
			wmgr->pointer_yofs = 0;
			break;
	}
}

U0 EWMSetWallpaper(EContext2D *ctx)
{ // Set the on-screen wallpaper.
	Blot2D(wmgr->wallpaper, (display.width/2)-(ctx->width/2), (display.height/2)-(ctx->height/2), ctx);
}

U0 EWMTextClipCopy(EWidget *wgt)
{
	if (wgt->sel_start>-1)
	{
		MemCpy(wmgr->text_clipboard, wgt->text+wgt->sel_start, wgt->sel_end-wgt->sel_start);
		MemSet(wmgr->text_clipboard + wgt->sel_end-wgt->sel_start, 0, 1);
		vbox_clip_SendToHost = TRUE;
	}
}

U0 EWMTextClipPaste(EWidget *wgt)
{
	U8 *tmp=CAlloc(StrLen(wgt->text)+StrLen(wmgr->text_clipboard));
	if (wgt->sel_start>-1)
	{
		wgt->text_pos=wgt->sel_start;
		StrPrint(tmp, wgt->text+wgt->sel_end);
		StrPrint(wgt->text+wgt->sel_start, wmgr->text_clipboard);
		StrPrint(wgt->text+wgt->sel_start+StrLen(wmgr->text_clipboard), tmp);
		wgt->text_pos+=StrLen(wmgr->text_clipboard);
		wgt->sel_start=-1;
		wgt->sel_end=-1;
	}
	else
	{
		StrPrint(tmp, wgt->text+wgt->text_pos);
		StrPrint(wgt->text+wgt->text_pos, wmgr->text_clipboard);
		StrPrint(wgt->text+wgt->text_pos+StrLen(wmgr->text_clipboard), tmp);
		wgt->text_pos+=StrLen(wmgr->text_clipboard);
	}
	Free(tmp);
}

U0 EWMTextClipCut(EWidget *wgt)
{
	if (wgt->sel_start>-1)
	{
		MemCpy(wmgr->text_clipboard, wgt->text+wgt->sel_start, wgt->sel_end-wgt->sel_start);
		MemSet(wmgr->text_clipboard + wgt->sel_end-wgt->sel_start, 0, 1);
		StrPrint(wgt->text+wgt->sel_start, wgt->text+wgt->sel_end);
		wgt->text_pos=wgt->sel_start;
		wgt->sel_start=-1;
		wgt->sel_end=-1;
		vbox_clip_SendToHost = TRUE;
	}
}

U0 EWMCallback(U64 cmd, I64 id, ETask *task, U8 *path=NULL)
{
	if (!cmd || !task)
	{
		task->menu->selected=-1;
		task->menu->hover=-1;
		wmgr->hover_cmenu=-1;
		return;
	}
	switch (cmd)
	{
	case WMGR_CMD_SEL_WIN:
		wmgr->show_taskmenu=FALSE;
		EWMFocusWindowByIndex(task, id);
		break;
	case WMGR_CMD_BLUR_ALL:
		wmgr->show_taskmenu=FALSE;
		wmgr->win_blurall=TRUE;
		break;
	case WMGR_CMD_TASK_CB:
		task->menu_cb = id;
		break;
	case WMGR_OPEN_SEL_CB:
		task->fp_mask = path;
		break;
	case WMGR_CMD_RUN_PROG:
		wmgr->show_taskmenu=FALSE;
		if (path)
		{
			EWMNewTask(path);
		}
		break;
	default:
		break;
	}
	task->menu->selected=-1;
	task->menu->hover=-1;
	wmgr->hover_cmenu=-1;
}

U0 EWMInit()
{ // Init window manager defaults.
	wmgr = CAlloc(sizeof(EWindowManager));
	wmgr->session = CAlloc(sizeof(ESession));
	wmgr->tasks = CAlloc(sizeof(ETask));
	wmgr->windows = CAlloc(sizeof(EWindow));
	wmgr->context_menus = CAlloc(sizeof(EContextMenu));
	wmgr->active = TRUE;
	wmgr->ctx = NewContext2D(display.width, display.height, display.bpp);
	wmgr->wallpaper = NewContext2D(display.width, display.height, display.bpp);
	wmgr->hover_cmenu=-1;
	wmgr->refresh_taskmenu=TRUE;
	wmgr->text_clipboard = CAlloc(WMGR_TEXT_CLIPBOARD_SIZE); // 4MB clipboard for text, should be fine for now
	wmgr->utf16_clipboard = CAllocAligned(WMGR_UTF16_CLIPBOARD_SIZE, 16, Fs->code_heap);
	//EWMSetMousePointer;
	Fill2D(wmgr->wallpaper, BG_COL_DEFAULT);
}

EWMInit;

U0 EWMInitMenu(ETask *task, I64 size)
{
	I64 i;
	task->menu->selected=-1;
	task->menu->items=CAlloc(sizeof(U64)*size);
	for (i=0; i<size; i++)
	{
		task->menu->items[i]=CAlloc(sizeof(EMenuItem));
	}
	task->menu->size = size;
}

// Menu Bar is a "special" EWindow
U64 menu_flags = (EWIN_IS_MENUBAR | EWIN_HAS_ICON);
EWindow *menu_bar = EWMNewWindow(-1, -1, display.width+2, 26, "", menu_flags);
EWMShow(menu_bar);

EWidget *menu_clock = EWMNewWidget(EWGT_LABEL, menu_bar->width-48, 7, 192,28, "TEST");
menu_clock->font = FONT_WINTITLE16;
EWMAddWidget(menu_bar, menu_clock);

EWidget *task_box = EWMNewWidget(EWGT_TASKBOX, 4, 4, display.width);
task_box->font = FONT_WINTITLE16;
EWMAddWidget(menu_bar, task_box);

EWidget *ctl_power = EWMNewWidget(EWGT_CONTEXT2D, display.width-18, 5);
ctl_power->ctx = tb_ctrl_power;
EWMAddWidget(menu_bar, ctl_power);

EWidget *ctl_sound = EWMNewWidget(EWGT_CONTEXT2D, display.width-116, 5);
ctl_sound->ctx = tb_ctrl_sound;
EWMAddWidget(menu_bar, ctl_sound);

EWidget *ctl_net = EWMNewWidget(EWGT_CONTEXT2D, display.width-116-24, 5);
ctl_net->ctx = tb_ctrl_net;
EWMAddWidget(menu_bar, ctl_net);


U0 EWMUpdateMenuBarClock(CDateStruct *ds)
{
	EContext2D *text_ctx=null_context;
	switch (ds->hour)
	{
	case 0:
		StrPrint(menu_clock->text, "%2d:%02d AM", ds->hour+12, ds->min);
		break;
	case 13 ... 23:
		StrPrint(menu_clock->text, "%2d:%02d PM", ds->hour-12, ds->min);
		break;
	default:
		StrPrint(menu_clock->text, "%2d:%02d AM", ds->hour, ds->min);
		break;
	}
	I64 text_width = Bitmap16Print2D(text_ctx, 0, 0, BLACK, FONT_WINTITLE16, menu_clock->text);
	menu_clock->x = menu_bar->width-32-text_width;
}

U0 EWMDrawDesktopSelect()
{
	U32 color;
	I64 x1 = Min(wmgr->desktop_sel_x1, mouse.x);
	I64 y1 = Min(wmgr->desktop_sel_y1, mouse.y);
	I64 x2 = Max(wmgr->desktop_sel_x1, mouse.x);
	I64 y2 = Max(wmgr->desktop_sel_y1, mouse.y);
	I64 xx,yy;

	/*
	if (wmgr->desktop_sel_old_x1 != x1 || wmgr->desktop_sel_old_y1 != y1 ||
		wmgr->desktop_sel_old_x2 != x2 || wmgr->desktop_sel_old_y2 != y2)
	*/
	if (1)
	{
		yy=0;
		while (y1+yy<y2)
		{
			xx=0;
			while (x1+xx<x2)
			{ // Highlight blue-tint for select rect on desktop
				color = Peek2D(wmgr->ctx, x1+xx, y1+yy);
				color.u8[1] = Min(color.u8[1] + 0x40, 0xFF);
				color.u8[3] = Max(color.u8[3] - 0x20, 0x0);
				Plot2D(wmgr->ctx, x1+xx, y1+yy, color);
				xx++;
			}
			yy++;
		}
	}

	HLine2D(wmgr->ctx, Min(wmgr->desktop_sel_x1, mouse.x), Min(wmgr->desktop_sel_y1, mouse.y),
		Max(wmgr->desktop_sel_x1, mouse.x), 0xBBB9D500);
	HLine2D(wmgr->ctx, Min(wmgr->desktop_sel_x1, mouse.x), Max(wmgr->desktop_sel_y1, mouse.y),
		Max(wmgr->desktop_sel_x1, mouse.x), 0xBBB9D500);
	VLine2D(wmgr->ctx, Min(wmgr->desktop_sel_x1, mouse.x), Min(wmgr->desktop_sel_y1, mouse.y),
		Max(wmgr->desktop_sel_y1, mouse.y), 0xBBB9D500);
	VLine2D(wmgr->ctx, Max(wmgr->desktop_sel_x1, mouse.x), Min(wmgr->desktop_sel_y1, mouse.y),
		Max(wmgr->desktop_sel_y1, mouse.y), 0xBBB9D500);

	wmgr->desktop_sel_old_x1 = x1;
	wmgr->desktop_sel_old_y1 = y1;
	wmgr->desktop_sel_old_x2 = x2;
	wmgr->desktop_sel_old_y2 = y2;
}

ETask *task_menu_task=CAlloc(sizeof(ETask));

U0 EWMTask()
{ // Main Window Manager task.
	CDateStruct cur_ds;
	EContextMenu *task_menu=NULL;
	EContextMenu *add_menu[8];
	EContextMenu *z_menu;
	EContextMenuItem *add_item[8];

	ETask *wm_active_task;
	EMenu *wm_active_menu;

	EWindow *add_win;
	ETask *tmp_task;
	U8 *tmp_str=CAlloc(1024);
	CDirEntry *tm_de[16];
	U8 *tm_de_str=CAlloc(256);
	EWindow *cur_win;
	EWidget *cur_wgt;
	EContextMenu *cur_cmenu;
	EWindow *active_win=NULL;
	EWindow *z_win;
	I64 awin_title_xofs;
	I64 awin_title_len;
	I64 i,j,k;

	// Startup tasks:
	EWMNewTask("T:/System/Programs/Tools/System Monitor.exec");
	Spawn(&Netcfg,,,5);
	
	while (1) //The ride never ends...
	{
		EWMSetMousePointer;
		Date2Struct(&cur_ds, Now);
		EWMUpdateMenuBarClock(&cur_ds);

		if (!wmgr->active)
		{
			goto wmgr_inactive;
		}

		if (!mouse.lb && wmgr->desktop_select)
		{ 
			wmgr->desktop_sel_x2=mouse.x;
			wmgr->desktop_sel_y2=mouse.y;
			wmgr->desktop_select=FALSE;
		}

		// Draw Wallpaper.
		MemCpy(wmgr->ctx->fb, wmgr->wallpaper->fb, (display.width*display.height)*display.bpp/8);

		// If modal exists, set active window
		z_win = wmgr->windows->next;
		while (z_win)
		{
			if (z_win->modal && z_win->visible)
			{
				EWMSetActiveWindow(z_win);
			}
			z_win = z_win->next;
		}

		// Get active window
		active_win = wmgr->windows->next;
		while (active_win)
		{
			if (!active_win->next)
			{
				wmgr->active_win = active_win;
			}
			active_win = active_win->next;
		}
		active_win = wmgr->active_win;

		if (!active_win)
		{
			wmgr->win_blurall = TRUE;
		}

		// TODO: detect if we are hovering a context menu
		if (mouse.lb && !wmgr->prev_lb && active_win)
		{
			wm_active_task = active_win->parent_task;
			wm_active_menu = wm_active_task->menu;
			if (wm_active_menu)
			{
				if (wm_active_menu->hover)
				{
				}
			}
		}

		// Handle Window hotkeys
		if (active_win && !wmgr->win_blurall)
		{
			if (KeyDown(SC_ALT) && KeyDown(SC_F4))
			{
				active_win->msg_close=TRUE;
				wmgr->win_blurall = TRUE;
			}
			if (KeyDown(SC_CTRL) && KeyDown(Char2ScanCode('w')))
			{
				active_win->msg_close=TRUE;
			}
		}

		// Unblur if desktop focused
		if (mouse.lb && !wmgr->prev_lb && active_win && wmgr->hover_cmenu<0)
		{
			if (
			        (mouse.x > active_win->x && mouse.x < active_win->x + active_win->width) &&
			        (mouse.y > active_win->y && mouse.y < active_win->y + active_win->height) &&
			        active_win->visible
			        )
			{
				if (!wmgr->win_blurall)
				{
					// Get top widget
					cur_wgt = active_win->widgets->next;
					while (cur_wgt->next && cur_wgt)
					{
						cur_wgt = cur_wgt->next;
					}

					while (cur_wgt->prev && cur_wgt)
					{ // Handle widget clicked.
						if (
						        (mouse.x > active_win->x+cur_wgt->x && mouse.x < active_win->x+cur_wgt->x+cur_wgt->width) &&
						        (mouse.y > active_win->y+cur_wgt->y && mouse.y < active_win->y+cur_wgt->y+cur_wgt->height)
						        )
						{
							cur_wgt->active = TRUE;
							break;
						}
						cur_wgt = cur_wgt->prev;
					}
					if (!cur_wgt->prev)
					{
						EWMSetWidgetFocus(active_win, NULL);
					}
				}
				if (active_win->parent_task->menu->selected>-1)
				{
					if (mouse.y > WMGR_WIN_MIN_Y) // TODO: && not hovering a dropdown menu
					{
						active_win->parent_task->menu->selected=-1;

					}
				}
				wmgr->win_blurall = FALSE;
			}
		}

		if (!wmgr->win_blurall)
		{
			wmgr->show_taskmenu=FALSE;
			task_menu->submenu=NULL;
		}

		// Handle widget hover.
		if (!wmgr->win_blurall && active_win && wmgr->hover_cmenu<0)
		{
			// Get top widget
			cur_wgt = active_win->widgets->next;
			while (cur_wgt->next && cur_wgt)
			{
				cur_wgt->hover=FALSE;
				cur_wgt = cur_wgt->next;
			}
			cur_wgt->hover=FALSE;
			while (cur_wgt->prev && cur_wgt)
			{
				if (
				        (mouse.x > active_win->x+cur_wgt->x && mouse.x < active_win->x+cur_wgt->x+cur_wgt->width) &&
				        (mouse.y > active_win->y+cur_wgt->y && mouse.y < active_win->y+cur_wgt->y+cur_wgt->height)
				        )
				{
					cur_wgt->hover = TRUE;
					if (cur_wgt->pointer)
					{
						EWMSetMousePointer(cur_wgt->pointer);
					}
					break;
				}
				cur_wgt = cur_wgt->prev;
			}
		}

		// Handle resizing
		if (mouse.lb && !wmgr->prev_lb && active_win && wmgr->hover_cmenu<0)
		{
			if (active_win->resizable &&
			    mouse.x > active_win->x + active_win->width - 16 &&
			    mouse.x < active_win->x + active_win->width &&
			    mouse.y > active_win->y + active_win->height - 16 &&
			    mouse.y < active_win->y + active_win->height)
			{
				wmgr->orig_win_xw = active_win->width;
				wmgr->orig_win_yh = active_win->height;
				wmgr->orig_ms_x = mouse.x;
				wmgr->orig_ms_y = mouse.y;
				wmgr->resize_win = TRUE;
				wmgr->win_blurall = FALSE;
			}
		}
		if (!mouse.lb)
		{
			wmgr->resize_win = FALSE;
		}

		if (wmgr->resize_win)
		{
			active_win->width = wmgr->orig_win_xw + (mouse.x - wmgr->orig_ms_x);
			active_win->height = wmgr->orig_win_yh + (mouse.y - wmgr->orig_ms_y);
		}

		// Handle dragging
		if (mouse.lb && !wmgr->prev_lb && active_win && wmgr->hover_cmenu<0 && !wmgr->context_menu)
		{
			awin_title_xofs = 4;
			if (active_win->has_icon)
			{
				awin_title_xofs += 20;
			}
			awin_title_len = active_win->width - 30;

			if (active_win->has_icon)
			{
				awin_title_len -= 20;
			}
			if (active_win->has_maxbtn)
			{
				awin_title_len -= 20;
			}
			if (active_win->has_minbtn)
			{
				awin_title_len -= 20;
			}

			if (active_win->has_title &&
			    mouse.x > active_win->x + awin_title_xofs &&
			    mouse.x < active_win->x + awin_title_xofs + awin_title_len &&
			    mouse.y > active_win->y &&
			    mouse.y < active_win->y + 18)
			{
				wmgr->orig_win_xw = active_win->x;
				wmgr->orig_win_yh = active_win->y;
				wmgr->orig_ms_x = mouse.x;
				wmgr->orig_ms_y = mouse.y;
				wmgr->drag_win = TRUE;
				wmgr->win_blurall = FALSE;
			}

			if (mouse.x > active_win->x+active_win->width-21 &&
			    mouse.x < active_win->x+active_win->width-5 &&
			    mouse.y > active_win->y+5 &&
			    mouse.y < active_win->y+21)
			{
				active_win->click_close=TRUE;
				active_win->tgt_close=TRUE;
			}
			else
			{
				active_win->click_close=FALSE;
			}

			if (active_win->has_minbtn)
			{
				if (mouse.x > active_win->x+active_win->width-41 &&
				    mouse.x < active_win->x+active_win->width-25 &&
				    mouse.y > active_win->y+5 &&
				    mouse.y < active_win->y+21)
				{
					active_win->click_minbtn=TRUE;
					active_win->tgt_minbtn=TRUE;
				}
				else
				{
					active_win->click_minbtn=FALSE;
				}
			}
		}
		if (!mouse.lb)
		{
			wmgr->drag_win = FALSE;
		}

		if (mouse.lb && wmgr->prev_lb && wmgr->hover_cmenu<0)
		{
			if (mouse.x > active_win->x+active_win->width-21 &&
			    mouse.x < active_win->x+active_win->width-5 &&
			    mouse.y > active_win->y+5 &&
			    mouse.y < active_win->y+21)
			{
				active_win->click_close=TRUE;
			}
			else
			{
				active_win->click_close=FALSE;
			}
			if (active_win->has_minbtn)
			{
				if (mouse.x > active_win->x+active_win->width-41 &&
				    mouse.x < active_win->x+active_win->width-25 &&
				    mouse.y > active_win->y+5 &&
				    mouse.y < active_win->y+21)
				{
					active_win->click_minbtn=TRUE;
				}
				else
				{
					active_win->click_minbtn=FALSE;
				}
			}
		}

		if (!mouse.lb && wmgr->prev_lb && active_win && wmgr->hover_cmenu<0)
		{
			if (mouse.x > active_win->x+active_win->width-21 &&
			    mouse.x < active_win->x+active_win->width-5 &&
			    mouse.y > active_win->y+5 &&
			    mouse.y < active_win->y+21 &&
			    active_win->tgt_close)
			{
				active_win->msg_close=TRUE; //notify program of intent to close window
			}
			active_win->click_close=FALSE;
			active_win->tgt_close=FALSE;

			if (active_win->has_minbtn)
			{
				if (mouse.x > active_win->x+active_win->width-41 &&
				    mouse.x < active_win->x+active_win->width-25 &&
				    mouse.y > active_win->y+5 &&
				    mouse.y < active_win->y+21)
				{
					EWMHide(active_win);
				}
				active_win->click_minbtn=FALSE;
				active_win->tgt_minbtn=FALSE;
			}
		}

		if (wmgr->drag_win && active_win && wmgr->hover_cmenu<0)
		{
			active_win->x = wmgr->orig_win_xw + (mouse.x - wmgr->orig_ms_x);
			active_win->y = wmgr->orig_win_yh + (mouse.y - wmgr->orig_ms_y);
		}

		// Handle select task menu
		if (mouse.lb && !wmgr->prev_lb && active_win)
		{
			if (active_win->parent_task->menu->hover>-1)
			{
				active_win->parent_task->menu->selected=active_win->parent_task->menu->hover;
			}
		}

		// Handle focus other window
		if (mouse.lb && !wmgr->prev_lb && wmgr->hover_cmenu<0 && (!active_win->modal || !wmgr->tasks->next))
		{
			if (mouse.x>0 && mouse.x<220 &&
			    mouse.y>0 && mouse.y<WMGR_WIN_MIN_Y &&
			    !wmgr->show_taskmenu)
			{
				wmgr->refresh_taskmenu=TRUE;
				wmgr->show_taskmenu=TRUE;
				wmgr->win_blurall=TRUE;
				wmgr->prev_lb=TRUE;
			}
		}

		if (mouse.lb && !wmgr->prev_lb && active_win && wmgr->hover_cmenu<0 && !(active_win->modal && active_win->visible))
		{
			/*
			if (mouse.x>0 && mouse.x<220 &&
			    mouse.y>0 && mouse.y<WMGR_WIN_MIN_Y &&
			    !wmgr->show_taskmenu)
			{
				wmgr->show_taskmenu=TRUE;
			}
			*/

			if (
			        ((mouse.x < active_win->x || mouse.x > active_win->x + active_win->width) ||
			         (mouse.y < active_win->y || mouse.y > active_win->y + active_win->height)
			        ) || active_win->modal || !active_win->visible)
			{
				z_win = active_win->prev;
				while (z_win)
				{
					if (
					        mouse.x > z_win->x && mouse.x < z_win->x + z_win->width &&
					        mouse.y > z_win->y && mouse.y < z_win->y + z_win->height &&
					        !z_win->modal &&
					        z_win->visible
					        )

					{
						wmgr->win_blurall = FALSE;
						EWMSetActiveWindow(z_win);
						break;
					}
					z_win = z_win->prev;
				}
				if (!z_win && active_win->parent_task->menu->selected<0)
				{
					wmgr->win_blurall = TRUE;
				}
				if (!z_win && active_win->parent_task->menu->selected>-1)
				{

					if (mouse.y > WMGR_WIN_MIN_Y) // TODO: && not hovering a dropdown menu
					{
						active_win->parent_task->menu->selected=-1;
						wmgr->win_blurall = TRUE;
					}

					if (active_win->parent_task->menu->hover<0)
					{
						active_win->parent_task->menu->selected=-1;
					}
				}
			}
		}

		if (mouse.lb && !wmgr->prev_lb && wmgr->win_blurall && mouse.y>WMGR_WIN_MIN_Y && !wmgr->desktop_select &&
			!wmgr->show_taskmenu && !wmgr->context_menu)
		{
			wmgr->desktop_sel_x1=mouse.x;
			wmgr->desktop_sel_y1=mouse.y;
			wmgr->desktop_select=TRUE;
		}

		// Draw Desktop Select range (if click-drag left button on desktop)

		if (wmgr->desktop_select)
		{
			EWMDrawDesktopSelect;
		}

		// Draw Windows
		cur_win = wmgr->windows->next;
		while (cur_win)
		{
			if (cur_win->height < WMGR_WIN_MIN_HEIGHT)
			{
				cur_win->height = WMGR_WIN_MIN_HEIGHT;
			}
			if (cur_win->width < WMGR_WIN_MIN_WIDTH)
			{
				cur_win->width = WMGR_WIN_MIN_WIDTH;
			}
			if (cur_win->y < WMGR_WIN_MIN_Y)
			{
				cur_win->y = WMGR_WIN_MIN_Y;
			}
			DrawWindow2D(wmgr->ctx, cur_win);
			if (active_win==cur_win)
			{
				task_box->text=cur_win->title;
				//task_box->ctx=default_icon;
				if (cur_win->icon)
				{
					menu_bar->icon=cur_win->icon;
				}
				else
				{
					menu_bar->icon=default_icon;
				}
			}
			cur_win->prev_width = cur_win->width;
			cur_win->prev_height = cur_win->height;
			cur_win = cur_win->next;
		}

		if (wmgr->win_blurall)
		{
			task_box->text="Desktop";
			//task_box->ctx=desktop_icon;
			menu_bar->icon=desktop_icon;			
		}
		// Draw Menu Bar.
		DrawWindow2D(wmgr->ctx, menu_bar);

		// Refresh task menu if needed.
		if (wmgr->refresh_taskmenu)
		{
			if (task_menu)
			{
				EWMDelContextMenu(task_menu);
			}
			wmgr->refresh_taskmenu=FALSE;
			i=1;
			tmp_task = wmgr->tasks->next;
			while (tmp_task)
			{
				tmp_task=tmp_task->next;
				i++;
			}
			task_menu = EWMNewContextMenu;
			task_menu->task = task_menu_task;
			task_menu->width = 218;
			add_item[0] = EWMAddContextMenuItem(task_menu, 0, "Desktop",, WMGR_CMD_BLUR_ALL);
			add_item[0]->icon = desktop_icon;
			if (wmgr->tasks->next)
			{
				EWMAddContextMenuHorizRule(task_menu);
			}
			i=1;
			tmp_task = wmgr->tasks->next;
			while (tmp_task)
			{ // Add a sub-menu with items for each task's child windows.
				add_item[0] = EWMAddContextMenuItem(task_menu, i, tmp_task->title);
				add_item[0]->icon = tmp_task->icon;
				add_menu[0] = EWMNewContextMenu; //testing
				add_menu[0]->task = tmp_task;
				add_menu[0]->is_submenu = TRUE;
				add_menu[0]->x = task_menu->x+task_menu->width-2;
				add_menu[0]->y = task_menu->y+4+(i*24);
				add_menu[0]->width = task_menu->width;
				add_win = wmgr->windows->next;
				j=1;
				while (add_win)
				{
					if (add_win->parent_task==tmp_task && !add_win->modal)
					{
						EWMAddContextMenuItem(add_menu[0], j, add_win->title,, WMGR_CMD_SEL_WIN);
						j++;
					}
					add_win=add_win->next;
				}
				add_item[0]->submenu = add_menu[0];
				tmp_task=tmp_task->next;
				i++;
			}
			// TODO: add sub-menus for launchable items (Programs, Settings, etc.)
			EWMAddContextMenuHorizRule(task_menu);
			add_item[0] = EWMAddContextMenuItem(task_menu, 0, "Programs");
			add_item[0]->icon = programs_icon;
			add_menu[0] = EWMNewContextMenu;
			add_menu[0]->task = task_menu_task;
			add_menu[0]->is_submenu = TRUE;
			add_menu[0]->selected=-1;
			add_menu[0]->hover=-1;
			add_menu[0]->x = task_menu->x+task_menu->width-2;
			add_menu[0]->y = task_menu->y+4+(i*24);
			add_menu[0]->width = task_menu->width;
			j=0;
			tm_de[1]=FilesFind("T:/System/Programs");
			tm_de[0]=tm_de[1];
			while (tm_de[0])
			{
				if (tm_de[0]->name[0]!='.' && tm_de[0]->attr & RS_ATTR_DIR == RS_ATTR_DIR)
				{
					add_item[1] = EWMAddContextMenuItem(add_menu[0], j, StrNew(tm_de[0]->name));
					
					add_menu[1] = EWMNewContextMenu;
					add_menu[1]->task = task_menu_task;
					add_menu[1]->is_submenu = TRUE;
					add_menu[1]->selected=-1;
					add_menu[1]->hover=-1;
					add_menu[1]->x = add_menu[0]->x+task_menu->width-2;
					add_menu[1]->y = add_menu[0]->y+(j*24);
					add_menu[1]->width = task_menu->width;
					StrPrint(tm_de_str,"T:/System/Programs/%s", tm_de[0]->name);
					k=1;
					tm_de[3]=FilesFind(tm_de_str);
					tm_de[2]=tm_de[3];
					while (tm_de[2])
					{
						if (tm_de[2]->name[0]!='.' && tm_de[2]->attr & RS_ATTR_DIR == RS_ATTR_DIR)
						if (2==2)
						{
							add_item[2] = EWMAddContextMenuItem(add_menu[1], k, StrNew(tm_de[2]->name),, WMGR_CMD_RUN_PROG, StrNew(tm_de[2]->full_name));
							add_item[2]->text[StrLen(add_item[2]->text)-5]=0;
						}
						k++;
						tm_de[2]=tm_de[2]->next;
					}
					DirTreeDel(tm_de[3]);
					add_item[1]->submenu = add_menu[1];					
					j++;
				}
				i++;			
				tm_de[0]=tm_de[0]->next;
			}

			DirTreeDel(tm_de[1]);
			add_item[0]->submenu = add_menu[0];
		}

		// Draw Task Menu (if active)
		if (wmgr->win_blurall && wmgr->show_taskmenu && task_menu)
		{
			DrawContextMenuExpanded2D(wmgr->ctx, task_menu);
		}

		// Draw Context Menu (if active)
		if (!wmgr->show_taskmenu && wmgr->context_menu)
		{
			DrawContextMenuExpanded2D(wmgr->ctx, wmgr->context_menu);
		}

		// Draw Mouse Pointer.
		if (wmgr->loading)
		{
			Blot2D(wmgr->ctx, mouse.x, mouse.y, ms_cur_wait[cnts.jiffies/200%8]);
		}
		else
		{
			Blot2D(wmgr->ctx, mouse.x+wmgr->pointer_xofs, mouse.y+wmgr->pointer_yofs, wmgr->pointer);
		}

		// Copy to system framebuffer.
		MemCpy(sys_fb->fb, wmgr->ctx->fb, (display.width*display.height)*display.bpp/8);

		wmgr->prev_lb = mouse.lb;
		wmgr->prev_rb = mouse.rb;
wmgr_inactive:
		text.raw_col=0;
		if (wmgr->loading)
		{
			Sleep(1);
		}
		ms.pos.z=0;
		Yield;
	}
}