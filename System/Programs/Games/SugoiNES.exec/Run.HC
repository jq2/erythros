U64 flags;
ETask *my_task=EWMGetTask(Fs);
my_task->title = "SugoiNES";
my_task->icon = LoadPNG("icon_16.png");

CDirEntry *rom_de;

U8 *my_fn=CAlloc(1024);

#define GAME_WIDTH  256
#define GAME_HEIGHT 240
I64 vid_scale = 2;

my_task->menu->selected=-1;
my_task->menu->size = 5;
my_task->menu->items=CAlloc(sizeof(U64)*my_task->menu->size);
my_task->menu->items[0]=CAlloc(sizeof(EMenuItem));
my_task->menu->items[1]=CAlloc(sizeof(EMenuItem));
my_task->menu->items[2]=CAlloc(sizeof(EMenuItem));
my_task->menu->items[3]=CAlloc(sizeof(EMenuItem));
my_task->menu->items[4]=CAlloc(sizeof(EMenuItem));

my_task->menu->items[0]->id = 1; my_task->menu->items[0]->text = "File";
my_task->menu->items[1]->id = 2; my_task->menu->items[1]->text = "Game";
my_task->menu->items[2]->id = 3; my_task->menu->items[2]->text = "Settings";
my_task->menu->items[3]->id = 4; my_task->menu->items[3]->text = "Debug";
my_task->menu->items[4]->id = 5; my_task->menu->items[4]->text = "Help";

EContextMenu *open_ctx_menu = EWMNewContextMenu;
open_ctx_menu->task=my_task;
open_ctx_menu->width=96;
EWMAddContextMenuItem(open_ctx_menu, 101, "NES ROM Files (*.nes)",, WMGR_OPEN_SEL_CB, ".nes");
EWMAddContextMenuItem(open_ctx_menu, 102, "All Files (*.*)",, WMGR_OPEN_SEL_CB);

my_task->fp_mask=".nes";

EContextMenu *file_menu = EWMNewContextMenu;
file_menu->task=my_task;
file_menu->width=96;
EWMAddContextMenuItem(file_menu, 1, "Open ROM",, WMGR_CMD_TASK_CB);
EWMAddContextMenuHorizRule(file_menu);
EWMAddContextMenuItem(file_menu, 2, "Load State",, WMGR_CMD_TASK_CB);
EWMAddContextMenuItem(file_menu, 3, "Save State",, WMGR_CMD_TASK_CB);
EWMAddContextMenuHorizRule(file_menu);
EWMAddContextMenuItem(file_menu, 4, "Close ROM",, WMGR_CMD_TASK_CB);
EWMAddContextMenuHorizRule(file_menu);
EWMAddContextMenuItem(file_menu, 5, "Exit",, WMGR_CMD_TASK_CB);
my_task->menu->items[0]->menu = file_menu;

EContextMenu *game_menu = EWMNewContextMenu;
game_menu->task=my_task;
game_menu->width=96;
EWMAddContextMenuItem(game_menu, 6, "Reset",, WMGR_CMD_TASK_CB);
my_task->menu->items[1]->menu = game_menu;

flags = (EWIN_HAS_ICON | EWIN_HAS_TITLE | EWIN_HAS_MINBTN);
EWindow *my_win = EWMNewWindow(2, 2, GAME_WIDTH+8, GAME_HEIGHT+28, CAlloc(1024), flags);
my_win->icon = my_task->icon;
StrPrint(my_win->title, "No ROM Loaded");
EWMAddWindow(my_task, my_win);

flags = (EWIN_HAS_ICON | EWIN_HAS_TITLE | EWIN_HAS_MINBTN);
EWindow *dbg_win = EWMNewWindow(2, 2, 320, 480, CAlloc(1024), flags);
dbg_win->icon = my_task->icon;
dbg_win->resizable = TRUE;
dbg_win->modal = TRUE;
StrPrint(dbg_win->title, "Debugger");
EWMAddWindow(my_task, dbg_win);
EWMCenterWindow(dbg_win);

EWidget *game_ctx0 = EWMNewWidget(EWGT_CONTEXT2D, 4, 24, GAME_WIDTH, GAME_HEIGHT);
game_ctx0->ctx = NewContext2D(game_ctx0->width, game_ctx0->height, display.bpp);
Fill2D(game_ctx0->ctx, theme.dark);
game_ctx0->visible=FALSE;
EWMAddWidget(my_win, game_ctx0);

EWidget *game_ctx1 = EWMNewWidget(EWGT_CONTEXT2D, 4, 24, GAME_WIDTH*2, GAME_HEIGHT*2);
game_ctx1->ctx = NewContext2D(game_ctx1->width, game_ctx1->height, display.bpp);
Fill2D(game_ctx1->ctx, theme.dark);
game_ctx1->visible=FALSE;
EWMAddWidget(my_win, game_ctx1);

EWindow *my_open_dlg=NULL;

#include "Main";

U0 SetVideoScale()
{
    switch (vid_scale)
    {
        case 2:
            my_win->width = (GAME_WIDTH*2)+8;
            my_win->height = (GAME_HEIGHT*2)+12;
            game_ctx0->visible=FALSE;
            game_ctx1->visible=TRUE;
            break;
        default:
            my_win->width = GAME_WIDTH+8;
            my_win->height = GAME_HEIGHT+20;
            game_ctx0->visible=TRUE;
            game_ctx1->visible=FALSE;
            break;
    }
}

SetVideoScale;
EWMCenterWindow(my_win);
EWMShow(my_win);

U0 KillEmuTask()
{
    if (emu_task)
    {
        fp_snd_fill_buf=fp_old_fill_buf;
        Kill(draw_task);
        Kill(emu_task);
        StrPrint(my_win->title, "No ROM Loaded");
        Fill2D(game_ctx0->ctx, theme.dark);
        Fill2D(game_ctx1->ctx, theme.dark);
        draw_task=NULL;
        emu_task=NULL;
    }
}

wmgr->loading=FALSE;
Cd("B:/");
while (1)
{

	if (!(my_win != wmgr->active_win || !my_win->visible || wmgr->win_blurall))
	{
	    if (KeyDown(Char2ScanCode('1')))
	    {
		    vid_scale=1;
	    }	
	    if (KeyDown(Char2ScanCode('2')))
	    {
		    vid_scale=2;
	    }	
	}

 	switch (my_task->menu_cb)
	{
        case 1:
            my_task->menu_cb=0;
            if (!my_open_dlg)
            {
                my_open_dlg = EWMOpenDialog(my_task, "Open ROM", "NES ROM Files (*.nes)|*.nes|All Files (*.*)|*.*");
                EWMSetOFSFileOptions(my_open_dlg, open_ctx_menu);
                my_task->fp_mask=".nes";
            }
            break;
		case 4:
            my_task->menu_cb=0;
            KillEmuTask;
            break;
        case 5:
            my_task->menu_cb=0;
            my_win->msg_close=TRUE;
            break;
		case 6:
            my_task->menu_cb=0;
            resetSystem;
            break;
        default:
            break;
    }

	if (my_open_dlg && (my_open_dlg->msg_close ||
        my_open_dlg->widgets->next->next->clicked)) 
	{
        my_open_dlg->widgets->next->next->clicked=FALSE;
        EWMDelWindow(my_open_dlg);
        EWMSetActiveWindow(my_win);
        my_open_dlg = NULL;
    }

    if (my_open_dlg && (my_open_dlg->widgets->next->clicked))
    {
        my_open_dlg->widgets->next->clicked=FALSE;
        rom_de=FilesFind(EWMGetOFSTextTarget(my_open_dlg));
        if (rom_de)
        {
            if (rom_de->attr & RS_ATTR_DIR == RS_ATTR_DIR)
            {
                Cd(EWMGetOFSTextTarget(my_open_dlg));
           	    StrPrint(ofs_dirsel, "*:%s|1", Fs->cur_dir);
                ofs_dirsel[0]=Fs->cur_dv->drv_let;
                EWMUpdateOFSDirTree(my_open_dlg, ofs_dirsel);
                StrPrint(EWMGetOFSTextTarget(my_open_dlg),"");

            }
            else
            {
                my_open_dlg->widgets->next->clicked=FALSE;
                //StrPrint(my_fn, "%s/ROMs/%s",DirCur, EWMGetOFSTextTarget(my_open_dlg) );
                StrPrint(my_fn, "%s/%s",DirCur, EWMGetOFSTextTarget(my_open_dlg) );
                EWMDelWindow(my_open_dlg);
                EWMSetActiveWindow(my_win);
                my_open_dlg = NULL;
                KillEmuTask;
                emu_task = Spawn(&TempleNES, my_fn,,2);
                wmgr->loading=FALSE;

            }
        }
        DirTreeDel(rom_de);
    }

	if (my_win && my_win->msg_close)
	{
        fp_snd_fill_buf=fp_old_fill_buf;
        Kill(draw_task);
        Kill(emu_task);
        EWMDelWindow(dbg_win);
		EWMDelWindow(my_win);
        EWMDelTask(my_task);
        my_win = NULL;
		Exit;
	}
    
    SetVideoScale;
    Sleep(1);
}