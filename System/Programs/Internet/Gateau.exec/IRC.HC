#define IRC_OP 0x1000

class IRCUser
{
    IRCUser *prev;
    IRCUser *next;
    I64 flags;
    U8 *nick;    
    U8 *username;
    U8 *realname;
    U8 *server;
};

class IRCChannel
{
    IRCChannel *prev;
    IRCChannel *next;
    EConsole *con;
    U8 *name;
    U8 *title;
    IRCUser *users;
};

class IRCSession
{
    I64 sock;
    EConsole *debug_con;
    U8 *nick;
    U8 *nick_alt;
    U8 *username;
    U8 *realname;
    U32 bg_color;
    U32 fg_color;
    EWindow *win;
    EWidget *ctx;
    U8 *active_chan;
    IRCChannel *channels;
    EConsole *consoles;
};

IRCChannel *IRCGetChannelFromName(IRCSession *irc, U8 *name)
{
    IRCChannel *chan = irc->channels->next;
    while (chan)
    {
        if (!StrCmp(chan->name, name))
        {
            return chan;
        }
        chan = chan->next;
    }
    return NULL;
}

U0 IRCAddUserToChannel(IRCSession *irc, U8 *chan_name, U8 *nick)
{
    IRCChannel *chan = IRCGetChannelFromName(irc, chan_name);
    if (chan)
    {
        IRCUser *new = CAlloc(sizeof(IRCUser));
        IRCUser *users = chan->users;
        while (users->next)
        {
            users = users->next;
        }
        if (nick[0]=='@')
        {
            new->nick = StrNew(nick+1);
            new->flags |= IRC_OP;
        }
        else
        {
            new->nick = StrNew(nick);
        }
        // WHOIS
        users->next = new;
        new->prev = users;
    }
}

Bool IRCExistingUserInChannel(IRCSession *irc, U8 *chan_name, U8 *nick)
{
    IRCChannel *chan = IRCGetChannelFromName(irc, chan_name);
    if (chan)
    {
        if (nick[0]=='@')
        {
            nick++;
        }
        IRCUser *user = chan->users->next;
        while (user)
        {
            if (!StrCmp(user->nick, nick))
            {
                return TRUE;
            }
            user = user->next;
        }
    }
    return FALSE;
}

U0 IRCDelUserFromChannel(IRCSession *irc, U8 *chan_name, U8 *nick)
{
    IRCChannel *chan = IRCGetChannelFromName(irc, chan_name);
    if (chan)
    {
        IRCUser *prev = NULL;
        IRCUser *next = NULL;
        if (nick[0]=='@')
        {
            nick++;
        }
        IRCUser *user = chan->users->next;
        while (user)
        {
            if (!StrCmp(user->nick, nick))
            {
                prev = user->prev;
                next = user->next;
                prev->next = next;
                next->prev = prev;
                Free(user);
                return;
            }
            user = user->next;
        }        
    }
}

EConsole *IRCAddChannel(IRCSession *irc, U8 *name)
{
    IRCChannel *prev = irc->channels;
    while (prev->next)
    {
        prev = prev->next;
    }
    IRCChannel *new = CAlloc(sizeof(IRCChannel));
    new->con = NewConsole(irc->win, NULL);
    new->con->fill_color = irc->bg_color;
    new->con->bg_color = irc->bg_color;
    new->con->fg_color = irc->fg_color;
    new->con->disable_cursor = TRUE;
    new->con->ch_width  = (irc->win->width-8)/6;
    new->con->ch_height = (irc->win->height-64)/12;
    new->prev = prev;
    new->name = StrNew(name);
    new->title = CAlloc(1024);
    new->users = CAlloc(sizeof(IRCUser));
    ResetHilight(new->con);
    ConClear(new->con);
    AddConsole(irc->consoles, new->con);
    prev->next = new;
    new->prev = prev;
    return new->con;
}

U0 IRCSetActiveChannel(IRCSession *irc, U8 *name)
{
    IRCChannel *chan = irc->channels->next;
    while (chan)
    {
        chan->con->wgt = NULL;
        chan = chan->next;
    }
    chan = irc->channels->next;
    while (chan)
    {
        if (!StrCmp(chan->name, name))
        {
            chan->con->wgt = irc->ctx;
            irc->active_chan = chan->name;
            //ConPrint(chan->con, "** Set active channel.");
            return;
        }
        chan = chan->next;
    }
}

Bool IRCExistingChannel(IRCSession *irc, U8 *name)
{
    IRCChannel *chan = irc->channels->next;
    while (chan)
    {
        if (!StrCmp(chan->name, name))
        {
            return TRUE;
        }
        chan = chan->next;
    }
    return FALSE;
}

EConsole *IRCGetChannelConsole(IRCSession *irc, U8 *name)
{
    IRCChannel *chan = irc->channels->next;
    while (chan)
    {
        if (!StrCmp(chan->name, name))
        {
            return chan->con;
        }
        chan = chan->next;
    }
    return NULL;
}

U0 IRCSetChannelTopicVal(IRCSession *irc, U8 *name, U8 *topic)
{
    IRCChannel *chan = irc->channels->next;
}

U0 IRCSend(IRCSession *irc, U8 *fmt,...)
{
	U8 *buf;
	if (argc)
	{
		buf=StrPrintJoin(NULL, fmt, argc, argv);
	}
	else
	{
		buf=StrNew(fmt);
	}
    sendString(irc->sock, buf, 0);
    sendString(irc->sock, "\r\n", 0);
    Free(buf);
}

U0 IRCSetNick(IRCSession *irc)
{
    IRCSend(irc, "NICK %s", irc->nick);
    IRCSend(irc, "USER %s * * :%s", irc->username, irc->realname);
}

U0 IRCJoin(IRCSession *irc, U8 *room)
{
    IRCSend(irc, "JOIN %s", room);
}

U0 IRCQuitMsg(EConsole *con, U8 *nick, U8 *user, U8 *quit_msg)
{
    con->new = TRUE;
    con->fg_color = 0x90909000;
    ConPrint(con, "%s ", menu_clock->text);
    con->fg_color = 0x7082a100;
    ConPrint(con, "-");
    con->fg_color = 0x90909000;
    ConPrint(con, "!");
    con->fg_color = 0x7082a100;
    ConPrint(con, "- ");
    con->fg_color = 0x42719200;
    ConPrint(con, nick);
    con->fg_color = 0x70707000;
    ConPrint(con, " [");
    con->fg_color = 0x42719200;
    ConPrint(con, user);
    con->fg_color = 0xc0c0c000;
    ConPrint(con, "] ");
    con->fg_color = 0x90909000;
    ConPrint(con, "has quit ");
    con->fg_color = 0x70707000;
    ConPrint(con, "[");
    con->fg_color = 0x90909000;
    if (quit_msg)
    {
        ConPrint(con, quit_msg);
    }
    con->fg_color = 0x70707000;
    ConPrint(con, "]\n");
    con->fg_color = 0x90909000;
}

U0 IRCProtocolHandler(IRCSession *irc)
{
    EConsole *chan_con = NULL;
    IRCChannel *scan_chan;
    U8 *msg_name = NULL;
    U8 *resp = CAlloc(4096);
    U8 **resp_argv = NULL;
    I64 resp_argc = NULL;
    I64 names_cnt = 0;
    I64 err = NULL;
    while (1)
    {

        err = recvLine(irc->sock, resp, 4096, 0);
        if (err < 0)    
        {   
            StrPrint(irc->win->title, "[no connections]");
            ConPrint(irc->debug_con, "** Disconnected\n");
            close(irc->sock);
            Free(resp);
            return; 
        }

        ConPrint(irc->debug_con, "<= %s\n", resp);
        resp_argv = ParseArgs(resp, &resp_argc);

        if (resp_argc>1)
        {
            if (!StrCmp(resp_argv[0], "PING"))
            {
                ConPrint(irc->debug_con, "=> PONG\n");
                IRCSend(irc, "PONG");
            }

            // Check for channel-specific messages, add new channels if needed
            if (!StrCmp(resp_argv[1], "PRIVMSG") ||
                !StrCmp(resp_argv[1], "JOIN") ||
                !StrCmp(resp_argv[1], "PART"))
            {
                if (!StrCmp(resp_argv[1], "PRIVMSG") &&
                    !StrCmp(resp_argv[2], irc->nick))
                {
                    msg_name = StrNew(resp_argv[0]+1);
                    *StrFind("!", msg_name) = NULL;
                    if (!IRCExistingChannel(irc, msg_name))
                    {
                        IRCAddChannel(irc, msg_name);
                    }                   
                    Free(msg_name);
                    goto skip_add_chan;
                }
                if (resp_argv[2][0] == ':')
                {
                    if (!IRCExistingChannel(irc, resp_argv[2]+1))
                    {
                        IRCAddChannel(irc, resp_argv[2]+1);
                    }
                }
                else
                {
                    if (!IRCExistingChannel(irc, resp_argv[2]))
                    {
                        IRCAddChannel(irc, resp_argv[2]);
                    }
                }
skip_add_chan:                
            }

            // Print messages to channel
            if (!StrCmp(resp_argv[1], "PRIVMSG"))
            {
                if (!StrCmp(resp_argv[2], irc->nick))
                {
                    msg_name = StrNew(resp_argv[0]+1);
                    *StrFind("!", msg_name) = NULL;
                    chan_con = IRCGetChannelConsole(irc, msg_name);
                    Free(msg_name);
                }
                else
                {
                    chan_con = IRCGetChannelConsole(irc, resp_argv[2]);    
                }
                if (chan_con)
                {
                    chan_con->new = TRUE;
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "%s ", menu_clock->text);
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "< ");
                    chan_con->fg_color = 0xB0B0B000;
                    msg_name = StrNew(resp_argv[0]+1);
                    *StrFind("!", msg_name) = NULL;
                    ConPrint(chan_con, msg_name);
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "> ");
                    chan_con->fg_color = 0xC0C0C000;
                    ConPrint(chan_con, "%s\n", resp + StrLen(resp_argv[0]) +
                        StrLen(resp_argv[1]) + StrLen(resp_argv[2]) + 4);
                    Free(msg_name);
                }
            }

            if (!StrCmp(resp_argv[1], "JOIN"))
            {
                chan_con = IRCGetChannelConsole(irc, resp_argv[2]+1);
                if (chan_con)
                {
                    chan_con->new = TRUE;
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "%s ", menu_clock->text);
                    chan_con->fg_color = 0x7082a100;
                    ConPrint(chan_con, "-");
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "!");
                    chan_con->fg_color = 0x7082a100;
                    ConPrint(chan_con, "- ");
                    chan_con->fg_color = 0x5b9dcc00;
                    msg_name = StrNew(resp_argv[0]+1);
                    *StrFind("!", msg_name) = NULL;
                    ConPrint(chan_con, msg_name);
                    if (!IRCExistingUserInChannel(irc, resp_argv[2]+1, msg_name))
                    {
                        IRCAddUserToChannel(irc, resp_argv[2]+1, msg_name);
                    }
                    Free(msg_name);
                    chan_con->fg_color = 0x70707000;
                    ConPrint(chan_con, " [");
                    chan_con->fg_color = 0x42719200;
                    ConPrint(chan_con, StrFind("!", resp_argv[0]+1)+1);
                    chan_con->fg_color = 0x70707000;
                    ConPrint(chan_con, "] ");
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "has joined ");
                    chan_con->fg_color = 0xFFFFFF00;
                    ConPrint(chan_con, "%s\n", resp_argv[2]+1);
                    chan_con->fg_color = 0x90909000;
                }
            }

            if (!StrCmp(resp_argv[1], "PART"))
            {
                chan_con = IRCGetChannelConsole(irc, resp_argv[2]);
                if (chan_con)
                {
                    chan_con->new = TRUE;
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "%s ", menu_clock->text);
                    chan_con->fg_color = 0x7082a100;
                    ConPrint(chan_con, "-");
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "!");
                    chan_con->fg_color = 0x7082a100;
                    ConPrint(chan_con, "- ");
                    chan_con->fg_color = 0x42719200;
                    msg_name = StrNew(resp_argv[0]+1);
                    *StrFind("!", msg_name) = NULL;
                    ConPrint(chan_con, msg_name);
                    if (!IRCExistingUserInChannel(irc, resp_argv[2], msg_name))
                    {
                        IRCDelUserFromChannel(irc, resp_argv[2], msg_name);
                    }
                    Free(msg_name);
                    chan_con->fg_color = 0x70707000;
                    ConPrint(chan_con, " [");
                    chan_con->fg_color = 0x42719200;
                    ConPrint(chan_con, StrFind("!", resp_argv[0]+1)+1);
                    chan_con->fg_color = 0xc0c0c000;
                    ConPrint(chan_con, "] ");
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "has left ");
                    chan_con->fg_color = 0xFFFFFF00;
                    ConPrint(chan_con, "%s ", resp_argv[2]);
                    chan_con->fg_color = 0x70707000;
                    ConPrint(chan_con, "[");
                    chan_con->fg_color = 0x90909000;
                    if (resp_argc>3)
                    {
                        ConPrint(chan_con, resp_argv[3]+1);
                    }
                    chan_con->fg_color = 0x70707000;
                    ConPrint(chan_con, "]\n");
                    chan_con->fg_color = 0x90909000;
                }
            }

            if (!StrCmp(resp_argv[1], "QUIT"))
            {
                msg_name = StrNew(resp_argv[0]+1);
                *StrFind("!", msg_name) = NULL;

                // PRIVMSGs open?
                chan_con = IRCGetChannelConsole(irc, msg_name);
                if (chan_con)
                {
                    chan_con->new = TRUE;
                    IRCQuitMsg(chan_con, msg_name, StrFind("!", resp_argv[0]+1)+1,
                        resp + StrLen(resp_argv[0]) + StrLen(resp_argv[1]) + 3);
                }

                // Check if user is (was) in channel(s)
                scan_chan = irc->channels->next;
                while (scan_chan)
                {
                    if (IRCExistingUserInChannel(irc, scan_chan->name, msg_name))
                    {
                        chan_con = IRCGetChannelConsole(irc, scan_chan->name);
                        if (chan_con)
                        {
                            chan_con->new = TRUE;
                            IRCQuitMsg(chan_con, msg_name, StrFind("!", resp_argv[0]+1)+1,
                                resp + StrLen(resp_argv[0]) + StrLen(resp_argv[1]) + 3);
                            IRCDelUserFromChannel(irc, scan_chan->name, msg_name);
                        }
                    }
                    scan_chan = scan_chan->next;
                }
                Free(msg_name);
            }

            // Handle response codes
            if (!StrCmp(resp_argv[1], "001"))
            { // Connect, hello :)
                StrPrint(irc->win->title, resp_argv[0]+1);
                IRCJoin(irc, "#erythros"); //testing
            }

            if (!StrCmp(resp_argv[1], "353"))
            { // reply to NAMES
                chan_con = IRCGetChannelConsole(irc, resp_argv[4]);
                if (chan_con)
                {
                    chan_con->fg_color = 0x90909000;
                    ConPrint(chan_con, "%s ", menu_clock->text);
                    chan_con->fg_color = 0x7dfe7d00;
                    ConPrint(chan_con, "Users: ");
                    chan_con->fg_color = 0x90909000;
                    for (names_cnt=5; names_cnt<resp_argc; names_cnt++)
                    {
                        if (names_cnt==5)
                        {
                            if (!IRCExistingUserInChannel(irc, resp_argv[4], resp_argv[names_cnt]+1))
                            {
                                IRCAddUserToChannel(irc, resp_argv[4], resp_argv[names_cnt]+1);
                            }
                            ConPrint(chan_con, "[ %s] ", resp_argv[names_cnt]+1);
                        }
                        else
                        {
                            if (!IRCExistingUserInChannel(irc, resp_argv[4], resp_argv[names_cnt]))
                            {
                                IRCAddUserToChannel(irc, resp_argv[4], resp_argv[names_cnt]);
                            }
                            ConPrint(chan_con, "[ %s] ", resp_argv[names_cnt]);
                        }
                    }
                    ConPrint(chan_con, "\n");
                }
            }

            if (!StrCmp(resp_argv[1], "403"))
            { // Not authorized
                IRCSend(irc, "QUIT");
            }

            if (!StrCmp(resp_argv[1], "433"))
            { // Nick already in use, choose another
                StrPrint(irc->nick + StrLen(irc->nick), "_");
                IRCSetNick(irc);
            }
        }
        FreeArgs(resp_argc, resp_argv);
        Sleep(1);
    }
}