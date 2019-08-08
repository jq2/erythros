EContext2D *wgt_button = LoadPNG("System/Media/Themes/Default/Widgets/button.png");
EContext2D *wgt_button_a = LoadPNG("System/Media/Themes/Default/Widgets/button_active.png");

EContext2D *wgt_checkbox = LoadPNG("System/Media/Themes/Default/Widgets/checkbox.png");
EContext2D *wgt_checkbox_c = LoadPNG("System/Media/Themes/Default/Widgets/checkbox_checked.png");
EContext2D *wgt_checkbox_active = LoadPNG("System/Media/Themes/Default/Widgets/checkbox_active.png");
EContext2D *wgt_checkbox_c_active = LoadPNG("System/Media/Themes/Default/Widgets/checkbox_checked_active.png");

EContext2D *wgt_radio = LoadPNG("System/Media/Themes/Default/Widgets/radio.png");
EContext2D *wgt_radio_c = LoadPNG("System/Media/Themes/Default/Widgets/radio_checked.png");
EContext2D *wgt_radio_active = LoadPNG("System/Media/Themes/Default/Widgets/radio_active.png");

EContext2D *wgt_combobox = LoadPNG("System/Media/Themes/Default/Widgets/combobox.png");
EContext2D *wgt_combobox_a = LoadPNG("System/Media/Themes/Default/Widgets/combobox_active.png");

EContext2D *wgt_hslider = LoadPNG("System/Media/Themes/Default/Widgets/horz_slider.png");
EContext2D *wgt_vslider = LoadPNG("System/Media/Themes/Default/Widgets/horz_slider.png");

EContext2D *fp_icon_folder = LoadPNG("System/Media/Themes/Default/Icons/16/folder.png");
EContext2D *fp_icon_txt = LoadPNG("System/Media/Themes/Default/Icons/16/file_extension_txt.png");

U8 *ofs_dirsel=CAlloc(1024);


U0 DrawDropdownBox2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	U8 *dd_text=CAlloc(512);
	U8 *dd_ptr;
	StrCpy(dd_text, wgt->text);

	I64 i;
	for (i=0;i<wgt->sel_index;i++)
	{
		StrCpy(dd_text, StrFirstOcc(dd_text, "|")+1);
		StrCpy(dd_text, StrFirstOcc(dd_text, "|")+1);
	}
	dd_ptr = StrFirstOcc(dd_text, "|");
	*dd_ptr=0;

	wgt->height=18;
	EContext2D *dd_ctx;
	if (wgt->enabled)
	{
		if (wgt->active && !mouse.lb)
		{
			if (wgt->hover)
			{
				wgt->clicked=TRUE;
			}
			wgt->active=FALSE;
			if (wgt->hover)
			{
				wgt->action_lb=TRUE;
				wgt->clicked_xofs = mouse.x-win->x-wgt->x;
				wgt->clicked_yofs = mouse.y-win->y-wgt->y;
				EWMSetWidgetFocus(win, wgt);
			}
		}
		HLine2D(ctx, wgt->x, wgt->y, wgt->x+wgt->width, theme.dark);
		VLine2D(ctx, wgt->x, wgt->y, wgt->y+wgt->height, theme.dark);
		HLine2D(ctx, wgt->x+1, wgt->y+wgt->height, wgt->x+wgt->width, theme.medium_dark);
		VLine2D(ctx, wgt->x+wgt->width, wgt->y+1, wgt->y+wgt->height, theme.medium_dark);
		Rect2D(ctx, wgt->x+1, wgt->y+1, wgt->width-1, wgt->height-1, theme.medium);
		if (wgt->focused)
		{
			HLine2D(ctx, wgt->x+1, wgt->y+1, wgt->x+wgt->width-2, BLACK);
			VLine2D(ctx, wgt->x+1, wgt->y+1, wgt->y+wgt->height-2, BLACK);
			HLine2D(ctx, wgt->x+1, wgt->y+wgt->height-1, wgt->x+wgt->width-1, BLACK);
			VLine2D(ctx, wgt->x+wgt->width-1, wgt->y+1, wgt->y+wgt->height-1, BLACK);
			if (!wmgr->context_menu)
			{
				wmgr->context_menu = wgt->context_menu;
			}
			if (wmgr->context_menu == wgt->context_menu)
			{
				wmgr->context_wgt = wgt;
				wgt->context_menu->x = win->x+wgt->x;
				wgt->context_menu->y = win->y+wgt->y;
				wgt->context_menu->width = wgt->width+1;
			}
		}
		dd_ctx=NewContext2D(wgt->width, wgt->height, display.bpp);
		dd_ctx->alpha_color=0x00FF0000;
		Fill2D(dd_ctx, dd_ctx->alpha_color);
		Bitmap16Print2D(dd_ctx, 0, 0, BLACK, FONT_SMOL16, dd_text);
		Blot2D(ctx, wgt->x+2, wgt->y+2, dd_ctx);
		DelContext2D(dd_ctx);
	}
	else
	{

	}
	if (wgt->clicked_xofs)
	{
		wmgr->debug1=wgt->clicked_xofs;
		wgt->clicked_xofs=0;
	}	
	Free(dd_text);
}

U0 DrawTaskBox2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	U8 *task_icon=NULL;
	I64 title_len = 192;
	I64 title_xofs = 24;
	I64 menu_xofs;
	I64 text_width;
	I64 i;
	if (!win->icon)
	{
		win->icon = default_icon;
	}
	//Blot2D(ctx, win->x+5, win->y+6, desktop_icon);

	if (wmgr->win_blurall)
	{
		win->title="Desktop";
		//Blot2D(ctx, win->x+5, win->y+6, desktop_icon);
	}
	else
	{
		win->title=wmgr->active_win->parent_task->title;
		task_icon=wmgr->active_win->parent_task->icon;
		if (!task_icon)
		{
			task_icon = default_icon;
		}
		//Blot2D(ctx, win->x+5, win->y+6, task_icon);
	}

	EContext2D *text_ctx;
	EContext2D *tbar_ctx=NewContext2D(title_len-10, 20, display.bpp);
	tbar_ctx->alpha_color=0x00FF0000;
	Fill2D(tbar_ctx, tbar_ctx->alpha_color);

	HLine2D(ctx, win->x+title_xofs, win->y+5, win->x+title_xofs+title_len-1, theme.dark);
	VLine2D(ctx, win->x+title_xofs, win->y+5, win->y+21, theme.dark);
	HLine2D(ctx, win->x+title_xofs, win->y+22, win->x+title_xofs+title_len, theme.light);
	VLine2D(ctx, win->x+title_xofs+title_len, win->y+5, win->y+22, theme.light);
	Rect2D(ctx, win->x+title_xofs+1, win->y+6, title_len-1, 16, theme.focus_title_bg);
	Bitmap16Print2D(tbar_ctx, 1, 1, theme.focus_title_shadow, FONT_WINTITLE16, win->title);
	Bitmap16Print2D(tbar_ctx, 0, 0, theme.focus_title_fg, FONT_WINTITLE16, win->title);
	Blot2D(ctx, win->x+title_xofs+8, win->y+7, tbar_ctx);
	Fill2D(tbar_ctx, tbar_ctx->alpha_color);

	menu_xofs = 240;
	text_ctx = null_context;

	if (wmgr->active_win && !wmgr->win_blurall)
	{
		ETask *active_task = wmgr->active_win->parent_task;
		EMenu *active_menu = active_task->menu;
		if (active_menu)
		{
			active_menu->hover=-1;

			for (i=0; i<active_menu->size; i++)
			{
				text_width = Bitmap16Print2D(text_ctx, 0, 0, BLACK, FONT_WINTITLE16, active_menu->items[i]->text);

				if (mouse.x > win->x+menu_xofs-16 &&
				    mouse.x < win->x+menu_xofs+text_width+16 &&
				    mouse.y > win->y+4 &&
				    mouse.y < win->y+23)
				{
					active_menu->hover=i;
					if (active_menu->selected>-1)
					{
						active_menu->selected=i;
					}
					HLine2D(ctx, win->x+menu_xofs-16, win->y+5, win->x+menu_xofs+text_width+15, theme.dark);
					VLine2D(ctx, win->x+menu_xofs-16, win->y+5, win->y+21, theme.dark);
					HLine2D(ctx, win->x+menu_xofs-16, win->y+22, win->x+menu_xofs+text_width+16, theme.light);
					VLine2D(ctx, win->x+menu_xofs+text_width+16, win->y+5, win->y+22, theme.light);
				}

				if (active_menu->selected==i)
				{
					HLine2D(ctx, win->x+menu_xofs-16, win->y+5, win->x+menu_xofs+text_width+15, theme.dark);
					VLine2D(ctx, win->x+menu_xofs-16, win->y+5, win->y+21, theme.dark);
					HLine2D(ctx, win->x+menu_xofs-16, win->y+22, win->x+menu_xofs+text_width+16, theme.light);
					VLine2D(ctx, win->x+menu_xofs+text_width+16, win->y+5, win->y+22, theme.light);
					Rect2D(ctx, win->x+menu_xofs-15, win->y+6, text_width+31, 16, 0xDCDCDC00);
					active_menu->items[i]->menu->x = win->x+menu_xofs-18;
					active_menu->items[i]->menu->y = win->y+20;
					DrawContextMenuExpanded2D(wmgr->ctx, active_menu->items[i]->menu);
				}

				Fill2D(tbar_ctx, tbar_ctx->alpha_color);
				Bitmap16Print2D(tbar_ctx, 0, 0, BLACK, FONT_WINTITLE16, active_menu->items[i]->text);
				Blot2D(ctx, win->x+menu_xofs, win->y+7, tbar_ctx);
				menu_xofs += text_width+36;
			}
		}
	}

	DelContext2D(tbar_ctx);
}

U0 DrawRadio2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	EWidget *tmp_wgt=win->widgets->next;
	wgt->width=13;
	wgt->height=13;
	U8 *font=FONT_SMOL16;
	if (wgt->font)
	{
		font=wgt->font;
	}
	if (wgt->enabled)
	{
		if (wgt->active && !mouse.lb)
		{
			if (wgt->hover)
			{
				wgt->clicked=TRUE;
			}
			wgt->active=FALSE;
			if (wgt->hover)
			{
				wgt->action_lb=TRUE;
				wgt->clicked_xofs = mouse.x-win->x-wgt->x;
				wgt->clicked_yofs = mouse.y-win->y-wgt->y;
				wgt->checked=TRUE;
				EWMSetWidgetFocus(win, wgt);
				while (tmp_wgt)
				{
					if (tmp_wgt->type == EWGT_RADIO &&
					    tmp_wgt != wgt &&
					    tmp_wgt->radio_group == wgt->radio_group)
					{
						tmp_wgt->checked=FALSE;
					}
					tmp_wgt=tmp_wgt->next;
				}
			}
		}
		if (wgt->checked)
		{
			Blot2D(ctx, wgt->x, wgt->y, wgt_radio_c);
		}
		else
		{
			if (wgt->active && wgt->hover)
			{
				Blot2D(ctx, wgt->x, wgt->y, wgt_radio_active);
			}
			else
			{
				Blot2D(ctx, wgt->x, wgt->y, wgt_radio);
			}
		}
	}
	else
	{

	}
}

EContext2D *DrawInputText2D(EWindow *win, EWidget *wgt)
{
	U8 *font=FONT_SMOL16;
	U8 *tmp_txtbuf;
	if (wgt->font)
	{
		font=wgt->font;
	}
	I64 i;
	I64 key;
	I64 x_ofs = 0;
	I64 x_origin = 0;

	I64 ms_x_ofs = 0;
	I64 ms_x_ofs_prev = 0;

	U8 text_char[2];
	text_char[1]=0;
	EContext2D *text_ctx;
	text_ctx = null_context;
	wgt->text_width = Bitmap16Print2D(text_ctx, 0, 0, theme.focus_title_fg, font, wgt->text);
	EContext2D *input_ctx=NewContext2D(wgt->width-3, wgt->height-3, display.bpp);
	input_ctx->alpha_color=0x00FF0000;
	Fill2D(input_ctx, input_ctx->alpha_color);

	for (i=0; i<wgt->text_pos; i++)
	{
		text_char[0]=wgt->text[i];
		x_ofs += Bitmap16PrintSpc2D(text_ctx, 0, 0, theme.focus_title_fg, font, &text_char);
	}

	if (x_ofs>input_ctx->width-4)
	{
		x_origin = x_ofs-input_ctx->width+4;
	}

	if (StrLen(wgt->text)<wgt->text_prev_len && !x_origin)
	{
		wgt->text_xoffset=x_origin;
	}

	wgt->text_prev_len=StrLen(wgt->text);

	if (x_origin>wgt->text_xoffset)
	{
		wgt->text_xoffset=x_origin;
	}
	else
	{
		x_origin=wgt->text_xoffset;
	}
	while (x_ofs-x_origin<0)
	{
		x_origin--;
		wgt->text_xoffset=x_origin;
	}

	if (wgt->clicked_xofs)
	{
		ms_x_ofs_prev = 0;
		ms_x_ofs = 0;
		for (i=0; i<StrLen(wgt->text); i++)
		{
			text_char[0]=wgt->text[i];
			ms_x_ofs_prev = ms_x_ofs;
			ms_x_ofs += Bitmap16PrintSpc2D(text_ctx, 0, 0, theme.focus_title_fg, font, &text_char);
			if (wgt->clicked_xofs >= -x_origin+ms_x_ofs_prev &&
			    wgt->clicked_xofs <= -x_origin+ms_x_ofs)
			{
				wgt->text_pos = i;
				wgt->clicked_xofs=0;
				wgt->clicked_yofs=0;
				wgt->sel_start=0;
				wgt->sel_end=0;
				break;

			}
		}
	}

	text_ctx = NewContext2D(input_ctx->width, input_ctx->height, display.bpp);
	text_ctx->alpha_color=0x00FF0000;
	Fill2D(text_ctx, text_ctx->alpha_color);

	Bitmap16PrintRange2D(text_ctx, -x_origin, 0, BLACK, 0xC6E2F700, wgt->sel_start, wgt->sel_end, font, wgt->text);
	Bitmap16Print2D(text_ctx, -x_origin, 0, wgt->fg_color, font, wgt->text);

	if (wgt->sel_start==wgt->sel_end)
	{
		wgt->sel_start=-1;
		wgt->sel_end=-1;
	}

	if (wgt->focused)
	{
		if (Blink(1.75) || wmgr->active_key)
		{
			VLine2D(text_ctx, -x_origin+x_ofs, 2, text_ctx->height-4, BLACK);
		}
		key=wmgr->active_key;
		if (key && win==wmgr->active_win && !wmgr->win_blurall && wmgr->active_key_tS != wgt->last_key_tS)
		{
			switch (key)
			{
			case SC_ENTER:
				if (wgt->text_action_wgt)
				{
					wgt->text_action_wgt->clicked=TRUE;
				}
				break;
			case SC_HOME:
				if (Bt(kbd.down_bitmap, SC_SHIFT) && wgt->text_pos)
				{
					if (wgt->sel_start>-1)
					{
						if (wgt->text_pos<wgt->sel_end)
						{
							wgt->sel_start=0;
						}
						else
						{
							wgt->sel_end=wgt->sel_start;
						}
					}
					else
					{
						wgt->sel_end=wgt->text_pos;
					}
					wgt->sel_start=0;
				}
				else
				{
					if (!Bt(kbd.down_bitmap, SC_SHIFT))
					{
						wgt->sel_start=-1;
						wgt->sel_end=-1;
					}
				}
				wgt->text_pos=0;
				//wgt->text_pos=wgt->sel_end;
				break;
			case SC_END:
				if (Bt(kbd.down_bitmap, SC_SHIFT) && wgt->sel_end<StrLen(wgt->text))
				{
					if (wgt->sel_end>-1)
					{
						if (wgt->text_pos>wgt->sel_start)
						{
							wgt->sel_end=StrLen(wgt->text);
						}
						else
						{
							wgt->sel_start=wgt->sel_end;
						}
					}
					else
					{
						wgt->sel_start=wgt->text_pos;
					}
					wgt->sel_end=StrLen(wgt->text);
				}
				else
				{
					if (!Bt(kbd.down_bitmap, SC_SHIFT))
					{
						wgt->sel_start=-1;
						wgt->sel_end=-1;
					}
				}
				wgt->text_pos=StrLen(wgt->text);
				break;
			case 0x02 ... 0x0D:
			case 0x10 ... 0x1B:
			case 0x1E ... 0x29:
			case 0x2B ... 0x35:
			case 0x39:
				if (Bt(kbd.down_bitmap, SC_CTRL) && ScanCode2Char(key)=='a')
				{ // maybe change this to set text pos to end??
					if (StrLen(wgt->text))
					{
						wgt->sel_start=0;
						wgt->sel_end=StrLen(wgt->text);
					}
					break;
				}
				if (Bt(kbd.down_bitmap, SC_CTRL) && ScanCode2Char(key)=='c')
				{
					EWMTextClipCopy(wgt);
					break;
				}
				if (Bt(kbd.down_bitmap, SC_CTRL) && ScanCode2Char(key)=='v')
				{
					EWMTextClipPaste(wgt);
					break;
				}
				if (Bt(kbd.down_bitmap, SC_CTRL) && ScanCode2Char(key)=='x')
				{
					EWMTextClipCut(wgt);
					break;
				}
				if (wgt->sel_start>-1)
				{
					StrCpy(wgt->text+wgt->sel_start, wgt->text+wgt->sel_end);
					wgt->text_pos=wgt->sel_start;
					wgt->sel_start=-1;
					wgt->sel_end=-1;
				}
				if (StrLen(wgt->text)<wgt->text_maxlen)
				{
					tmp_txtbuf=CAlloc(wgt->text_maxlen);
					StrCpy(tmp_txtbuf, wgt->text+wgt->text_pos);
					StrCpy(wgt->text+wgt->text_pos+1, tmp_txtbuf);
					if (!Bt(kbd.down_bitmap, SC_SHIFT))
					{
						wgt->text[wgt->text_pos]=NORMAL_KEY_SCAN_DECODE_TABLE(U8*)[key];
					}
					else
					{
						if (key==0x39)
						{ // Handle TempleOS SHIFT-SPACE character.
							wgt->text[wgt->text_pos]=0x20;
						}
						else
						{
							wgt->text[wgt->text_pos]=SHIFT_KEY_SCAN_DECODE_TABLE(U8*)[key];
						}
					}
					wgt->text_pos++;
					Free(tmp_txtbuf);
				}
				break;
			case SC_CURSOR_LEFT:
				if (wgt->text_pos)
				{
					if (Bt(kbd.down_bitmap, SC_SHIFT))
					{
						if (wgt->sel_start>-1)
						{
							if (wgt->sel_start < wgt->text_pos)
							{
								wgt->sel_end--;
							}
							else
							{
								wgt->sel_start--;
							}
						}
						else
						{
							wgt->sel_start=wgt->text_pos-1;
							wgt->sel_end=wgt->text_pos;
						}
					}
					else
					{
						wgt->sel_start=-1;
						wgt->sel_end=-1;
					}
					wgt->text_pos--;
				}
				else
				{
					if (!Bt(kbd.down_bitmap, SC_SHIFT))
					{
						wgt->sel_start=-1;
						wgt->sel_end=-1;
					}
				}
				break;
			case SC_CURSOR_RIGHT:
				if (wgt->text_pos<StrLen(wgt->text))
				{
					if (Bt(kbd.down_bitmap, SC_SHIFT))
					{
						if (wgt->sel_start>-1)
						{
							if (wgt->sel_start < wgt->text_pos)
							{
								wgt->sel_end++;
							}
							else
							{
								wgt->sel_start++;
							}
						}
						else
						{
							wgt->sel_start=wgt->text_pos;
							wgt->sel_end=wgt->text_pos+1;
						}
					}
					else
					{
						wgt->sel_start=-1;
						wgt->sel_end=-1;
					}
					wgt->text_pos++;
				}
				else
				{
					if (!Bt(kbd.down_bitmap, SC_SHIFT))
					{
						wgt->sel_start=-1;
						wgt->sel_end=-1;
					}
				}
				break;
			case SC_BACKSPACE:
				if (wgt->sel_start>-1)
				{
					StrCpy(wgt->text+wgt->sel_start, wgt->text+wgt->sel_end);
					wgt->text_pos=wgt->sel_start;
					wgt->sel_start=-1;
					wgt->sel_end=-1;
					break;
				}
				if (wgt->text_pos)
				{
					StrCpy(wgt->text+wgt->text_pos-1, wgt->text+wgt->text_pos);
					wgt->text_pos--;
				}
				break;
			case SC_DELETE:
				if (wgt->sel_start>-1)
				{
					StrCpy(wgt->text+wgt->sel_start, wgt->text+wgt->sel_end);
					wgt->text_pos=wgt->sel_start;
					wgt->sel_start=-1;
					wgt->sel_end=-1;
					break;
				}
				if (wgt->text_pos<StrLen(wgt->text))
				{
					StrCpy(wgt->text+wgt->text_pos, wgt->text+wgt->text_pos+1);
				}
				break;
			default:
				break;
			}
			wgt->last_key_tS = wmgr->active_key_tS;
		}
	}
	Blot2D(input_ctx, 0, 0, text_ctx);
	DelContext2D(text_ctx);
	return input_ctx;
}

EContext2D *EWMGetIconForFileType(U8 *fn)
{//TODO:
	return fp_icon_txt;
}

U0 DrawHSlider2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	wgt->height=12;

	Rect2D(ctx, wgt->x, wgt->y+5, wgt->width, 4, theme.dark);

	HLine2D(ctx, wgt->x, wgt->y+1, wgt->x+wgt->width, theme.medium_dark);
	HLine2D(ctx, wgt->x+1, wgt->y+4, wgt->x+wgt->width-1, BLACK);
	VLine2D(ctx, wgt->x+1, wgt->y+4, wgt->y+8, BLACK);
	VLine2D(ctx, wgt->x, wgt->y+4, wgt->y+9, theme.medium_dark);
	HLine2D(ctx, wgt->x, wgt->y+9, wgt->x+wgt->width, theme.light);
	VLine2D(ctx, wgt->x+wgt->width, wgt->y+4, wgt->y+9, theme.light);

	VLine2D(ctx, wgt->x, wgt->y+11, wgt->y+16, theme.medium_dark);
	VLine2D(ctx, wgt->x+1, wgt->y+11, wgt->y+16, theme.light);

	VLine2D(ctx, wgt->x+(wgt->width/2)-1, wgt->y+11, wgt->y+16, theme.medium_dark);
	VLine2D(ctx, wgt->x+(wgt->width/2), wgt->y+11, wgt->y+16, theme.light);

	VLine2D(ctx, wgt->x+wgt->width-1, wgt->y+11, wgt->y+16, theme.medium_dark);
	VLine2D(ctx, wgt->x+wgt->width, wgt->y+11, wgt->y+16, theme.light);

	if (mouse.lb && !wmgr->prev_lb && !wgt->clicked &&
		(mouse.x>win->x+wgt->x-7+wgt->x_scroll && mouse.x<win->x+wgt->x-7+wgt->x_scroll+14 && mouse.y>win->y+wgt->y && mouse.y<win->y+wgt->y+16)
		)
	{
		wgt->clicked=TRUE;
		wgt->orig_wgt_xw = wgt->x_scroll;
		wgt->orig_ms_x = mouse.x;
		wgt->orig_ms_y = mouse.y;
	}

	if (wgt->hover && ms.pos.z!=0)
	{			
		wgt->x_scroll -= Max(-1,Min(ms.pos.z,1));
		//wgt->x_scroll = Max(0, Min(wgt->width-1, wgt->x_scroll));
	}

	if (!mouse.lb)
	{
		wgt->clicked=FALSE;
	}

	if (wgt->clicked)
	{
		wgt->x_scroll = Max(0, Min(wgt->width-1, wgt->orig_wgt_xw + (mouse.x-wgt->orig_ms_x)));
	}

	Blot2D(ctx, wgt->x-7+wgt->x_scroll, wgt->y, wgt_hslider);

}

U0 DrawVSlider2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{

}

U0 DrawHScrollBar2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	if (!wgt->parent_wgt)
	{
		return;
	}
	wgt->x=wgt->parent_wgt->x+1;
	wgt->y=wgt->parent_wgt->y+wgt->parent_wgt->height-16;
	wgt->width=wgt->parent_wgt->width-1;
	wgt->height=16;

	I64 bar_width=wgt->width-32 - (wgt->parent_wgt->x_scroll_max-wgt->parent_wgt->width);
	I64 bar_pos=wgt->x_scroll;

	if (wgt->clicked && mouse.x != wgt->orig_ms_x)
	{
		wgt->x_scroll = wgt->orig_wgt_xw+ (mouse.x-wgt->orig_ms_x);
	}


	if (mouse.lb && !wmgr->prev_lb && wgt->hover && !wgt->clicked &&
		(mouse.x>win->x+wgt->x+16+bar_pos && mouse.x<win->x+wgt->x+16+bar_pos+bar_width && mouse.y>win->y+wgt->y && mouse.y<win->y+wgt->y+16)
		)
	{
		wgt->clicked=TRUE;
		//wgt->orig_wgt_xw = wgt->x;
		//wgt->orig_wgt_yh = wgt->y;
		wgt->orig_wgt_xw = wgt->x_scroll;
		wgt->orig_ms_x = mouse.x;
		wgt->orig_ms_y = mouse.y;
	}

	if (mouse.lb && !wmgr->prev_lb && wgt->hover && !wgt->clicked &&
	(mouse.x>win->x+wgt->x+16 && mouse.x<win->x+wgt->x+16+bar_pos && mouse.y>win->y+wgt->y && mouse.y<win->y+wgt->y+16)
	)
	{
		wgt->x_scroll = mouse.x - (win->x+wgt->x+16);
		bar_pos=wgt->x_scroll;
		wgt->clicked=TRUE;
	}

	if (mouse.lb && !wmgr->prev_lb && wgt->hover && !wgt->clicked &&
	(mouse.x>win->x+wgt->x+16+bar_pos+bar_width && mouse.y>win->y+wgt->y && mouse.y<win->y+wgt->y+16)
	)
	{
		wgt->x_scroll = mouse.x + (win->x+wgt->x+16+bar_width);
		bar_pos=wgt->x_scroll;
		wgt->clicked=TRUE;
	}

	if (!mouse.lb)
	{
		wgt->clicked=FALSE;
	}

	if (wgt->x_scroll<0)
	{
		wgt->x_scroll=0;
	}

	if (wgt->x_scroll>wgt->width-bar_width-33)
	{
		wgt->x_scroll=wgt->width-bar_width-33;
	}
	bar_pos=wgt->x_scroll;

	wgt->parent_wgt->x_scroll=wgt->x_scroll;
	wgt->parent_wgt->redraw=TRUE;

	Rect2D(ctx, wgt->x, wgt->y, wgt->width, wgt->height, theme.medium_dark);

		//if (win->click_close)
		if (2==3)
		{
			Blot2D(ctx, wgt->x+win->width-21, win->y+5, window_btn);
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

			//Blot2D(ctx, wgt->x, wgt->y, window_btn);

			// Draw left scroll button

			Rect2D(ctx, wgt->x, wgt->y+1, 16, 15, 0xE8E8E800);
			Blot2D(ctx, wgt->x-1, wgt->y, left_arrow_icon);
			VLine2D(ctx, wgt->x, wgt->y+1, wgt->y+14, theme.light);
			HLine2D(ctx, wgt->x, wgt->y+1, wgt->x+16, theme.light);
			VLine2D(ctx, wgt->x+16, wgt->y+1, wgt->y+15, theme.dark);
			HLine2D(ctx, wgt->x, wgt->y+15, wgt->x+16, theme.dark);

			// Draw scrollbar

			Rect2D(ctx, bar_pos+wgt->x+16, wgt->y+1, bar_width, 15, 0xE8E8E800);
			VLine2D(ctx, bar_pos+wgt->x+16, wgt->y+1, wgt->y+15, theme.medium_dark);
			VLine2D(ctx, bar_pos+wgt->x+17, wgt->y+1, wgt->y+14, theme.light);
			HLine2D(ctx, bar_pos+wgt->x+17, wgt->y+1, bar_pos+wgt->x+17+bar_width-3, theme.light);
			VLine2D(ctx, bar_pos+wgt->x+17+bar_width-2, wgt->y+1, wgt->y+15, theme.dark);
			HLine2D(ctx, bar_pos+wgt->x+17, wgt->y+15, bar_pos+wgt->x+17+bar_width-3, theme.dark);

			// Draw right scroll button

			Rect2D(ctx, wgt->x+wgt->width-17, wgt->y+1, 16, 15, 0xE8E8E800);
			Blot2D(ctx, wgt->x+wgt->width-17, wgt->y, right_arrow_icon);
			VLine2D(ctx, wgt->x+wgt->width-17, wgt->y+1, wgt->y+14, theme.light);
			HLine2D(ctx, wgt->x+wgt->width-17, wgt->y+1, wgt->x+16+wgt->width-17, theme.light);
			VLine2D(ctx, wgt->x+16+wgt->width-17, wgt->y+1, wgt->y+15, theme.dark);
			HLine2D(ctx, wgt->x+wgt->width-17, wgt->y+15, wgt->x+16+wgt->width-17, theme.dark);


			//Blot2D(ctx, wgt->x+wgt->width-16, wgt->y, window_btn);


			/*
			if (wmgr->active_win!=win || wmgr->win_blurall)
			{
				Bitmap16Print2D(ctx, win->x+win->width-17, win->y+5, theme.blur_title_fg, FONT_WINTITLE16, "x");
			}
			else
			{
				*/
				//Blot2D(ctx, wgt->x-1+4, wgt->y+2, )
				//Bitmap16Print2D(ctx, wgt->x-1+4, wgt->y+2, theme.dark, FONT_WINTITLE16, "<");
				//Bitmap16Print2D(ctx, wgt->x+4, wgt->y+1, theme.focus_title_fg, FONT_WINTITLE16, "<");

				//Bitmap16Print2D(ctx, wgt->x-1-4+wgt->width-8, wgt->y+2, theme.dark, FONT_WINTITLE16, ">");
				//Bitmap16Print2D(ctx, wgt->x-4+wgt->width-8, wgt->y+1, theme.focus_title_fg, FONT_WINTITLE16, ">");


			//}
			/*
			HLine2D(ctx, win->x+win->width-23, win->y+4, win->x+win->width-6, theme.light);
			VLine2D(ctx, win->x+win->width-23, win->y+4, win->y+20, theme.light);
			HLine2D(ctx, win->x+win->width-23, win->y+21, win->x+win->width-6, theme.dark);
			VLine2D(ctx, win->x+win->width-5, win->y+4, win->y+21, theme.dark);
			*/
		}



}

U0 DrawVScrollBar2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{

}

EContext2D *fp_ctx=NULL;
U8 *fp_de_cmp=CAlloc(512);

U0 DrawFilePicker2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	I64 max_per_row=9;
	U8 *tmp;
	CDirEntry *tmpde;

	I64 i=0, j=0, k=0, l=0;
	if (!wgt->ctx)
	{
		wgt->ctx = NewContext2D(wgt->width, wgt->height, display.bpp);
		wgt->ctx->alpha_color=0x00FF0000;
		Fill2D(wgt->ctx, wgt->ctx->alpha_color);
	}

	if (wgt->fp_mask != win->parent_task->fp_mask)
	{
		wgt->fp_mask = win->parent_task->fp_mask;
		wgt->x_scroll=0;
		wgt->clicked_xofs=-1;
		wgt->clicked_yofs=-1;
		wgt->clicked=FALSE;
		wgt->refresh=TRUE;
	}

	if (mouse.lb && !wmgr->prev_lb)
	{
		if (wgt->hover)
		{
			wgt->clicked=TRUE;

		//wgt->active=FALSE;
			wgt->action_lb=TRUE;
			wgt->clicked_xofs = mouse.x-win->x-wgt->x;
			wgt->clicked_yofs = mouse.y-win->y-wgt->y;
			EWMSetWidgetFocus(win, wgt);
			wgt->refresh=TRUE;
		}
		//EWMSetWidgetFocus(win, wgt);
	}

	if (wgt->refresh)
	{

		if (fp_ctx)
		{
			DelContext2D(fp_ctx);
		}

		tmp=CAlloc(512);
		wgt->refresh = FALSE;
		StrCpy(tmp,ofs_dirsel);
		tmp[StrLen(tmp)-2]=0;
		
		if (!wgt->clicked)
		{
			if (wgt->fp_de)
			{
				DirTreeDel(wgt->fp_de);
			}
			DocPrint(trace_log, tmp);
			wgt->fp_de=FilesFind(tmp);
			wmgr->loading=FALSE;
		}

		tmpde=wgt->fp_de;
		while (tmpde)
		{
			tmpde=tmpde->next;
			if (!(tmpde->attr & RS_ATTR_DIR == RS_ATTR_DIR))
			{
				if (win->parent_task->fp_mask)
				{
					if (StrCmp(win->parent_task->fp_mask, tmpde->name+StrLen(tmpde->name)-StrLen((win->parent_task->fp_mask)))!=0)
					{
						goto fp_next_cnt;
					}
				}
			}
			l++;
			if (l>20)
			{
				max_per_row=8;
			}
fp_next_cnt:
		}
		if (max_per_row>8)
		{
			wgt->next->visible=FALSE;
		}
		else
		{
			wgt->next->visible=TRUE;
		}

		if (l>20)
		{
			wgt->x_scroll_max = 224*MaxI64(l/max_per_row, 1);
			fp_ctx = NewContext2D(224*MaxI64(l/max_per_row, 1), wgt->height, display.bpp);
		}
		else
		{
			if (l>10)
			{
				wgt->x_scroll_max = 224*MaxI64(l/max_per_row, 2);
				fp_ctx = NewContext2D(224*MaxI64(l/max_per_row, 2), wgt->height, display.bpp);
			}
			else
			{
				wgt->x_scroll_max = 224*MaxI64(l/max_per_row, 1);
				fp_ctx = NewContext2D(224*MaxI64(l/max_per_row, 1), wgt->height, display.bpp);
			}
		}
		fp_ctx->alpha_color=0x00FF0000;
		Fill2D(fp_ctx, fp_ctx->alpha_color);

		tmpde=wgt->fp_de;
		while (tmpde)
		{
			if (!(tmpde->attr & RS_ATTR_DIR == RS_ATTR_DIR))
			{
				if (win->parent_task->fp_mask)
				{
					if (StrCmp(win->parent_task->fp_mask, tmpde->name+StrLen(tmpde->name)-StrLen((win->parent_task->fp_mask)))!=0)
					{
						goto fp_next_de;
					}
				}
			}

			if (wgt->clicked_xofs>-wgt->x_scroll+k+2 &&
				wgt->clicked_xofs<-wgt->x_scroll+k+224 &&
				wgt->clicked_yofs>2+j &&
				wgt->clicked_yofs<2+j+16)
			{
				Rect2D(fp_ctx, k+2, 2+j, 214, 16, 0xC6E2F700);
				if (wgt->clicked)
				{
					if (StrCmp(fp_de_cmp, tmpde->name)!=0)
					{
						StrPrint(fp_de_cmp, tmpde->name);
						if (!wgt->dbl_click_tS)
						{
							wgt->dbl_click_tS=cnts.jiffies;
							wgt->clicked = FALSE;
						}
					}
				}

				StrPrint(wgt->text_action_wgt->text, tmpde->name);
				if (wgt->clicked && wgt->dbl_click_tS)
				{
					if (cnts.jiffies<wgt->dbl_click_tS+250)
					{
						wgt->dbl_click_wgt->clicked=TRUE;
						wgt->clicked_xofs = -1;
						wgt->clicked_yofs = -1;
						wmgr->loading=TRUE;
					}
					fp_de_cmp[0]=0;
					wgt->dbl_click_tS=0;
					wgt->clicked=FALSE;
				}

				//Reboot;
			}
			if (tmpde->attr & RS_ATTR_DIR == RS_ATTR_DIR)
			{
				Blot2D(fp_ctx, k+2, 2+j, fp_icon_folder);
			}
			else
				{
				Blot2D(fp_ctx, k+2, 2+j, EWMGetIconForFileType(tmpde->name));
			}
			Bitmap16Print2D(fp_ctx, k+22, 4+j, BLACK, FONT_SMOL16, tmpde->name);
			j+=17;
			i++;
			if (i>max_per_row)
			{
				i=0;
				j=0;
				k+=224;
			}
fp_next_de:
			tmpde=tmpde->next;
		}
		Free(tmp);
		wgt->clicked=FALSE;
	}

	if (wgt->enabled)
	{
		Rect2D(ctx, wgt->x+1, wgt->y+1, wgt->width-1, wgt->height-1, theme.light);
		Fill2D(wgt->ctx, wgt->ctx->alpha_color);
		Blot2D(wgt->ctx, -wgt->x_scroll, 0, fp_ctx);
		Blot2D(ctx, wgt->x, wgt->y, wgt->ctx);
		HLine2D(ctx, wgt->x, wgt->y, wgt->x+wgt->width, theme.dark);
		VLine2D(ctx, wgt->x, wgt->y, wgt->y+wgt->height, theme.dark);
		HLine2D(ctx, wgt->x+1, wgt->y+wgt->height, wgt->x+wgt->width, theme.medium_dark);
		VLine2D(ctx, wgt->x+wgt->width, wgt->y+1, wgt->y+wgt->height, theme.medium_dark);
	}
	else
	{

	}
}

U0 DrawInput2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	if (wgt->text_pos>StrLen(wgt->text))
	{
		wgt->text_pos=StrLen(wgt->text);
	}
	EContext2D *input_ctx;
	wgt->height=18;
	EContext2D *text_ctx;
	text_ctx = null_context;
	if (wgt->enabled)
	{
		if (wgt->active && !mouse.lb)
		{
			if (wgt->hover)
			{
				wgt->clicked=TRUE;
			}
			wgt->active=FALSE;
			if (wgt->hover)
			{
				wgt->action_lb=TRUE;
				wgt->clicked_xofs = mouse.x-win->x-wgt->x;
				wgt->clicked_yofs = mouse.y-win->y-wgt->y;
				EWMSetWidgetFocus(win, wgt);
			}
		}
		HLine2D(ctx, wgt->x, wgt->y, wgt->x+wgt->width, theme.dark);
		VLine2D(ctx, wgt->x, wgt->y, wgt->y+wgt->height, theme.dark);
		HLine2D(ctx, wgt->x+1, wgt->y+wgt->height, wgt->x+wgt->width, theme.medium_dark);
		VLine2D(ctx, wgt->x+wgt->width, wgt->y+1, wgt->y+wgt->height, theme.medium_dark);
		Rect2D(ctx, wgt->x+1, wgt->y+1, wgt->width-1, wgt->height-1, theme.light);
		if (wgt->focused)
		{
			HLine2D(ctx, wgt->x+1, wgt->y+1, wgt->x+wgt->width-2, BLACK);
			VLine2D(ctx, wgt->x+1, wgt->y+1, wgt->y+wgt->height-2, BLACK);
			HLine2D(ctx, wgt->x+1, wgt->y+wgt->height-1, wgt->x+wgt->width-1, BLACK);
			VLine2D(ctx, wgt->x+wgt->width-1, wgt->y+1, wgt->y+wgt->height-1, BLACK);
		}
		input_ctx=DrawInputText2D(win, wgt);
		Blot2D(ctx, wgt->x+2, wgt->y+2, input_ctx);
		DelContext2D(input_ctx);
	}
	else
	{

	}
	if (wgt->clicked_xofs)
	{
		wmgr->debug1=wgt->clicked_xofs;
		wgt->clicked_xofs=0;
	}
}

U0 DrawContext2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	if (!wgt->ctx || !ctx)
	{
		return;
	}
	if (wgt->enabled)
	{
		if (wgt->active && !mouse.lb)
		{
			if (wgt->hover)
			{
				wgt->clicked=TRUE;
			}
			wgt->active=FALSE;

			if (wgt->hover)
			{
				wgt->action_lb=TRUE;
				wgt->clicked_xofs = mouse.x-win->x-wgt->x;
				wgt->clicked_yofs = mouse.y-win->y-wgt->y;
				EWMSetWidgetFocus(win, wgt);
			}
		}
	}
	CopyRect2D(ctx, wgt->x, wgt->y, wgt->ctx);
	//Blot2D(ctx, wgt->x, wgt->y, wgt->ctx);
}

U0 DrawLabel2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	U8 *font=FONT_SMOL16;
	if (wgt->font)
	{
		font=wgt->font;
	}
	EContext2D *text_ctx;
	text_ctx = null_context;
	if (wgt->enabled)
	{
		if (wgt->active && !mouse.lb)
		{
			if (wgt->hover)
			{
				wgt->clicked=TRUE;
			}
			wgt->active=FALSE;

			if (wgt->hover)
			{
				wgt->action_lb=TRUE;
				wgt->clicked_xofs = mouse.x-win->x-wgt->x;
				wgt->clicked_yofs = mouse.y-win->y-wgt->y;
				EWMSetWidgetFocus(win, wgt);
			}
		}
		text_ctx = NewContext2D(wgt->width, 20, display.bpp);
		text_ctx->alpha_color=0x00FF0000;
		Fill2D(text_ctx, text_ctx->alpha_color);
		Bitmap16Print2D(text_ctx, 1, 1, theme.medium, font, wgt->text);
		Bitmap16Print2D(text_ctx, 0, 0, theme.focus_title_fg, font, wgt->text);
		Blot2D(ctx, wgt->x, wgt->y, text_ctx);
		DelContext2D(text_ctx);
	}
	else
	{

	}
}

U0 DrawCheckBox2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	wgt->width=13;
	wgt->height=13;
	U8 *font=FONT_SMOL16;
	if (wgt->font)
	{
		font=wgt->font;
	}
	if (wgt->enabled)
	{
		if (wgt->active && !mouse.lb)
		{
			if (wgt->hover)
			{
				wgt->clicked=TRUE;
			}

			wgt->active=FALSE;

			if (wgt->hover)
			{
				wgt->action_lb=TRUE;
				wgt->clicked_xofs = mouse.x-win->x-wgt->x;
				wgt->clicked_yofs = mouse.y-win->y-wgt->y;
				wgt->checked=!wgt->checked;
				EWMSetWidgetFocus(win, wgt);
			}
		}
		if (wgt->checked)
		{
			if (wgt->active && wgt->hover)
			{
				Blot2D(ctx, wgt->x, wgt->y, wgt_checkbox_c_active);
			}
			else
			{
				Blot2D(ctx, wgt->x, wgt->y, wgt_checkbox_c);
			}
		}
		else
		{
			if (wgt->active && wgt->hover)
			{
				Blot2D(ctx, wgt->x, wgt->y, wgt_checkbox_active);
			}
			else
			{
				Blot2D(ctx, wgt->x, wgt->y, wgt_checkbox);
			}
		}
	}
	else
	{

	}
}

U0 DrawButton2D(EContext2D *ctx, EWindow *win, EWidget *wgt)
{
	U8 *font=FONT_SMOL16;
	if (wgt->font)
	{
		font=wgt->font;
	}
	EContext2D *text_ctx;
	text_ctx = null_context;

	wgt->height=22;
	wgt->text_width = Bitmap16Print2D(text_ctx, 0, 0, theme.focus_title_fg, font, wgt->text);
	if (wgt->text_width > wgt->width)
	{
		wgt->width = wgt->text_width+52;
	}
	I64 i,j,k;
	if (wgt->enabled)
	{
		if (wgt->active && !mouse.lb)
		{
			if (wgt->hover)
			{
				wgt->clicked=TRUE;
			}
			wgt->active=FALSE;
			wgt->action_lb=TRUE;
			wgt->clicked_xofs = mouse.x-win->x-wgt->x;
			wgt->clicked_yofs = mouse.y-win->y-wgt->y;
			EWMSetWidgetFocus(win, wgt);
		}
		if (wgt->active && wgt->hover)
		{
			Blot2D(ctx, wgt->x, wgt->y, wgt_button_a);
			Blot2D(ctx, wgt->x+wgt->width-wgt_button_a->width, wgt->y, wgt_button_a);
			for (i=wgt->x+4; i<wgt->x+wgt->width-wgt_button_a->width+4; i++)
			{
				Plot2D(ctx, i, wgt->y+0, 0x63636300);
				Plot2D(ctx, i, wgt->y+1, 0x83838300);
				Plot2D(ctx, i, wgt->y+2, 0xC5C5C500);
				for (j=3; j<18; j++)
				{
					Plot2D(ctx, i, wgt->y+j, 0xD6D6D600);
				}
				Plot2D(ctx, i, wgt->y+18, 0xE6E6E600);
				Plot2D(ctx, i, wgt->y+19, 0xE6E6E600);
				Plot2D(ctx, i, wgt->y+20, 0xD6D6D600);
				Plot2D(ctx, i, wgt->y+21, 0x63636300);
			}
			if (wgt->ctx)
			{
				k=24;
				Blot2D(ctx, wgt->x+4, wgt->y+2, wgt->ctx);
			}
			else
			{
				k=8;
			}
			text_ctx = NewContext2D(wgt->width-wgt_button_a->width-24, 20, display.bpp);
			text_ctx->alpha_color=0x00FF0000;
			Fill2D(text_ctx, text_ctx->alpha_color);
			Bitmap16Print2D(text_ctx, 1, 1, theme.medium, font, wgt->text);
			Bitmap16Print2D(text_ctx, 0, 0, theme.focus_title_fg, font, wgt->text);
			Blot2D(ctx, wgt->x+((wgt->width/2)-(wgt->text_width/2))+1, wgt->y+5, text_ctx);
			DelContext2D(text_ctx);
		}
		else
		{
			Blot2D(ctx, wgt->x, wgt->y, wgt_button);
			Blot2D(ctx, wgt->x+wgt->width-wgt_button->width, wgt->y, wgt_button);
			for (i=wgt->x+4; i<wgt->x+wgt->width-wgt_button->width+4; i++)
			{
				Plot2D(ctx, i, wgt->y+0, 0x60606000);
				Plot2D(ctx, i, wgt->y+1, 0xE8E8E800);
				Plot2D(ctx, i, wgt->y+2, 0xFFFFFF00);
				Plot2D(ctx, i, wgt->y+3, 0xFFFFFF00);
				for (j=4; j<19; j++)
				{
					Plot2D(ctx, i, wgt->y+j, 0xE8E8E800);
				}
				Plot2D(ctx, i, wgt->y+19, 0xD8D8D800);
				Plot2D(ctx, i, wgt->y+20, 0x98989800);
				Plot2D(ctx, i, wgt->y+21, 0x60606000);
			}
			if (wgt->ctx)
			{
				k=24;
				Blot2D(ctx, wgt->x+4, wgt->y+4, wgt->ctx);
			}
			else
			{
				k=8;
			}
			text_ctx = NewContext2D(wgt->width-wgt_button->width-24, 20, display.bpp);
			text_ctx->alpha_color=0x00FF0000;
			Fill2D(text_ctx, text_ctx->alpha_color);
			Bitmap16Print2D(text_ctx, 1, 1, theme.medium, font, wgt->text);
			Bitmap16Print2D(text_ctx, 0, 0, theme.focus_title_fg, font, wgt->text);
			Blot2D(ctx, wgt->x+((wgt->width/2)-(wgt->text_width/2)), wgt->y+4, text_ctx);
			DelContext2D(text_ctx);
		}
	}
	else
	{ //TODO: add "disabled"

	}
}