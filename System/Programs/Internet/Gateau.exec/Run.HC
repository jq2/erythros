//  Gateau - Chat client [IRC, Twitch, Discord (shh...)] for Erythros
//  by Alec Murphy

//  Why Gateau? Because chat, cat, gato, gateau.

//  TODO: EVERYTHING

// Protocols
#include "IRC";

U64 flags;
ETask *my_task=EWMGetTask(Fs);
my_task->title = "Gateau";
my_task->icon = LoadPNG("icon_16.png");

EWMInitMenu(my_task, 3);

my_task->menu->items[0]->id = 1;
my_task->menu->items[0]->text = "Server";
my_task->menu->items[1]->id = 2;
my_task->menu->items[1]->text = "Edit";
my_task->menu->items[2]->id = 3;
my_task->menu->items[2]->text = "Help";

EContextMenu *server_menu = EWMNewContextMenu;
server_menu->task=my_task;
server_menu->width=96;
EWMAddContextMenuItem(server_menu, 1, "New");
EWMAddContextMenuHorizRule(server_menu);
EWMAddContextMenuItem(server_menu, 2, "Open",, WMGR_CMD_TASK_CB);
EWMAddContextMenuItem(server_menu, 3, "Close");
my_task->menu->items[0]->menu = server_menu;

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
EWindow *my_win = EWMNewWindow(180, 108, 694, 424, CAlloc(1024), flags);
StrPrint(my_win->title, "[no connections]");

EWMAddWindow(my_task, my_win);
my_win->icon = my_task->icon;
my_win->resizable = TRUE;

EWidget *chan_ctx = EWMNewWidget(EWGT_CONTEXT2D, 4, 24, 48, 48);
chan_ctx->ctx = NewContext2D(256, display.height, display.bpp);
//my_ctx->pointer=ms_cur_input;
EWMAddWidget(my_win, chan_ctx);
chan_ctx->ctx->width = 74;
chan_ctx->ctx->height = my_win->height-28;

EWidget *chat_ctx = EWMNewWidget(EWGT_CONTEXT2D, 80, 24, 2, 2);
chat_ctx->ctx = NewContext2D(display.width, display.height, display.bpp);
//my_ctx->pointer=ms_cur_input;
EWMAddWidget(my_win, chat_ctx);

EWidget *btn_send = EWMNewWidget(EWGT_BUTTON, 0, 0,,, "Send"); // Not added to win

EWidget *inp_text = EWMNewWidget(EWGT_INPUT, 56, 35, 256);
inp_text->text_action_wgt = btn_send;
EWMAddWidget(my_win, inp_text);

// begin irc params

IRCSession *irc = CAlloc(sizeof(IRCSession));
irc->consoles = CAlloc(sizeof(EConsole));
irc->win = my_win;
irc->ctx = chat_ctx;
irc->bg_color = 0x082b3600;
irc->fg_color = 0x4384b500;

Fill2D(chan_ctx->ctx, irc->bg_color);

irc->channels = CAlloc(sizeof(IRCChannel));
irc->debug_con = IRCAddChannel(irc, " "); // debug channel
IRCSetActiveChannel(irc, " ");

CTask *con_task=Spawn(&DrawConsoles, irc->consoles, , 4);

U8 *host=CAlloc(64);
U8 send_buf = CAlloc(2048);
StrPrint(host, "some.irc.server.here"); // Testing

I64 err, sock = socket(AF_INET, SOCK_STREAM);
sockaddr_in addr;
addr.sin_family = AF_INET;
addr.sin_port = htons(6667);

EWMSetWidgetFocus(my_win, inp_text);
EWMShow(my_win);

CTask *irc_task = NULL;

irc->nick = CAlloc(1024);
irc->nick_alt = CAlloc(1024);
irc->username = CAlloc(1024);
irc->realname = CAlloc(1024);

// Testing
StrPrint(irc->nick, "nick");
StrPrint(irc->nick_alt, "nick_");
StrPrint(irc->username, "username");
StrPrint(irc->realname, "realname");

err = GetAddressForHost(host, &addr.sin_addr);
if (!err)
{
    err = connect(sock, &addr, sizeof(addr));
    if (!err)
    {
        irc->sock = sock;
        ConPrint(irc->debug_con, "** Connected to %s\n", host);
        IRCSetNick(irc);
        irc_task=Spawn(&IRCProtocolHandler, irc, , 4);
    }
}
else
{
}

EConsole *resize_con;
IRCChannel *scan_chan;

EConsole *send_chan_con = NULL;

I64 chan_list_y;

wmgr->loading=FALSE;
while (1)
{
    
    chan_ctx->ctx->height = my_win->height - 28;
    chan_ctx->height = my_win->height - 28;

    chat_ctx->width = my_win->width - 88;
    chat_ctx->ctx->height = my_win->height - 48;
    inp_text->x = chat_ctx->x;
    inp_text->y = chat_ctx->y + chat_ctx->ctx->height + 2;
    inp_text->width = chat_ctx->width - 11;



    Fill2D(chan_ctx->ctx, irc->bg_color);
    resize_con = irc->consoles->next;
    while (resize_con)
    {
        resize_con->ch_width  = (my_win->width-8)/6;
        resize_con->ch_height = (my_win->height-64)/12;
        resize_con = resize_con->next;
    }

    if (!StrCmp(irc->active_chan, " "))
    {
        Rect2D(chan_ctx->ctx, 0, 0, chan_ctx->ctx->width, 18, 0x9C9C9C00);    
    }
    Bitmap16Print2D(chan_ctx->ctx, 4, 2, 0xFFFFFF00, FONT_WINTITLE16, "Server");

    chan_list_y = 18;
    scan_chan = irc->channels->next->next;
    while (scan_chan)
    {
        if (chan_ctx->clicked)
        {
            if (chan_ctx->clicked_yofs < 18)
            {
                IRCSetActiveChannel(irc, " ");
                chan_ctx->clicked = FALSE;
            }
            if (chan_ctx->clicked_yofs >= chan_list_y &&
                chan_ctx->clicked_yofs < chan_list_y + 18)
            {
                IRCSetActiveChannel(irc, scan_chan->name);
                chan_ctx->clicked = FALSE;
            }
            EWMSetWidgetFocus(my_win, inp_text);            
        }
        if (!StrCmp(irc->active_chan, scan_chan->name))
        {
            scan_chan->con->new = FALSE;
            Rect2D(chan_ctx->ctx, 0, chan_list_y, chan_ctx->ctx->width, 18, 0x9C9C9C00);    
        }
        if (scan_chan->con->new)
        {
            Bitmap16Print2D(chan_ctx->ctx, 4, 2 + chan_list_y, 0xFF000000, FONT_WINTITLE16, scan_chan->name);
        }
        else
        {
            Bitmap16Print2D(chan_ctx->ctx, 4, 2 + chan_list_y, 0xFFFFFF00, FONT_WINTITLE16, scan_chan->name);
        }
        chan_list_y += 18;
        scan_chan = scan_chan->next;
    }

    if (btn_send->clicked)
    {
        if (!StrCmp(irc->active_chan, " "))
        {
            StrPrint(send_buf, "%s\r\n", inp_text->text);
        }
        else
        {
            StrPrint(send_buf, "PRIVMSG %s :%s\r\n", irc->active_chan, inp_text->text);
        }

        send_chan_con = IRCGetChannelConsole(irc, irc->active_chan);

        send_chan_con->fg_color = 0x90909000;
        ConPrint(send_chan_con, "%s ", menu_clock->text);
        send_chan_con->fg_color = 0x90909000;
        ConPrint(send_chan_con, "<");
        send_chan_con->fg_color = 0xFFFFFF00;
        ConPrint(send_chan_con, irc->nick);
        send_chan_con->fg_color = 0x90909000;
        ConPrint(send_chan_con, "> ");
        send_chan_con->fg_color = 0xC0C0C000;
        ConPrint(send_chan_con, "%s\n", inp_text->text);

        sendString(sock, send_buf, 0);
        StrPrint(inp_text->text, "");
        btn_send->clicked = FALSE;
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