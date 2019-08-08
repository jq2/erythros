class EContext2D
{
I64 width;
I64 height;
I64 bpp;
I64 alpha_color;
U8 *fb;
};

EContext2D *NewContext2D(I64 width, I64 height, I64 bpp=display.bpp)
{ //Create new Context2D.
	switch (bpp)
	{
	case 32:
	case 24:
		break;
	default:
		return NULL;
		break;
	}
	EContext2D *ctx = CAlloc(sizeof(EContext2D));
	ctx->width = width;
	ctx->height = height;
	ctx->bpp = bpp;
	ctx->alpha_color = -1;
	ctx->fb = CAlloc((width*height)*bpp/8);
	return ctx;
}

U0 DelContext2D(EContext2D *ctx)
{
	if (!ctx)
	{
		return;
	}
	Free(ctx->fb);
	Free(ctx);
}

U0 Fill2D(EContext2D *ctx, U32 color=0)
{ //Fill a Context2D with color.
	U64 i = ctx->fb;
	I64 pos = 0;
	while (pos<(ctx->width*ctx->height)*ctx->bpp/8)
	{
		(i+pos)(U8*)[0]=color.u8[1];
		(i+pos)(U8*)[1]=color.u8[2];
		(i+pos)(U8*)[2]=color.u8[3];
		switch (ctx->bpp)
		{
		case 32:
			pos+=4;
			break;
		case 24:
			pos+=3;
			break;
		default:
			break;
		}
	}
}

U32 Peek2D(EContext2D *ctx, I64 x, I64 y)
{ //Return RGB value for pixel.
	U32 color=0;
	if (x<0 || x>ctx->width-1 || y<0 || y>ctx->height-1)
	{
		return 0xFFFFFFFF;
	}
	U64 i = ctx->fb;
	I64 pos = (ctx->width*y)*(ctx->bpp/8);
	pos += x*(ctx->bpp/8);
	color.u8[1]=(i+pos)(U8*)[0];
	color.u8[2]=(i+pos)(U8*)[1];
	color.u8[3]=(i+pos)(U8*)[2];
	return color;
}

U0 Plot2D(EContext2D *ctx, I64 x, I64 y, U32 color)
{ //Plot a pixel.
	if (x<0 || x>ctx->width-1 || y<0 || y>ctx->height-1)
	{
		return;
	}
	U64 i = ctx->fb;
	I64 pos = (ctx->width*y)*(ctx->bpp/8);
	pos += x*(ctx->bpp/8);
	(i+pos)(U8*)[0]=color.u8[1];
	(i+pos)(U8*)[1]=color.u8[2];
	(i+pos)(U8*)[2]=color.u8[3];
}

U0 HLine2D(EContext2D *ctx, I64 x, I64 y, I64 x2, U32 color)
{ //Draw a horizontal line.
	if (x2<x)
	{
		return;
	}
	while (x<x2+1)
	{
		Plot2D(ctx, x, y, color);
		x++;
	}
}

U0 VLine2D(EContext2D *ctx, I64 x, I64 y, I64 y2, U32 color)
{ //Draw a vertical line.
	if (y2<y)
	{
		return;
	}
	while (y<y2+1)
	{
		Plot2D(ctx, x, y, color);
		y++;
	}
}

U0 Blot2D(EContext2D *dst, I64 x, I64 y, EContext2D *src)
{
	if (src==NULL || dst==NULL)
	{
		return;
	}
	U8 *chk_alpha_ptr;
	U32 chk_alpha;
	U64 i=dst->fb;
	U64 j=src->fb;
	I64 xx,yy;
	I64 dx,sx;
	i+=(x*dst->bpp/8)+((dst->width*y)*dst->bpp/8);
	for (yy=0; yy<src->height; yy++)
	{
		dx=0;
		sx=0;
		for (xx=0; xx<src->width; xx++)
		{
			chk_alpha_ptr=j+dx+((src->width*yy)*src->bpp/8);
			chk_alpha=0;
			chk_alpha.u8[1]=chk_alpha_ptr[0];
			chk_alpha.u8[2]=chk_alpha_ptr[1];
			chk_alpha.u8[3]=chk_alpha_ptr[2];

			if ((chk_alpha!=src->alpha_color || src->alpha_color==-1) &&
			    x+xx>-1 && y+yy>-1 &&
			    x+xx<dst->width && y+yy<dst->height)
			{
				MemCpy(i+sx+((dst->width*yy)*dst->bpp/8), j+dx+((src->width*yy)*src->bpp/8), 3);
			}
			switch (dst->bpp)
			{
			case 32:
				dx+=4;
				break;
			case 24:
				dx+=3;
				break;
			default:
				break;
			}
			switch (src->bpp)
			{
			case 32:
				sx+=4;
				break;
			case 24:
				sx+=3;
				break;
			default:
				break;
			}
		}
	}
}

U0 CopyRect2D(EContext2D *ctx, I64 x, I64 y, EContext2D *rect)
{//Copy rect with clipping.

  U8 *ctx_pos=ctx->fb;
  U8 *rect_pos=rect->fb;
  I64 rect_row=0;  
  I64 rect_y_ofs=0;
  I64 rect_x_ofs=0;
  I64 clip_y=0;
  U8 *rect_line;

  //Handle horizontal clipping left
  while (x<0) { rect_x_ofs++; x++; }

  //Handle vertical clipping top
  while (y<0)
  {
    rect_pos+=(rect->width)*(display.bpp/8);
    rect_y_ofs++; y++;
  }

  // default, clip line to copy as width-left off screen
  rect_line=rect->width-rect_x_ofs;

  if (-rect_x_ofs+x+rect->width>=ctx->width)
  {
    rect_line-=((-rect_x_ofs+x+rect->width)-ctx->width);
  }  

  rect_pos+=(rect_x_ofs)*(display.bpp/8);
  clip_y = y;
  while (rect_row<(rect->height-rect_y_ofs) && clip_y<ctx->height) 
  {    
    MemCpy(ctx_pos+(y*((ctx->width)*(display.bpp/8)))+x*(display.bpp/8),rect_pos,(rect_line)*(display.bpp/8));
    ctx_pos+=(ctx->width)*(display.bpp/8);
    rect_pos+=(rect->width)*(display.bpp/8);
	clip_y++;
    rect_row++;
  }
}

U0 Rect2D(EContext2D *ctx, I64 x, I64 y, I64 w, I64 h, U32 color)
{ //Draw a rectangle fill.
	EContext2D *tmpctx=NewContext2D(w, h, display.bpp);
	Fill2D(tmpctx, color);
	//Blot2D(ctx, x, y, tmpctx);
	CopyRect2D(ctx, x, y, tmpctx);
	DelContext2D(tmpctx);
}

I64 Bitmap16Print2D(EContext2D *ctx, I64 x, I64 y, U32 color=0, U16 *chr=FONT_WINTITLE16, U8 *fmt,...)
{ //Print formatted string with 16x16 bitmap font.
	Bool skip;
	U8 *buf;
	if (argc)
	{
		buf=StrPrintJoin(NULL, fmt, argc, argv);
	}
	else
	{
		buf=StrNew(fmt);
	}
	U8 *str=buf;
	I64 xx,yy;
	I64 space;
	U16 *pos;
	while (*str)
	{
		skip=FALSE;
		if (*str==' ')
		{
			skip=TRUE;
		}
		space=0;
		pos = chr;
		pos += ((*str)-32)*16;
		for (yy=0; yy<16; yy++)
		{
			for (xx=0; xx<16; xx++)
			{
				if (*pos & 1<<xx == 1<<xx && !skip)
				{
					if (xx>space)
					{
						space = xx;
					}
					Plot2D(ctx, x+xx, y+yy, color);
				}
			}
			pos++;
		}
		if (skip)
		{
			space=4;
		}
		str++;
		if (*str)
		{
			switch (chr)
			{
				case FONT_SMOL16:
					x += space + 1;
					break;
				default:
					x += space + 2;
					break;
			}
		}
		else
		{
			x += space;
		}
	}
	Free(buf);
	return x;
}

I64 Bitmap16PrintSpc2D(EContext2D *ctx, I64 x, I64 y, U32 color=0, U16 *chr=FONT_WINTITLE16, U8 *fmt,...)
{ //Print formatted string with 16x16 bitmap font, leaving trailing whitespace. (this is a kludge...for now)
	Bool skip;
	U8 *buf;
	if (argc)
	{
		buf=StrPrintJoin(NULL, fmt, argc, argv);
	}
	else
	{
		buf=StrNew(fmt);
	}
	U8 *str=buf;
	I64 xx,yy;
	I64 space;
	U16 *pos;
	while (*str)
	{
		skip=FALSE;
		if (*str==' ')
		{
			skip=TRUE;
		}
		space=0;
		pos = chr;
		pos += ((*str)-32)*16;
		for (yy=0; yy<16; yy++)
		{
			for (xx=0; xx<16; xx++)
			{
				if (*pos & 1<<xx == 1<<xx && !skip)
				{
					if (xx>space)
					{
						space = xx;
					}
					Plot2D(ctx, x+xx, y+yy, color);
				}
			}
			pos++;
		}
		if (skip)
		{
			space=4;
		}
		str++;
		switch (chr)
		{
			case FONT_SMOL16:
				x += space + 1;
				break;
			default:
				x += space + 2;
				break;
		}
	}
	Free(buf);
	return x;
}

I64 Bitmap16PrintRange2D(EContext2D *ctx, I64 x, I64 y, U32 color=0, U32 bgcolor, I64 start, I64 end, U16 *chr=FONT_WINTITLE16, U8 *fmt,...)
{ //Print formatted string with 16x16 bitmap font, only chars specified in range start-end. Used for highlighting.
	if (start<0)
	{
		return 0;
	}
	Bool skip;
	Bool dirty_col;
	I64 x_start=0;
	I64 x_end=0;
	U8 *buf=StrPrintJoin(NULL, fmt, argc, argv);
	U8 *str=buf;
	I64 xx,yy;
	I64 space;
	U16 *pos;
	I64 ctr=0;
	while (*str)
	{
		skip=FALSE;
		if (*str==' ')
		{
			skip=TRUE;
		}
		space=0;
		pos = chr;
		pos += ((*str)-32)*16;
		for (yy=0; yy<16; yy++)
		{
			
			for (xx=0; xx<16; xx++)
			{
				dirty_col=FALSE;
				if (*pos & 1<<xx == 1<<xx && !skip)
				{
					if (xx>space)
					{
						space = xx;
					}
					dirty_col=TRUE;
				}
				if (dirty_col)
				{
					if (ctr>=start && ctr<end)
					{
						if (x_start==0)
						{
							x_start = x+xx;
						}
						else
						{
							x_end = x+xx;
						}
						//VLine2D(ctx, x+xx, y, ctx->height, bgcolor);		
					}			
				}
			}
			pos++;
		}
		if (skip)
		{			
			if (ctr>=start && ctr<end)
			{
				if (x_start==0)
				{
					x_start = x+space+4;
				}
				else
				{
					x_end = x+space+4;
				}
			}
			space=4;
		}
		str++;
		ctr++;
		switch (chr)
		{
			case FONT_SMOL16:
				if (ctr>=start && ctr<end)
				{
					if (ctr>=start && ctr<end)
					{
						if (x_start==0)
						{
							x_start = x+space+1;
						}
						else
						{
							x_end = x+space+1;
						}
					}
				}
				x += space + 1;
				break;
			default:
				if (ctr>=start && ctr<end)
				{
					if (ctr>=start && ctr<end)
					{
						if (x_start==0)
						{
							x_start = x+space+2;
						}
						else
						{
							x_end = x+space+2;
						}
					}
				}
				x += space + 2;
				break;
		}
	}
	if (x_start)
	{
		if (buf[0]==0x20 && x_start<5)
		{
			x_start=1;
		}
		if (!x_end)
		{
			x_start=1;
			x_end=x_start+4;
		}
		Rect2D(ctx, x_start, 0, x_end-x_start+2, ctx->height, bgcolor);
	}
	Free(buf);
	return x;
}

I64 Bitmap16PrintShadow2D(EContext2D *ctx, I64 x, I64 y, U32 color1=0xFFFFFF00, U32 color2=0, U16 *chr=FONT_WINTITLE16, U8 *fmt,...)
{
	U8 *buf=StrPrintJoin(NULL, fmt, argc, argv);
	U8 *str=buf;
	Bitmap16Print2D(ctx, x+1, y+1, color2, chr, buf);
	I64 xx = Bitmap16Print2D(ctx, x, y, color1, chr, buf);
	Free(buf);
	return xx;
}

U0 ConsolePrint2D(EContext2D *ctx, I64 x, I64 y, U32 color=0xFFFFFF00, U32 colorbg=0, U8 *fmt,...)
{ //Print formatted string using console font.
	Bool skip;
	U8 *buf=StrPrintJoin(NULL, fmt, argc, argv);
	U8 *str=buf;
	I64 orig_x=x;
	I64 xx,yy;
	U64 *chr = console_font;
	while (*str)
	{   skip=FALSE;
	    if (*str=='\n')
	    {
		    skip=TRUE;
		    y+=16;
		    x=orig_x-8;
	    }
	    for (yy=0; yy<16; yy++)
	    {
		    for (xx=0; xx<8; xx++)
		    {
			    if (chr[(*str)*2].u8[yy] & 1<<xx == 1<<xx && !skip)
			    {
				    Plot2D(ctx, x+xx, y+yy, color);
			    }
			    else
			    {
				    Plot2D(ctx, x+xx, y+yy, colorbg);
			    }
		    }
	    }
	    x+=8;
	    str++; }
	Free(buf);
}

U0 SwapBGR(U8 *buf, I64 width, I64 height, I64 bpp)
{ //Swap RGB->BGR raw bitmap.
	I64 start_pos=buf;
	I64 tmp;
	switch (bpp)
	{
	case 32:
	case 24:
		break;
	default:
		return;
	}
	while (buf<start_pos+((width*height)*bpp/8))
	{
		tmp=buf[0];
		buf[0]=buf[2];
		buf[2]=tmp;
		switch (bpp)
		{
		case 32:
			buf+=4;
			break;
		case 24:
			buf+=3;
			break;
		default:
			break;
		}
	}
}

EContext2D *sys_fb = CAlloc(sizeof(EContext2D));

U0 SysFrameBufferInit()
{ //Init values for Context2D alias to system framebuffer.
	sys_fb->width = display.width;
	sys_fb->height = display.height;
	sys_fb->bpp = display.bpp;
	sys_fb->alpha_color = -1;
	sys_fb->fb = svga.fb;
}