U0 FreeArgs(I64 argc, U8 **argv)
{
    I64 i;
	for (i = 0; i < argc; i++)
	{
		Free(argv[i]);
	}
	if (argv)
	{
		Free(argv);
	}
}

U8 **ParseArgs(U8 *str, I64 *argc)
{ // Return argc, argv from str.
	Bool quoted = FALSE;
	I64 _argc = 0;
	U8 **_argv = NULL;
	U8 **_tmp = CAlloc(sizeof(U64) * StrLen(str));
	I64 i = 0;
	I64 s = 0;
	I64 len;
	while (i < StrLen(str) + 1)
	{
		switch (str[i])
		{
		case 0:
		case ' ':
			if (!quoted)
			{
				len = (str + i)-(str + s - 1);
				if (str[i - 1] == '"')
				{
					len--;
				}
				if (len - 1)
				{
					_tmp[_argc] = CAlloc(len);
					MemCpy(_tmp[_argc], str + s, len-1);
					_argc++;
				}
				s = i + 1;
			}
			break;
		case '"':
			quoted = !quoted;
			if (quoted)
			{
				s = i + 1;
			}
			break;
		default:
			break;
		}
		i++;
	}
	*argc = _argc;
	_argv = CAlloc(sizeof(U64) * _argc);
	MemCpy(_argv, _tmp, sizeof(U64) * _argc);
	Free(_tmp);
	return _argv;
}

class EConAutoComplete
{
    I64 depth;
    I64 length[8];
    U8 ***entries;    
}

class EConHistory
{
    I64 limit;
    I64 pos;
    U8 **entries;
}

class EConReadLine
{
    EConAutoComplete *ac;
    EConHistory *history;
    Bool multi_ac;
};

EContext2D *term_ctx = NewContext2D(display.width, display.height, display.bpp);

U32 ConColPeek(U32 *buf, I64 x, I64 y)
{
    return buf[(y*display.width)+x];
}

U0 ConColPlot(U32 *buf, I64 x, I64 y, U32 color)
{
    buf[(y*display.width)+x]=color;
}

U0 ConPutChar(EConsole *con, U8 ch)
{
    if (con->disable_echo)
    {
        return;
    }
    switch (ch)
    {
        case 8:
            con->screen_x--;
            if (con->screen_x<0)
            {
                con->screen_x=con->ch_width-1;
                con->screen_y--;
                if (con->screen_y<0)
                {
                    con->screen_y=0;
                }
            }
            con->ch_buf->color=0;
            GrPlot(con->ch_buf, con->scroll_x+con->screen_x, con->scroll_y+con->screen_y);
            ConColPlot(con->fg_buf, con->scroll_x+con->screen_x, con->scroll_y+con->screen_y, con->fg_color);
            ConColPlot(con->bg_buf, con->scroll_x+con->screen_x, con->scroll_y+con->screen_y, con->bg_color);
            break;
        case 10:
            // Line feed
            con->screen_x=0;
            con->screen_y++;
            if (con->screen_y>con->ch_height-1)
            {
                con->screen_y--;
                con->scroll_y++;
            }
            break;
        case 13:
            // Carriage return
            con->screen_x=0;
            break;
        default:
            con->ch_buf->color=ch;
            GrPlot(con->ch_buf, con->scroll_x+con->screen_x, con->scroll_y+con->screen_y);
            ConColPlot(con->fg_buf, con->scroll_x+con->screen_x, con->scroll_y+con->screen_y, con->fg_color);
            ConColPlot(con->bg_buf, con->scroll_x+con->screen_x, con->scroll_y+con->screen_y, con->bg_color);
            con->screen_x++;
            if (con->screen_x>con->ch_width-1)
            {
                con->screen_x=0;
                con->screen_y++;
                if (con->screen_y>con->ch_height-1)
                {
                    con->screen_y--;
                    con->scroll_y++;
                }
            }
            break;
    }
}

U0 ConClear(EConsole *con)
{
    I64 _i;
	DCFill(con->ch_buf, 0);
	for (_i=0;_i<display.width*128;_i++)
	{
		con->fg_buf[_i]=0xFFFFFF00;
		con->bg_buf[_i]=0x00000000;
	}
    con->scroll_x=0;
    con->scroll_y=0;
    con->screen_x=0;
    con->screen_y=0;
}

U0 ConPrint(EConsole *con, U8 *fmt,...)
{
    I64 _i;
   	U8 *buf;
	if (argc)
	{
		buf=StrPrintJoin(NULL, fmt, argc, argv);
	}
	else
	{
		buf=StrNew(fmt);
	}
    for (_i=0;_i<StrLen(buf);_i++)
    {
        ConPutChar(con, buf[_i]);
    }
    Free(buf);
}
extern U0 ShellRefreshAutoComplete(EConReadLine *rl);

U8 *StrCommonMatch(I64 size, U8 **strs)
{
    U8 *res=CAlloc(1024);
    I64 pos = 0;
    Bool match;
    U8 *matrix = CAlloc(256);
    I64 i, j, k, l;
    U8 m;

    k = 0;
    match = TRUE;
    while (match)
    {
        MemSet(matrix, 0, 256);

        // Get count of all chars for char position
        for (i = 0; i < 256; i++)
        {
            for (j = 0; j < size; j++)
            {
                if (strs[j])
                {
                    if (k<StrLen(strs[j])-1)
                    { // Remove shorter strings from list.
                        if (strs[j][k] == i)
                        {
                            matrix[i]++;
                        }
                    }
                    else
                    {
                        //strs[j] = NULL;
                    }
                }
            }
        }

        j = 0;
        // Find out if unique common character exists
        for (i = 0; i < 256; i++)
        {
            j += matrix[i];
        }
        for (i = 0; i < 256; i++)
        {
            if (matrix[i] > 0)
            {
                if (matrix[i] == j)
                {
                    res[pos] = i;
                    pos++;
                }
                else
                {
                    match = FALSE;
                    i = 256;
                }
            }
        }

        /*
        
        // Find if highest count >1
        j = 0;
        for (i = 0; i < 256; i++)
        {
            j = Max(j, matrix[i]);
        }

        l = 0;
        m = 0;
        if (j > 1)
        {
            // Find if highest count is unique.
            for (i = 0; i < 256; i++)
            {
                if (matrix[i] == j)
                {
                    l++;
                    if (l == 1)
                    {// Get common char
                        m = i;
                    }
                }
            }
        }

        if (l == 1)
        {
            for (i = 0; i < size; i++)
            {
                if (strs[i])
                {
                    if (strs[i][k] != m)
                    { // Remove non-matching strings from list.
                        strs[i] = NULL;
                    }
                }
            }
            res[pos] = m;
            pos++;                                               
        }

        if (j == 1)
        {
            match = FALSE;
        }

        */

        k++;
    }
    Free(matrix);
    return res;
}


U8 *ConReadLine(EConsole *con, EConReadLine *rl, I64 size)
{
    Bool ac_match;
    I64 ac_argc;
    I64 ac_res;
    I64 ac_ew = 0;
    I64 ac_match_pos = 0;
    I64 ac_match_col = 0;
    U8 **ac_argv = NULL;
    U8 **ac_matches = NULL;
    U8 *ac_chk_str;
    U8 *ac_out_str;
    U8 *ac_res_str;
    U8 *res = CAlloc(size);
    U8 ch;
    U8 match_ch;
    I64 i, j, k, l, m;
    I64 pos=-1;
    I64 hist_idx = rl->history->pos;
    while (1)
    {
        while (FifoU8Cnt(con->stdin))
        {
            FifoU8Rem(con->stdin, &ch);
            switch (ch)
            {
                case 8:
                    if (pos>-1)
                    {
                        res[pos]=0;
                        pos--;
                        ConPutChar(con, ch);
                    }
                    rl->multi_ac = FALSE;
                    break;
                case 9:
                    /*
                    ConPrint(con, "\n");
                    for (i=0;i<rl->ac->length[0];i++)
                    {
                        ConPrint(con, "%d: %08X, %s\n", i, rl->ac->entries[0][i], rl->ac->entries[0][i]);    
                    }
                    */
                    ac_argv = ParseArgs(res, &ac_argc);
                    //if (ac_argc <2 && res[pos] == ' ')
                    if (res[pos] == ' ')
                    {
                        rl->multi_ac = FALSE;
                        break;
                    }
                    switch (ac_argc)
                    {
                        case 1:
                            ac_res = 0;
                            ac_out_str = NULL;
                            for (i = 0; i < rl->ac->length[0]; i++)
                            {
                                ac_chk_str = rl->ac->entries[0][i]+5;
                                ac_match = TRUE;
                                for (j = 0; j < StrLen(ac_argv[0]); j++)
                                {
                                    if (ac_argv[0][j] != ac_chk_str[j])
                                    {
                                        ac_match = FALSE;
                                        j = StrLen(ac_argv[0]);
                                    }
                                }
                                if (ac_match)
                                {
                                    if (!ac_out_str)
                                    {
                                        ac_out_str = ac_chk_str;
                                    }
                                    ac_res++;
                                }
                            }
                            switch (ac_res)
                            {
                                case 0:
                                    break;
                                case 1:
                                    for (k = StrLen(ac_argv[0]); k < StrLen(ac_out_str); k++)
                                    {
                                        FifoU8Ins(con->stdin, ac_out_str[k]);
                                    }
                                    FifoU8Ins(con->stdin, ' ');
                                    rl->multi_ac = FALSE;
                                    break;
                                default:
                                    if (rl->multi_ac)
                                    {
                                        ConPrint(con, "\n");
                                        for (i = 0; i < rl->ac->length[0]; i++)
                                        {
                                            ac_chk_str = rl->ac->entries[0][i]+5;
                                            ac_match = TRUE;
                                            for (j = 0; j < StrLen(ac_argv[0]); j++)
                                            {
                                                if (ac_argv[0][j] != ac_chk_str[j])
                                                {
                                                    ac_match = FALSE;
                                                    j = StrLen(ac_argv[0]);
                                                }
                                            }
                                            if (ac_match)
                                            {
                                                ConPrint (con, "%s  ", ac_chk_str);                                         
                                            }
                                        }
                                        ConPrint(con, "\n");
                                        for (i = 0; i < StrLen(ac_argv[0]); i++)
                                        {
                                            FifoU8Ins(con->stdin, ac_argv[0][i]);
                                        }
                                        FifoU8Ins(con->stdin, 9);
                                        for (i = 0; i < ac_argc; i++)
                                        {
                                            Free(ac_argv[i]);
                                        }
                                        if (ac_argv)
                                        {
                                            Free(ac_argv);
                                        }
                                        Free(res);
                                        return NULL;
                                    }
                                    rl->multi_ac = TRUE;
                                    break;
                            }
                            break;
                        default:
                            ac_matches = CAlloc(sizeof(U64)*rl->ac->length[1]);
                            ac_res = 0;
                            ac_out_str = NULL;
                            for (i = 0; i < rl->ac->length[1]; i++)
                            {
                                ac_chk_str = rl->ac->entries[1][i];
                                ac_match = TRUE;
                                for (j = 0; j < StrLen(ac_argv[ac_argc-1]); j++)
                                {
                                    if (ac_argv[ac_argc-1][j] != ac_chk_str[j])
                                    {
                                        ac_match = FALSE;
                                        j = StrLen(ac_argv[ac_argc-1]);
                                    }
                                }
                                if (ac_match)
                                {
                                    if (!ac_out_str)
                                    {
                                        ac_out_str = ac_chk_str;
                                    }
                                    ac_matches[ac_match_pos] = ac_chk_str;
                                    ac_match_pos++;
                                    ac_res++;
                                }
                            }
                            switch (ac_res)
                            {
                                case 0:
                                    break;
                                case 1:
                                    for (k = StrLen(ac_argv[ac_argc-1]); k < StrLen(ac_out_str); k++)
                                    {
                                        FifoU8Ins(con->stdin, ac_out_str[k]);
                                    }
                                    if (ac_out_str[k-1] != '/')
                                    {
                                        FifoU8Ins(con->stdin, ' ');
                                    }
                                    rl->multi_ac = FALSE;
                                    break;
                                default:
                                    if (rl->multi_ac)
                                    {
                                        ConPrint(con, "\n");
                                        for (i = 0; i < rl->ac->length[1]; i++)
                                        {
                                            ac_chk_str = rl->ac->entries[1][i];
                                            ac_match = TRUE;
                                            for (j = 0; j < StrLen(ac_argv[ac_argc-1]); j++)
                                            {
                                                if (ac_argv[ac_argc-1][j] != ac_chk_str[j])
                                                {
                                                    ac_match = FALSE;
                                                    j = StrLen(ac_argv[ac_argc-1]);
                                                }
                                            }
                                            if (ac_match)
                                            {
                                                ac_ew = Max(ac_ew, StrLen(ac_chk_str) + 2);
                                            }
                                        }
                                        for (i = 0; i < rl->ac->length[1]; i++)
                                        {
                                            ac_chk_str = rl->ac->entries[1][i];
                                            ac_match = TRUE;
                                            for (j = 0; j < StrLen(ac_argv[ac_argc-1]); j++)
                                            {
                                                if (ac_argv[ac_argc-1][j] != ac_chk_str[j])
                                                {
                                                    ac_match = FALSE;
                                                    j = StrLen(ac_argv[ac_argc-1]);
                                                }
                                            }
                                            if (ac_match)
                                            {
                                                ConPrint(con, "%s", ac_chk_str);
                                                for (j = 0; j < ac_ew - StrLen(ac_chk_str); j++)
                                                {
                                                    ConPrint(con, " ");
                                                }
                                                if (con->screen_x + ac_ew >= con->ch_width)
                                                {
                                                    ConPrint(con, "\n");
                                                }                                                
                                            }
                                        }                                        
                                        ConPrint(con, "\n");

                                        for (i = 0; i < ac_argc-1; i++)
                                        {
                                            for (j = 0; j < StrLen(ac_argv[i]); j++)
                                            {
                                                FifoU8Ins(con->stdin, ac_argv[i][j]);
                                            }
                                            FifoU8Ins(con->stdin, ' ');

                                        }
                                        
                                        /*
                                        for (i = 0; i < StrLen(ac_argv[ac_argc-1]); i++)
                                        {
                                            FifoU8Ins(con->stdin, ac_argv[ac_argc-1][i]);
                                        }
                                        */
                                        
                                        ac_res_str = StrCommonMatch(ac_match_pos, ac_matches);
                                        for (i = 0; i < StrLen(ac_res_str); i++)
                                        {
                                            FifoU8Ins(con->stdin, ac_res_str[i]);
                                        }
                                        Free(ac_res_str);
                                        FifoU8Ins(con->stdin, 9);
                                        for (i = 0; i < ac_argc; i++)
                                        {
                                            Free(ac_argv[i]);
                                        }
                                        if (ac_argv)
                                        {
                                            Free(ac_argv);
                                        }
                                        Free(res);
                                        Free(ac_matches);
                                        return NULL;
                                    }
                                    ac_res_str = StrCommonMatch(ac_match_pos, ac_matches);
                                    j = 0;
                                    for (i = StrLen(ac_argv[ac_argc-1]); i < StrLen(ac_res_str); i++)
                                    {
                                        FifoU8Ins(con->stdin, ac_res_str[i]);
                                        j++;
                                    }
                                    Free(ac_res_str);
                                    if (j)
                                    {
                                        FifoU8Ins(con->stdin, 9);
                                    }
                                    rl->multi_ac = TRUE;
                                    break;
                            }
                            Free(ac_matches);
                            break;
                    }
                    for (i = 0; i < ac_argc; i++)
                    {
                        Free(ac_argv[i]);
                    }
                    if (ac_argv)
                    {
                        Free(ac_argv);
                    }
                    break;
                case 10:
                    ConPutChar(con, ch);
                    rl->multi_ac = FALSE;
                    return res;
                    break;
                case 17:
                    hist_idx = Max(0, hist_idx - 1);
                    while (!rl->history->entries[hist_idx])
                    {
                        hist_idx--;
                    }
                    while (pos>-1)
                    {
                        res[pos]=0;
                        pos--;
                        ConPutChar(con, 8);
                    }
                    for (i = 0; i < StrLen(rl->history->entries[hist_idx]); i++)
                    {
                        pos++;
                        res[pos] = rl->history->entries[hist_idx][i];
                        ConPutChar(con, rl->history->entries[hist_idx][i]);
                    }
                    rl->multi_ac = FALSE;
                    break;
                case 18:
                    while (pos>-1)
                    {
                        res[pos]=0;
                        pos--;
                        ConPutChar(con, 8);
                    }
                    hist_idx++;
                    if (hist_idx > rl->history->limit-1)
                    {
                        hist_idx--;
                    }
                    else
                    {
                        if (rl->history->entries[hist_idx])
                        {
                            for (i = 0; i < StrLen(rl->history->entries[hist_idx]); i++)
                            {
                                pos++;
                                res[pos] = rl->history->entries[hist_idx][i];
                                ConPutChar(con, rl->history->entries[hist_idx][i]);
                            }
                        }
                    }
                    rl->multi_ac = FALSE;
                    break;
                case 19:
                case 20:
                    rl->multi_ac = FALSE;
                    break;
                default:
                    pos++;
                    res[pos] = ch;
                    ConPutChar(con, ch);
                    rl->multi_ac = FALSE;
                    break;
            }
        }
        Sleep(1);
    }
}

U0 ConDocDump(EConsole *con, CDoc *doc, CDocEntry *de=NULL)
{
  U8 *st;
  CDocEntry *doc_e,*doc_e2;
  Bool unlock=DocLock(doc);
  doc_e=doc->head.next;
  if (de)
  {
      doc_e=de;
  }
  while (doc_e!=doc) {
    st=DocScanLine(doc,doc_e,NULL,&doc_e2);
    ConPrint(con, st);
    Free(st);
    doc_e=doc_e2;
    if (doc_e->type_u8==DOCT_NEW_LINE) {
      ConPrint(con, "\n");
      doc_e=doc_e->next;
    }
  }
  if (unlock)
    DocUnlock(doc);
}

Bool CharIsHilighted(EConsole *con, I64 bx, I64 by)
{
    if (con->hl_x1==-1 || con->hl_x2==-1 || 
        con->hl_y1==-1 || con->hl_y2==-1)
    {
        return FALSE;
    }
    I64 i, j;

    I64 lx;
    I64 hx;

    I64 ly = Min(con->hl_y1, con->hl_y2);
    I64 hy = Max(con->hl_y1, con->hl_y2);

    if (ly == con->hl_y1)
    {
        lx = con->hl_x1;
    }
    else
    {
        lx = con->hl_x2;
    }
    if (hy == con->hl_y1)
    {
        hx = con->hl_x1;
    }
    else
    {
        hx = con->hl_x2;
    }
    if (ly==hy)
    {
        lx = Min(con->hl_x1, con->hl_x2);
        hx = Max(con->hl_x1, con->hl_x2);
    }

    i = lx;
    j = ly;

    while (j < hy+1)
    {
        if (j == hy)
        {
            if (bx-con->scroll_x > hx)
            {
                return FALSE;
            }
        }
        if (i==bx-con->scroll_x && j==by-con->scroll_y)
        {
            return TRUE;

        }
        i++;
        if (i > con->ch_width)
        {
            i = 0;
            j++;
        }
    }

    return FALSE;
}

U0 ResetHilight(EConsole *con)
{
    con->hl_x1 = -1;
    con->hl_x2 = -1;
    con->hl_y1 = -1;
    con->hl_y2 = -1;
}

U0 DrawConsoles(EConsole *consoles)
{
    EConsole *con;
    
    I64 bx, by, bc1, bc2, bc3;
    U32 fg, bg;
    while (1)
    {        
        con = consoles->next;
        while (con)
        {
            Fill2D(term_ctx, 0);
            for (by=0;by<con->ch_height;by++)
            {
                for (bx=0;bx<con->ch_width;bx++)
                {
                    fg = ConColPeek(con->fg_buf, con->scroll_x+bx, con->scroll_y+by);
                    bg = ConColPeek(con->bg_buf, con->scroll_x+bx, con->scroll_y+by);
                    if (CharIsHilighted(con, con->scroll_x+bx, con->scroll_y+by))
                    {
                        fg = con->fg_hilight;
                        bg = con->bg_hilight;
                    }
                    ETEDrawChar(term_ctx, bx*6, by*12, GrPeek(con->ch_buf, con->scroll_x+bx, con->scroll_y+by),
                        fg, bg);
                }
            }

            for (by=0;by<con->win->height;by++)  
            {   
                for (bx=0;bx<con->win->width;bx++)   
                {   
                    bc1=Peek2D(term_ctx, bx, by);
                    bc2=Peek2D(con->win->alpha_ctx, con->wgt->x+bx, con->wgt->y+by);  
                    bc3.u8[1] = (bc2.u8[1] * 0.25) + (bc1.u8[1] * (1.0 - 0.25));    
                    bc3.u8[2] = (bc2.u8[2] * 0.25) + (bc1.u8[2] * (1.0 - 0.25));    
                    bc3.u8[3] = (bc2.u8[3] * 0.25) + (bc1.u8[3] * (1.0 - 0.25));    
                    Plot2D(term_ctx, bx, by, bc3);   
                }   
            }   

            for (by=0;by<con->ch_height;by++)
            { // Draw foreground text without alpha
                for (bx=0;bx<con->ch_width;bx++)
                {
                    fg = ConColPeek(con->fg_buf, con->scroll_x+bx, con->scroll_y+by);
                    if (CharIsHilighted(con, con->scroll_x+bx, con->scroll_y+by))
                    {
                        fg = con->fg_hilight;
                    }
                    ETEDrawChar(term_ctx, bx*6, by*12, GrPeek(con->ch_buf, con->scroll_x+bx, con->scroll_y+by),
                        fg, -1);
                }
            }
            
            if (Blink || wmgr->active_key)
            {
                Rect2D(term_ctx, con->screen_x*6, con->screen_y*12, 6, 12, con->fg_color);
            }

            CopyRect2D(con->wgt->ctx, 0, 0, term_ctx);

            con=con->next;
        }

        Sleep(1);
    }
}
