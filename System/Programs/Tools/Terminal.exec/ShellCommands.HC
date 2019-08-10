#define ERR_INVALID_OPT -1
#define ERR_EXTRA_OPD	-2

I64 ParseOpt(U8 *op_lst, I64 argc, U8 **argv, I64 *flags, U64 *op_err,
    Bool ignore_extra_opd = FALSE)
{
    I64 i, j;
    U8 op_chr[2];
    op_chr[1] = 0;
    for (i = 1; i < argc; i++)
    {
        if (argv[i][0] == '-')
        {
            for (j = 1; j < StrLen(argv[i]); j++)
            {
                op_chr[0] = argv[i][j];
                if (StrFind(&op_chr, op_lst))
                {
                    *flags |= 1 << (StrFind(&op_chr, op_lst) - op_lst);
                }
                else
                {
					*op_err = StrNew(&op_chr);
					return ERR_INVALID_OPT;
                }
            }
        }
        else
        {
            if (!ignore_extra_opd)
            {
			    *op_err = StrNew(argv[i]);
			    return ERR_EXTRA_OPD;
            }
        }
    }
    return 0;
}

U0 _LSPCI_PCILookUpSingle(CDoc *doc,I64 m,I64 d,U8 **_vendor,U8 **_dev)
{
  Bool first=TRUE;
  U8 buf[8],*vendor=NULL,*dev=NULL;
  CDocEntry *doc_e=doc->head.next;
  while (doc_e!=doc) {
    if (first) {
      if (doc_e->type_u8==DOCT_TEXT && doc_e->tag[0]!=';' &&
            StrLen(doc_e->tag)>=4) {
        buf[0](U16)='0x';
        buf[2](U32)=doc_e->tag(U32 *)[0];
        buf[6]=0;
        if (Str2I64(buf)==m) {
          doc_e=doc_e->next->next;
          if (doc_e->type_u8==DOCT_TEXT) {
            vendor=AStrNew(doc_e->tag);
            first=FALSE;
            break;
          }
        }
      }
      first=FALSE;
    }
    if (doc_e->type_u8==DOCT_NEW_LINE)
      first=TRUE;
    doc_e=doc_e->next;
  }

  if (vendor) {
    while (doc_e!=doc) {
      if (first) {
        if (doc_e->type_u8==DOCT_TAB) {
          doc_e=doc_e->next;
          if (doc_e->type_u8==DOCT_TEXT && StrLen(doc_e->tag)>=4) {
            buf[0](U16)='0x';
            buf[2](U32)=doc_e->tag(U32 *)[0];
            buf[6]=0;
            if (Str2I64(buf)==d) {
              doc_e=doc_e->next->next;
              if (doc_e->type_u8==DOCT_TEXT) {
                dev=AStrNew(doc_e->tag);
                break;
              }
            }
          }
        } else
          break;
        first=FALSE;
      }
      if (doc_e->type_u8==DOCT_NEW_LINE)
        first=TRUE;
      doc_e=doc_e->next;
    }
  }

  if (vendor)
    *_vendor=vendor;
  else
    *_vendor=AStrNew("Unknown");

  if (dev)
    *_dev=dev;
  else
    *_dev=AStrNew("Unknown");
}

U0 _LSPCI_PCILookUpDevs()
{
  CPCIDev *tmppci;
  I64 w1,w2,b,d,f,timeout=32*8*2;
  CDoc *doc;
  if (dev.pci_head.next!=&dev.pci_head)
    return;
  doc=DocRead("T:/System/Drivers/pci.ids",DOCF_PLAIN_TEXT|DOCF_NO_CURSOR);
  for (b=0;b<sys_pci_busses;b++)
    for (d=0;d<32;d++)
      for (f=0;f<8;f++) {
        w1=PCIReadU16(b,d,f,0);
        if (w1!=0xFFFF) {
          tmppci=ACAlloc(sizeof(CPCIDev));
          tmppci->bus=b;
          tmppci->dev=d;
          tmppci->fun=f;
          tmppci->vendor=w1;
          tmppci->dev_id=w2=PCIReadU16(b,d,f,2);
          tmppci->sub_code=PCIReadU8(b,d,f,0xA);
          tmppci->base_code=PCIReadU8(b,d,f,0xB);
          _LSPCI_PCILookUpSingle(doc,w1,w2,&tmppci->vendor_str,&tmppci->dev_id_str);
          QueIns(tmppci,dev.pci_head.last);
          timeout=32*8*2;
        } else if (sys_pci_busses==256 && --timeout<=0)
          goto lspci_lud_done;
      }
lspci_lud_done:
  DocDel(doc);
}

I64 CCMD_bgset(EConsole *con, I64 argc, U8 **argv)
{
    EContext2D *bg;
    if (argc < 2)
    {
        ConPrint(con, "usage: bgset background-image\n");
        return 1;
    }
    if (!FileFind(argv[1]))
    {
        ConPrint(con, "bgset: %s: File not found\n", argv[1]);
        return 1;
    }
    bg = LoadPNG(argv[1]);
    EWMSetWallpaper(bg);
    DelContext2D(bg);
    return 0;
}

I64 CCMD_cat(EConsole *con, I64 argc, U8 **argv)
{
    // TODO: actually be a cat implementation :P
    I64 i, j;
    I64 res = 0;
    U8 *buf;
    U8 *st;
    U8 char[2];
    char[1] = NULL;
    I64 size;
    CDirEntry *de;
    CDocEntry *doc_e,*doc_e2;
    CDoc *doc;
    if (argc < 2)
    {
        return 0;
    }
    for (i = 1; i < argc; i++)
    {
        de = FilesFind(argv[i]);
        if (de)
        {
            if (de->attr & RS_ATTR_DIR == RS_ATTR_DIR)
            {
                ConPrint(con, "cat %s: Is a directory\n", argv[i]);
            }
            else
            {
                if (StrLen(argv[i])>3)
                {
                    if (!StrCmp(".HC.Z", argv[i]+StrLen(argv[i])-5) || !StrCmp(".DD.Z", argv[i]+StrLen(argv[i])-5) ||
                        !StrCmp(".HC", argv[i]+StrLen(argv[i])-3) || !StrCmp(".DD", argv[i]+StrLen(argv[i])-3))
                    {
                        doc = DocRead(argv[i]);
                        doc_e=doc->head.next;
                        while (doc_e!=doc)
                        {
                            st=DocScanLine(doc,doc_e,NULL,&doc_e2);
                            ConPrint(con, st);
                            Free(st);
                            doc_e=doc_e2;
                            if (doc_e->type_u8==DOCT_NEW_LINE)
                            {
                                ConPrint(con, "\n");
                                doc_e=doc_e->next;
                            }
                        }
                        DocDel(doc);
                    }
                    else
                    {
                        buf = FileRead(argv[i], &size);
                        for (j = 0; j < size; j++)
                        {
                            char[0] = buf[j];
                            ConPrint(con, &char);
                        }
                        Free(buf);
                    }
                }
                else
                {
                    buf = FileRead(argv[i], &size);
                    for (j = 0; j < size; j++)
                    {
                        char[0] = buf[j];
                        ConPrint(con, &char);
                    }
                    Free(buf);
                }
            }
            DirTreeDel(de);
        }
        else
        {
            ConPrint(con, "cat: %s: No such file or directory\n", argv[i]);
        }
    }
    return res;
}

I64 CCMD_cd(EConsole *con, I64 argc, U8 **argv)
{
    if (argc < 2)
    {
        return 0;
    }
    if (argc > 2)
    {
        ConPrint(con, "esh: cd: too many arguments\n");
        return 1;
    }
    CDirEntry *tmpde = FilesFind(argv[1]);
    if (!tmpde)
    {
        ConPrint(con, "esh: cd: %s: No such file or directory\n", argv[1]);
        DirTreeDel(tmpde);
        return 1;
    }
    if (tmpde->attr & RS_ATTR_DIR == RS_ATTR_DIR)
    {
        Cd(argv[1]);
    }
    else
    {
        ConPrint(con, "esh: cd: %s: Not a directory\n", argv[1]);
        DirTreeDel(tmpde);
        return 1;
    }
    DirTreeDel(tmpde);
    return 0;
}

I64 CCMD_clear(EConsole *con, I64 argc, U8 **argv)
{
    if (argc > 2)
    {
        ConPrint(con, "esh: clear: too many arguments\n");
        return 1;
    }
    ConClear(con);
    return 0;
}

I64 CCMD_echo(EConsole *con, I64 argc, U8 **argv)
{
    I64 i;
    for (i = 1; i < argc; i++)
    {
        ConPrint(con, "%s ", argv[i]);
    }
    ConPrint(con, "\n");
    return 0;
}

I64 CCMD_exit(EConsole *con, I64 argc, U8 **argv)
{
    // stub
    return 0;
}

U8 *_FTP_GetResponse(I64 sock, EConsole *con=NULL)
{
    U8 *resp = CAlloc(4096);
    I64 err = NULL;
    err = recvLine(sock, resp, 4096, 0);
    if (err < 0)
    {
        close(sock);
        Free(resp);
        return NULL;
    }
    if (con)
    {
        ConPrint(con, "%s\n", resp);
    }
    return resp;
}

I64 _FTP_SetPassiveMode(I64 sock, EConsole *con=NULL)
{
    I64 d_port = NULL;
    U8 *dp_1, *dp_2;
    U8 *resp;
    sendString(sock, "PASV\r\n", 0);
    resp = _FTP_GetResponse(sock, con);
    StrLastOcc(resp,")")[0]=0;
    dp_2=StrLastOcc(resp,",")+1;
    StrLastOcc(resp,",")[0]=0;
    dp_1=StrLastOcc(resp,",")+1;
    StrLastOcc(resp,",")[0]=0;
    d_port=Str2I64(dp_1)*256;
    d_port+=Str2I64(dp_2);
    Free(resp);
    return d_port;
}

I64 CCMD_ftp(EConsole *con, I64 argc, U8 **argv)
{
    Bool im_exit = FALSE;
    U8 *resp = NULL;
    U8 *ftp_res = CAlloc(1024);
    U8 *ftp_cmd = CAlloc(1024);
    U8 *im_pmt = NULL;
    I64 im_argc = NULL;
    I64 size = NULL;
    U8 *data = NULL;
    I64 got = 0;
    I64 step = 0;
    I64 total = 0;
    U8 **im_argv = NULL;
    U8 *dp_1, *dp_2;
    I64 d_port;
    I64 c_sock = socket(AF_INET, SOCK_STREAM);
    I64 d_sock = NULL;
    I64 err = 0;
    I64 _i = NULL;
    sockaddr_in c_addr;
    sockaddr_in d_addr;

    if (argc < 2)
    {
        return 0;
    }
    if (argc > 2)
    {
        return 0;
    }
   
    c_addr.sin_family = AF_INET;
    c_addr.sin_port = htons(21);
    err = GetAddressForHost(argv[1], &c_addr.sin_addr);
    if (!err)
    {
        err = connect(c_sock, &c_addr, sizeof(c_addr));
        if (!err)
        {

            EConReadLine *ftp_rl = CAlloc(sizeof(EConReadLine));
	        ftp_rl->history = CAlloc(sizeof(EConHistory));
            ftp_rl->ac = CAlloc(sizeof(EConAutoComplete));

            ConPrint(con, "Connected to %s.\n", argv[1]);
            resp = _FTP_GetResponse(c_sock, con);
            if (resp) { Free(resp); };

            ConPrint(con, "Name (%s:%s): ", argv[1], wmgr->session->user);
            im_pmt = ConReadLine(con, ftp_rl, 4096);
            if (!StrLen(im_pmt))
            {
                StrPrint(im_pmt, wmgr->session->user);
            }
            StrPrint(ftp_cmd, "USER %s\r\n", im_pmt);
            sendString(c_sock, ftp_cmd, 0);
            resp = _FTP_GetResponse(c_sock, con);

            if (resp[0] == '2' || resp[0] == '3' )
            {
                if (resp[0] == '3')
                {
                    Free(resp);
                    ConPrint(con, "Password:");
                    con->disable_echo = TRUE;
                    im_pmt = ConReadLine(con, ftp_rl, 4096);
                    ConPrint(con, "\n");
                    con->disable_echo = FALSE;
                    StrPrint(ftp_cmd, "PASS %s\r\n", im_pmt);
                    sendString(c_sock, ftp_cmd, 0);
                    resp = _FTP_GetResponse(c_sock, con);
                }
                else
                {
                    Free(resp);
                }
            }
            else
            {
                Free(resp);
                im_exit = TRUE;
                goto ftp_im_loop;
            }
            if (resp[0] == '2')
            {
                Free(resp);
            }
            else
            {
                im_exit = TRUE;
                goto ftp_im_loop;
            }

            StrPrint(ftp_cmd, "TYPE I\r\n");
            sendString(c_sock, ftp_cmd, 0);
            resp = _FTP_GetResponse(c_sock, con);
            if (resp) { Free(resp); };

            StrPrint(ftp_cmd, "");

            while (!im_exit)
            {
                ConPrint(con, "ftp> ");
                im_pmt = ConReadLine(con, ftp_rl, 4096);

                im_argv = ParseArgs(im_pmt, &im_argc);

                if (im_argc)
                {
                    if (!StrICmp(im_argv[0], "cd"))
                    {
                        if (im_argc>1)
                        {
                            StrPrint(ftp_cmd, "CWD %s\r\n", im_argv[1]);
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);                    
                            Free(resp);
                        }
                        else
                        {
                            ConPrint(con, "usage: cd remote-directory\n");
                        }                        
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "del"))
                    {
                        if (im_argc>1)
                        {
                            StrPrint(ftp_cmd, "DELE %s\r\n", im_argv[1]);
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);                    
                            Free(resp);
                        }
                        else
                        {
                            ConPrint(con, "usage: del remote-file\n");
                        }                        
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "dir") || !StrICmp(im_argv[0], "ls"))
                    {
                        StrPrint(ftp_cmd, "LIST\r\n");
                        if (im_argc>1)
                        {
                            StrPrint(ftp_cmd, "LIST %s\r\n", im_argv[1]);
                        }
                        MemCpy(&d_addr, &c_addr, sizeof(sockaddr_in));
                        d_port = _FTP_SetPassiveMode(c_sock, con);
                        d_addr.sin_port = htons(d_port);
                        sendString(c_sock, ftp_cmd, 0);
                        resp = _FTP_GetResponse(c_sock, con);
                        if (resp[0] == '1')
                        {
                            Free(resp);
                            d_sock = socket(AF_INET, SOCK_STREAM);
                            err = connect(d_sock, &d_addr, sizeof(d_addr));
                            {
                                if (err < 0)
                                {
                                    close(d_sock);
                                    im_exit = TRUE;
                                    goto ftp_im_loop;
                                }
                                err = recvLine(d_sock, ftp_res, 1024, 0);
                                while (err>-1)
                                {
                                    ConPrint(con, "%s\n", ftp_res);
                                    err = recvLine(d_sock, ftp_res, 1024, 0);
                                }
                                close(d_sock);
                            }
                            resp = _FTP_GetResponse(c_sock, con);
                        }
                        Free(resp);
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "get"))
                    {
                        if (im_argc>1)
                        {
                            StrPrint(ftp_cmd, "TYPE I\r\n");
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);
                            if (resp) { Free(resp); };
                            StrPrint(ftp_cmd, "SIZE %s\r\n", im_argv[1]);
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);
                            if (resp[0] == '2')
                            {
                                size = Str2I64(resp + 4);
                                Free(resp);
                            }
                            else
                            {
                                Free(resp);
                                goto ftp_im_loop;
                            }
                            MemCpy(&d_addr, &c_addr, sizeof(sockaddr_in));
                            d_port = _FTP_SetPassiveMode(c_sock, con);
                            d_addr.sin_port = htons(d_port);
                            StrPrint(ftp_cmd, "RETR %s\r\n", im_argv[1]);
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);
                            if (resp[0] == '1')
                            {
                                Free(resp);
                                d_sock = socket(AF_INET, SOCK_STREAM);
                                err = connect(d_sock, &d_addr, sizeof(d_addr));
                                {
                                    if (err < 0)
                                    {
                                        close(d_sock);
                                        im_exit = TRUE;
                                        goto ftp_im_loop;
                                    }
                                    data = CAlloc(size);
                                    got = 0;
                                    step = 0;
                                    total = 0;
                                    while (total < size)
                                    {
                                        step = size - total;
                                        if (step > 1024) { step = 1024; };
                                        got = recv(d_sock, data + total, step, 0);
                                        if (got <= 0)
                                        {
                                            Free(data);
                                            close(d_sock);
                                            im_exit = TRUE;
                                            goto ftp_im_loop;
                                        }
                                        total += got;
                                    }
                                    FileWrite(cond(im_argc>2, im_argv[2], im_argv[1]), data, size);
                                    Free(data);
                                    close(d_sock);
                                }
                                resp = _FTP_GetResponse(c_sock, con);
                            }
                            Free(resp);                            
                        }
                        else
                        {
                            ConPrint(con, "usage: get remote-file [ local-file ]\n");
                        }                        
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "mkdir"))
                    {
                        if (im_argc>1)
                        {
                            StrPrint(ftp_cmd, "MKD %s\r\n", im_argv[1]);
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);                    
                            Free(resp);
                        }
                        else
                        {
                            ConPrint(con, "usage: mkdir directory-name\n");
                        }                        
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "pwd"))
                    {
                        sendString(c_sock, "PWD\r\n", 0);
                        resp = _FTP_GetResponse(c_sock, con);                    
                        Free(resp);
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "put"))
                    {
                        if (im_argc>1)
                        {
                            ConPrint(con, "local: %s remote: %s\n", im_argv[1], cond(im_argc>2, im_argv[2], im_argv[1]));
                            if (!FileFind(im_argv[1]))
                            {
                                ConPrint(con, "local: %s: No such file or directory\n", im_argv[1]);
                                goto ftp_im_loop;
                            }
                            StrPrint(ftp_cmd, "TYPE I\r\n");
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);
                            if (resp) { Free(resp); };
                            MemCpy(&d_addr, &c_addr, sizeof(sockaddr_in));
                            d_port = _FTP_SetPassiveMode(c_sock, con);
                            d_addr.sin_port = htons(d_port);
                            StrPrint(ftp_cmd, "STOR %s\r\n", cond(im_argc>2, im_argv[2], im_argv[1]));
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);
                            if (resp[0] == '1')
                            {
                                Free(resp);
                                d_sock = socket(AF_INET, SOCK_STREAM);
                                err = connect(d_sock, &d_addr, sizeof(d_addr));
                                {
                                    if (err < 0)
                                    {
                                        close(d_sock);
                                        im_exit = TRUE;
                                        goto ftp_im_loop;
                                    }
                                    err = 0;
                                    got = 0;
                                    step = 0;
                                    total = 0;
                                    data = FileRead(im_argv[1], &size);
                                    while (total < size)
                                    {
                                        step = size - total;
                                        if (step > 1024) { step = 1024; };
                                        err = send(d_sock, data + total, step, 0);
                                        if (err < 0)
                                        {
                                            Free(data);
                                            close(d_sock);
                                            im_exit = TRUE;
                                            goto ftp_im_loop;
                                        }
                                        total += step;
                                    }
                                    Free(data);
                                    close(d_sock);
                                }
                                resp = _FTP_GetResponse(c_sock, con);
                            }
                            Free(resp);
                        }
                        else
                        {
                            ConPrint(con, "usage: put local-file remote-file\n");
                        }                        
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "rm"))
                    {
                        if (im_argc>1)
                        {
                            StrPrint(ftp_cmd, "DELE %s\r\n", im_argv[1]);
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);                    
                            Free(resp);
                        }
                        else
                        {
                            ConPrint(con, "usage: rm remote-file\n");
                        }                        
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "rmdir"))
                    {
                        if (im_argc>1)
                        {
                            StrPrint(ftp_cmd, "RMD %s\r\n", im_argv[1]);
                            sendString(c_sock, ftp_cmd, 0);
                            resp = _FTP_GetResponse(c_sock, con);                    
                            Free(resp);
                        }
                        else
                        {
                            ConPrint(con, "usage: rmdir directory-name\n");
                        }                        
                        goto ftp_im_loop;
                    }
                    if (!StrICmp(im_argv[0], "exit") || !StrICmp(im_argv[0], "quit"))
                    {
                        im_exit = TRUE;
                        goto ftp_im_loop;
                    }
                    ConPrint(con, "?Invalid command\n");                    
                }
ftp_im_loop:
                FreeArgs(im_argc, im_argv);
                if (im_pmt)
                {
                    Free(im_pmt);
                }
            }
            sendString(c_sock, "QUIT\r\n", 0);
            resp = _FTP_GetResponse(c_sock, con);
            if (resp) { Free(resp); };
            Free(ftp_rl->ac);
            Free(ftp_rl->history);
            Free(ftp_rl);            
            close(c_sock);
            Free(ftp_cmd);
            return 0;
        }
        close(c_sock);
        Free(ftp_cmd);
        return 1;
    }
    Free(ftp_cmd);
    return 1;
}

I64 CCMD_history(EConsole *con, I64 argc, U8 **argv)
{
    I64 i;
    for (i = 0; i < shell_rl->history->pos; i++)
    {
        ConPrint(con, "%5d  %s\n", i, shell_rl->history->entries[i]);
    }
    return 0;
}

I64 CCMD_hcc(EConsole *con, I64 argc, U8 **argv)
{
    I64 res = NULL;
    CDocEntry *doc_e;
    Bool hcc_exit = FALSE;
    EConReadLine *hcc_rl = CAlloc(sizeof(EConReadLine));
	hcc_rl->history = CAlloc(sizeof(EConHistory));
    hcc_rl->ac = CAlloc(sizeof(EConAutoComplete));
    U8 *hcc_input_buf = NULL;
    while (!hcc_exit)
    {
        con->fg_color=0x729FCF00;
        ConPrint(con, "> ");
        con->fg_color=0xADE25D00;
        hcc_input_buf = ConReadLine(con, hcc_rl, 4096);
        doc_e = adam_task->put_doc->head;
        while (doc_e->next != adam_task->put_doc->head)
        {
            doc_e = doc_e->next;
        }
        doc_e = doc_e->last;
        res = Adam(hcc_input_buf);
        doc_e = doc_e->next;
        con->fg_color=0x729FCF00;
        ConDocDump(con, adam_task->put_doc, doc_e);
        con->fg_color=0xADE25D00;
        ConPrint(con, "\n%d", res);
    }
    Free(hcc_rl->ac);
    Free(hcc_rl->history);
    Free(hcc_rl);
}

I64 CCMD_ifconfig(EConsole *con, I64 argc, U8 **argv)
{
    U8 *en0_mac = EthernetGetAddress;
    U32 en0_addr = virtio_net.ipv4.addr;
    U32 en0_mask = virtio_net.ipv4.mask;
    U32 en0_bcast = virtio_net.ipv4.bcast;
    /*
    I64 i;
    for (i = 1; i < argc; i++)
    {
        ConPrint(con, "%s ", argv[i]);
    }
    */    
    ConPrint(con, "en0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu %d\n",
        ETHERNET_FRAME_SIZE - 18);
    ConPrint(con, "        inet %d.%d.%d.%d  netmask %d.%d.%d.%d  broadcast %d.%d.%d.%d\n",
        en0_addr.u8[3], en0_addr.u8[2], en0_addr.u8[1], en0_addr.u8[0],
        en0_mask.u8[3], en0_mask.u8[2], en0_mask.u8[1], en0_mask.u8[0],
        en0_bcast.u8[3], en0_bcast.u8[2], en0_bcast.u8[1], en0_bcast.u8[0]);
    ConPrint(con, "        ether %02x:%02x:%02x:%02x:%02x:%02x  txqueuelen 0  (Ethernet)\n",
        en0_mac[0], en0_mac[1], en0_mac[2], en0_mac[3], en0_mac[4], en0_mac[5]);
    //ConPrint(con, "        RX packets %d  bytes %d (0.0 MB)\n",
    ConPrint(con, "        RX packets %d  bytes %d\n",
        virtio_net.rx_packets, virtio_net.rx_bytes);
    ConPrint(con, "        RX errors %d  dropped %d  overruns %d  frame %d\n",
        0, 0, 0, 0);//TODO
    //ConPrint(con, "        TX packets %d  bytes %d (0.0 MB)\n",
    ConPrint(con, "        TX packets %d  bytes %d\n",
        virtio_net.tx_packets, virtio_net.tx_bytes);
    ConPrint(con, "        TX errors %d  dropped %d overruns %d  carrier %d  collisions %d\n",
        0, 0, 0, 0, 0);//TODO
    ConPrint(con, "\n");
    return 0;
}

#define CCMD_LS_OP_a     0
#define CCMD_LS_OP_l     1

U0 _CCMD_ls_output(EConsole *con, CDirEntry *de, I64 flags)
{
    I64 i, j;
    I64 tw = 0, ew = 0;
    I64 sw = 0;
    U8 *tmpsz = CAlloc(64);
    CDirEntry *tmpde;
    tmpde=de;
    while (tmpde)
    {
        if (!(tmpde->name[0]=='.' && !(flags & 1 << CCMD_LS_OP_a)))
        {
            tw += StrLen(tmpde->name) + 2;
            ew = Max(ew, StrLen(tmpde->name) + 2);
            StrPrint(tmpsz, "%d", tmpde->size);
            sw = Max(sw, StrLen(tmpsz));
        }
        tmpde = tmpde->next;
    }
    tmpde=de;
    while (tmpde)
    {
        con->fg_color=0xFFFFFF00;
        if (tmpde->attr & RS_ATTR_DIR == RS_ATTR_DIR)
        {
            con->fg_color=0x729FCF00;
        }
        if (!(tmpde->name[0]=='.' && !(flags & 1 << CCMD_LS_OP_a)))
        {
            if (!(flags & 1 << CCMD_LS_OP_l))
            {

                if (tw > con->ch_width)
                {
                    ConPrint(con, "%s", tmpde->name);
                    for (i = 0; i < ew - StrLen(tmpde->name); i++)
                    {
                        ConPrint(con, " ");
                    }
                    if (con->screen_x + ew >= con->ch_width && tmpde->next)
                    {
                        ConPrint(con, "\n");
                    }
                }
                else
                {
                    ConPrint(con, "%s  ", tmpde->name);
                }
            }
            else
            {
                StrPrint(tmpsz, "%d", tmpde->size);
                j = StrLen(tmpsz);
                while (j < sw)
                {
                    ConPrint(con, " ");
                    j++;
                }
                StrPrint(tmpsz, "%d ", tmpde->size);
                ConPrint(con, tmpsz);
                ConPrint(con, "%s\n", tmpde->name);
            }
        }
        tmpde = tmpde->next;
    }
    if (!(flags & 1 << CCMD_LS_OP_l))
    {
        ConPrint(con, "\n");
    }
    Free(tmpsz);
    DirTreeDel(de);
}

I64 CCMD_ls(EConsole *con, I64 argc, U8 **argv)
{
    I64 i, j;
    I64 dirc = 0;
    CDirEntry *de;
    CDirEntry *tmpde;
    U8 *op_lst = "al";
    U64 op_err = NULL;
    I64 flags = NULL;
    switch (ParseOpt(op_lst, argc, argv, &flags, &op_err, TRUE))
    {
        case ERR_INVALID_OPT:
            ConPrint(con, "ls: invalid option -- '%s'\n", op_err);
            break;
        default:
            break;
    }
    if (op_err)
    {
        Free(op_err);
        return 1;
    }
    j = 0;
    for (i = 1; i < argc; i++)
    {
        if (argv[i][0] != '-')
        {
            j++;
        }
    }
    for (i = 1; i < argc; i++)
    {
        if (argv[i][0] != '-')
        {
            dirc++;
        }
    }
    if (!dirc)
    {
        de = FilesFind(Fs->cur_dir);
        _CCMD_ls_output(con, de, flags);

    }
    else
    {
        // TODO: sort
        for (i = 1; i < argc; i++)
        {
            if (argv[i][0] != '-')
            {
                de = FilesFind(argv[i]);
                if (de)
                {
                    _CCMD_ls_output(con, de, flags);
                }
                else
                {
                    ConPrint(con, "ls: cannot access '%s': No such file or directory\n", argv[i]);
                }
            }
        }
    }
    return 0;
}

I64 CCMD_lspci(EConsole *con, I64 argc, U8 **argv)
{
    U8 *dev_class=CAlloc(256);
    CPCIDev *tmppci;
    _LSPCI_PCILookUpDevs;
    tmppci=dev.pci_head.next;
    while (tmppci!=&dev.pci_head)
    {
        StrPrint(dev_class, "Unknown");
        switch (tmppci->base_code)
        {
            case 0x00:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Non-VGA unclassified device");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "VGA compatible unclassified device");
                        break;
                    default:
                        break;
                }
                break;
            case 0x01:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "SCSI storage controller");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "IDE Interface");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "Floppy disk controller");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "IPI bus controller");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "RAID bus controller");
                        break;
                    case 0x05:
                        StrPrint(dev_class, "ATA controller");
                        break;
                    case 0x06:
                        StrPrint(dev_class, "SATA controller");
                        break;
                    case 0x07:
                        StrPrint(dev_class, "Serial Attached SCSI controller");
                        break;
                    case 0x08:
                        StrPrint(dev_class, "Non-Volatile memory controller");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Mass storage controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x02:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Ethernet controller");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "Token ring network controller");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "FDDI network controller");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "ATM network controller");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "ISDN controller");
                        break;
                    case 0x05:
                        StrPrint(dev_class, "WorldFip controller");
                        break;
                    case 0x06:
                        StrPrint(dev_class, "PICMG controller");
                        break;
                    case 0x07:
                        StrPrint(dev_class, "Infiniband controller");
                        break;
                    case 0x08:
                        StrPrint(dev_class, "Fabric controller");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Network controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x03:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "VGA compatible controller");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "XGA compatible controller");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "3D controller");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Display controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x04:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Multimedia video controller");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "Multimedia audio controller");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "Computer telephony device");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "Audio device");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Multimedia controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x05:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "RAM memory");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "FLASH memory");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Memory controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x06:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Host bridge");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "ISA bridge");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "EISA bridge");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "MicroChannel bridge");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "PCI bridge");
                        break;
                    case 0x05:
                        StrPrint(dev_class, "PCMCIA bridge");
                        break;
                    case 0x06:
                        StrPrint(dev_class, "NuBus bridge");
                        break;
                    case 0x07:
                        StrPrint(dev_class, "CardBus bridge");
                        break;
                    case 0x08:
                        StrPrint(dev_class, "RACEway bridge");
                        break;
                    case 0x09:
                        StrPrint(dev_class, "Semi-transparent PCI-to-PCI bridge");
                        break;
                    case 0x0a:
                        StrPrint(dev_class, "InfiniBand to PCI host bridge");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Bridge");
                        break;
                    default:
                        break;
                }
                break;
            case 0x07:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Serial controller");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "Parallel controller");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "Multiport serial controller");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "Modem");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "GPIB controller");
                        break;
                    case 0x05:
                        StrPrint(dev_class, "Smart Card controller");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Communication controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x08:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "PIC");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "DMA controller");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "Timer");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "RTC");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "PCI Hot-plug controller");
                        break;
                    case 0x05:
                        StrPrint(dev_class, "SD Host controller");
                        break;
                    case 0x06:
                        StrPrint(dev_class, "IOMMU");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "System peripheral");
                        break;
                    default:
                        break;
                }
                break;
            case 0x09:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Keyboard controller");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "Digitizer Pen");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "Mouse controller");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "Scanner controller");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "Gameport controller");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Input device controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x0A:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Generic Docking Station");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Docking Station");
                        break;
                    default:
                        break;
                }
                break;
            case 0x0B:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "386");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "486");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "Pentium");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "Pentium");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "P6");
                        break;
                    case 0x10:
                        StrPrint(dev_class, "Alpha");
                        break;
                    case 0x20:
                        StrPrint(dev_class, "PowerPC");
                        break;
                    case 0x30:
                        StrPrint(dev_class, "MIPS");
                        break;
                    case 0x40:
                        StrPrint(dev_class, "Co-processor");
                        break;
                    default:
                        break;
                }
                break;
            case 0x0C:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "FireWire (IEEE 1394)");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "ACCESS Bus");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "SSA");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "USB controller");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "Fibre Channel");
                        break;
                    case 0x05:
                        StrPrint(dev_class, "SMBus");
                        break;
                    case 0x06:
                        StrPrint(dev_class, "InfiniBand");
                        break;
                    case 0x07:
                        StrPrint(dev_class, "IPMI Interface");
                        break;
                    case 0x08:
                        StrPrint(dev_class, "SERCOS interface");
                        break;
                    case 0x09:
                        StrPrint(dev_class, "CANBUS");
                        break;
                    default:
                        break;
                }
                break;
            case 0x0D:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "IRDA controller");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "Consumer IR controller");
                        break;
                    case 0x10:
                        StrPrint(dev_class, "RF controller");
                        break;
                    case 0x11:
                        StrPrint(dev_class, "Bluetooth");
                        break;
                    case 0x12:
                        StrPrint(dev_class, "Broadband");
                        break;
                    case 0x20:
                        StrPrint(dev_class, "802.1a controller");
                        break;
                    case 0x21:
                        StrPrint(dev_class, "802.1b controller");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Wireless controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x0E:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "I2O");
                        break;
                    default:
                        break;
                }
                break;
            case 0x0F:
                switch (tmppci->sub_code)
                {
                    case 0x01:
                        StrPrint(dev_class, "Satellite TV controller");
                        break;
                    case 0x02:
                        StrPrint(dev_class, "Satellite audio communication controller");
                        break;
                    case 0x03:
                        StrPrint(dev_class, "Satellite video communication controller");
                        break;
                    case 0x04:
                        StrPrint(dev_class, "Satellite data communication controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x10:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Network and computing encryption device");
                        break;
                    case 0x10:
                        StrPrint(dev_class, "Entertainment encryption device");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Encryption controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x11:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "DPIO module");
                        break;
                    case 0x01:
                        StrPrint(dev_class, "Performance counters");
                        break;
                    case 0x10:
                        StrPrint(dev_class, "Communication synchronizer");
                        break;
                    case 0x20:
                        StrPrint(dev_class, "Signal processing management");
                        break;
                    case 0x80:
                        StrPrint(dev_class, "Signal processing controller");
                        break;
                    default:
                        break;
                }
                break;
            case 0x12:
                switch (tmppci->sub_code)
                {
                    case 0x00:
                        StrPrint(dev_class, "Processing accelerators");
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
        ConPrint(con, 
            "%02x:%02x.%01x %s: %s %s\n",
            tmppci->bus,tmppci->dev,tmppci->fun,
            dev_class, tmppci->vendor_str,tmppci->dev_id_str);
        tmppci=tmppci->next;
    }
    Free(dev_class);
    return 0;
}

I64 CCMD_more(EConsole *con, I64 argc, U8 **argv)
{
    //TODO: everything
}

I64 CCMD_mkdir(EConsole *con, I64 argc, U8 **argv)
{
    // TODO: options
    I64 i;
    I64 res = 0;
    if (argc < 2)
    {
        ConPrint(con, "mkdir: missing operand\n");
        return 1;
    }
    for (i = 1; i < argc; i++)
    {
        if (FileFind(argv[i]))
        {
            ConPrint(con, "mkdir: cannot create directory '%s': File exists\n", argv[i]);
            res = 1;
        }
        else
        {
            Silent(ON);
            DirMk(argv[i]);
            Silent(OFF);
        }
    }
    return res;
}

I64 CCMD_nslookup(EConsole *con, I64 argc, U8 **argv)
{
    U32 dns_ip = virtio_net.ipv4.dns1;
    U32 res_ip = 0;
    addrinfo* res = NULL;

    if (argc < 2)
    {//TODO: interactive mode
        return 0;
    }

    if (argc > 2)
    {
        //TODO: server argument
    }

    ConPrint(con, "Server:         %d.%d.%d.%d\n",
        dns_ip.u8[3], dns_ip.u8[2], dns_ip.u8[1], dns_ip.u8[0]);
    ConPrint(con, "Address:        %d.%d.%d.%d#53\n\n",
        dns_ip.u8[3], dns_ip.u8[2], dns_ip.u8[1], dns_ip.u8[0]);

    I64 err = getaddrinfo(argv[1], NULL, NULL, &res);
    if (!err)
    {
        ConPrint(con, "Non-authoritative answer:\n");
        res_ip = (res->ai_addr(sockaddr_in*))->sin_addr.s_addr;
        ConPrint(con, "Name:   %s\n", argv[1]);
        ConPrint(con, "Address: %d.%d.%d.%d\n\n",
            res_ip.u8[0], res_ip.u8[1], res_ip.u8[2], res_ip.u8[3]);
        if (res)
        {
            freeaddrinfo(res);
        }
        return 0;
    }

    ConPrint(con, "** server can't find %s: SERVFAIL\n\n", argv[1]);
    if (res)
    {
        freeaddrinfo(res);
    }
    return 1;
}

I64 CCMD_ping(EConsole *con, I64 argc, U8 **argv)
{
    CIPv4Packet *ipv4_pkt;
    CIcmpHeader *icmp_hdr;
    U32 res_ip = NULL;
    I64 cnt = 0;
    I64 echo_size = 48;
    I64 timeout = 0;
    U16 iden = (RandU16 * SysTimerRead) & 0xFFFF;
    U16 seq = 0;
    I64 time_req, time_resp;
    U8 *data = MAlloc(echo_size);
    MemSet(data, 0, echo_size);
    if (argc < 2)
    {
        return 0;
    }
    I64 error = GetAddressForHost(argv[1], &res_ip);
    if (!error)
    {
        ConPrint(con, "PING %s (%d.%d.%d.%d): %d data bytes\n",
            argv[1], res_ip.u8[0], res_ip.u8[1], res_ip.u8[2], res_ip.u8[3], echo_size + 8);
        while (cnt<4) // testing
        {
            icmp_reply[iden] = NULL;
            IcmpSendRequest(htonl(res_ip), iden, seq, 0, data, echo_size);
            time_req = cnts.jiffies;
            timeout = 0;
            while (!icmp_reply[iden] && timeout<1000)
            {
                Sleep(1);
                timeout++;
            }
            if (timeout<1000)
            {
                ipv4_pkt = icmp_reply[iden];
                icmp_hdr = ipv4_pkt->data;
                time_resp = cnts.jiffies;
                ConPrint(con, "%d bytes from %d.%d.%d.%d: icmp_seq=%d ttl=%d time=%d ms\n",
                    ipv4_pkt->length + 8,
                    res_ip.u8[0], res_ip.u8[1], res_ip.u8[2], res_ip.u8[3], 
                    icmp_hdr->seq_number, ipv4_pkt->ttl, time_resp-time_req);
            }
            else
            {
                ConPrint(con, "no answer yet for icmp_seq=%d\n", seq);
                timeout = 500;
            }
            seq++;
            cnt++;
            if (cnt<4) // testing
            {
                Sleep(1000 - timeout);
            }
        }
        ConPrint(con, "\n");
        return 0;
    }
    else
    {
        ConPrint(con, "ping: %s: Name or service not known\n", argv[1]);
    }
    return 0;
}

I64 CCMD_pwd(EConsole *con, I64 argc, U8 **argv)
{
    U8 *buf = MAlloc(512);
    StrPrint(buf, "!:%s", Fs->cur_dir);
    buf[0] = Fs->cur_dv->drv_let;
    ConPrint(con, "%s\n", buf);
    Free(buf);
    return 0;
}

I64 CCMD_reboot(EConsole *con, I64 argc, U8 **argv)
{
    Reboot;
}

#define CCMD_UNAME_OP_s     0
#define CCMD_UNAME_OP_n     1
#define CCMD_UNAME_OP_r     2
#define CCMD_UNAME_OP_v     3
#define CCMD_UNAME_OP_m     4
#define CCMD_UNAME_OP_p     5
#define CCMD_UNAME_OP_i     6
#define CCMD_UNAME_OP_o     7
#define CCMD_UNAME_OP_a     8

I64 CCMD_uname(EConsole *con, I64 argc, U8 **argv)
{
    I64 i;
    CDateStruct *ds = CAlloc(sizeof(CDateStruct));
    Date2Struct(ds, sys_compile_time);
    U8 *op_lst = "snrvmpioa";
    U64 op_err = NULL;
    U8 *ds_m = "JanFebMarAprMayJunJulAugSepOctNovDec";
    U8 *ds_d = "SunMonTueWedThuFriSat";
    U8 *ds_mm = "   ";
    U8 *ds_dd = "   ";
    U8 *tmp=CAlloc(512);
    I64 flags = NULL;
    if (argc < 2)
    {
        flags |= 1 << CCMD_UNAME_OP_s;
    }
    switch (ParseOpt(op_lst, argc, argv, &flags, &op_err))
    {
        case ERR_INVALID_OPT:
            ConPrint(con, "uname: invalid option -- '%s'\n", op_err);
            break;
        case ERR_EXTRA_OPD:
            ConPrint(con, "uname: extra operand '%s'\n", op_err);
            break;
        default:
            break;
    }
    if (op_err)
    {
        Free(op_err);
        Free(tmp);
        Free(ds);
        return 1;
    }
    if (flags & 1 << CCMD_UNAME_OP_a)
    {
        flags = 0x01FF; // Set all options.
    }
    for (i = 0; i < 8; i++)
    { 
        switch (flags & 1 << i)
        {
            case 1 << CCMD_UNAME_OP_s:
                StrAppend(tmp, Define("DD_OS_NAME_VERSION"));
                *StrLastOcc(tmp, "V") = NULL;
                break;
            case 1 << CCMD_UNAME_OP_n:
                StrAppend(tmp, "%s ", wmgr->session->hostname);
                break;
            case 1 << CCMD_UNAME_OP_r:
                StrAppend(tmp, "%1.2f ", sys_os_version);
                break;
            case 1 << CCMD_UNAME_OP_v:
                MemCpy(ds_mm, ds_m + ((ds->mon-1) * 3), 3);
                MemCpy(ds_dd, ds_d + (ds->day_of_week * 3), 3);
                StrAppend(tmp, "%s %s %d %02d:%02d:%02d UTC %d ",
                    ds_dd, ds_mm, ds->day_of_mon, ds->hour, ds->min, ds->sec, ds->year);
                break;
            case 1 << CCMD_UNAME_OP_m:
            case 1 << CCMD_UNAME_OP_p:
            case 1 << CCMD_UNAME_OP_i:
                StrAppend(tmp, "x86_64 ");
                break;
            case 1 << CCMD_UNAME_OP_o:
                StrAppend(tmp, "Erythros ");
                break;
            default:
                break;
        }
    }
    ConPrint(con, "%s\n", tmp);
    Free(tmp);
    Free(ds);
    return 0;
}

I64 CCMD_who(EConsole *con, I64 argc, U8 **argv)
{
    //TODO
    return 0;
}

I64 CCMD_whoami(EConsole *con, I64 argc, U8 **argv)
{
    U8 *op_lst = "";
    U64 op_err = NULL;
    I64 flags = NULL;
    I64 res = 0;
    switch (ParseOpt(op_lst, argc, argv, &flags, &op_err))
    {
        case ERR_INVALID_OPT:
            ConPrint(con, "uname: invalid option -- '%s'\n", op_err);
            res = 1;
            break;
        case ERR_EXTRA_OPD:
            ConPrint(con, "uname: extra operand '%s'\n", op_err);
            res = 1;
            break;
        default:
            ConPrint(con, "%s\n", wmgr->session->user);
            break;
    }
    if (op_err)
    {
        Free(op_err);
    }
    return res;
}

#define CCMD_WMCTRL_OP_m 0
#define CCMD_WMCTRL_OP_l 1
#define CCMD_WMCTRL_OP_a 2
#define CCMD_WMCTRL_OP_c 3
#define CCMD_WMCTRL_OP_G 4

I64 CCMD_wmctrl(EConsole *con, I64 argc, U8 **argv)
{
    EWindow *win = NULL;
    U8 val[5];
    U8 *op_lst = "mlacG";
    U64 op_err = NULL;
    I64 flags = NULL;
    I64 i,j,k;
    I64 res = 0;
    switch (ParseOpt(op_lst, argc, argv, &flags, &op_err, TRUE))
    {
        case ERR_INVALID_OPT:
            ConPrint(con, "wmctrl: invalid option -- '%s'\n", op_err);
            res = 1;
            break;
        case ERR_EXTRA_OPD:
            ConPrint(con, "wmctrl: extra operand '%s'\n", op_err);
            res = 1;
            break;
        default:            
            break;
    }
    if (op_err)
    {
        Free(op_err);
        return res;
    }
    for (i = 0; i < StrLen(op_lst); i++)
    { 
        switch (flags & 1 << i)
        {
            case 1 << CCMD_WMCTRL_OP_m:
                ConPrint(con, "Name: Ewm\n");
                ConPrint(con, "Class: ewm\n");
                ConPrint(con, "PID: %d\n", ewm_task);
                ConPrint(con, "Window manager's \"showing the desktop\" mode: N/A\n");
                break;
            case 1 << CCMD_WMCTRL_OP_l:
                win=wmgr->windows->next;
                while (win)
                {
                    ConPrint(con, "0x%010X  0 ", win);
                    if (flags & 1 << CCMD_WMCTRL_OP_G)
                    {
                        for (k=0;k<4;k++)
                        {
                            switch (k)
                            {
                                case 0:
                                    StrPrint(&val, "%d", win->x);
                                    break;
                                case 1:
                                    StrPrint(&val, "%d", win->y);
                                    break;
                                case 2:
                                    StrPrint(&val, "%d", win->width);
                                    break;
                                case 3:
                                    StrPrint(&val, "%d", win->height);
                                    break;
                                default:
                                    break;
                            }
                            ConPrint(con, &val);
                            for (j=0; j<5-StrLen(&val);j++)
                            {
                                ConPrint(con, " ");
                            }                      
                        }
                    }
                    ConPrint(con, "%s %s\n", wmgr->session->hostname, win->title);
                    win = win->next;
                }
                break;
            case 1 << CCMD_WMCTRL_OP_a:
                break;
            case 1 << CCMD_WMCTRL_OP_c:
                if (argc > 2)
                {
                    win=wmgr->windows->next;
                    while (win)
                    {
                        if (!StrCmp(win->title, argv[2]))
                        {
                            win->msg_close = TRUE;
                        }
                        win = win->next;
                    }
                }
                break;
            default:
                break;
        }
    }
    return res;
}