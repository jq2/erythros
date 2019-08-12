// Erythros Terminal

#include "/System/Libraries/JUnzip";

U64 ccmd_table = Fs->hash_table;
EConReadLine *shell_rl = CAlloc(sizeof(EConReadLine));

#include "ShellCommands";
#include "Shell";

U64 flags;
ETask *my_task=EWMGetTask(Fs);
my_task->title = "Terminal";
my_task->icon = terminal_icon;

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
EWindow *my_win = EWMNewWindow(558, 218, 610, 350, "Terminal", flags);
//EWMCenterWindow(my_win);
EWMAddWindow(my_task, my_win);
my_win->resizable = TRUE;
my_win->icon = my_task->icon;
my_win->has_alpha = TRUE;
EWMShow(my_win);

EWidget *my_ctx = EWMNewWidget(EWGT_CONTEXT2D, 4, 24, 420, 240);
my_ctx->ctx = NewContext2D(display.width, display.height, display.bpp);
//Fill2D(term_ctx, 0);
EWMAddWidget(my_win, my_ctx);

EConsole *consoles_head = CAlloc(sizeof(EConsole));

EConsole *my_con = NewConsole(my_win, my_ctx);

//my_con->ch_width=160;
//my_con->ch_height=128;

AddConsole(consoles_head, my_con);

I64 key;
I64 cb_pos;
I64 cb_x, cb_y, cb_curY;
I64 cb_ch;
Bool cb_hi;

CTask *alpha_task=Spawn(&DrawConsoles, consoles_head, , 4);
CTask *shell_task=Spawn(&Shell, my_con, , 6); // we can change this, it was acting slow on same core.

my_ctx->pointer=ms_cur_input;

wmgr->loading=FALSE;
while (1)
{
    my_ctx->width = my_win->width-12;
    my_ctx->height = my_win->height-24;
    my_con->ch_width  = (my_win->width-8)/6;
    if (my_con->ch_height>(my_win->height-28)/12)
    {
        //my_con->scroll_y+=my_con->ch_height-(my_win->height-28)/12;
        //GrBlot(my_con->ch_buf, 0, -1, my_con->ch_buf);
    }
    /*
    if (my_con->ch_height<(my_win->height-28)/12)
    {
        //my_con->scroll_y-=my_con->ch_height+(my_win->height-28)/12;
        if (my_con->scroll_y<0)
        {
            my_con->scroll_y=0;
        }
    }
    */
    my_con->ch_height = (my_win->height-28)/12;

    key = wmgr->active_key;
    if (key && wmgr->active_key_tS != my_ctx->last_key_tS && wmgr->active_win==my_win && !wmgr->win_blurall && !my_win->minimized)
    {
        switch (key)
        {
            case SC_CURSOR_UP:
                ResetHilight(my_con);
                FifoU8Ins(my_con->stdin, 17);
                break;
            case SC_CURSOR_DOWN:
                ResetHilight(my_con);
                FifoU8Ins(my_con->stdin, 18);
                break;
            case SC_CURSOR_LEFT:
                ResetHilight(my_con);
                FifoU8Ins(my_con->stdin, 19);
                break;
            case SC_CURSOR_RIGHT:
                ResetHilight(my_con);
                FifoU8Ins(my_con->stdin, 20);
                break;
            case SC_BACKSPACE:
                ResetHilight(my_con);
                FifoU8Ins(my_con->stdin, 8);
                break;
            case SC_TAB:
                ResetHilight(my_con);
                FifoU8Ins(my_con->stdin, 9);
                break;
            case SC_ENTER:
                ResetHilight(my_con);
                FifoU8Ins(my_con->stdin, 10);
                break;
			case 0x02 ... 0x0D:
			case 0x10 ... 0x1B:
			case 0x1E ... 0x29:
			case 0x2B ... 0x35:
			case 0x39:
                if (!Bt(kbd.down_bitmap, SC_SHIFT))
                {
                    FifoU8Ins(my_con->stdin, NORMAL_KEY_SCAN_DECODE_TABLE(U8*)[key]);
                }
                else
                {
					if (key==0x39)
					{ // Handle TempleOS SHIFT-SPACE character.
                        ResetHilight(my_con);
						FifoU8Ins(my_con->stdin, ' ');
					}
                    
					else
					{
                        if (Bt(kbd.down_bitmap, SC_CTRL))
                        {
                            switch (key)
                            {
                                case Char2ScanCode('v'):
                                    for (cb_pos=0; cb_pos<StrLen(wmgr->text_clipboard); cb_pos++)
                                    {
                                        FifoU8Ins(my_con->stdin, wmgr->text_clipboard[cb_pos]);
                                    }
                                    break;
                                case Char2ScanCode('c'):
                                    StrPrint(wmgr->text_clipboard, "");
                                    cb_pos = 0;
                                    cb_curY = -1;
                                    for (cb_y=0; cb_y<my_con->ch_height; cb_y++)
                                    {
                                        cb_hi = FALSE;                                       
                                        for (cb_x=0; cb_x<my_con->ch_width; cb_x++)
                                        {                                            
                                            if (CharIsHilighted(my_con, my_con->scroll_x+cb_x, my_con->scroll_y+cb_y))
                                            {                                            
                                                if (!cb_hi) 
                                                {
                                                    if (cb_curY != -1)
                                                    {
                                                        wmgr->text_clipboard[cb_pos] = 10;
                                                        cb_pos++;
                                                    }
                                                    cb_hi = TRUE;
                                                    cb_curY = cb_y;
                                                }
                                                cb_ch = GrPeek(my_con->ch_buf, my_con->scroll_x+cb_x, my_con->scroll_y+cb_y);
                                                if (cb_ch<10)
                                                {
                                                    cb_ch = 32;
                                                }
                                                wmgr->text_clipboard[cb_pos] = cb_ch;
                                                cb_pos++;
                                            }
                                        }
                                    }
                                    wmgr->text_clipboard[cb_pos] = NULL;
                                    vbox_clip_SendToHost = TRUE;
                                    break;
                                default:
                                    break;
                            }
                        }
                        else
                        {
                            ResetHilight(my_con);
                            FifoU8Ins(my_con->stdin, SHIFT_KEY_SCAN_DECODE_TABLE(U8*)[key]);            
                        }
					}
                }
                break;
            default:
                break;
        }
        my_ctx->last_key_tS=wmgr->active_key_tS;
    }

    if (ms.lb && my_ctx->hover)
    {        
        if (!wmgr->prev_lb || wmgr->resize_win)
        {
            ResetHilight(my_con);
        }
        if (my_con->hl_x1 == -1)
        {
            if (!wmgr->drag_win)
            {
                my_con->hl_x1 = (mouse.x-(my_win->x+my_ctx->x))/6;
                my_con->hl_y1 = (mouse.y-(my_win->y+my_ctx->y))/12;
            }
        }
        else
        {
            if (!wmgr->drag_win)
            {
                my_con->hl_x2 = (mouse.x-(my_win->x+my_ctx->x))/6;
                my_con->hl_y2 = (mouse.y-(my_win->y+my_ctx->y))/12;
            }
        }
    }
    if (!ms.lb)
    {
        if (my_con->hl_x1 == my_con->hl_x2 &&
            my_con->hl_y1 == my_con->hl_y2)
        {
            ResetHilight(my_con);
        }
    }

	if (my_win && my_win->msg_close)
	{
        Kill(alpha_task);
        Kill(shell_task);
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

