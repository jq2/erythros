extern I64 NetFifoPushCopy(U8* data, I64 length);

#define ETHERNET_FRAME_SIZE 1518

// Current Rx/Tx buffer
I64 rx_buffer_ptr = 0;
I64 tx_buffer_ptr = 0;

I64 rx_buffer_count = 256;
I64 tx_buffer_count = 256;

U64 rx_buffers = MAlloc(ETHERNET_FRAME_SIZE * 256);
U64 tx_buffers = MAlloc(ETHERNET_FRAME_SIZE * 256);

class EIPV4Info
{
    U32 addr;
    U32 mask;
    U32 router;
    U32 bcast;
    U32 dns1;
    U32 dns2;
};

class EVirtioNet
{
U16 port;
U8 mac[6];
EVirtioQueue *rq;
EVirtioQueue *sq;
I64 rq_size;
I64 rq_index;
I64 sq_size;
I64 sq_index;
I64 rx_packets;
I64 rx_bytes;
I64 tx_packets;
I64 tx_bytes;
EIPV4Info ipv4;
};

class EVirtioNetHeader
{
    U8 flags;
    U8 gso_type;
    U16 header_length;
    U16 gso_size;
    U16 checksum_start;
    U16 checksum_offset;
};

EVirtioNet virtio_net;
MemSet(&virtio_net, 0, sizeof(EVirtioNet));

EVirtioNetHeader *def_pkt_hdr = CAlloc(sizeof(EVirtioNetHeader));

static I64 VirtioNetAllocTxPacket(U8** buffer_out, I64 length, I64 flags)
{
  // FIXME: validate length
  flags = flags;
  I64 sq_idx = virtio_net.sq->available.index % 256;
  I64 sq_idx2 = sq_idx % 128;
  I64 index = tx_buffer_ptr;
  tx_buffer_ptr = (tx_buffer_ptr + 1) & (tx_buffer_count - 1);
  *buffer_out = tx_buffers + index * ETHERNET_FRAME_SIZE;

  virtio_net.sq->buffers[sq_idx2*2].address = def_pkt_hdr;
  virtio_net.sq->buffers[sq_idx2*2].length = sizeof(EVirtioNetHeader);
  virtio_net.sq->buffers[sq_idx2*2].flags = VRING_DESC_F_NEXT;
  virtio_net.sq->buffers[sq_idx2*2].next = (sq_idx2*2)+1;
  virtio_net.sq->buffers[(sq_idx2*2)+1].address = *buffer_out;
  virtio_net.sq->buffers[(sq_idx2*2)+1].length = length;
  virtio_net.sq->buffers[(sq_idx2*2)+1].flags = NULL;
  virtio_net.sq->buffers[(sq_idx2*2)+1].next = 0;
  virtio_net.sq->available.ring[sq_idx] = sq_idx2*2;
  
  virtio_net.sq->available.index++;

  virtio_net.tx_packets++;
  virtio_net.tx_bytes += length;

  return index;
}

static I64 VirtioNetFinishTxPacket(I64 index)
{
  OutU16(virtio_net.port + VIRTIO_PCI_QUEUE_NOTIFY, 1);
  return 0;
}

U0 VirtioNetInit(I64 bus, I64 dev_, I64 fun)
{

}

I64 EthernetFrameAlloc(U8** buffer_out, U8* src_addr, U8* dst_addr, U16 ethertype, I64 length, I64 flags)
{
  U8* frame;

  // APAD_XMT doesn't seem to work in VirtualBox, so we have to pad the frame ourselves
  if (length < 46)
    length = 46;

  I64 index = VirtioNetAllocTxPacket(&frame, 14 + length, flags);

  if (index < 0)
    return index;

  MemCpy(frame + 0, dst_addr, 6);
  MemCpy(frame + 6, src_addr, 6);
  frame[12] = (ethertype >> 8);
  frame[13] = (ethertype & 0xff);

  *buffer_out = frame + 14;
  return index;
}

I64 EthernetFrameFinish(I64 index)
{
  return VirtioNetFinishTxPacket(index);
}

U8* EthernetGetAddress()
{
  return &virtio_net.mac;
}

I64 EthernetInit()
{
	I64 i,j;
    U8 k;

	//Scan for device
	j=PCIClassFind(0x020000,0);
	if (j<0)
	{
		"\nVirtio-net device not found.\n";
		return -1;
	}
	virtio_net.port=PCIReadU32(j.u8[2],
	                     j.u8[1],j.u8[0],0x10) & 0xFFFFFFFC;
    for (i=0; i<6; i++)
    {
        virtio_net.mac[i] = InU8(virtio_net.port + VIRTIO_PCI_CONFIG + i);
    }

    /*
    "\nVirtio-net device info:\n";
    "-------------------------------------\n\n";
    "I/O base address: 0x%04X\n", virtio_net.port;
    "MAC address:      ";
    for (i=0; i<6; i++)
    {
        "%02X", virtio_net.mac[i];
        if (i<5)
        {
            ":";
        }
    }
    "\n";
    */

    // Reset Device
    OutU8(virtio_net.port + VIRTIO_PCI_STATUS, 0);

    // Found Driver
    OutU8(virtio_net.port + VIRTIO_PCI_STATUS, InU8(virtio_net.port + VIRTIO_PCI_STATUS) | VIRTIO_CONFIG_S_ACKNOWLEDGE | VIRTIO_CONFIG_S_DRIVER);

    // Set up receive queue
    OutU16(virtio_net.port + VIRTIO_PCI_QUEUE_SEL, 0);
    virtio_net.rq_size = InU16(virtio_net.port + VIRTIO_PCI_QUEUE_SIZE);//256
    virtio_net.rq = CAllocAligned(sizeof(EVirtioQueue), 4096, Fs->code_heap);
    OutU32(virtio_net.port + VIRTIO_PCI_QUEUE_PFN, virtio_net.rq / 4096);

    // Set up send queue
    OutU16(virtio_net.port + VIRTIO_PCI_QUEUE_SEL, 1);
    virtio_net.sq_size = InU16(virtio_net.port + VIRTIO_PCI_QUEUE_SIZE);//256
    virtio_net.sq = CAllocAligned(sizeof(EVirtioQueue), 4096, Fs->code_heap);
    OutU32(virtio_net.port + VIRTIO_PCI_QUEUE_PFN, virtio_net.sq / 4096);

    /*
    "recv queue addr: %08X\n", virtio_net.rq;
    "recv queue size: %d\n", virtio_net.rq_size;
    "\n";
    "send queue addr: %08X\n", virtio_net.sq;
    "send queue size: %d\n", virtio_net.sq_size;
    */

    for (i=0; i<128; i++)
    {
      virtio_net.rq->buffers[i*2].address = CAlloc(sizeof(EVirtioNetHeader));
      virtio_net.rq->buffers[i*2].length = sizeof(EVirtioNetHeader);
      virtio_net.rq->buffers[i*2].flags = VRING_DESC_F_NEXT | VRING_DESC_F_WRITE;
      virtio_net.rq->buffers[i*2].next = (i*2)+1;
      virtio_net.rq->buffers[(i*2)+1].address = CAlloc(ETHERNET_FRAME_SIZE);
      virtio_net.rq->buffers[(i*2)+1].length = ETHERNET_FRAME_SIZE;
      virtio_net.rq->buffers[(i*2)+1].flags = VRING_DESC_F_WRITE;
      virtio_net.rq->buffers[(i*2)+1].next = 0;
      virtio_net.rq->available.ring[i] = i*2;
      virtio_net.rq->available.ring[i+128] = i*2; 
    }
    virtio_net.rq->available.index = 1;
    
    // Init OK
    OutU8(virtio_net.port + VIRTIO_PCI_STATUS, InU8(virtio_net.port + VIRTIO_PCI_STATUS) | VIRTIO_CONFIG_S_DRIVER_OK);
    OutU16(virtio_net.port + VIRTIO_PCI_QUEUE_NOTIFY, 0);  
}

U0 VirtioNetRxHandler()
{
  I64 idx_used, idx_rec;
  I64 i,j;
  EVirtioUsedItem *item;
  U8 *buffer;
  I64 length;
  while (1)
  {
    idx_rec = virtio_net.rq_index;
    idx_used = virtio_net.rq->used.index;

    if (idx_rec != idx_used && idx_used)
    {

      j=0;
      for (i=idx_rec; i<idx_used; i++)
      {
        item = virtio_net.rq->used.ring;
        buffer = virtio_net.rq->buffers[item[i%256].index+1];
        length = item[i%256].length;
        NetFifoPushCopy(buffer, length-10);
        j++;
        virtio_net.rx_packets++;
        virtio_net.rx_bytes += length-10;
      }
      virtio_net.rq_index = idx_used;
      virtio_net.rq->available.index += j;
      OutU16(virtio_net.port + VIRTIO_PCI_QUEUE_NOTIFY, 0);  
    }
    Yield;
  }
}

EthernetInit;
Spawn(&VirtioNetRxHandler,,,6);