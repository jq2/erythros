U0 EDbgPlot2D(I64 x, I64 y, U32 color)
{
	U64 i = svga.fb;
	I64 pos = (svga.width*y)*svga.bpp/8;
	pos += x*svga.bpp/8;
	(i+pos)(U8*)[0]=color.u8[1];
	(i+pos)(U8*)[1]=color.u8[2];
	(i+pos)(U8*)[2]=color.u8[3];
}

U0 EDbgChar2D(I64 x, I64 y, I64 ch)
{
	U64 *char=console_font;
	I64 xx,yy;
	I64 ii=0;
	ch *=2;
	for (yy=0; yy<16; yy++)
	{
		xx=0;
		for (xx=0; xx<8; xx++)
		{
			if (char[ch].u8[ii] & 1<<xx == 1<<xx)
			{
				EDbgPlot2D(x+xx, y+yy, 0xFFFFFF00);
			}
			else
			{
				EDbgPlot2D(x+xx, y+yy, BLACK);
			}
		}
		ii++;
		if (ii>8)
		{
			ch++;
			ii=0;
		}
	}
}

U0 EDbgPutChar(I64 ch)
{
	text.raw_flags &=~RWF_SHOW_DOLLAR;
	if (ch>'~' && ch!=219)
	{
		ch=' ';
	}
	I64 i,row,col;
	I64 raw_pos;
	I64 raw_y;
	U8 *ptr,*ptr1,*ptr2;

	if (!(text.raw_flags&RWF_SHOW_DOLLAR)) {
		if (ch=='$$') {
			if (text.raw_flags&RWF_IN_DOLLAR) {
				text.raw_flags&=~RWF_IN_DOLLAR;
				if (!(text.raw_flags & RWF_LAST_DOLLAR)) {
					text.raw_flags&=~RWF_LAST_DOLLAR;
					return;
				}
			} else {
				text.raw_flags|=RWF_IN_DOLLAR|RWF_LAST_DOLLAR;
				return;
			}
		}
		text.raw_flags&=~RWF_LAST_DOLLAR;
		if (text.raw_flags&RWF_IN_DOLLAR)
			return;
	}
	if (ch=='\t') {
		EDbgPutChar(CH_SPACE);
		while (text.raw_col & 7)
			EDbgPutChar(CH_SPACE);
	} else if (ch==CH_BACKSPACE) {
		text.raw_col--;
		EDbgPutChar(CH_SPACE);
		text.raw_col--;
	} else if (ch=='\n') {
		EDbgPutChar(CH_SPACE);
		while (text.raw_col % text.cols)
			EDbgPutChar(CH_SPACE);

	} else if (Bt(char_bmp_displayable,ch)) {
		row=text.raw_col/text.cols%text.rows;
		col=text.raw_col%text.cols;
		if (text.raw_flags&RWF_SCROLL && text.raw_col && !row && !col) {
			for (raw_y=0; raw_y<(text.rows*16)-16; raw_y++)
			{
				MemCpy(svga.fb+(raw_y*svga.width*(svga.bpp/8)),
				       svga.fb+((raw_y+16)*svga.width*(svga.bpp/8)),
				       (text.cols*8)*(svga.bpp/8));
			}
			for (raw_y=(text.rows*16)-16; raw_y<(text.rows*16); raw_y++)
			{
				MemSet(svga.fb+(raw_y*svga.width*(svga.bpp/8)),
				       0,
				       (text.cols*8)*(svga.bpp/8));
			}
			text.raw_col-=text.cols;
			row=text.rows-1;
		}
		EDbgChar2D(col*8, row*16, ch);
		text.raw_col++;
	}
}

Bool EKDRawPutKey(I64 ch,I64)
{
	if (IsRaw) {
		EDbgPutChar(ch);
		return TRUE;
	} else
		return FALSE;
}

Bool EKDRawPutS(U8 *st)
{
	I64 ch;
	if (IsRaw) {
		while (ch=*st++)
			EDbgPutChar(ch);
		return TRUE;
	} else
		return FALSE;
}

U0 RawDrNull(CTask *task=NULL)
{
}

CKeyDevEntry *tmp_kde = keydev.put_key_head;
while (tmp_kde->put_s != &KDRawPutS)
{
	tmp_kde = tmp_kde->next;
}
tmp_kde->put_key    = &EKDRawPutKey;
tmp_kde->put_s      = &EKDRawPutS;

text.cols = display.width/8;
text.rows = display.height/16;
MemSet(console_font+(219*16), 0xFF, 16);
MemCpy(&RawDr, &RawDrNull, sizeof(RawDrNull));

U0 ShowLastTaskDoc()
{
	ETask *tmp=wmgr->tasks->next;
	while (tmp->next)
	{
		tmp = tmp->next;
	}
	DocDump(tmp->tos_task(CTask*)->put_doc);
}