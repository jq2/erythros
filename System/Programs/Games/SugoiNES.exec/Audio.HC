	// vim: set ft=c:

I64 start_buf_num;
U0 (*fp_old_fill_buf)(SND_OUT_CONTAINER *buf,I64 buf_num)=NULL;

U0 AudioFillBuf(SND_OUT_CONTAINER *buf,I64)
{
	I64 j=0,k;
	I64 intL, intR;

	if (paused)
	{
		while (j<SND_BUF_LEN)
		/*
		{
			buf[j++]=0;
		}
		*/
		{
        	if (ewm_hd_buf && ewm_hd_buf_pos<ewm_hd_buf_size)
        	{
            	buf[j++]=ewm_hd_buf[ewm_hd_buf_pos];
            	ewm_hd_buf_pos++;
        	}
        	else
        	{
            	buf[j++]=0;
        	}
		}
		return;
	}

	while (j<SND_BUF_LEN)
	{
		// TODO: fix this - dirty hack to keep audio in sync
		if (FifoI64Cnt(audio_fifo_L)>3192)
		{
			while (FifoI64Cnt(audio_fifo_L)>2680)
			{
				FifoI64Rem(audio_fifo_L, &k);
				FifoI64Rem(audio_fifo_R, &k);
			}
		}

		if (FifoI64Cnt(audio_fifo_L))
		{
			FifoI64Rem(audio_fifo_L, &intL);
		}
		else
		{
			intL = 0;
		}
		intL *= 0xFFFF;
		if (intL < 0)
		{
			intL += 0x1000000;
		}

		if (FifoI64Cnt(audio_fifo_R))
		{
			FifoI64Rem(audio_fifo_R, &intR);
		}
		else
		{
			intR = 0;
		}
		intR *= 0xFFFF;
		if (intR < 0)
		{
			intR += 0x1000000;
		}

		intL *= 64;
		intR *= 64;

        if (ewm_hd_buf && ewm_hd_buf_pos<ewm_hd_buf_size)
        {
            buf[j]=ewm_hd_buf[ewm_hd_buf_pos];
			buf[j].u8[0] += intL;
			buf[j].u8[1] += intL >> 8;
			buf[j].u8[2] += intL;
			buf[j].u8[3] += intL >> 8;
            ewm_hd_buf_pos++;
        }
		else
		{
			buf[j].u8[0] = intL;
			buf[j].u8[1] = intL >> 8;
			buf[j].u8[2] = intL;
			buf[j].u8[3] = intL >> 8;
		}
		j++;
	}
}