EContext2D *font_fw812_ctx = LoadPNG("FixedWidthFont.png");

I64 font_ox, font_oy;
I64 font_sx, font_sy;

U0 ETEDrawChar(EContext2D *ctx, I64 x, I64 y, U8 ch, U32 fg=0xFFFFFF00, U32 bg=0, I64 font=NULL)
{
    EContext2D *font_ctx;
    I64 font_iw;
    I64 font_ih;
    I64 font_dw;
    I64 font_dh;

    switch (font)
    {
        case 0:
        default:
            font_ctx = font_fw812_ctx;
            font_iw = 7;
            font_dw = 6;
            font_ih = 15;
            font_dh = 12;
            break;
    }

    font_oy = (ch/91) * font_ih;
    //ch -= (ch/91);
    font_ox = ch%91 * font_iw;

    for (font_sy=0;font_sy<font_dh;font_sy++)
    {
        for (font_sx=0;font_sx<font_dw;font_sx++)
        {
            if (!Peek2D(font_ctx, font_ox+font_sx, font_oy+font_sy))
            {
                Plot2D(ctx, x+font_sx, y+font_sy, fg);
            }
            else
            {
                if (bg.u8[3]!=0xFF)
                {
                    Plot2D(ctx, x+font_sx, y+font_sy, bg);
                }
            }
        }
    }

}