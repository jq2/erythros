#define EWIN_IS_MENUBAR      0x10
#define EWIN_HAS_ICON        0x20
#define EWIN_HAS_TITLE       0x40
#define EWIN_HAS_MINBTN      0x80
#define EWIN_HAS_MAXBTN      0x100
#define EWIN_MODAL           0x200
#define EWIN_TRANSPARENT	 0x400

#define EWGT_NULL                 0
#define EWGT_BUTTON               1
#define EWGT_CHECKBOX             2
#define EWGT_RADIO                3
#define EWGT_LABEL                4
#define EWGT_INPUT                5
#define EWGT_DROPDOWN             6
#define EWGT_FILEPICKER                   7
#define EWGT_HSCROLLBAR                   8
#define EWGT_VSCROLLBAR                   9
#define EWGT_HSCROLLBAR                   8
#define EWGT_VSCROLLBAR                   9
#define EWGT_COMBOBOX             10
#define EWGT_HSLIDER                   11
#define EWGT_VSLIDER                   12

#define EWGT_CONTEXT2D            20

#define EWGT_TASKBOX              100

#define WMGR_WIN_X_DEFAULT        120
#define WMGR_WIN_Y_DEFAULT        120
#define WMGR_WIN_W_DEFAULT        120
#define WMGR_WIN_H_DEFAULT        120

#define WMGR_CMENU_HRZ_RULE               -1000

#define WMGR_CMD_SEL_WIN                  0x01
#define WMGR_CMD_BLUR_ALL                 0x02
#define WMGR_CMD_TASK_CB                  0x03
#define WMGR_OPEN_SEL_CB                  0x04
#define WMGR_CMD_RUN_PROG                 0x05

extern class EContextMenu;
extern class ETask;
extern U0 EWMCallback(U64 cmd, I64 id, ETask *task, U8 *path);
extern U0 DrawContextMenuExpanded2D(EContext2D *ctx, EContextMenu *cmenu);

class EContextMenuItem
{
EContextMenuItem *prev;
EContextMenuItem *next;
I64 id;
U8 *text;
U8 *path;
EContext2D *icon;
I64 idle_timer;
U64 wmgr_callback;
EContextMenu *submenu;
};

class EContextMenu
{ //we don't want doubly linked list for EContextMenu since we will delete these recursively when EContextMenuItem is deleted.
//EContextMenu *prev;
//EContextMenu *next;
EContext2D *ctx;
I64 x;
I64 y;
I64 width;
I64 height;
I64 selected;
I64 hover;
Bool is_submenu;
ETask *task;
EContextMenuItem *items;
EContextMenu *submenu;
};

class EMenuItem
{
I64 id;    //unique value for program
U8 *text;
EContextMenu *menu;
};

class EMenu
{
I64 size;    //number of items
I64 selected;
I64 hover;
EMenuItem **items;
};

class ETask
{
ETask *prev;
ETask *next;
U8 *title;
EContext2D *icon;
CTask *tos_task;
EMenu *menu;
I64 menu_cb;
U8 *fp_mask;// filepicker file mask string
};

class EWidget
{
EWidget *prev;
EWidget *next;
ETask *parent_task;
EWidget *parent_wgt;
I64 type;
EContext2D *ctx;
EContextMenu *context_menu;
EContext2D *pointer;
I64 x;
I64 y;
I64 x_scroll;
I64 y_scroll;
I64 x_scroll_max;
I64 y_scroll_max;
CDirEntry *fp_de;// filepicker CDirEntry
U8 *fp_mask;// filepicker file mask string
I64 orig_ms_x;
I64 orig_ms_y;
I64 orig_wgt_xw;
I64 orig_wgt_yh;
Bool scroll_horz;
Bool scroll_vert;
I64 width;
I64 height;
I64 bg_color;
I64 fg_color;
I64 radio_group; //for radio buttons
I64 tab_group; //for tabs
Bool active;
Bool focused;
Bool action_lb;
Bool action_rb;
Bool clicked;
I64 clicked_xofs;
I64 clicked_yofs;
Bool checked;
Bool hover;
Bool visible;
Bool enabled;
Bool refresh;
Bool redraw;
I64 sel_index;
U8 *text;
I64 text_pos;
I64 text_maxlen;
I64 text_width;
I64 text_xoffset;
I64 text_prev_len;
I64 last_key_tS; // to debounce
I64 dbl_click_tS;// detect double-click
EWidget *text_action_wgt;
EWidget *dbl_click_wgt;
I64 sel_start; //text select
I64 sel_end; //text select
U8 *font;
};

class EWindow
{
EWindow *prev;
EWindow *next;
ETask *parent_task;
U8 *title;
EContext2D *icon;
EContext2D *ctx;
EContext2D *alpha_ctx;
EWidget *widgets;
I64 x;
I64 y;
I64 width;
I64 height;
I64 prev_width;
I64 prev_height;
I64 min_width;
I64 min_height;
I64 max_width;
I64 max_height;
Bool modal;
Bool transparent;
Bool minimized;
Bool maximized;
Bool visible;
Bool enabled;
Bool resizable;
Bool is_menubar;
Bool has_alpha;
Bool has_icon;
Bool has_title;
Bool has_minbtn;
Bool has_maxbtn;
Bool click_close;
Bool click_maxbtn;
Bool click_minbtn;
Bool tgt_close;
Bool tgt_maxbtn;
Bool tgt_minbtn;
Bool msg_close; //handled by program
};

class ESession
{
	U8 *user;
	U8 *hostname;
	I64 id;
	U8 *full_name;
}

class EConsole 
{
    EConsole *prev;
    EConsole *next;
    EWindow *win;
	EWidget *wgt;
    //U8 *screen_buf;
    //U8 *scroll_buf;
	Bool disable_echo;
	Bool disable_cursor;
	U32 fill_color;
	U32 fg_color;
	U32 bg_color;
	U32 fg_hilight;
	U32 bg_hilight;
	CDC *ch_buf;
	U32 *fg_buf;
	U32 *bg_buf;
	I64 ch_width;
	I64 ch_height;
	I64 hl_x1;
	I64 hl_x2;
	I64 hl_y1;
	I64 hl_y2;
	I64 screen_x;
	I64 screen_y;
	I64 scroll_x;
	I64 scroll_y;
	Bool new;
	EContext2D *term_ctx;
    CFifoU8 *stdin;
    CFifoU8 *stdout;
    CFifoU8 *stderr;
};

class EWindowManager
{
Bool active;
ESession *session;
ETask *tasks;
EWindow *windows;
EWindow *active_win;
EContextMenu *context_menus;
EContext2D *ctx;
EContext2D *wallpaper;
EContext2D *pointer;
I64 pointer_xofs;
I64 pointer_yofs;
EContextMenu *context_menu;
EWidget *context_wgt;
I64 context_x;
I64 context_y;
I64 context_w;
I64 context_h;
U8 *text_clipboard;
U8 *utf16_clipboard;
Bool dbg;
Bool prev_lb;
Bool prev_rb;
Bool dragging_lb;
Bool dragging_rb;
Bool desktop_select;
I64 desktop_sel_x1;
I64 desktop_sel_x2;
I64 desktop_sel_y1;
I64 desktop_sel_y2;
I64 desktop_sel_old_x1;
I64 desktop_sel_old_y1;
I64 desktop_sel_old_x2;
I64 desktop_sel_old_y2;
Bool resize_win;
Bool drag_win;
Bool win_blurall;
Bool refresh_taskmenu;
Bool show_taskmenu;
Bool hover_cmenu;
Bool loading;
I64 active_key;    // for inputs; key being pressed/repeated (result)
I64 active_key_tS;    // to debounce keys
I64 orig_win_xw;    // original x or width (for win drag/resize)
I64 orig_win_yh;    // original y or height (for win drag/resize)
I64 orig_ms_x;    // orig mouse x pos (for win drag/resize)
I64 orig_ms_y;    // orig mouse y pos (for win drag/resize)
I64 debug1;
};

extern I64 EWMGetContextMenuHeight(EContextMenu *cmenu);

EWindowManager *wmgr=NULL;

class EWinTheme
{
U32 outline;
U32 dark;
U32 medium_dark; //uughhh....
U32 medium;
U32 light;
U32 blur_title_bg;
U32 blur_title_fg;
U32 blur_title_shadow;
U32 focus_title_bg;
U32 focus_title_fg;
U32 focus_title_shadow;
};

EWinTheme theme;
theme.outline               = 0x00000000;
theme.dark                  = 0x9C9C9C00;
theme.medium_dark           = 0xBEBEBE00;
theme.medium                = 0xCCCCCC00;
theme.light                 = 0xFFFFFF00;
theme.blur_title_bg         = 0xEBEBEB00;
theme.blur_title_fg         = 0x9C9C9C00;
theme.focus_title_bg		= 0xFFC74F00;
theme.focus_title_fg        = 0x0;
theme.focus_title_shadow	= 0xFFE78F00;

EContext2D *null_context = NewContext2D(display.width, display.height, display.bpp);

extern U0 EWMSetWidgetFocus(EWindow *win, EWidget *wgt);
extern U0 EWMTextClipCopy(EWidget *wgt);
extern U0 EWMTextClipPaste(EWidget *wgt);
extern U0 EWMTextClipCut(EWidget *wgt);

EContext2D *ms_cur_default = LoadPNG("System/Media/Themes/Default/Cursors/Pointer.png");
EContext2D *ms_cur_input = LoadPNG("System/Media/Themes/Default/Cursors/Input.png");

EContext2D *ms_cur_wait[8];
ms_cur_wait[0] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_01.png");
ms_cur_wait[1] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_02.png");
ms_cur_wait[2] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_03.png");
ms_cur_wait[3] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_04.png");
ms_cur_wait[4] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_05.png");
ms_cur_wait[5] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_06.png");
ms_cur_wait[6] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_07.png");
ms_cur_wait[7] = LoadPNG("System/Media/Themes/Default/Cursors/Wait_08.png");

EContext2D *default_icon = LoadPNG("System/Media/Themes/Default/Icons/16/application_form.png");
EContext2D *desktop_icon = LoadPNG("System/Media/Themes/Default/Icons/16/desktop.png");
EContext2D *programs_icon = LoadPNG("System/Media/Themes/Default/Icons/16/application_double.png");
EContext2D *terminal_icon = LoadPNG("System/Media/Themes/Default/Icons/16/terminal_emulator.png");

EContext2D *cmenu_arrow_icon = LoadPNG("System/Media/Themes/Default/Icons/16/bullet_arrow_right.png");
EContext2D *left_arrow_icon = LoadPNG("System/Media/Themes/Default/Icons/16/bullet_arrow_left.png");
EContext2D *right_arrow_icon = cmenu_arrow_icon;

EContext2D *window_btn = NewContext2D(16, 16, display.bpp);
window_btn->alpha_color = 0x00FF0000;
U8 *window_btn_data = FileRead("window_button.data");
SwapBGR(window_btn_data, 16, 16, display.bpp);
MemCpy(window_btn->fb, window_btn_data, (16*16)*display.bpp/8);
Free(window_btn_data);

#include "System/Libraries/Widgets";

U0 EWMCenterWidget(EWidget *wgt, EWindow *win, Bool horz = TRUE, Bool vert = TRUE)
{
	if (horz)
	{
		wgt->x = (win->width/2)-(wgt->width/2);
	}
	if (vert)
	{
		wgt->y = (win->height/2)-(wgt->height/2);
	}
}

U0 EWMCenterWindow(EWindow *win, Bool horz = TRUE, Bool vert = TRUE)
{
	if (horz)
	{
		win->x = (display.width/2)-(win->width/2);
	}
	if (vert)
	{
		win->y = (display.height/2)-(win->height/2);
	}
}

EWindow *EWMNewWindow(I64 x=WMGR_WIN_X_DEFAULT, I64 y=WMGR_WIN_Y_DEFAULT,
                      I64 w=WMGR_WIN_W_DEFAULT, I64 h=WMGR_WIN_H_DEFAULT, U8 *title=NULL, U64 flags=NULL)
{
	EWindow *win = CAlloc(sizeof(EWindow));
	EWidget *widgets_head=CAlloc(sizeof(EWidget));
	win->widgets=widgets_head;
	win->x=x;
	win->y=y;
	win->width=w;
	win->height=h;
	win->enabled=TRUE;

	if (title)
	{
		win->title=title;
	}

	if (flags & EWIN_IS_MENUBAR == EWIN_IS_MENUBAR)
	{
		win->is_menubar=TRUE;
	}
	if (flags & EWIN_HAS_ICON == EWIN_HAS_ICON)
	{
		win->has_icon=TRUE;
	}
	if (flags & EWIN_HAS_TITLE == EWIN_HAS_TITLE)
	{
		win->has_title=TRUE;
	}
	if (flags & EWIN_HAS_MINBTN == EWIN_HAS_MINBTN)
	{
		win->has_minbtn=TRUE;
	}
	if (flags & EWIN_HAS_MAXBTN == EWIN_HAS_MAXBTN)
	{
		win->has_maxbtn=TRUE;
	}
	if (flags & EWIN_MODAL == EWIN_MODAL)
	{
		win->modal=TRUE;
	}
	return win;
}

EWidget *EWMNewWidget(I64 type, I64 x=0, I64 y=0, I64 w=0, I64 h=0, U8 *text=NULL)
{
	EWidget *wgt = CAlloc(sizeof(EWidget));
	wgt->type = type;
	wgt->x = x;
	wgt->y = y;
	wgt->width = w;
	wgt->height = h;
	switch (type)
	{
	case EWGT_BUTTON:
	case EWGT_INPUT:
	case EWGT_LABEL:
	case EWGT_DROPDOWN:
		wgt->text=CAlloc(1024);
		wgt->text_maxlen=1024;
		if (text)
		{
			if (StrLen(text)<wgt->text_maxlen)
			{
				StrPrint(wgt->text, text);
			}
		}
		break;
	default:
		break;
	}
	switch (type)
	{
		case EWGT_INPUT:
			wgt->pointer = ms_cur_input;
			break;
		default:
			break;
	}
	wgt->enabled = TRUE;
	wgt->visible = TRUE;
	return wgt;
}

U0 DrawWidget2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	if (!wgt->visible)
	{
		return;
	}
	switch (wgt->type)
	{
	case EWGT_BUTTON:
		DrawButton2D(ctx, win, wgt);
		break;
	case EWGT_CHECKBOX:
		DrawCheckBox2D(ctx, win, wgt);
		break;
	case EWGT_RADIO:
		DrawRadio2D(ctx, win, wgt);
		break;
	case EWGT_LABEL:
		DrawLabel2D(ctx, win, wgt);
		break;
	case EWGT_INPUT:
		DrawInput2D(ctx, win, wgt);
		break;
	case EWGT_COMBOBOX:
		//DrawComboBox2D(ctx, win, wgt);
		break;
	case EWGT_DROPDOWN:
		DrawDropdownBox2D(ctx, win, wgt);
		break;
	case EWGT_TASKBOX:
		DrawTaskBox2D(ctx, win, wgt);
		break;
	case EWGT_CONTEXT2D:
		DrawContext2D(ctx, win, wgt);
		break;
	case EWGT_FILEPICKER:
		DrawFilePicker2D(ctx, win, wgt);
		break;
	case EWGT_HSCROLLBAR:
		DrawHScrollBar2D(ctx, win, wgt);
		break;
	case EWGT_VSCROLLBAR:
		DrawVScrollBar2D(ctx, win, wgt);
		break;
	case EWGT_HSLIDER:
		DrawHSlider2D(ctx, win, wgt);
		break;
	case EWGT_VSLIDER:
		DrawVSlider2D(ctx, win, wgt);
		break;
	default:
		break;
	}
}

U0 DrawWindow2D(EContext2D *ctx, EWindow *win)
{
	if (win->has_alpha)
	{
		if (win->alpha_ctx)
		{
			if (win->alpha_ctx->width != win->width || win->alpha_ctx->height != win->height)
			{
				DelContext2D(win->alpha_ctx);
				win->alpha_ctx = NewContext2D(win->width, win->height, display.bpp);
			}

		}
		else
		{
			win->alpha_ctx = NewContext2D(win->width, win->height, display.bpp);
		}
		CopyRect2D(win->alpha_ctx, -win->x, -win->y, wmgr->ctx);
	}
	I64 i;
	if (!win->ctx)
	{
		win->ctx=NewContext2D(win->width-4, win->height-4, display.bpp);
		win->ctx->alpha_color=0x00FF0000;
	}
	else
	{
		if (win->prev_width != win->width ||
		    win->prev_height != win->height)
		{
			DelContext2D(win->ctx);
			win->ctx=NewContext2D(win->width-4, win->height-4, display.bpp);
			win->ctx->alpha_color=0x00FF0000;
		}
	}
	Fill2D(win->ctx, win->ctx->alpha_color);
	EWidget *wgt=win->widgets->next;

	I64 title_xofs = 4;
	I64 btn_xofs=0;
	I64 title_len = win->width - 30;
	if (!win->visible || win->minimized)
	{
		return;
	}

	if (win->has_icon)
	{
		title_len -= 20;
	}
	if (win->has_maxbtn)
	{
		title_len -= 20;
	}
	if (win->has_minbtn)
	{
		title_len -= 20;
	}

	if (wmgr->active_win==win && !wmgr->win_blurall)
	{ // Draw outline
		HLine2D(ctx, win->x, win->y, win->x+win->width-1, theme.outline);
		VLine2D(ctx, win->x, win->y, win->y+win->height-1, theme.outline);
		HLine2D(ctx, win->x, win->y+win->height-1, win->x+win->width-1, theme.outline);
		VLine2D(ctx, win->x+win->width-1, win->y, win->y+win->height-1, theme.outline);
		HLine2D(ctx, win->x+2, win->y+win->height, win->x+win->width, theme.outline);
		VLine2D(ctx, win->x+win->width, win->y+2, win->y+win->height, theme.outline);
	}

	// Draw window border
	HLine2D(ctx, win->x+1, win->y+1, win->x+1+win->width-4, theme.light);
	Plot2D(ctx, win->x+1+win->width-3, win->y+1, theme.medium);
	VLine2D(ctx, win->x+1, win->y+1, win->y+win->height-3, theme.light);
	Plot2D(ctx, win->x+1, win->y+win->height-2, theme.medium);
	HLine2D(ctx, win->x+2, win->y+win->height-2, win->x+win->width-2, theme.dark);
	VLine2D(ctx, win->x+win->width-2, win->y+2, win->y+win->height-2, theme.dark);

	// Fill window
	Rect2D(ctx, win->x+2, win->y+2, win->width-4, win->height-4, theme.medium);

	while (wgt)
	{ // Draw widgets
		if (wgt->visible)
		{
			DrawWidget2D(win->ctx, win, wgt);
			Blot2D(wmgr->ctx, win->x, win->y, win->ctx);
		}
		wgt = wgt->next;
	}

	if (win->has_icon)
	{ // Draw icon
		title_xofs = 24;
		if (!win->icon)
		{
			win->icon = default_icon;
		}
		/*
		HLine2D(ctx, win->x+4, win->y+4, win->x+20, theme.dark);
		VLine2D(ctx, win->x+4, win->y+4, win->y+20, theme.dark);
		HLine2D(ctx, win->x+4, win->y+21, win->x+20, theme.light);
		VLine2D(ctx, win->x+21, win->y+4, win->y+21, theme.light);
		*/
		Blot2D(ctx, win->x+5, win->y+5, win->icon);
	}

	if (win->has_title)
	{ // Draw titlebar
		EContext2D *tbar_ctx=NewContext2D(title_len-10, 20, display.bpp);
		tbar_ctx->alpha_color=0x00FF0000;
		Fill2D(tbar_ctx, tbar_ctx->alpha_color);
		HLine2D(ctx, win->x+title_xofs, win->y+4, win->x+title_xofs+title_len-1, theme.dark);
		VLine2D(ctx, win->x+title_xofs, win->y+4, win->y+20, theme.dark);
		HLine2D(ctx, win->x+title_xofs, win->y+21, win->x+title_xofs+title_len, theme.light);
		VLine2D(ctx, win->x+title_xofs+title_len, win->y+4, win->y+21, theme.light);
		if (wmgr->active_win!=win || wmgr->win_blurall)
		{
			Rect2D(ctx, win->x+title_xofs+1, win->y+5, title_len-1, 16, theme.blur_title_bg);
			if (!StrCmp(win->parent_task->title, win->title))
			{
				Bitmap16Print2D(tbar_ctx, 0, 0, theme.blur_title_fg, FONT_WINTITLE16, win->parent_task->title);
			}
			else
			{
				//Bitmap16Print2D(tbar_ctx, 0, 0, theme.blur_title_fg, FONT_WINTITLE16, "%s - %s", win->parent_task->title, win->title);
				Bitmap16Print2D(tbar_ctx, 0, 0, theme.blur_title_fg, FONT_WINTITLE16, win->title);
			}
			Blot2D(ctx, win->x+title_xofs+8, win->y+6, tbar_ctx);
		}
		else
		{
			Rect2D(ctx, win->x+title_xofs+1, win->y+5, title_len-1, 16, theme.focus_title_bg);
			if (!StrCmp(win->parent_task->title, win->title))
			{
				Bitmap16Print2D(tbar_ctx, 1, 1, theme.focus_title_shadow, FONT_WINTITLE16, win->parent_task->title);
				Bitmap16Print2D(tbar_ctx, 0, 0, theme.focus_title_fg, FONT_WINTITLE16, win->parent_task->title);
			}
			else
			{
				//Bitmap16Print2D(tbar_ctx, 1, 1, theme.focus_title_shadow, FONT_WINTITLE16, "%s - %s", win->parent_task->title, win->title);
				//Bitmap16Print2D(tbar_ctx, 0, 0, theme.focus_title_fg, FONT_WINTITLE16, "%s - %s", win->parent_task->title, win->title);
				Bitmap16Print2D(tbar_ctx, 1, 1, theme.focus_title_shadow, FONT_WINTITLE16, win->title);
				Bitmap16Print2D(tbar_ctx, 0, 0, theme.focus_title_fg, FONT_WINTITLE16, win->title);
			}
			Blot2D(ctx, win->x+title_xofs+8, win->y+6, tbar_ctx);
		}
		DelContext2D(tbar_ctx);
	}

	// Draw close button
	if (!win->is_menubar)
	{
		if (win->click_close)
		{
			Blot2D(ctx, win->x+win->width-21, win->y+5, window_btn);
			Blot2D(ctx, win->x+win->width-21, win->y+6, window_btn);
			if (wmgr->active_win!=win || wmgr->win_blurall)
			{
				Bitmap16Print2D(ctx, win->x+win->width-16, win->y+6, theme.blur_title_fg, FONT_WINTITLE16, "x");
			}
			else
			{
				Bitmap16Print2D(ctx, win->x+win->width-15, win->y+7, theme.dark, FONT_WINTITLE16, "x");
				Bitmap16Print2D(ctx, win->x+win->width-16, win->y+6, theme.focus_title_fg, FONT_WINTITLE16, "x");
			}
			HLine2D(ctx, win->x+win->width-22, win->y+4, win->x+win->width-5, theme.dark);
			VLine2D(ctx, win->x+win->width-22, win->y+4, win->y+20, theme.dark);
			HLine2D(ctx, win->x+win->width-22, win->y+21, win->x+win->width-5, theme.light);
			VLine2D(ctx, win->x+win->width-4, win->y+4, win->y+21, theme.light);
		}
		else
		{
			Blot2D(ctx, win->x+win->width-22, win->y+5, window_btn);
			if (wmgr->active_win!=win || wmgr->win_blurall)
			{
				Bitmap16Print2D(ctx, win->x+win->width-17, win->y+5, theme.blur_title_fg, FONT_WINTITLE16, "x");
			}
			else
			{
				Bitmap16Print2D(ctx, win->x+win->width-16, win->y+6, theme.dark, FONT_WINTITLE16, "x");
				Bitmap16Print2D(ctx, win->x+win->width-17, win->y+5, theme.focus_title_fg, FONT_WINTITLE16, "x");
			}
			HLine2D(ctx, win->x+win->width-23, win->y+4, win->x+win->width-6, theme.light);
			VLine2D(ctx, win->x+win->width-23, win->y+4, win->y+20, theme.light);
			HLine2D(ctx, win->x+win->width-23, win->y+21, win->x+win->width-6, theme.dark);
			VLine2D(ctx, win->x+win->width-5, win->y+4, win->y+21, theme.dark);
		}
	}
	btn_xofs += 20;
	if (win->has_maxbtn)
	{ // Draw maximize button
		if (win->click_maxbtn)
		{
			Blot2D(ctx, win->x+win->width-21, win->y+5, window_btn);
			Blot2D(ctx, win->x+win->width-21, win->y+6, window_btn);
			if (wmgr->active_win!=win || wmgr->win_blurall)
			{
				Bitmap16Print2D(ctx, win->x+win->width-17, win->y+7, theme.blur_title_fg, FONT_WINTITLE16, "+");
			}
			else
			{
				Bitmap16Print2D(ctx, win->x+win->width-16, win->y+8, theme.dark, FONT_WINTITLE16, "+");
				Bitmap16Print2D(ctx, win->x+win->width-17, win->y+7, theme.focus_title_fg, FONT_WINTITLE16, "+");
			}
			HLine2D(ctx, win->x+win->width-22, win->y+4, win->x+win->width-5, theme.dark);
			VLine2D(ctx, win->x+win->width-22, win->y+4, win->y+20, theme.dark);
			HLine2D(ctx, win->x+win->width-22, win->y+21, win->x+win->width-5, theme.light);
			VLine2D(ctx, win->x+win->width-4, win->y+4, win->y+21, theme.light);
		}
		else
		{
			Blot2D(ctx, win->x+win->width-22-btn_xofs, win->y+5, window_btn);
			if (wmgr->active_win!=win || wmgr->win_blurall)
			{
				Bitmap16Print2D(ctx, win->x+win->width-18-btn_xofs, win->y+6, theme.blur_title_fg, FONT_WINTITLE16, "+");
			}
			else
			{
				Bitmap16Print2D(ctx, win->x+win->width-17-btn_xofs, win->y+7, theme.dark, FONT_WINTITLE16, "+");
				Bitmap16Print2D(ctx, win->x+win->width-18-btn_xofs, win->y+6, theme.focus_title_fg, FONT_WINTITLE16, "+");
			}
			HLine2D(ctx, win->x+win->width-23-btn_xofs, win->y+4, win->x+win->width-6-btn_xofs, theme.light);
			VLine2D(ctx, win->x+win->width-23-btn_xofs, win->y+4, win->y+20, theme.light);
			HLine2D(ctx, win->x+win->width-23-btn_xofs, win->y+21, win->x+win->width-6-btn_xofs, theme.dark);
			VLine2D(ctx, win->x+win->width-5-btn_xofs, win->y+4, win->y+21, theme.dark);
		}
		btn_xofs += 20;
	}
	if (win->has_minbtn)
	{ // Draw minimize button
		if (win->click_minbtn)
		{
			Blot2D(ctx, win->x+win->width-21-btn_xofs, win->y+5, window_btn);
			Blot2D(ctx, win->x+win->width-21-btn_xofs, win->y+6, window_btn);
			if (wmgr->active_win!=win || wmgr->win_blurall)
			{
				Bitmap16Print2D(ctx, win->x+win->width-16-btn_xofs, win->y+5, theme.blur_title_fg, FONT_WINTITLE16, "_");
			}
			else
			{
				Bitmap16Print2D(ctx, win->x+win->width-15-btn_xofs, win->y+6, theme.dark, FONT_WINTITLE16, "_");
				Bitmap16Print2D(ctx, win->x+win->width-16-btn_xofs, win->y+5, theme.focus_title_fg, FONT_WINTITLE16, "_");
			}
			HLine2D(ctx, win->x+win->width-22-btn_xofs, win->y+4, win->x+win->width-5-btn_xofs, theme.dark);
			VLine2D(ctx, win->x+win->width-22-btn_xofs, win->y+4, win->y+20, theme.dark);
			HLine2D(ctx, win->x+win->width-22-btn_xofs, win->y+21, win->x+win->width-5-btn_xofs, theme.light);
			VLine2D(ctx, win->x+win->width-4-btn_xofs, win->y+4, win->y+21, theme.light);
		}
		else
		{
			Blot2D(ctx, win->x+win->width-22-btn_xofs, win->y+5, window_btn);
			if (wmgr->active_win!=win || wmgr->win_blurall)
			{
				Bitmap16Print2D(ctx, win->x+win->width-17-btn_xofs, win->y+4, theme.blur_title_fg, FONT_WINTITLE16, "_");
			}
			else
			{
				Bitmap16Print2D(ctx, win->x+win->width-16-btn_xofs, win->y+5, theme.dark, FONT_WINTITLE16, "_");
				Bitmap16Print2D(ctx, win->x+win->width-17-btn_xofs, win->y+4, theme.focus_title_fg, FONT_WINTITLE16, "_");
			}
			HLine2D(ctx, win->x+win->width-23-btn_xofs, win->y+4, win->x+win->width-6-btn_xofs, theme.light);
			VLine2D(ctx, win->x+win->width-23-btn_xofs, win->y+4, win->y+20, theme.light);
			HLine2D(ctx, win->x+win->width-23-btn_xofs, win->y+21, win->x+win->width-6-btn_xofs, theme.dark);
			VLine2D(ctx, win->x+win->width-5-btn_xofs, win->y+4, win->y+21, theme.dark);
		}
	}

	if (win->resizable)
	{

		/*
		for (i=0; i<14; i++)
		{
			HLine2D(ctx, win->x+win->width-16, win->y+win->height-16+i, win->x+win->width-3, theme.medium );
		}
		*/

		for (i=18; i>-1; i--)
		{
			HLine2D(ctx, win->x+win->width-21+(18-i), win->y+win->height-21+i, win->x+win->width-3, theme.medium );
		}

		// Draw resize corner dots
		Plot2D(ctx, win->x+win->width-6, win->y+win->height-15, theme.dark);
		Plot2D(ctx, win->x+win->width-5, win->y+win->height-14, theme.light);
		Plot2D(ctx, win->x+win->width-6, win->y+win->height-12, theme.dark);
		Plot2D(ctx, win->x+win->width-5, win->y+win->height-11, theme.light);
		Plot2D(ctx, win->x+win->width-6, win->y+win->height-9, theme.dark);
		Plot2D(ctx, win->x+win->width-5, win->y+win->height-8, theme.light);
		Plot2D(ctx, win->x+win->width-6, win->y+win->height-6, theme.dark);
		Plot2D(ctx, win->x+win->width-5, win->y+win->height-5, theme.light);
		Plot2D(ctx, win->x+win->width-9, win->y+win->height-12, theme.dark);
		Plot2D(ctx, win->x+win->width-8, win->y+win->height-11, theme.light);
		Plot2D(ctx, win->x+win->width-9, win->y+win->height-9, theme.dark);
		Plot2D(ctx, win->x+win->width-8, win->y+win->height-8, theme.light);
		Plot2D(ctx, win->x+win->width-9, win->y+win->height-6, theme.dark);
		Plot2D(ctx, win->x+win->width-8, win->y+win->height-5, theme.light);
		Plot2D(ctx, win->x+win->width-12, win->y+win->height-9, theme.dark);
		Plot2D(ctx, win->x+win->width-11, win->y+win->height-8, theme.light);
		Plot2D(ctx, win->x+win->width-12, win->y+win->height-6, theme.dark);
		Plot2D(ctx, win->x+win->width-11, win->y+win->height-5, theme.light);
		Plot2D(ctx, win->x+win->width-15, win->y+win->height-6, theme.dark);
		Plot2D(ctx, win->x+win->width-14, win->y+win->height-5, theme.light);
	}
}

U0 DrawContextMenu2D(EContext2D *ctx, EContextMenu *cmenu)
{
	EMenu *cur_menu;
	EContext2D *text_ctx;
	EContextMenuItem *cur_item;

	I64 i;
	I64 x, y;
	I64 text_width;

	cmenu->height=EWMGetContextMenuHeight(cmenu);
	// Calculate width of context menu
	text_ctx = null_context;
	cur_item = cmenu->items->next;
	while (cur_item)
	{
		text_width = Bitmap16Print2D(text_ctx, 0, 0, BLACK, FONT_SMOL16, cur_item->text);
		if (text_width>cmenu->width)
		{
			cmenu->width=text_width;
		}
		cur_item = cur_item->next;
	}

	cmenu->ctx=NewContext2D(cmenu->width+16, cmenu->height+16, display.bpp);
	cmenu->ctx->alpha_color=0x00FF0000;
	Fill2D(cmenu->ctx, cmenu->ctx->alpha_color);

	if (2==3)
	{ // Draw outline
		HLine2D(ctx, cmenu->x, cmenu->y, cmenu->x+cmenu->width-1, theme.outline);
		VLine2D(ctx, cmenu->x, cmenu->y, cmenu->y+cmenu->height-1, theme.outline);
		HLine2D(ctx, cmenu->x, cmenu->y+cmenu->height-1, cmenu->x+cmenu->width-1, theme.outline);
		VLine2D(ctx, cmenu->x+cmenu->width-1, cmenu->y, cmenu->y+cmenu->height-1, theme.outline);
		HLine2D(ctx, cmenu->x+2, cmenu->y+cmenu->height, cmenu->x+cmenu->width, theme.outline);
		VLine2D(ctx, cmenu->x+cmenu->width, cmenu->y+2, cmenu->y+cmenu->height, theme.outline);
	}

	// Draw context menu border
	HLine2D(ctx, cmenu->x+1, cmenu->y+1, cmenu->x+1+cmenu->width-4, theme.light);
	Plot2D(ctx, cmenu->x+1+cmenu->width-3, cmenu->y+1, theme.medium);
	VLine2D(ctx, cmenu->x+1, cmenu->y+1, cmenu->y+cmenu->height-3, theme.light);
	Plot2D(ctx, cmenu->x+1, cmenu->y+cmenu->height-2, theme.medium);
	HLine2D(ctx, cmenu->x+2, cmenu->y+cmenu->height-2, cmenu->x+cmenu->width-2, theme.dark);
	VLine2D(ctx, cmenu->x+cmenu->width-2, cmenu->y+2, cmenu->y+cmenu->height-2, theme.dark);

	// Fill context menu
	Rect2D(ctx, cmenu->x+2, cmenu->y+2, cmenu->width-4, cmenu->height-4, theme.medium);

	x = 8;
	y = 4;
	cmenu->hover=-1;
	wmgr->hover_cmenu=-1;
	i=0;
	cur_item = cmenu->items->next;
	while (cur_item)
	{
		if (cur_item->id==WMGR_CMENU_HRZ_RULE)
		{
			HLine2D(ctx, cmenu->x+x-4, cmenu->y+y, cmenu->x+x+cmenu->width-13, theme.dark);
			HLine2D(ctx, cmenu->x+x-4, cmenu->y+y+1, cmenu->x+x+cmenu->width-13, theme.light);
			y += 4;
		}
		else
		{
			if (cur_item->icon)
			{
				Blot2D(ctx, cmenu->x+x, cmenu->y+y+4, cur_item->icon);
				Bitmap16Print2D(ctx, cmenu->x+x+24, cmenu->y+y+5, BLACK, FONT_SMOL16, cur_item->text);
			}
			else
			{
				Bitmap16Print2D(ctx, cmenu->x+x, cmenu->y+y+5, BLACK, FONT_SMOL16, cur_item->text);
			}		
			if (mouse.x > cmenu->x+x-4 &&
			    mouse.x < cmenu->x+x+cmenu->width-4 &&
			    mouse.y > cmenu->y+y &&
			    mouse.y < cmenu->y+y+24)
			{
				cmenu->hover=i;
				wmgr->hover_cmenu=i;
				cur_item->idle_timer++;
				//if (cur_item->idle_timer>1000)
				//{
				cmenu->submenu=cur_item->submenu;
				//}
				HLine2D(ctx, cmenu->x+x-4, cmenu->y+y, cmenu->x+x+cmenu->width-14, theme.dark);
				VLine2D(ctx, cmenu->x+x-4, cmenu->y+y, cmenu->y+y+21, theme.dark);
				HLine2D(ctx, cmenu->x+x-4, cmenu->y+y+22, cmenu->x+x+cmenu->width-13, theme.light);
				VLine2D(ctx, cmenu->x+x+cmenu->width-13, cmenu->y+y, cmenu->y+y+22, theme.light);
				if (mouse.lb && !wmgr->prev_lb)
				{
					if (cmenu == wmgr->context_menu)
					{
						wmgr->context_wgt->sel_index = i;
						wmgr->context_wgt->focused=FALSE;
						wmgr->context_menu=NULL;
						wmgr->context_wgt=NULL;
					}
					EWMCallback(cur_item->wmgr_callback, cur_item->id, cmenu->task, cur_item->path);
				}
			}
			else
			{
				cur_item->idle_timer=0;
			}
			if (cur_item->submenu)
			{
				Blot2D(ctx, cmenu->x+x+cmenu->width-30, cmenu->y+y+3, cmenu_arrow_icon);
			}
			y += 24;
		}

		i++;
		cur_item = cur_item->next;
	}
	DelContext2D(cmenu->ctx);
}

U0 DrawContextMenuExpanded2D(EContext2D *ctx, EContextMenu *cmenu)
{
	while (cmenu)
	{
		DrawContextMenu2D(ctx, cmenu);
		cmenu = cmenu->submenu;
	}
}