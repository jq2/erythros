U0 GBSoundTask(U8 *regs)
{

  I64 frmCtr=0;
  I64 restCtrA=0;
  I64 restCtrB=0;
  I64 restA=0;
  I64 restB=0;
  I64 div;
  I64 freq;
  I64 x;

  I64 prevA=0;
  I64 prevB=0;

  while (TRUE)
  {
    if(memory[0xFEED]==0)
    {   
      restA=1;
      if (memory[0xFF12]>0b10000)
      {
        x = memory[0xFF13];
        x += ((memory[0xFF14] & 0b00000111)<<8);
        if (x!=prevA && IsMute==0)
        {
          freq=131072/(2048-x);
          div=1193180/freq;
          // I wanted to use Snd(Freq2Ona(freq)); here
          // instead of I/O port writes, but the 
          // conversion isn't right...?
          OutU8(0x43, 0xB6);
          OutU8(0x42, div);
          OutU8(0x42, div>>8);
          OutU8(0x61,3|InU8(0x61));
          prevA=x;
          restA=0;
          restCtrA=0;
        };
      } else {
      };

      if (restA==1)
      { 
        restCtrA++;
        if (restCtrA>30000)
        {
          SndRst;
          SndRst;
          restCtrA=0;
          //prevB=0;
        };
      };

    };

    if(memory[0xFEED]==1)
    {   
      restB=1;
      if (memory[0xFF17]>0b10000)
      {
        x = memory[0xFF18];
        x += ((memory[0xFF19] & 0b00000111)<<8);
        if (x!=prevB && IsMute==0)
        {
          freq=131072/(2048-x);
          div=1193180/freq;
          OutU8(0x43, 0xB6);
          OutU8(0x42, div);
          OutU8(0x42, div>>8);
          OutU8(0x61,3|InU8(0x61));
          prevB=x;
          restB=0;
          restCtrB=0;
        };
      } else {
      };

      if (restB==1)
      { 
        restCtrB++;
        if (restCtrB>30000)
        {
          SndRst;
          SndRst;
          restCtrB=0;
          //prevA=0;
        };
      };

    };

    if(memory[0xFEED]==128)
    {
      SndRst;
    };


    frmCtr=0;
    while(frmCtr<30000){frmCtr++;};  
  };
}
