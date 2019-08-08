// Erythros Constructor
U64 flags;
ETask *my_task=EWMGetTask(Fs);
my_task->title = "Constructor";
my_task->icon = LoadPNG("/System/Media/Themes/Default/Icons/16/application_form.png");

EWMInitMenu(my_task, 3);

my_task->menu->items[0]->id = 1;
my_task->menu->items[0]->text = "Project";
my_task->menu->items[1]->id = 2;
my_task->menu->items[1]->text = "Edit";
my_task->menu->items[2]->id = 3;
my_task->menu->items[2]->text = "Help";

U0 DrawGrid(EContext2D *ctx, I64 w, I64 h)
{
	ctx->alpha_color=0x00FF00FF;
	Fill2D(ctx, ctx->alpha_color);
	I64 x,y;
	for (y=0; y<ctx->height; y+=h)
	{
		for (x=0; x<ctx->width; x+=w)
		{
			Plot2D(ctx, x, y, 0x77777700);
		}	
	}
}

flags = (EWIN_HAS_ICON | EWIN_HAS_TITLE | EWIN_HAS_MINBTN);
EWindow *my_win = EWMNewWindow(-2, 24, 192, display.height-24, "Tools", flags);
EWMAddWindow(my_task, my_win);
EWMShow(my_win);

EWindow *my_form = EWMNewWindow(232, 70, 764, 478, "Untitled Form", flags);
my_form->resizable = TRUE;
EWMAddWindow(my_task, my_form);
EWMShow(my_form);

EWidget *ctx_grid = EWMNewWidget(EWGT_CONTEXT2D, 4, 24,,,);
ctx_grid->ctx=NewContext2D(display.width, display.height, display.bpp);
DrawGrid(ctx_grid->ctx, 8, 8);
EWMAddWidget(my_form, ctx_grid);

EWidget *btn_1 = EWMNewWidget(EWGT_BUTTON, 24, 32,,, "Test Button");
EWMAddWidget(my_form, btn_1);


wmgr->loading=FALSE;
while (1)
{
	if (btn_1->hover && ms.lb)
	{
		if (!wmgr->prev_lb)
		{
			btn_1->clicked_xofs = btn_1->x;
			btn_1->clicked_yofs = btn_1->y;
		}
		else
		{
			btn_1->x = Max(0, -btn_1->clicked_xofs+mouse.x);
			btn_1->y = Max(24, -btn_1->clicked_yofs+mouse.y);
		}	
	}

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