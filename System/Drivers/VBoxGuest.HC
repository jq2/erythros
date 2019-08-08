#define KBD_MS_UPDATE_INTERVAL          10

#define VBOX_VMMDEV_VERSION             0x00010003
#define VBOX_REQUEST_HEADER_VERSION     0x10001

#define VBOX_REQUEST_GET_MOUSE          1
#define VBOX_REQUEST_SET_MOUSE          2
#define VBOX_REQUEST_GUEST_INFO         50
#define VBOX_REQUEST_HGCM_CONNECT               60
#define VBOX_REQUEST_HGCM_CALL                  62

#define VBOX_SHARED_CLIPBOARD_FMT_UNICODETEXT   0x01
#define VBOX_SHARED_CLIPBOARD_FMT_BITMAP        0x02

#define VBOX_SHARED_CLIPBOARD_FN_GET_HOST_MSG      1
#define VBOX_SHARED_CLIPBOARD_FN_FORMATS           2
#define VBOX_SHARED_CLIPBOARD_FN_READ_DATA         3
#define VBOX_SHARED_CLIPBOARD_FN_WRITE_DATA        4

#define VBOX_SHARED_CLIPBOARD_HOST_MSG_READ_DATA   2
#define VBOX_SHARED_CLIPBOARD_HOST_MSG_FORMATS     3

#define WMGR_TEXT_CLIPBOARD_SIZE	4194304
#define WMGR_UTF16_CLIPBOARD_SIZE	WMGR_TEXT_CLIPBOARD_SIZE*2

Bool vbox_clip_SendToHost = FALSE;

class EVBoxGuest
{
U16 port;
U32 vmmdev;
I64 irq;
};

class EVBoxHeader
{
U32 size;
U32 version;
U32 requestType;
I32 rc;
U32 reserved1;
U32 reserved2;
};

class EVBoxHGCMHeader
{
U32 size;
U32 version;
U32 requestType;
I32 rc;
U32 reserved1;
U32 reserved2;
U32 flags;
I32 result;
};

class EVBoxGuestInfo
{
EVBoxHeader header;
U32 version;
U32 ostype;
};

class EVBoxMouseAbsolute
{
EVBoxHeader header;
U32 features;
I32 x;
I32 y;
};

class EVBoxClipboardConnect
{
EVBoxHGCMHeader header;
U32 locationType;
U8 location[128];
U32 clientId;
U32 msg;
U32 formats;
};

class EVBoxHGCMParam
{
U32 type;
U64 value;
};

class EVBoxHGCMPtr
{
U32 type;
U32 size;
U32 ptr;
};

class EVBoxClipboardFormats
{
EVBoxHGCMHeader header;
U32 clientId;
U32 functionCode;
U32 parameterCount;
EVBoxHGCMParam formats;
};

class EVBoxClipboardMsg
{
EVBoxHGCMHeader header;
U32 clientId;
U32 functionCode;
U32 parameterCount;
EVBoxHGCMParam msg;
EVBoxHGCMParam formats;
};

class EVBoxClipboardRead
{
EVBoxHGCMHeader header;
U32 clientId;
U32 functionCode;
U32 parameterCount;
EVBoxHGCMParam format;
EVBoxHGCMPtr ptr;
EVBoxHGCMParam size;
};

class EVBoxClipboardWrite
{
EVBoxHGCMHeader header;
U32 clientId;
U32 functionCode;
U32 parameterCount;
EVBoxHGCMParam format;
EVBoxHGCMPtr ptr;
};

EVBoxGuest vbox;
EVBoxMouseAbsolute *vbox_mouse = CAllocAligned(sizeof(EVBoxMouseAbsolute), 16, Fs->code_heap);

EVBoxClipboardConnect *vbox_clip = CAllocAligned(sizeof(EVBoxClipboardConnect), 16, Fs->code_heap);
EVBoxClipboardMsg *vbox_clip_msg = CAllocAligned(sizeof(EVBoxClipboardMsg), 16, Fs->code_heap);
EVBoxClipboardRead *vbox_clip_read = CAllocAligned(sizeof(EVBoxClipboardRead), 16, Fs->code_heap);
EVBoxClipboardFormats *vbox_clip_formats = CAllocAligned(sizeof(EVBoxClipboardFormats), 16, Fs->code_heap);
EVBoxClipboardWrite *vbox_clip_write = CAllocAligned(sizeof(EVBoxClipboardWrite), 16, Fs->code_heap);

U0 VBoxConvertFromUtf16(U8 *dst, U16 *src, U32 size)
{
	I64 i;
	for (i=0; i<size; i++)
	{
		dst[i]=src[i];
	}
}

U0 VBoxConvertToUtf16(U16 *dst, U8 *src, I64 size)
{
	I64 i;
	for (i=0; i<size; i++)
	{
		dst[i]=src[i];
	}
}

U0 VBoxClipboardInit()
{
	vbox_clip->header.size = sizeof(EVBoxClipboardConnect);
	vbox_clip->header.version = VBOX_REQUEST_HEADER_VERSION;
	vbox_clip->header.requestType = VBOX_REQUEST_HGCM_CONNECT;
	vbox_clip->header.rc = 0;
	vbox_clip->locationType = 2;
	StrPrint(&vbox_clip->location, "VBoxSharedClipboard");
	OutU32(vbox.port, vbox_clip);
	Sleep(10);
}

U0 VBoxHostClipboardMsgReq()
{
	vbox_clip_msg->header.size = sizeof(EVBoxClipboardMsg);
	vbox_clip_msg->header.version = VBOX_REQUEST_HEADER_VERSION;
	vbox_clip_msg->header.requestType = VBOX_REQUEST_HGCM_CALL;
	vbox_clip_msg->header.rc = 0;
	vbox_clip_msg->header.reserved1 = 0;
	vbox_clip_msg->header.reserved2 = 0;
	vbox_clip_msg->clientId = vbox_clip->clientId;
	vbox_clip_msg->functionCode = VBOX_SHARED_CLIPBOARD_FN_GET_HOST_MSG;
	vbox_clip_msg->parameterCount = 2;
	vbox_clip_msg->msg.type = 1;
	vbox_clip_msg->msg.value = 0;
	vbox_clip_msg->formats.type = 1;
	vbox_clip_msg->formats.value = 0;
	OutU32(vbox.port, vbox_clip_msg);
	Sleep(10);
}

U0 VBoxHostClipboardRead()
{
	vbox_clip_read->header.size = sizeof(EVBoxClipboardRead);
	vbox_clip_read->header.version = VBOX_REQUEST_HEADER_VERSION;
	vbox_clip_read->header.requestType = VBOX_REQUEST_HGCM_CALL;
	vbox_clip_read->header.rc = 0;
	vbox_clip_read->header.reserved1 = 0;
	vbox_clip_read->header.reserved2 = 0;
	vbox_clip_read->clientId = vbox_clip->clientId;
	vbox_clip_read->functionCode = VBOX_SHARED_CLIPBOARD_FN_READ_DATA;
	vbox_clip_read->parameterCount = 3;
	vbox_clip_read->format.type = 1;
	vbox_clip_read->format.value = VBOX_SHARED_CLIPBOARD_FMT_UNICODETEXT;
	vbox_clip_read->ptr.type = 4;
	vbox_clip_read->ptr.size = WMGR_UTF16_CLIPBOARD_SIZE;
	vbox_clip_read->ptr.ptr = wmgr->utf16_clipboard;
	vbox_clip_read->size.type = 1;
	vbox_clip_read->size.value = 0;
	OutU32(vbox.port, vbox_clip_read);
	Sleep(10);
}

U0 VBoxHostClipboardFormats()
{
	vbox_clip_formats->header.size = sizeof(EVBoxClipboardFormats);
	vbox_clip_formats->header.version = VBOX_REQUEST_HEADER_VERSION;
	vbox_clip_formats->header.requestType = VBOX_REQUEST_HGCM_CALL;
	vbox_clip_formats->header.rc = 0;
	vbox_clip_formats->header.reserved1 = 0;
	vbox_clip_formats->header.reserved2 = 0;
	vbox_clip_formats->clientId = vbox_clip->clientId;
	vbox_clip_formats->functionCode = VBOX_SHARED_CLIPBOARD_FN_FORMATS;
	vbox_clip_formats->parameterCount = 1;
	vbox_clip_formats->formats.type = 1;
	vbox_clip_formats->formats.value = VBOX_SHARED_CLIPBOARD_FMT_UNICODETEXT;
	OutU32(vbox.port, vbox_clip_formats);
	Sleep(10);
}

U0 VBoxHostClipboardWrite()
{
	vbox_clip_write->header.size = sizeof(EVBoxClipboardWrite);
	vbox_clip_write->header.version = VBOX_REQUEST_HEADER_VERSION;
	vbox_clip_write->header.requestType = VBOX_REQUEST_HGCM_CALL;
	vbox_clip_write->header.rc = 0;
	vbox_clip_write->header.reserved1 = 0;
	vbox_clip_write->header.reserved2 = 0;
	vbox_clip_write->clientId = vbox_clip->clientId;
	vbox_clip_write->functionCode = VBOX_SHARED_CLIPBOARD_FN_WRITE_DATA;
	vbox_clip_write->parameterCount = 2;
	vbox_clip_write->format.type = 1;
	vbox_clip_write->format.value = VBOX_SHARED_CLIPBOARD_FMT_UNICODETEXT;
	vbox_clip_write->ptr.type = 4;
	vbox_clip_write->ptr.size = StrLen(wmgr->text_clipboard)*2;
	vbox_clip_write->ptr.ptr = wmgr->utf16_clipboard;
	OutU32(vbox.port, vbox_clip_write);
	Sleep(10);
}

U0 VBoxMouseUpdate()
{
	OutU32(vbox.port, vbox_mouse);
	mouse.x = (vbox_mouse->x * display.width) / 0xFFFF;
	mouse.y = (vbox_mouse->y * display.height) / 0xFFFF;
	mouse.lb = ms.lb;
	mouse.rb = ms.rb;
}

Bool KeyDown(I64 sc)
{
	return Bt(kbd.down_bitmap, sc);
}

Bool KeyUp(I64 sc)
{
	return !Bt(kbd.down_bitmap, sc);
}

U0 KeyInputUpdate()
{
	I64 sc;
	if (FifoI64Rem(kbd.scan_code_fifo,&sc))
	{
		if (!(sc&SCF_KEY_UP))
		{
			wmgr->active_key=sc(U8);
			wmgr->active_key_tS=cnts.jiffies;
			return;
		}
	}
	wmgr->active_key=0;
}

U0 VBoxGuestAdditions_Start()
{
	I64 j;
	//Scan for device
	j=PCIClassFind(0x088000,0);
	if (j<0)
	{
		"\nVBoxGuest device not found.\n";
		return;
	}
	vbox.port=PCIReadU32(j.u8[2],
	                     j.u8[1],j.u8[0],0x10) & 0xFFFFFFFC;
	vbox.vmmdev=PCIReadU32(j.u8[2],
	                       j.u8[1],j.u8[0],0x14) & 0xFFFFFFF0;
	vbox.irq=PCIReadU8(j.u8[2],
	                   j.u8[1],j.u8[0],0x3C);
	EVBoxGuestInfo *guest_info = MAllocAligned(sizeof(EVBoxGuestInfo), 16, Fs->code_heap);
	guest_info->header.size = sizeof(EVBoxGuestInfo);
	guest_info->header.version = VBOX_REQUEST_HEADER_VERSION;
	guest_info->header.requestType = VBOX_REQUEST_GUEST_INFO;
	guest_info->header.rc = 0;
	guest_info->header.reserved1 = 0;
	guest_info->header.reserved2 = 0;
	guest_info->version = VBOX_VMMDEV_VERSION;
	guest_info->ostype = 0;
	OutU32(vbox.port, guest_info);
	vbox_mouse->header.size = sizeof(EVBoxMouseAbsolute);
	vbox_mouse->header.version = VBOX_REQUEST_HEADER_VERSION;
	vbox_mouse->header.requestType = VBOX_REQUEST_SET_MOUSE;
	vbox_mouse->header.rc = 0;
	vbox_mouse->header.reserved1 = 0;
	vbox_mouse->header.reserved2 = 0;
	vbox_mouse->features = (1 << 0) | (1 << 4);
	vbox_mouse->x = 0;
	vbox_mouse->y = 0;
	OutU32(vbox.port, vbox_mouse);
	vbox_mouse->header.requestType = VBOX_REQUEST_GET_MOUSE;
}

U0 KbdMsUpdateTask()
{
	VBoxGuestAdditions_Start;
	VBoxClipboardInit;
	VBoxHostClipboardMsgReq;

	while (1)
	{
		WinMsUpdate;
		KbdMsHndlr(0, 0);
		KeyInputUpdate;
		VBoxMouseUpdate;
		if (vbox_clip_SendToHost)
		{
			VBoxHostClipboardFormats;
			VBoxHostClipboardMsgReq;
			vbox_clip_SendToHost = FALSE;
		}
		if (vbox_clip_msg->msg.value==VBOX_SHARED_CLIPBOARD_HOST_MSG_READ_DATA)
		{
			VBoxConvertToUtf16(wmgr->utf16_clipboard, wmgr->text_clipboard, StrLen(wmgr->text_clipboard));
			VBoxHostClipboardWrite;
			VBoxHostClipboardMsgReq;
		}
		if (vbox_clip_msg->msg.value==VBOX_SHARED_CLIPBOARD_HOST_MSG_FORMATS)
		{
			VBoxHostClipboardRead;
			VBoxHostClipboardMsgReq;
		}
		if (!vbox_clip_read->header.reserved2 && vbox_clip_read->size.value)
		{
			VBoxConvertFromUtf16(wmgr->text_clipboard, wmgr->utf16_clipboard, vbox_clip_read->size.value);
			vbox_clip_read->size.value = 0;
		}
		Sleep(KBD_MS_UPDATE_INTERVAL);
	}
}

Spawn(&KbdMsUpdateTask,,,5);