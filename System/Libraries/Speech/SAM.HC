// See https://github.com/s-macke/SAM#license

U8 *sam_audio_buf=CAlloc(1048576);
I64 sam_audio_len=0;
I64 sam_audio_ctr=0;
I64 sam_audio_size=0;
I64 sam_audio_ctr2=0;
I64 sam_audio_step=4;
I16 *sam_audio_s;

U8 *sam_audio_cmp = CAlloc(256);

/*
U8 *strncat(U8 *dest, U8 *src, I64 n)
{
    U8 *ret = dest;
    while (*dest)
        dest++;
    while (n--)
        if (!(*dest++ = *src++))
            return ret;
    *dest = 0;
    return ret;
}
*/

U8 signedByte(U8 byte)
{
    if (byte > 127)
    {
        return byte - 127;
    }
    else
    {
        return byte + 127;
    }
}

//tab40672
U8 stressInputTable[9] =
{
    '*', '1', '2', '3', '4', '5', '6', '7', '8'
};

//tab40682
U8 signInputTable1[81]={
    ' ', '.', '?', ',', '-', 'I', 'I', 'E',
    'A', 'A', 'A', 'A', 'U', 'A', 'I', 'E',
    'U', 'O', 'R', 'L', 'W', 'Y', 'W', 'R',
    'L', 'W', 'Y', 'M', 'N', 'N', 'D', 'Q',
    'S', 'S', 'F', 'T', '/', '/', 'Z', 'Z',
    'V', 'D', 'C', '*', 'J', '*', '*', '*',
    'E', 'A', 'O', 'A', 'O', 'U', 'B', '*',
    '*', 'D', '*', '*', 'G', '*', '*', 'G',
    '*', '*', 'P', '*', '*', 'T', '*', '*',
    'K', '*', '*', 'K', '*', '*', 'U', 'U',
    'U'
};

//tab40763
U8 signInputTable2[81] =
{
    '*', '*', '*', '*', '*', 'Y', 'H', 'H',
    'E', 'A', 'H', 'O', 'H', 'X', 'X', 'R',
    'X', 'H', 'X', 'X', 'X', 'X', 'H', '*',
    '*', '*', '*', '*', '*', 'X', 'X', '*',
    '*', 'H', '*', 'H', 'H', 'X', '*', 'H',
    '*', 'H', 'H', '*', '*', '*', '*', '*',
    'Y', 'Y', 'Y', 'W', 'W', 'W', '*', '*',
    '*', '*', '*', '*', '*', '*', '*', 'X',
    '*', '*', '*', '*', '*', '*', '*', '*',
    '*', '*', '*', 'X', '*', '*', 'L', 'M',
    'N'
};

//loc_9F8C
U8 flags[81]={
    0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0xA4 , 0xA4 , 0xA4 ,
    0xA4 , 0xA4 , 0xA4 , 0x84 , 0x84 , 0xA4 , 0xA4 , 0x84 ,
    0x84 , 0x84 , 0x84 , 0x84 , 0x84 , 0x84 , 0x44 , 0x44 ,
    0x44 , 0x44 , 0x44 , 0x4C , 0x4C , 0x4C , 0x48 , 0x4C ,
    0x40 , 0x40 , 0x40 , 0x40 , 0x40 , 0x40 , 0x44 , 0x44 ,
    0x44 , 0x44 , 0x48 , 0x40 , 0x4C , 0x44 , 0x00 , 0x00 ,
    0xB4 , 0xB4 , 0xB4 , 0x94 , 0x94 , 0x94 , 0x4E , 0x4E ,
    0x4E , 0x4E , 0x4E , 0x4E , 0x4E , 0x4E , 0x4E , 0x4E ,
    0x4E , 0x4E , 0x4B , 0x4B , 0x4B , 0x4B , 0x4B , 0x4B ,
    0x4B , 0x4B , 0x4B , 0x4B , 0x4B , 0x4B , 0x80 , 0xC1 ,
    0xC1


};

//??? flags overlap flags2
//loc_9FDA
U8 flags2[78] =
{
    0x80 , 0xC1 , 0xC1 , 0xC1 , 0xC1 , 0x00 , 0x00 , 0x00 ,
    0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 ,
    0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x10 ,
    0x10 , 0x10 , 0x10 , 0x08 , 0x0C , 0x08 , 0x04 , 0x40 ,
    0x24 , 0x20 , 0x20 , 0x24 , 0x00 , 0x00 , 0x24 , 0x20 ,
    0x20 , 0x24 , 0x20 , 0x20 , 0x00 , 0x20 , 0x00 , 0x00 ,
    0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 ,
    0x00 , 0x04 , 0x04 , 0x04 , 0x00 , 0x00 , 0x00 , 0x00 ,
    0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x04 , 0x04 , 0x04 ,
    0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
};



//tab45616???
U8 phonemeStressedLengthTable[80] =
{
    0x00 , 0x12 , 0x12 , 0x12 , 8 ,0xB , 9 ,0xB ,
    0xE ,0xF ,0xB , 0x10 ,0xC , 6 , 6 ,0xE ,
    0xC ,0xE ,0xC ,0xB , 8 , 8 ,0xB ,0xA ,
    9 , 8 , 8 , 8 , 8 , 8 , 3 , 5 ,
    2 , 2 , 2 , 2 , 2 , 2 , 6 , 6 ,
    8 , 6 , 6 , 2 , 9 , 4 , 2 , 1 ,
    0xE ,0xF ,0xF ,0xF ,0xE ,0xE , 8 , 2 ,
    2 , 7 , 2 , 1 , 7 , 2 , 2 , 7 ,
    2 , 2 , 8 , 2 , 2 , 6 , 2 , 2 ,
    7 , 2 , 4 , 7 , 1 , 4 , 5 , 5
};

//tab45536???
U8 phonemeLengthTable[80] =
{
    0 , 0x12 , 0x12 , 0x12 , 8 , 8 , 8 , 8 ,
    8 ,0xB , 6 ,0xC ,0xA , 5 , 5 ,0xB ,
    0xA ,0xA ,0xA , 9 , 8 , 7 , 9 , 7 ,
    6 , 8 , 6 , 7 , 7 , 7 , 2 , 5 ,
    2 , 2 , 2 , 2 , 2 , 2 , 6 , 6 ,
    7 , 6 , 6 , 2 , 8 , 3 , 1 , 0x1E ,
    0xD ,0xC ,0xC ,0xC ,0xE , 9 , 6 , 1 ,
    2 , 5 , 1 , 1 , 6 , 1 , 2 , 6 ,
    1 , 2 , 8 , 2 , 2 , 4 , 2 , 2 ,
    6 , 1 , 4 , 6 , 1 , 4 , 0xC7 , 0xFF
};

U8 wait1 = 7;
U8 wait2 = 6;

//U8 input[256]; //tab39445
U8 *input=CAlloc(256);
//standard sam sound
U8 sam_speed = 72;
//U8 sam_pitch = 64;
U8 sam_pitch = 32;
U8 mouth = 128;
U8 throat = 128;
I64 singmode = 0;

U8 mem39;
U8 mem44;
U8 mem47;
U8 mem49;
U8 mem50;
U8 mem51;
U8 mem53;
U8 mem56;

U8 mem59=0;

U8 stress[256]; //numbers from 0 to 8
U8 phonemeLength[256]; //tab40160
U8 phonemeindex[256];

U8 phonemeIndexOutput[60]; //tab47296
U8 stressOutput[60]; //tab47365
U8 phonemeLengthOutput[60]; //tab47416

U8 sam_pitches[256]; // tab43008

U8 frequency1[256];
U8 frequency2[256];
U8 frequency3[256];

U8 amplitude1[256];
U8 amplitude2[256];
U8 amplitude3[256];

U8 sampledConsonantFlag[256]; // tab44800

I64 speech_bufferpos=0;
//U8 *speech_buffer = CAlloc(22050*10);
U8 *speech_buffer = CAlloc(1048576);

//timetable for more accurate c64 simulation
I64 timetable[5][5] =
{
    {162, 167, 167, 127, 128},
    {226, 60, 60, 0, 0},
    {225, 60, 59, 0, 0},
    {200, 0, 0, 54, 55},
    {199, 0, 0, 54, 54}
};

U8 tab48426[5] = { 0x18, 0x1A, 0x17, 0x17, 0x17 };

U8 tab47492[11] =
{
    0 , 0 , 0xE0 , 0xE6 , 0xEC , 0xF3 , 0xF9 , 0 ,
    6 , 0xC , 6
};


U8 amplitudeRescale[17] =
{
    0 , 1 , 2 , 2 , 2 , 3 , 3 , 4 ,
    4 , 5 , 6 , 8 , 9 ,0xB ,0xD ,0xF, 0  //17 elements?
};

// Used to decide which phoneme's blend lengths. The candidate with the lower score is selected.
// tab45856
U8 blendRank[80] =
{
    0 , 0x1F , 0x1F , 0x1F , 0x1F , 2 , 2 , 2 ,
    2 , 2 , 2 , 2 , 2 , 2 , 5 , 5 ,
    2 ,0xA , 2 , 8 , 5 , 5 ,0xB ,0xA ,
    9 , 8 , 8 , 0xA0 , 8 , 8 , 0x17 , 0x1F ,
    0x12 , 0x12 , 0x12 , 0x12 , 0x1E , 0x1E , 0x14 , 0x14 ,
    0x14 , 0x14 , 0x17 , 0x17 , 0x1A , 0x1A , 0x1D , 0x1D ,
    2 , 2 , 2 , 2 , 2 , 2 , 0x1A , 0x1D ,
    0x1B , 0x1A , 0x1D , 0x1B , 0x1A , 0x1D , 0x1B , 0x1A ,
    0x1D , 0x1B , 0x17 , 0x1D , 0x17 , 0x17 , 0x1D , 0x17 ,
    0x17 , 0x1D , 0x17 , 0x17 , 0x1D , 0x17 , 0x17 , 0x17
};


// Number of frames at the end of a phoneme devoted to interpolating to next phoneme's final value
//tab45696
U8 outBlendLength[80] =
{
    0 , 2 , 2 , 2 , 2 , 4 , 4 , 4 ,
    4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 ,
    4 , 4 , 3 , 2 , 4 , 4 , 2 , 2 ,
    2 , 2 , 2 , 1 , 1 , 1 , 1 , 1 ,
    1 , 1 , 1 , 1 , 1 , 1 , 2 , 2 ,
    2 , 1 , 0 , 1 , 0 , 1 , 0 , 5 ,
    5 , 5 , 5 , 5 , 4 , 4 , 2 , 0 ,
    1 , 2 , 0 , 1 , 2 , 0 , 1 , 2 ,
    0 , 1 , 2 , 0 , 2 , 2 , 0 , 1 ,
    3 , 0 , 2 , 3 , 0 , 2 , 0xA0 , 0xA0
};


// Number of frames at beginning of a phoneme devoted to interpolating to phoneme's final value
// tab45776
U8 inBlendLength[80] =
{
    0 , 2 , 2 , 2 , 2 , 4 , 4 , 4 ,
    4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 ,
    4 , 4 , 3 , 3 , 4 , 4 , 3 , 3 ,
    3 , 3 , 3 , 1 , 2 , 3 , 2 , 1 ,
    3 , 3 , 3 , 3 , 1 , 1 , 3 , 3 ,
    3 , 2 , 2 , 3 , 2 , 3 , 0 , 0 ,
    5 , 5 , 5 , 5 , 4 , 4 , 2 , 0 ,
    2 , 2 , 0 , 3 , 2 , 0 , 4 , 2 ,
    0 , 3 , 2 , 0 , 2 , 2 , 0 , 2 ,
    3 , 0 , 3 , 3 , 0 , 3 , 0xB0 , 0xA0
};


// Looks like it's used as bit flags
// High bits masked by 248 (11111000)
//
// 32: S*    241         11110001
// 33: SH    226         11100010
// 34: F*    211         11010011
// 35: TH    187         10111011
// 36: /H    124         01111100
// 37: /X    149         10010101
// 38: Z*    1           00000001
// 39: ZH    2           00000010
// 40: V*    3           00000011
// 41: DH    3           00000011
// 43: **    114         01110010
// 45: **    2           00000010
// 67: **    27          00011011
// 70: **    25          00011001
// tab45936
U8 sampledConsonantFlags[80] =
{
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0xF1 , 0xE2 , 0xD3 , 0xBB , 0x7C , 0x95 , 1 , 2 ,
    3 , 3 , 0 , 0x72 , 0 , 2 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0x1B , 0 , 0 , 0x19 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
};


//tab45056
U8 freq1data[80]=
{
    0x00 ,0x13 ,0x13 ,0x13 ,0x13 , 0xA , 0xE ,0x12
    ,  0x18 ,0x1A ,0x16 ,0x14 ,0x10 ,0x14 , 0xE ,0x12
    ,   0xE ,0x12 ,0x12 ,0x10 , 0xC , 0xE , 0xA ,0x12
    ,   0xE ,0xA  , 8  , 6  , 6  ,  6 ,  6 ,0x11
    ,    6 , 6 , 6 , 6 ,0xE , 0x10 , 9 ,0xA
    ,    8 ,0xA , 6 , 6 , 6 , 5 , 6 , 0
    ,  0x12 , 0x1A , 0x14 , 0x1A , 0x12 ,0xC , 6 , 6
    ,    6 , 6 , 6 , 6 , 6 , 6 , 6 , 6
    ,    6 , 6 , 6 , 6 , 6 , 6 , 6 , 6
    ,    6 ,0xA ,0xA , 6 , 6 , 6 , 0x2C , 0x13
};

//tab451356
U8 freq2data[80]=
{
    0x00 , 0x43 , 0x43 , 0x43 , 0x43 , 0x54 , 0x48 , 0x42 ,
    0x3E , 0x28 , 0x2C , 0x1E , 0x24 , 0x2C , 0x48 , 0x30 ,
    0x24 , 0x1E , 0x32 , 0x24 , 0x1C , 0x44 , 0x18 , 0x32 ,
    0x1E , 0x18 , 0x52 , 0x2E , 0x36 , 0x56 , 0x36 , 0x43 ,
    0x49 , 0x4F , 0x1A , 0x42 , 0x49 , 0x25 , 0x33 , 0x42 ,
    0x28 , 0x2F , 0x4F , 0x4F , 0x42 , 0x4F , 0x6E , 0x00 ,
    0x48 , 0x26 , 0x1E , 0x2A , 0x1E , 0x22 , 0x1A , 0x1A ,
    0x1A , 0x42 , 0x42 , 0x42 , 0x6E , 0x6E , 0x6E , 0x54 ,
    0x54 , 0x54 , 0x1A , 0x1A , 0x1A , 0x42 , 0x42 , 0x42 ,
    0x6D , 0x56 , 0x6D , 0x54 , 0x54 , 0x54 , 0x7F , 0x7F
};

//tab45216
U8 freq3data[80]=
{
    0x00 , 0x5B , 0x5B , 0x5B , 0x5B , 0x6E , 0x5D , 0x5B ,
    0x58 , 0x59 , 0x57 , 0x58 , 0x52 , 0x59 , 0x5D , 0x3E ,
    0x52 , 0x58 , 0x3E , 0x6E , 0x50 , 0x5D , 0x5A , 0x3C ,
    0x6E , 0x5A , 0x6E , 0x51 , 0x79 , 0x65 , 0x79 , 0x5B ,
    0x63 , 0x6A , 0x51 , 0x79 , 0x5D , 0x52 , 0x5D , 0x67 ,
    0x4C , 0x5D , 0x65 , 0x65 , 0x79 , 0x65 , 0x79 , 0x00 ,
    0x5A , 0x58 , 0x58 , 0x58 , 0x58 , 0x52 , 0x51 , 0x51 ,
    0x51 , 0x79 , 0x79 , 0x79 , 0x70 , 0x6E , 0x6E , 0x5E ,
    0x5E , 0x5E , 0x51 , 0x51 , 0x51 , 0x79 , 0x79 , 0x79 ,
    0x65 , 0x65 , 0x70 , 0x5E , 0x5E , 0x5E , 0x08 , 0x01
};

U8 ampl1data[80] =
{
    0 , 0 , 0 , 0 , 0 ,0xD ,0xD ,0xE ,
    0xF ,0xF ,0xF ,0xF ,0xF ,0xC ,0xD ,0xC ,
    0xF ,0xF ,0xD ,0xD ,0xD ,0xE ,0xD ,0xC ,
    0xD ,0xD ,0xD ,0xC , 9 , 9 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 ,0xB ,0xB ,
    0xB ,0xB , 0 , 0 , 1 ,0xB , 0 , 2 ,
    0xE ,0xF ,0xF ,0xF ,0xF ,0xD , 2 , 4 ,
    0 , 2 , 4 , 0 , 1 , 4 , 0 , 1 ,
    4 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 ,0xC , 0 , 0 , 0 , 0 ,0xF ,0xF
};

U8 ampl2data[80] =
{
    0 , 0 , 0 , 0 , 0 ,0xA ,0xB ,0xD ,
    0xE ,0xD ,0xC ,0xC ,0xB , 9 ,0xB ,0xB ,
    0xC ,0xC ,0xC , 8 , 8 ,0xC , 8 ,0xA ,
    8 , 8 ,0xA , 3 , 9 , 6 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 3 , 5 ,
    3 , 4 , 0 , 0 , 0 , 5 ,0xA , 2 ,
    0xE ,0xD ,0xC ,0xD ,0xC , 8 , 0 , 1 ,
    0 , 0 , 1 , 0 , 0 , 1 , 0 , 0 ,
    1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 ,0xA , 0 , 0 ,0xA , 0 , 0 , 0
};

U8 ampl3data[80] =
{
    0 , 0 , 0 , 0 , 0 , 8 , 7 , 8 ,
    8 , 1 , 1 , 0 , 1 , 0 , 7 , 5 ,
    1 , 0 , 6 , 1 , 0 , 7 , 0 , 5 ,
    1 , 0 , 8 , 0 , 0 , 3 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ,
    0 , 0 , 0 , 0 , 0 , 1 ,0xE , 1 ,
    9 , 1 , 0 , 1 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 7 , 0 , 0 , 5 , 0 , 0x13 , 0x10
};



//tab42240
I8 sinus[256] =
{0,3,6,9,12,16,19,22,25,28,31,34,37,40,43,46,49,51,54,57,60,63,65,68,71,73,76,78,81,83,85,88,90,92,94,96,98,100,102,104,106,107,109,111,112,113,115,116,117,118,120,121,122,122,123,124,125,125,126,126,126,127,127,127,127,127,127,127,126,126,126,125,125,124,123,122,122,121,120,118,117,116,115,113,112,111,109,107,106,104,102,100,98,96,94,92,90,88,85,83,81,78,76,73,71,68,65,63,60,57,54,51,49,46,43,40,37,34,31,28,25,22,19,16,12,9,6,3,0,-3,-6,-9,-12,-16,-19,-22,-25,-28,-31,-34,-37,-40,-43,-46,-49,-51,-54,-57,-60,-63,-65,-68,-71,-73,-76,-78,-81,-83,-85,-88,-90,-92,-94,-96,-98,-100,-102,-104,-106,-107,-109,-111,-112,-113,-115,-116,-117,-118,-120,-121,-122,-122,-123,-124,-125,-125,-126,-126,-126,-127,-127,-127,-127,-127,-127,-127,-126,-126,-126,-125,-125,-124,-123,-122,-122,-121,-120,-118,-117,-116,-115,-113,-112,-111,-109,-107,-106,-104,-102,-100,-98,-96,-94,-92,-90,-88,-85,-83,-81,-78,-76,-73,-71,-68,-65,-63,-60,-57,-54,-51,-49,-46,-43,-40,-37,-34,-31,-28,-25,-22,-19,-16,-12,-9,-6,-3};

//tab42496
U8 rectangle[256] =
{
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 , 0x90 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 ,
    0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70 , 0x70
};


//random data ?
U8 sampleTable[0x500] =
{
    //00

    0x38 , 0x84 , 0x6B , 0x19 , 0xC6 , 0x63 ,  0x18 , 0x86
    ,  0x73 , 0x98 , 0xC6 , 0xB1 , 0x1C , 0xCA , 0x31 , 0x8C
    ,  0xC7 , 0x31 , 0x88 , 0xC2 , 0x30 , 0x98 , 0x46 , 0x31
    ,  0x18 , 0xC6 , 0x35 ,0xC , 0xCA , 0x31 ,0xC , 0xC6
    //20
    ,  0x21 , 0x10 , 0x24 , 0x69 , 0x12 , 0xC2 , 0x31 , 0x14
    ,  0xC4 , 0x71 , 8 , 0x4A , 0x22 , 0x49 , 0xAB , 0x6A
    ,  0xA8 , 0xAC , 0x49 , 0x51 , 0x32 , 0xD5 , 0x52 , 0x88
    ,  0x93 , 0x6C , 0x94 , 0x22 , 0x15 , 0x54 , 0xD2 , 0x25
    //40
    ,  0x96 , 0xD4 , 0x50 , 0xA5 , 0x46 , 0x21 , 8 , 0x85
    ,  0x6B , 0x18 , 0xC4 , 0x63 , 0x10 , 0xCE , 0x6B , 0x18
    ,  0x8C , 0x71 , 0x19 , 0x8C , 0x63 , 0x35 ,0xC , 0xC6
    ,  0x33 , 0x99 , 0xCC , 0x6C , 0xB5 , 0x4E , 0xA2 , 0x99
    //60
    ,  0x46 , 0x21 , 0x28 , 0x82 , 0x95 , 0x2E , 0xE3 , 0x30
    ,  0x9C , 0xC5 , 0x30 , 0x9C , 0xA2 , 0xB1 , 0x9C , 0x67
    ,  0x31 , 0x88 , 0x66 , 0x59 , 0x2C , 0x53 , 0x18 , 0x84
    ,  0x67 , 0x50 , 0xCA , 0xE3 ,0xA , 0xAC , 0xAB , 0x30
    //80
    ,  0xAC , 0x62 , 0x30 , 0x8C , 0x63 , 0x10 , 0x94 , 0x62
    ,  0xB1 , 0x8C , 0x82 , 0x28 , 0x96 , 0x33 , 0x98 , 0xD6
    ,  0xB5 , 0x4C , 0x62 , 0x29 , 0xA5 , 0x4A , 0xB5 , 0x9C
    ,  0xC6 , 0x31 , 0x14 , 0xD6 , 0x38 , 0x9C , 0x4B , 0xB4
    //A0
    ,  0x86 , 0x65 , 0x18 , 0xAE , 0x67 , 0x1C , 0xA6 , 0x63
    ,  0x19 , 0x96 , 0x23 , 0x19 , 0x84 , 0x13 , 8 , 0xA6
    ,  0x52 , 0xAC , 0xCA , 0x22 , 0x89 , 0x6E , 0xAB , 0x19
    ,  0x8C , 0x62 , 0x34 , 0xC4 , 0x62 , 0x19 , 0x86 , 0x63
    //C0
    ,  0x18 , 0xC4 , 0x23 , 0x58 , 0xD6 , 0xA3 , 0x50 , 0x42
    ,  0x54 , 0x4A , 0xAD , 0x4A , 0x25 , 0x11 , 0x6B , 0x64
    ,  0x89 , 0x4A , 0x63 , 0x39 , 0x8A , 0x23 , 0x31 , 0x2A
    ,  0xEA , 0xA2 , 0xA9 , 0x44 , 0xC5 , 0x12 , 0xCD , 0x42
    //E0
    ,  0x34 , 0x8C , 0x62 , 0x18 , 0x8C , 0x63 , 0x11 , 0x48
    ,  0x66 , 0x31 , 0x9D , 0x44 , 0x33 , 0x1D , 0x46 , 0x31
    ,  0x9C , 0xC6 , 0xB1 ,0xC , 0xCD , 0x32 , 0x88 , 0xC4
    ,  0x73 , 0x18 , 0x86 , 0x73 , 8 , 0xD6 , 0x63 , 0x58
    //100
    ,    7 , 0x81 , 0xE0 , 0xF0 , 0x3C , 7 , 0x87 , 0x90
    ,  0x3C , 0x7C ,0xF , 0xC7 , 0xC0 , 0xC0 , 0xF0 , 0x7C
    ,  0x1E , 7 , 0x80 , 0x80 , 0 , 0x1C , 0x78 , 0x70
    ,  0xF1 , 0xC7 , 0x1F , 0xC0 ,0xC , 0xFE , 0x1C , 0x1F
    //120
    ,  0x1F ,0xE ,0xA , 0x7A , 0xC0 , 0x71 , 0xF2 , 0x83
    ,  0x8F , 3 ,0xF ,0xF ,0xC , 0 , 0x79 , 0xF8
    ,  0x61 , 0xE0 , 0x43 ,0xF , 0x83 , 0xE7 , 0x18 , 0xF9
    ,  0xC1 , 0x13 , 0xDA , 0xE9 , 0x63 , 0x8F ,0xF , 0x83
    //140
    ,  0x83 , 0x87 , 0xC3 , 0x1F , 0x3C , 0x70 , 0xF0 , 0xE1
    ,  0xE1 , 0xE3 , 0x87 , 0xB8 , 0x71 ,0xE , 0x20 , 0xE3
    ,  0x8D , 0x48 , 0x78 , 0x1C , 0x93 , 0x87 , 0x30 , 0xE1
    ,  0xC1 , 0xC1 , 0xE4 , 0x78 , 0x21 , 0x83 , 0x83 , 0xC3
    //160
    ,  0x87 , 6 , 0x39 , 0xE5 , 0xC3 , 0x87 , 7 ,0xE
    ,  0x1C , 0x1C , 0x70 , 0xF4 , 0x71 , 0x9C , 0x60 , 0x36
    ,  0x32 , 0xC3 , 0x1E , 0x3C , 0xF3 , 0x8F ,0xE , 0x3C
    ,  0x70 , 0xE3 , 0xC7 , 0x8F ,0xF ,0xF ,0xE , 0x3C
    //180
    ,  0x78 , 0xF0 , 0xE3 , 0x87 , 6 , 0xF0 , 0xE3 , 7
    ,  0xC1 , 0x99 , 0x87 ,0xF , 0x18 , 0x78 , 0x70 , 0x70
    ,  0xFC , 0xF3 , 0x10 , 0xB1 , 0x8C , 0x8C , 0x31 , 0x7C
    ,  0x70 , 0xE1 , 0x86 , 0x3C , 0x64 , 0x6C , 0xB0 , 0xE1
    //1A0
    ,  0xE3 ,0xF , 0x23 , 0x8F ,0xF , 0x1E , 0x3E , 0x38
    ,  0x3C , 0x38 , 0x7B , 0x8F , 7 ,0xE , 0x3C , 0xF4
    ,  0x17 , 0x1E , 0x3C , 0x78 , 0xF2 , 0x9E , 0x72 , 0x49
    ,  0xE3 , 0x25 , 0x36 , 0x38 , 0x58 , 0x39 , 0xE2 , 0xDE
    //1C0
    ,  0x3C , 0x78 , 0x78 , 0xE1 , 0xC7 , 0x61 , 0xE1 , 0xE1
    ,  0xB0 , 0xF0 , 0xF0 , 0xC3 , 0xC7 ,0xE , 0x38 , 0xC0
    ,  0xF0 , 0xCE , 0x73 , 0x73 , 0x18 , 0x34 , 0xB0 , 0xE1
    ,  0xC7 , 0x8E , 0x1C , 0x3C , 0xF8 , 0x38 , 0xF0 , 0xE1
    //1E0
    ,  0xC1 , 0x8B , 0x86 , 0x8F , 0x1C , 0x78 , 0x70 , 0xF0
    ,  0x78 , 0xAC , 0xB1 , 0x8F , 0x39 , 0x31 , 0xDB , 0x38
    ,  0x61 , 0xC3 ,0xE ,0xE , 0x38 , 0x78 , 0x73 , 0x17
    ,  0x1E , 0x39 , 0x1E , 0x38 , 0x64 , 0xE1 , 0xF1 , 0xC1
    //200
    ,  0x4E ,0xF , 0x40 , 0xA2 , 2 , 0xC5 , 0x8F , 0x81
    ,  0xA1 , 0xFC , 0x12 , 8 , 0x64 , 0xE0 , 0x3C , 0x22
    ,  0xE0 , 0x45 , 7 , 0x8E ,0xC , 0x32 , 0x90 , 0xF0
    ,  0x1F , 0x20 , 0x49 , 0xE0 , 0xF8 ,0xC , 0x60 , 0xF0
    //220
    ,  0x17 , 0x1A , 0x41 , 0xAA , 0xA4 , 0xD0 , 0x8D , 0x12
    ,  0x82 , 0x1E , 0x1E , 3 , 0xF8 , 0x3E , 3 ,0xC
    ,  0x73 , 0x80 , 0x70 , 0x44 , 0x26 , 3 , 0x24 , 0xE1
    ,  0x3E , 4 , 0x4E , 4 , 0x1C , 0xC1 , 9 , 0xCC
    //240
    ,  0x9E , 0x90 , 0x21 , 7 , 0x90 , 0x43 , 0x64 , 0xC0
    ,   0xF , 0xC6 , 0x90 , 0x9C , 0xC1 , 0x5B , 3 , 0xE2
    ,  0x1D , 0x81 , 0xE0 , 0x5E , 0x1D , 3 , 0x84 , 0xB8
    ,  0x2C ,0xF , 0x80 , 0xB1 , 0x83 , 0xE0 , 0x30 , 0x41
    //260
    ,  0x1E , 0x43 , 0x89 , 0x83 , 0x50 , 0xFC , 0x24 , 0x2E
    ,  0x13 , 0x83 , 0xF1 , 0x7C , 0x4C , 0x2C , 0xC9 ,0xD
    ,  0x83 , 0xB0 , 0xB5 , 0x82 , 0xE4 , 0xE8 , 6 , 0x9C
    ,    7 , 0xA0 , 0x99 , 0x1D , 7 , 0x3E , 0x82 , 0x8F
    //280
    ,  0x70 , 0x30 , 0x74 , 0x40 , 0xCA , 0x10 , 0xE4 , 0xE8
    ,   0xF , 0x92 , 0x14 , 0x3F , 6 , 0xF8 , 0x84 , 0x88
    ,  0x43 , 0x81 ,0xA , 0x34 , 0x39 , 0x41 , 0xC6 , 0xE3
    ,  0x1C , 0x47 , 3 , 0xB0 , 0xB8 , 0x13 ,0xA , 0xC2
    //2A0
    ,  0x64 , 0xF8 , 0x18 , 0xF9 , 0x60 , 0xB3 , 0xC0 , 0x65
    ,  0x20 , 0x60 , 0xA6 , 0x8C , 0xC3 , 0x81 , 0x20 , 0x30
    ,  0x26 , 0x1E , 0x1C , 0x38 , 0xD3 , 1 , 0xB0 , 0x26
    ,  0x40 , 0xF4 ,0xB , 0xC3 , 0x42 , 0x1F , 0x85 , 0x32
    //2C0
    ,  0x26 , 0x60 , 0x40 , 0xC9 , 0xCB , 1 , 0xEC , 0x11
    ,  0x28 , 0x40 , 0xFA , 4 , 0x34 , 0xE0 , 0x70 , 0x4C
    ,  0x8C , 0x1D , 7 , 0x69 , 3 , 0x16 , 0xC8 , 4
    ,  0x23 , 0xE8 , 0xC6 , 0x9A ,0xB , 0x1A , 3 , 0xE0
    //2E0
    ,  0x76 , 6 , 5 , 0xCF , 0x1E , 0xBC , 0x58 , 0x31
    ,  0x71 , 0x66 , 0 , 0xF8 , 0x3F , 4 , 0xFC ,0xC
    ,  0x74 , 0x27 , 0x8A , 0x80 , 0x71 , 0xC2 , 0x3A , 0x26
    ,    6 , 0xC0 , 0x1F , 5 ,0xF , 0x98 , 0x40 , 0xAE
    //300
    ,    1 , 0x7F , 0xC0 , 7 , 0xFF , 0 ,0xE , 0xFE
    ,    0 , 3 , 0xDF , 0x80 , 3 , 0xEF , 0x80 , 0x1B
    ,  0xF1 , 0xC2 , 0 , 0xE7 , 0xE0 , 0x18 , 0xFC , 0xE0
    ,  0x21 , 0xFC , 0x80 , 0x3C , 0xFC , 0x40 ,0xE , 0x7E
    //320
    ,    0 , 0x3F , 0x3E , 0 ,0xF , 0xFE , 0 , 0x1F
    ,  0xFF , 0 , 0x3E , 0xF0 , 7 , 0xFC , 0 , 0x7E
    ,  0x10 , 0x3F , 0xFF , 0 , 0x3F , 0x38 ,0xE , 0x7C
    ,    1 , 0x87 ,0xC , 0xFC , 0xC7 , 0 , 0x3E , 4
    //340
    ,   0xF , 0x3E , 0x1F ,0xF ,0xF , 0x1F ,0xF , 2
    ,  0x83 , 0x87 , 0xCF , 3 , 0x87 ,0xF , 0x3F , 0xC0
    ,    7 , 0x9E , 0x60 , 0x3F , 0xC0 , 3 , 0xFE , 0
    ,  0x3F , 0xE0 , 0x77 , 0xE1 , 0xC0 , 0xFE , 0xE0 , 0xC3
    //360
    ,  0xE0 , 1 , 0xDF , 0xF8 , 3 , 7 , 0 , 0x7E
    ,  0x70 , 0 , 0x7C , 0x38 , 0x18 , 0xFE ,0xC , 0x1E
    ,  0x78 , 0x1C , 0x7C , 0x3E ,0xE , 0x1F , 0x1E , 0x1E
    ,  0x3E , 0 , 0x7F , 0x83 , 7 , 0xDB , 0x87 , 0x83
    //380
    ,    7 , 0xC7 , 7 , 0x10 , 0x71 , 0xFF , 0 , 0x3F
    ,  0xE2 , 1 , 0xE0 , 0xC1 , 0xC3 , 0xE1 , 0 , 0x7F
    ,  0xC0 , 5 , 0xF0 , 0x20 , 0xF8 , 0xF0 , 0x70 , 0xFE
    ,  0x78 , 0x79 , 0xF8 , 2 , 0x3F ,0xC , 0x8F , 3
    //3a0
    ,   0xF , 0x9F , 0xE0 , 0xC1 , 0xC7 , 0x87 , 3 , 0xC3
    ,  0xC3 , 0xB0 , 0xE1 , 0xE1 , 0xC1 , 0xE3 , 0xE0 , 0x71
    ,  0xF0 , 0 , 0xFC , 0x70 , 0x7C ,0xC , 0x3E , 0x38
    ,   0xE , 0x1C , 0x70 , 0xC3 , 0xC7 , 3 , 0x81 , 0xC1
    //3c0
    ,  0xC7 , 0xE7 , 0 ,0xF , 0xC7 , 0x87 , 0x19 , 9
    ,  0xEF , 0xC4 , 0x33 , 0xE0 , 0xC1 , 0xFC , 0xF8 , 0x70
    ,  0xF0 , 0x78 , 0xF8 , 0xF0 , 0x61 , 0xC7 , 0 , 0x1F
    ,  0xF8 , 1 , 0x7C , 0xF8 , 0xF0 , 0x78 , 0x70 , 0x3C
    //3e0
    ,  0x7C , 0xCE ,0xE , 0x21 , 0x83 , 0xCF , 8 , 7
    ,  0x8F , 8 , 0xC1 , 0x87 , 0x8F , 0x80 , 0xC7 , 0xE3
    ,    0 , 7 , 0xF8 , 0xE0 , 0xEF , 0 , 0x39 , 0xF7
    ,  0x80 ,0xE , 0xF8 , 0xE1 , 0xE3 , 0xF8 , 0x21 , 0x9F
    //400
    ,  0xC0 , 0xFF , 3 , 0xF8 , 7 , 0xC0 , 0x1F , 0xF8
    ,  0xC4 , 4 , 0xFC , 0xC4 , 0xC1 , 0xBC , 0x87 , 0xF0
    ,   0xF , 0xC0 , 0x7F , 5 , 0xE0 , 0x25 , 0xEC , 0xC0
    ,  0x3E , 0x84 , 0x47 , 0xF0 , 0x8E , 3 , 0xF8 , 3
    //420
    ,  0xFB , 0xC0 , 0x19 , 0xF8 , 7 , 0x9C ,0xC , 0x17
    ,  0xF8 , 7 , 0xE0 , 0x1F , 0xA1 , 0xFC ,0xF , 0xFC
    ,    1 , 0xF0 , 0x3F , 0 , 0xFE , 3 , 0xF0 , 0x1F
    ,    0 , 0xFD , 0 , 0xFF , 0x88 ,0xD , 0xF9 , 1
    //440
    ,  0xFF , 0 , 0x70 , 7 , 0xC0 , 0x3E , 0x42 , 0xF3
    ,   0xD , 0xC4 , 0x7F , 0x80 , 0xFC , 7 , 0xF0 , 0x5E
    ,  0xC0 , 0x3F , 0 , 0x78 , 0x3F , 0x81 , 0xFF , 1
    ,  0xF8 , 1 , 0xC3 , 0xE8 ,0xC , 0xE4 , 0x64 , 0x8F
    ////460
    ,  0xE4 ,0xF , 0xF0 , 7 , 0xF0 , 0xC2 , 0x1F , 0
    ,  0x7F , 0xC0 , 0x6F , 0x80 , 0x7E , 3 , 0xF8 , 7
    ,  0xF0 , 0x3F , 0xC0 , 0x78 ,0xF , 0x82 , 7 , 0xFE
    ,  0x22 , 0x77 , 0x70 , 2 , 0x76 , 3 , 0xFE , 0
    //480
    ,  0xFE , 0x67 , 0 , 0x7C , 0xC7 , 0xF1 , 0x8E , 0xC6
    ,  0x3B , 0xE0 , 0x3F , 0x84 , 0xF3 , 0x19 , 0xD8 , 3
    ,  0x99 , 0xFC , 9 , 0xB8 ,0xF , 0xF8 , 0 , 0x9D
    ,  0x24 , 0x61 , 0xF9 ,0xD , 0 , 0xFD , 3 , 0xF0
    //4a0
    ,  0x1F , 0x90 , 0x3F , 1 , 0xF8 , 0x1F , 0xD0 ,0xF
    ,  0xF8 , 0x37 , 1 , 0xF8 , 7 , 0xF0 ,0xF , 0xC0
    ,  0x3F , 0 , 0xFE , 3 , 0xF8 ,0xF , 0xC0 , 0x3F
    ,    0 , 0xFA , 3 , 0xF0 ,0xF , 0x80 , 0xFF , 1
    //4c0
    ,  0xB8 , 7 , 0xF0 , 1 , 0xFC , 1 , 0xBC , 0x80
    ,  0x13 , 0x1E , 0 , 0x7F , 0xE1 , 0x40 , 0x7F , 0xA0
    ,  0x7F , 0xB0 , 0 , 0x3F , 0xC0 , 0x1F , 0xC0 , 0x38
    ,   0xF , 0xF0 , 0x1F , 0x80 , 0xFF , 1 , 0xFC , 3
    //4e0
    ,  0xF1 , 0x7E , 1 , 0xFE , 1 , 0xF0 , 0xFF , 0
    ,  0x7F , 0xC0 , 0x1D , 7 , 0xF0 ,0xF , 0xC0 , 0x7E
    ,    6 , 0xE0 , 7 , 0xE0 ,0xF , 0xF8 , 6 , 0xC1
    ,  0xFE , 1 , 0xFC , 3 , 0xE0 ,0xF , 0 , 0xFC
};

U64 oldtimetableindex = 0;
U0 Output8BitAry(I64 index, U8 *ary)
{
    I64 k;
    speech_bufferpos += timetable[oldtimetableindex][index];
    oldtimetableindex = index;
    // write a little bit in advance
    for(k=0; k<5; k++)
    {
        speech_buffer[speech_bufferpos/50 + k] = ary[k];
    }
    sam_audio_len++;
}
U0 Output8Bit(I64 index, U8 A)
{
    //U8 ary[5] = {A,A,A,A,A};
    U8 ary[5];
    MemSet(&ary, A, 5);
    Output8BitAry(index, &ary);
}

U8 Read(U8 p, U8 Y)
{
    switch(p)
    {
    case 168: return sam_pitches[Y];
    case 169: return frequency1[Y];
    case 170: return frequency2[Y];
    case 171: return frequency3[Y];
    case 172: return amplitude1[Y];
    case 173: return amplitude2[Y];
    case 174: return amplitude3[Y];
    }
    Print("Error reading to tables");
    return 0;
}

U0 Write(U8 p, U8 Y, U8 value)
{

    switch(p)
    {
    case 168: sam_pitches[Y] = value; return;
    case 169: frequency1[Y] = value;  return;
    case 170: frequency2[Y] = value;  return;
    case 171: frequency3[Y] = value;  return;
    case 172: amplitude1[Y] = value;  return;
    case 173: amplitude2[Y] = value;  return;
    case 174: amplitude3[Y] = value;  return;
    }
    Print("Error writing to tables\n");
}

U0 RenderSample(U8 *mem66)
{
    I64 tempA;
    // current phoneme's index
    mem49 = Y;

    // mask low three bits and subtract 1 get value to
    // convert 0 bits on unvoiced samples.
    A = mem39&7;
    X = A-1;

    // store the result
    mem56 = X;

    // determine which offset to use from table { 0x18, 0x1A, 0x17, 0x17, 0x17 }
    // T, S, Z                0          0x18
    // CH, J, SH, ZH          1          0x1A
    // P, F*, V, TH, DH       2          0x17
    // /H                     3          0x17
    // /X                     4          0x17

    // get value from the table
    mem53 = tab48426[X];
    mem47 = X;      //46016+mem[56]*256
    //return;
    // voiced sample?
    A = mem39 & 248;
    if(A == 0)
    {
        // voiced phoneme: Z*, ZH, V*, DH
        Y = mem49;
        A = sam_pitches[mem49] >> 4;

        // jump to voiced portion
        goto pos48315;
    }

    Y = A ^ 255;
pos48274:

    // step through the 8 bits in the sample
    mem56 = 8;

    // get the next sample from the table
    // mem47*256 = offset to start of samples
    A = sampleTable[mem47*256+Y];
pos48280:

    // left shift to get the high bit
    tempA = A;
    A = A << 1;
    //48281: BCC 48290

    // bit not set?
    if ((tempA & 128) == 0)
    {
        // convert the bit to value from table
        X = mem53;
        //mem[54296] = X;
        // output the byte
        Output8Bit(1, (X&0x0f) * 16);
        // if X != 0, exit loop
        if(X != 0) goto pos48296;
    }

    // output a 5 for the on bit
    Output8Bit(2, 5 * 16);

    //48295: NOP
pos48296:

    X = 0;

    // decrement counter
    mem56--;

    // if not done, jump to top of loop
    if (mem56 != 0) goto pos48280;

    // increment position
    Y++;
    if (Y != 0) goto pos48274;

    // restore values and return
    mem44 = 1;
    Y = mem49;
    return;


    U8 phase1;

pos48315:
// handle voiced samples here
    return;
   // number of samples?
    phase1 = A ^ 255;

    Y = *mem66;
    do
    {
        //pos48321:

        // shift through all 8 bits
        mem56 = 8;
        //A = Read(mem47, Y);

        // fetch value from table
        A = sampleTable[mem47*256+Y];

        // loop 8 times
        //pos48327:
        do
        {
            //48327: ASL A
            //48328: BCC 48337

            // left shift and check high bit
            tempA = A;
            A = A << 1;
            if ((tempA & 128) != 0)
            {
                // if bit set, output 26
                X = 26;
                Output8Bit(3, (X&0xf)*16);
            } else
            {
                //timetable 4
                // bit is not set, output a 6
                X=6;
                Output8Bit(4, (X&0xf)*16);
            }

            mem56--;
        } while(mem56 != 0);

        // move ahead in the table
        Y++;

        // continue until counter done
        phase1++;

    } while (phase1 != 0);
    //  if (phase1 != 0) goto pos48321;

    // restore values and return
    A = 1;
    mem44 = 1;
    *mem66 = Y;
    Y = mem49;
    return;
}

extern U0 AddInflection(U8 mem48, U8 phase1);

U0 Render()
{
    U8 phase1 = 0;  //mem43
    U8 phase2=0;
    U8 phase3=0;
    U8 mem66=0;
    U8 mem38=0;
    U8 mem40=0;
    U8 sam_speedcounter=0; //mem45
    U8 mem48=0;
    I64 i;
    if (phonemeIndexOutput[0] == 255) return; //exit if no data

    A = 0;
    X = 0;
    mem44 = 0;


// CREATE FRAMES
//
// The length parameter in the list corresponds to the number of frames
// to expand the phoneme to. Each frame represents 10 milliseconds of time.
// So a phoneme with a length of 7 = 7 frames = 70 milliseconds duration.
//
// The parameters are copied from the phoneme to the frame verbatim.


// pos47587:
do
{
    // get the index
    Y = mem44;
    // get the phoneme at the index
    A = phonemeIndexOutput[mem44];
    mem56 = A;

    // if terminal phoneme, exit the loop
    if (A == 255) break;

    // period phoneme *.
    if (A == 1)
    {
       // add rising inflection
        A = 1;
        mem48 = 1;
        //goto pos48376;
        AddInflection(mem48, phase1);
    }
    /*
    if (A == 2) goto pos48372;
    */

    // question mark phoneme?
    if (A == 2)
    {
        // create falling inflection
        mem48 = 255;
        AddInflection(mem48, phase1);
    }
    //  pos47615:

    // get the stress amount (more stress = higher sam_pitch)
    phase1 = tab47492[stressOutput[Y] + 1];

    // get number of frames to write
    phase2 = phonemeLengthOutput[Y];
    Y = mem56;

    // copy from the source to the frames list
    do
    {
        frequency1[X] = freq1data[Y];     // F1 frequency
        frequency2[X] = freq2data[Y];     // F2 frequency
        frequency3[X] = freq3data[Y];     // F3 frequency
        amplitude1[X] = ampl1data[Y];     // F1 amplitude
        amplitude2[X] = ampl2data[Y];     // F2 amplitude
        amplitude3[X] = ampl3data[Y];     // F3 amplitude
        sampledConsonantFlag[X] = sampledConsonantFlags[Y];        // phoneme data for sampled consonants
        sam_pitches[X] = sam_pitch + phase1;      // sam_pitch
        X++;
        phase2--;
    } while(phase2 != 0);
    mem44++;
} while(mem44 != 0);
    A = 0;
    mem44 = 0;
    mem49 = 0; // mem49 starts at as 0
    X = 0;
    while(1) //while No. 1
    {

        // get the current and following phoneme
        Y = phonemeIndexOutput[X];
        A = phonemeIndexOutput[X+1];
        X++;

        // exit loop at end token
        if (A == 255) break;//goto pos47970;


        // get the ranking of each phoneme
        X = A;
        mem56 = blendRank[A];
        A = blendRank[Y];

        // compare the rank - lower rank value is stronger
        if (A == mem56)
        {
            // same rank, so use out blend lengths from each phoneme
            phase1 = outBlendLength[Y];
            phase2 = outBlendLength[X];
        } else
        if (A < mem56)
        {
            // first phoneme is stronger, so us it's blend lengths
            phase1 = inBlendLength[X];
            phase2 = outBlendLength[X];
        } else
        {
            // second phoneme is stronger, so use it's blend lengths
            // note the out/in are swapped
            phase1 = outBlendLength[Y];
            phase2 = inBlendLength[Y];
        }

        Y = mem44;
        A = mem49 + phonemeLengthOutput[mem44]; // A is mem49 + length
        mem49 = A; // mem49 now holds length + position
        A = A + phase2; //Maybe Problem because of carry flag

        //47776: ADC 42
        sam_speedcounter = A;
        mem47 = 168;
        phase3 = mem49 - phase1; // what is mem49
        A = phase1 + phase2; // total transition?
        mem38 = A;

        X = A;
        X -= 2;
        if ((X & 128) == 0)
        do   //while No. 2
        {
            //pos47810:

          // mem47 is used to index the tables:
          // 168  sam_pitches[]
          // 169  frequency1
          // 170  frequency2
          // 171  frequency3
          // 172  amplitude1
          // 173  amplitude2
          // 174  amplitude3

            mem40 = mem38;

            if (mem47 == 168)     // sam_pitch
            {

               // unlike the other values, the sam_pitches[] interpolates from
               // the middle of the current phoneme to the middle of the
               // next phoneme

                U8 mem36, mem37;
                // half the width of the current phoneme
                mem36 = phonemeLengthOutput[mem44] >> 1;
                // half the width of the next phoneme
                mem37 = phonemeLengthOutput[mem44+1] >> 1;
                // sum the values
                mem40 = mem36 + mem37; // length of both halves
                mem37 += mem49; // center of next phoneme
                mem36 = mem49 - mem36; // center index of current phoneme
                A = Read(mem47, mem37); // value at center of next phoneme - end interpolation value
                //A = mem[address];

                Y = mem36; // start index of interpolation
                mem53 = A - Read(mem47, mem36); // value to center of current phoneme
            } else
            {
                // value to interpolate to
                A = Read(mem47, sam_speedcounter);
                // position to start interpolation from
                Y = phase3;
                // value to interpolate from
                mem53 = A - Read(mem47, phase3);
            }

            //Code47503(mem40);
            // ML : Code47503 is division with remainder, and mem50 gets the sign

            // calculate change per frame
            I8 m53 = mem53(I8);
            mem50 = mem53 & 128;
            U8 m53abs = Abs(m53);
            mem51 = m53abs % mem40; //abs((char)m53) % mem40;
            mem53 = ((m53)(I8) / mem40)(U8);

            // interpolation range
            X = mem40; // number of frames to interpolate over
            Y = phase3; // starting frame


            // linearly interpolate values

            mem56 = 0;
            //47907: CLC
            //pos47908:
            while(1)     //while No. 3
            {
                A = Read(mem47, Y) + mem53; //carry alway cleared

                mem48 = A;
                Y++;
                X--;
                if(X == 0) break;

                mem56 += mem51;
                if (mem56 >= mem40)  //???
                {
                    mem56 -= mem40; //carry? is set
                    //if ((mem56 & 128)==0)
                    if ((mem50 & 128)==0)
                    {
                        //47935: BIT 50
                        //47937: BMI 47943
                        if(mem48 != 0) mem48++;
                    } else mem48--;
                }
                //pos47945:
                Write(mem47, Y, mem48);
            } //while No. 3

            //pos47952:
            mem47++;
            //if (mem47 != 175) goto pos47810;
        } while (mem47 != 175);     //while No. 2
        //pos47963:
        mem44++;
        X = mem44;
    }  //while No. 1

    //goto pos47701;
    //pos47970:

    // add the length of this phoneme
    mem48 = mem49 + phonemeLengthOutput[mem44];


// ASSIGN PITCH CONTOUR
//
// This subtracts the F1 frequency from the sam_pitch to create a
// sam_pitch contour. Without this, the output would be at a single
// sam_pitch level (monotone).


    // don't adjust sam_pitch if in sing mode
    if (!singmode)
    {
        // iterate through the speech_buffer
        for(i=0; i<256; i++) {
            // subtract half the frequency of the formant 1.
            // this adds variety to the voice
            sam_pitches[i] -= (frequency1[i] >> 1);
        }
    }

    phase1 = 0;
    phase2 = 0;
    phase3 = 0;
    mem49 = 0;
    sam_speedcounter = 72; //sam standard sam_speed

// RESCALE AMPLITUDE
//
// Rescale volume from a linear scale to decibels.
//

    //amplitude rescaling
    for(i=255; i>=0; i--)
    {
        amplitude1[i] = amplitudeRescale[amplitude1[i]];
        amplitude2[i] = amplitudeRescale[amplitude2[i]];
        amplitude3[i] = amplitudeRescale[amplitude3[i]];
    }

    Y = 0;
    A = sam_pitches[0];
    mem44 = A;
    X = A;
    mem38 = A - (A>>2);     // 3/4*A ???

// PROCESS THE FRAMES
//
// In traditional vocal synthesis, the glottal pulse drives filters, which
// are attenuated to the frequencies of the formants.
//
// SAM generates these formants directly with sin and rectangular waves.
// To simulate them being driven by the glottal pulse, the waveforms are
// reset at the beginning of each glottal pulse.

    //finally the loop for sound output
    //pos48078:
    while(1)
    {
        // get the sampled information on the phoneme
        A = sampledConsonantFlag[Y];
        mem39 = A;

        // unvoiced sampled phoneme?
        A = A & 248;
        if(A != 0)
        {
            // render the sample for the phoneme
            RenderSample(&mem66);

            // skip ahead two in the phoneme speech_buffer
            Y += 2;
            mem48 -= 2;
        } else
        {
            // simulate the glottal pulse and formants
            U8 ary[5];
            U32 p1 = phase1 * 256; // Fixed point integers because we need to divide later on
            U32 p2 = phase2 * 256;
            U32 p3 = phase3 * 256;
            I64 k;
            for (k=0; k<5; k++) {
                I8 sp1 = sinus[0xff & (p1>>8)](I8);
                I8 sp2 = sinus[0xff & (p2>>8)](I8);
                I8 rp3 = rectangle[0xff & (p3>>8)](I8);
                I32 sin1 = sp1 * (amplitude1[Y](U8) & 0x0f);
                I32 sin2 = sp2 * (amplitude2[Y](U8) & 0x0f);
                I32 rect = rp3 * (amplitude3[Y](U8) & 0x0f);
                I32 mux = sin1 + sin2 + rect;
                mux /= 32;
                mux += 128; // Go from signed to unsigned amplitude
                ary[k] = mux;
                p1 += frequency1[Y] * 256 / 4; // Compromise, this becomes a shift and works well
                p2 += frequency2[Y] * 256 / 4;
                p3 += frequency3[Y] * 256 / 4;
            }
            // output the accumulated value
            Output8BitAry(0, &ary);
            sam_speedcounter--;
            if (sam_speedcounter != 0) goto pos48155;
            Y++; //go to next amplitude

            // decrement the frame count
            mem48--;
        }

        // if the frame count is zero, exit the loop
        if(mem48 == 0)  return;
        sam_speedcounter = sam_speed;
pos48155:

        // decrement the remaining length of the glottal pulse
        mem44--;

        // finished with a glottal pulse?
        if(mem44 == 0)
        {
pos48159:
            // fetch the next glottal pulse length
            A = sam_pitches[Y];
            mem44 = A;
            A = A - (A>>2);
            mem38 = A;

            // reset the formant wave generators to keep them in
            // sync with the glottal pulse
            phase1 = 0;
            phase2 = 0;
            phase3 = 0;
            goto cont1;
            //continue;
        }

        // decrement the count
        mem38--;

        // is the count non-zero and the sampled flag is zero?
        if((mem38 != 0) || (mem39 == 0))
        {
            // reset the phase of the formants to match the pulse
            phase1 += frequency1[Y];
            phase2 += frequency2[Y];
            phase3 += frequency3[Y];
            goto cont1;
            //continue;
        }

        // voiced sampled phonemes interleave the sample with the
        // glottal pulse. The sample flag is non-zero, so render
        // the sample for the phoneme.
        RenderSample(&mem66);
        goto pos48159;
cont1:        
    } //while


    // The following code is never reached. It's left over from when
    // the voiced sample code was part of this loop, instead of part
    // of RenderSample();

    //pos48315:
    I64 tempA;
    phase1 = A ^ 255;
    Y = mem66;
    do
    {
        //pos48321:

        mem56 = 8;
        A = Read(mem47, Y);

        //pos48327:
        do
        {
            //48327: ASL A
            //48328: BCC 48337
            tempA = A;
            A = A << 1;
            if ((tempA & 128) != 0)
            {
                X = 26;
                // mem[54296] = X;
                speech_bufferpos += 150;
                speech_buffer[speech_bufferpos/50] = (X & 15)*16;
            } else
            {
                //mem[54296] = 6;
                X=6;
                speech_bufferpos += 150;
                speech_buffer[speech_bufferpos/50] = (X & 15)*16;
            }

            for(X = wait2; X>0; X--); //wait
            mem56--;
        } while(mem56 != 0);

        Y++;
        phase1++;

    } while (phase1 != 0);
    //  if (phase1 != 0) goto pos48321;
    A = 1;
    mem44 = 1;
    mem66 = Y;
    Y = mem49;
    return;
}

U0 AddInflection(U8 mem48, U8 phase1)
{
    //pos48372:
    //  mem48 = 255;
//pos48376:

    // store the location of the punctuation
    mem49 = X;
    A = X;
    I64 Atemp = A;

    // backup 30 frames
    A = A - 30;
    // if index is before speech_buffer, point to start of speech_buffer
    if (Atemp <= 30) A=0;
    X = A;

    // FIXME: Explain this fix better, it's not obvious
    // ML : A =, fixes a problem with invalid sam_pitch with '.'
    while( (A=sam_pitches[X]) == 127) X++;


pos48398:
    //48398: CLC
    //48399: ADC 48

    // add the inflection direction
    A += mem48;
    phase1 = A;

    // set the inflection
    sam_pitches[X] = A;
pos48406:

    // increment the position
    X++;

    // exit if the punctuation has been reached
    if (X == mem49) return; //goto pos47615;
    if (sam_pitches[X] == 255) goto pos48406;
    A = phase1;
    goto pos48398;
}

// mouth formants (F1) 5..29
U8 mouthFormants5_29[30] = {
    0, 0, 0, 0, 0, 10,
    14, 19, 24, 27, 23, 21, 16, 20, 14, 18, 14, 18, 18,
    16, 13, 15, 11, 18, 14, 11, 9, 6, 6, 6};
// throat formants (F2) 5..29
U8 throatFormants5_29[30] = {
255, 255,
255, 255, 255, 84, 73, 67, 63, 40, 44, 31, 37, 45, 73, 49,
36, 30, 51, 37, 29, 69, 24, 50, 30, 24, 83, 46, 54, 86};
// there must be no zeros in this 2 tables
// formant 1 frequencies (mouth) 48..53
U8 mouthFormants48_53[6] = {19, 27, 21, 27, 18, 13};
// formant 2 frequencies (throat) 48..53
U8 throatFormants48_53[6] = {72, 39, 31, 43, 30, 34};

extern U8 trans(U8 mem39212, U8 mem39213);

U0 SetMouthThroat(U8 mouth, U8 throat)
{
    U8 initialFrequency;
    U8 newFrequency = 0;
    //U8 mouth; //mem38880
    //U8 throat; //mem38881

    U8 pos = 5; //mem39216
//pos38942:
    // recalculate formant frequencies 5..29 for the mouth (F1) and throat (F2)
    while(pos != 30)
    {
        // recalculate mouth frequency
        initialFrequency = mouthFormants5_29[pos];
        if (initialFrequency != 0) newFrequency = trans(mouth, initialFrequency);
        freq1data[pos] = newFrequency;

        // recalculate throat frequency
        initialFrequency = throatFormants5_29[pos];
        if(initialFrequency != 0) newFrequency = trans(throat, initialFrequency);
        freq2data[pos] = newFrequency;
        pos++;
    }

//pos39059:
    // recalculate formant frequencies 48..53
    pos = 48;
    Y = 0;
    while(pos != 54)
    {
        // recalculate F1 (mouth formant)
        initialFrequency = mouthFormants48_53[Y];
        newFrequency = trans(mouth, initialFrequency);
        freq1data[pos] = newFrequency;

        // recalculate F2 (throat formant)
        initialFrequency = throatFormants48_53[Y];
        newFrequency = trans(throat, initialFrequency);
        freq2data[pos] = newFrequency;
        Y++;
        pos++;
    }
}

U8 trans(U8 mem39212, U8 mem39213)
{
    //pos39008:
    U8 carry;
    I64 temp;
    U8 mem39214, mem39215;
    A = 0;
    mem39215 = 0;
    mem39214 = 0;
    X = 8;
    do
    {
        carry = mem39212 & 1;
        mem39212 = mem39212 >> 1;
        if (carry != 0)
        {
            /*
                        39018: LSR 39212
                        39021: BCC 39033
                        */
            carry = 0;
            A = mem39215;
            //temp = A(I64) + mem39213(I64);
            temp = A + mem39213;
            A = A + mem39213;
            if (temp > 255) carry = 1;
            mem39215 = A;
        }
        temp = mem39215 & 1;
        mem39215 = (mem39215 >> 1) | (cond(carry,128,0));
        carry = temp;
        //39033: ROR 39215
        X--;
    } while (X != 0);
    temp = mem39214 & 128;
    mem39214 = (mem39214 << 1) | (cond(carry,1,0));
    carry = temp;
    temp = mem39215 & 128;
    mem39215 = (mem39215 << 1) | (cond(carry,1,0));
    carry = temp;

    return mem39215;
}


U0 SAM_SetInput(U8 *_input)
{
    MemSet(input, 0, 256);
    I64 i, l;
    l = StrLen(_input);
    if (l > 254) l = 254;
    for(i=0; i<l; i++)
        input[i] = _input[i];
    input[l] = 0;
    MemSet(&stress, 0, 256);
    MemSet(&phonemeLength, 0, 256);
    MemSet(&phonemeindex, 0, 256);
    MemSet(&phonemeIndexOutput, 0, 256);
    MemSet(&stressOutput, 0, 256);
    MemSet(&sam_pitches, 0, 256);
    MemSet(&frequency1, 0, 256);
    MemSet(&frequency2, 0, 256);
    MemSet(&frequency3, 0, 256);
    MemSet(&amplitude1, 0, 256);
    MemSet(&amplitude2, 0, 256);
    MemSet(&amplitude3, 0, 256);
    MemSet(&sampledConsonantFlag, 0, 256);
}

U0 SAM_Init()
{
    I64 i;
    SetMouthThroat( mouth, throat);

    speech_bufferpos = 0;
    // TODO, check for free the memory, 10 seconds of output should be more than enough
    MemSet(speech_buffer, 0, 1048576);
    MemSet(sam_audio_buf, 0, 1048576);
    sam_audio_len=0;

    for(i=0; i<256; i++)
    {
        stress[i] = 0;
        phonemeLength[i] = 0;
    }

    for(i=0; i<60; i++)
    {
        phonemeIndexOutput[i] = 0;
        stressOutput[i] = 0;
        phonemeLengthOutput[i] = 0;
    }
    phonemeindex[255] = 255; //to prevent speech_buffer overflow // ML : changed from 32 to 255 to stop freezing with long inputs

}

extern I64 Parser1();
extern U0 Parser2();
extern U0 CopyStress();
extern U0 SetPhonemeLength();
extern U0 AdjustLengths();
extern U0 Code41240();
extern U0 InsertBreath();
extern U0 PrepareOutput();


//int Code39771()
I64 SAM_RenderSpeech()
{
    I64 _i;
    SAM_Init();
    phonemeindex[255] = 32; //to prevent speech_buffer overflow

    if (!Parser1()) return 0;
    Parser2();
    CopyStress();
    SetPhonemeLength();
    AdjustLengths();
    Code41240();
    do
    {
        A = phonemeindex[X];
        if (A > 80)
        {
            phonemeindex[X] = 255;
            break; // error: delete all behind it
        }
        X++;
    } while (X != 0);

    //pos39848:
    InsertBreath();

    //mem[40158] = 255;

    PrepareOutput();

    sam_audio_ctr=0;
    for (_i=0;_i<speech_bufferpos;_i++)
    {
        MemSet(sam_audio_buf+sam_audio_ctr, speech_buffer[_i], sam_audio_step*2);
        sam_audio_s=sam_audio_buf+sam_audio_ctr;
        sam_audio_buf[sam_audio_ctr]=0;
        sam_audio_buf[sam_audio_ctr+1]=signedByte(speech_buffer[_i]);
        sam_audio_buf[sam_audio_ctr+2]=0;
        sam_audio_buf[sam_audio_ctr+3]=signedByte(speech_buffer[_i]);
        sam_audio_buf[sam_audio_ctr+4]=0;
        sam_audio_buf[sam_audio_ctr+5]=signedByte(speech_buffer[_i]);
        sam_audio_buf[sam_audio_ctr+6]=0;
        sam_audio_buf[sam_audio_ctr+7]=signedByte(speech_buffer[_i]);
        sam_audio_s[0]/=4;
        sam_audio_s[1]/=4;
        sam_audio_s[2]/=4;
        sam_audio_s[3]/=4;
        sam_audio_ctr+=sam_audio_step*2;
    }

    return 1;
}


//U0 Code48547()
U0 PrepareOutput()
{
    A = 0;
    X = 0;
    Y = 0;

    //pos48551:
    while(1)
    {
        A = phonemeindex[X];
        if (A == 255)
        {
            A = 255;
            phonemeIndexOutput[Y] = 255;
            Render();
            return;
        }
        if (A == 254)
        {
            X++;
            I64 temp = X;
            //mem[48546] = X;
            phonemeIndexOutput[Y] = 255;
            Render();
            //X = mem[48546];
            X=temp;
            Y = 0;
            goto cont_s01;
            //continue;
        }

        if (A == 0)
        {
            X++;
            goto cont_s01;
            //continue;
        }

        phonemeIndexOutput[Y] = A;
        phonemeLengthOutput[Y] = phonemeLength[X];
        stressOutput[Y] = stress[X];
        X++;
        Y++;
cont_s01:
    }
}

extern U0 Insert(U8 position/*var57*/, U8 mem60, U8 mem59, U8 mem58);

//U0 Code48431()
U0 InsertBreath()
{
    U8 mem54;
    U8 mem55;
    U8 index; //variable Y
    mem54 = 255;
    X++;
    mem55 = 0;
    U8 mem66 = 0;
    while(1)
    {
        //pos48440:
        X = mem66;
        index = phonemeindex[X];
        if (index == 255) return;
        mem55 += phonemeLength[X];

        if (mem55 < 232)
        {
            if (index != 254) // ML : Prevents an index out of bounds problem
            {
                A = flags2[index]&1;
                if(A != 0)
                {
                    X++;
                    mem55 = 0;
                    Insert(X, 254, mem59, 0);
                    mem66++;
                    mem66++;
                    goto cont_s02;
                    //continue;
                }
            }
            if (index == 0) mem54 = X;
            mem66++;
            goto cont_s02;
            //continue;
        }
        X = mem54;
        phonemeindex[X] = 31;   // 'Q*' glottal stop
        phonemeLength[X] = 4;
        stress[X] = 0;
        X++;
        mem55 = 0;
        Insert(X, 254, mem59, 0);
        X++;
        mem66 = X;
cont_s02:
    }

}

// Iterates through the phoneme speech_buffer, copying the stress value from
// the following phoneme under the following circumstance:

//     1. The current phoneme is voiced, excluding plosives and fricatives
//     2. The following phoneme is voiced, excluding plosives and fricatives, and
//     3. The following phoneme is stressed
//
//  In those cases, the stress value+1 from the following phoneme is copied.
//
// For example, the word LOITER is represented as LOY5TER, with as stress
// of 5 on the diphtong OY. This routine will copy the stress value of 6 (5+1)
// to the L that precedes it.


//U0 Code41883()
U0 CopyStress()
{
    // loop thought all the phonemes to be output
    U8 pos=0; //mem66
    while(1)
    {
        // get the phomene
        Y = phonemeindex[pos];

        // exit at end of speech_buffer
        if (Y == 255) return;

        // if CONSONANT_FLAG set, skip - only vowels get stress
        if ((flags[Y] & 64) == 0) {pos++; goto cont_s03;}
        // get the next phoneme
        Y = phonemeindex[pos+1];
        if (Y == 255) //prevent speech_buffer overflow
        {
            pos++; goto cont_s03;
        } else
        // if the following phoneme is a vowel, skip
        if ((flags[Y] & 128) == 0)  {pos++; goto cont_s03;}

        // get the stress value at the next position
        Y = stress[pos+1];

        // if next phoneme is not stressed, skip
        if (Y == 0)  {pos++; goto cont_s03;}

        // if next phoneme is not a VOWEL OR ER, skip
        if ((Y & 128) != 0)  {pos++; goto cont_s03;}

        // copy stress from prior phoneme to this one
        stress[pos] = Y+1;

        // advance pointer
        pos++;
cont_s03:        
    }

}


//U0 Code41014()
U0 Insert(U8 position/*var57*/, U8 mem60, U8 mem59, U8 mem58)
{
    I64 i;
    for(i=253; i >= position; i--) // ML : always keep last safe-guarding 255
    {
        phonemeindex[i+1] = phonemeindex[i];
        phonemeLength[i+1] = phonemeLength[i];
        stress[i+1] = stress[i];
    }

    phonemeindex[position] = mem60;
    phonemeLength[position] = mem59;
    stress[position] = mem58;
    return;
}

I64 Parser1()
{
    I64 i;
    U8 sign1;
    U8 sign2;
    U8 position = 0;
    X = 0;
    A = 0;
    Y = 0;

    // CLEAR THE STRESS TABLE
    for(i=0; i<256; i++)
        stress[i] = 0;

  // THIS CODE MATCHES THE PHONEME LETTERS TO THE TABLE
    // pos41078:
    while(1)
    {
        // GET THE FIRST CHARACTER FROM THE PHONEME BUFFER
        sign1 = input[X];
        // TEST FOR 155 (�) END OF LINE MARKER
        if (sign1 == 155)
        {
           // MARK ENDPOINT AND RETURN
            phonemeindex[position] = 255;      //mark endpoint
            // REACHED END OF PHONEMES, SO EXIT
            return 1;       //all ok
        }

        // GET THE NEXT CHARACTER FROM THE BUFFER
        X++;
        sign2 = input[X];

        // NOW sign1 = FIRST CHARACTER OF PHONEME, AND sign2 = SECOND CHARACTER OF PHONEME

       // TRY TO MATCH PHONEMES ON TWO TWO-CHARACTER NAME
       // IGNORE PHONEMES IN TABLE ENDING WITH WILDCARDS

       // SET INDEX TO 0
        Y = 0;
pos41095:

         // GET FIRST CHARACTER AT POSITION Y IN signInputTable
         // --> should change name to PhonemeNameTable1
        A = signInputTable1[Y];

        // FIRST CHARACTER MATCHES?
        if (A == sign1)
        {
           // GET THE CHARACTER FROM THE PhonemeSecondLetterTable
            A = signInputTable2[Y];
            // NOT A SPECIAL AND MATCHES SECOND CHARACTER?
            if ((A != '*') && (A == sign2))
            {
               // STORE THE INDEX OF THE PHONEME INTO THE phomeneIndexTable
                phonemeindex[position] = Y;

                // ADVANCE THE POINTER TO THE phonemeIndexTable
                position++;
                // ADVANCE THE POINTER TO THE phonemeInputBuffer
                X++;

                // CONTINUE PARSING
                goto cont_s04;
                //continue;
            }
        }

        // NO MATCH, TRY TO MATCH ON FIRST CHARACTER TO WILDCARD NAMES (ENDING WITH '*')

        // ADVANCE TO THE NEXT POSITION
        Y++;
        // IF NOT END OF TABLE, CONTINUE
        if (Y != 81) goto pos41095;

// REACHED END OF TABLE WITHOUT AN EXACT (2 CHARACTER) MATCH.
// THIS TIME, SEARCH FOR A 1 CHARACTER MATCH AGAINST THE WILDCARDS

// RESET THE INDEX TO POINT TO THE START OF THE PHONEME NAME TABLE
        Y = 0;
pos41134:
// DOES THE PHONEME IN THE TABLE END WITH '*'?
        if (signInputTable2[Y] == '*')
        {
// DOES THE FIRST CHARACTER MATCH THE FIRST LETTER OF THE PHONEME
            if (signInputTable1[Y] == sign1)
            {
                // SAVE THE POSITION AND MOVE AHEAD
                phonemeindex[position] = Y;

                // ADVANCE THE POINTER
                position++;

                // CONTINUE THROUGH THE LOOP
                goto cont_s04;
                //continue;
            }

        }
        Y++;
        if (Y != 81) goto pos41134; //81 is size of PHONEME NAME table

// FAILED TO MATCH WITH A WILDCARD. ASSUME THIS IS A STRESS
// CHARACTER. SEARCH THROUGH THE STRESS TABLE

        // SET INDEX TO POSITION 8 (END OF STRESS TABLE)
        Y = 8;

       // WALK BACK THROUGH TABLE LOOKING FOR A MATCH
        while( (sign1 != stressInputTable[Y]) && (Y>0))
        {
  // DECREMENT INDEX
            Y--;
        }

        // REACHED THE END OF THE SEARCH WITHOUT BREAKING OUT OF LOOP?
        if (Y == 0)
        {
            //mem[39444] = X;
            //41181: JSR 42043 //Error
           // FAILED TO MATCH ANYTHING, RETURN 0 ON FAILURE
           "ERROR: FAILED TO MATCH ANYTHING\n";
            return 0;
        }
// SET THE STRESS FOR THE PRIOR PHONEME
        stress[position-1] = Y;
cont_s04:            
    } //while
}




//change phonemelength depedendent on stress
//U0 Code41203()
U0 SetPhonemeLength()
{
    U8 A;
    I64 position = 0;
    while(phonemeindex[position] != 255 )
    {
        A = stress[position];
        //41218: BMI 41229
        if ((A == 0) || ((A&128) != 0))
        {
            phonemeLength[position] = phonemeLengthTable[phonemeindex[position]];
        } else
        {
            phonemeLength[position] = phonemeStressedLengthTable[phonemeindex[position]];
        }
        position++;
    }
}


U0 Code41240()
{
    U8 pos=0;

    while(phonemeindex[pos] != 255)
    {
        U8 index; //register AC
        X = pos;
        index = phonemeindex[pos];
        if ((flags[index]&2) == 0)
        {
            pos++;
            goto cont_s06;
            //continue;
        } else
        if ((flags[index]&1) == 0)
        {
            Insert(pos+1, index+1, phonemeLengthTable[index+1], stress[pos]);
            Insert(pos+2, index+2, phonemeLengthTable[index+2], stress[pos]);
            pos += 3;
            goto cont_s06;
            //continue;
        }

        do
        {
            X++;
            A = phonemeindex[X];
        } while(A==0);

        if (A != 255)
        {
            if ((flags[A] & 8) != 0)  {pos++; goto cont_s06;}
            if ((A == 36) || (A == 37)) {pos++; goto cont_s06;} // '/H' '/X'
        }

        Insert(pos+1, index+1, phonemeLengthTable[index+1], stress[pos]);
        Insert(pos+2, index+2, phonemeLengthTable[index+2], stress[pos]);
        pos += 3;
cont_s06:        
    };

}

// Rewrites the phonemes using the following rules:
//
//       <DIPHTONG ENDING WITH WX> -> <DIPHTONG ENDING WITH WX> WX
//       <DIPHTONG NOT ENDING WITH WX> -> <DIPHTONG NOT ENDING WITH WX> YX
//       UL -> AX L
//       UM -> AX M
//       <STRESSED VOWEL> <SILENCE> <STRESSED VOWEL> -> <STRESSED VOWEL> <SILENCE> Q <VOWEL>
//       T R -> CH R
//       D R -> J R
//       <VOWEL> R -> <VOWEL> RX
//       <VOWEL> L -> <VOWEL> LX
//       G S -> G Z
//       K <VOWEL OR DIPHTONG NOT ENDING WITH IY> -> KX <VOWEL OR DIPHTONG NOT ENDING WITH IY>
//       G <VOWEL OR DIPHTONG NOT ENDING WITH IY> -> GX <VOWEL OR DIPHTONG NOT ENDING WITH IY>
//       S P -> S B
//       S T -> S D
//       S K -> S G
//       S KX -> S GX
//       <ALVEOLAR> UW -> <ALVEOLAR> UX
//       CH -> CH CH' (CH requires two phonemes to represent it)
//       J -> J J' (J requires two phonemes to represent it)
//       <UNSTRESSED VOWEL> T <PAUSE> -> <UNSTRESSED VOWEL> DX <PAUSE>
//       <UNSTRESSED VOWEL> D <PAUSE>  -> <UNSTRESSED VOWEL> DX <PAUSE>


//U0 Code41397()
U0 Parser2()
{
    U8 pos = 0; //mem66;
    U8 mem58 = 0;


  // Loop through phonemes
    while(1)
    {
// SET X TO THE CURRENT POSITION
        X = pos;
// GET THE PHONEME AT THE CURRENT POSITION
        A = phonemeindex[pos];

// DEBUG: Print phoneme and index

// Is phoneme pause?
        if (A == 0)
        {
// Move ahead to the
            pos++;
            goto cont_s07;
        }

// If end of phonemes flag reached, exit routine
        if (A == 255) return;

// Copy the current phoneme index to Y
        Y = A;

// RULE:
//       <DIPHTONG ENDING WITH WX> -> <DIPHTONG ENDING WITH WX> WX
//       <DIPHTONG NOT ENDING WITH WX> -> <DIPHTONG NOT ENDING WITH WX> YX
// Example: OIL, COW


// Check for DIPHTONG
        if ((flags[A] & 16) == 0) goto pos41457;

// Not a diphthong. Get the stress
        mem58 = stress[pos];

// End in IY sound?
        A = flags[Y] & 32;

// If ends with IY, use YX, else use WX
        if (A == 0) A = 20; else A = 21;    // 'WX' = 20 'YX' = 21
        //pos41443:
// Insert at WX or YX following, copying the stress

        Insert(pos+1, A, mem59, mem58);
        X = pos;
// Jump to ???
        goto pos41749;



pos41457:

// RULE:
//       UL -> AX L
// Example: MEDDLE

// Get phoneme
        A = phonemeindex[X];
// Skip this rule if phoneme is not UL
        if (A != 78) goto pos41487;  // 'UL'
        A = 24;         // 'L'                 //change 'UL' to 'AX L'


pos41466:
// Get current phoneme stress
        mem58 = stress[X];

// Change UL to AX
        phonemeindex[X] = 13;  // 'AX'
// Perform insert. Note code below may jump up here with different values
        Insert(X+1, A, mem59, mem58);
        pos++;
// Move to next phoneme
        goto cont_s07;

pos41487:

// RULE:
//       UM -> AX M
// Example: ASTRONOMY

// Skip rule if phoneme != UM
        if (A != 79) goto pos41495;   // 'UM'
        // Jump up to branch - replaces current phoneme with AX and continues
        A = 27; // 'M'  //change 'UM' to  'AX M'
        goto pos41466;
pos41495:

// RULE:
//       UN -> AX N
// Example: FUNCTION


// Skip rule if phoneme != UN
        if (A != 80) goto pos41503; // 'UN'

        // Jump up to branch - replaces current phoneme with AX and continues
        A = 28;         // 'N' //change UN to 'AX N'
        goto pos41466;
pos41503:

// RULE:
//       <STRESSED VOWEL> <SILENCE> <STRESSED VOWEL> -> <STRESSED VOWEL> <SILENCE> Q <VOWEL>
// EXAMPLE: AWAY EIGHT

        Y = A;
// VOWEL set?
        A = flags[A] & 128;

// Skip if not a vowel
        if (A != 0)
        {
// Get the stress
            A = stress[X];

// If stressed...
            if (A != 0)
            {
// Get the following phoneme
                X++;
                A = phonemeindex[X];
// If following phoneme is a pause

                if (A == 0)
                {
// Get the phoneme following pause
                    X++;
                    Y = phonemeindex[X];

// Check for end of speech_buffer flag
                    if (Y == 255) //speech_buffer overflow
// ??? Not sure about these flags
                        A = 65&128;
                    else
// And VOWEL flag to current phoneme's flags
                        A = flags[Y] & 128;

// If following phonemes is not a pause
                    if (A != 0)
                    {
// If the following phoneme is not stressed
                        A = stress[X];
                        if (A != 0)
                        {
// Insert a glottal stop and move forward
                            // 31 = 'Q'
                            Insert(X, 31, mem59, 0);
                            pos++;
                            goto cont_s07;
                        }
                    }
                }
            }
        }


// RULES FOR PHONEMES BEFORE R
//        T R -> CH R
// Example: TRACK


// Get current position and phoneme
        X = pos;
        A = phonemeindex[pos];
        if (A != 23) goto pos41611;     // 'R'

// Look at prior phoneme
        X--;
        A = phonemeindex[pos-1];
        //pos41567:
        if (A == 69)                    // 'T'
        {
// Change T to CH
            phonemeindex[pos-1] = 42;
            goto pos41779;
        }


// RULES FOR PHONEMES BEFORE R
//        D R -> J R
// Example: DRY

// Prior phonemes D?
        if (A == 57)                    // 'D'
        {
// Change D to J
            phonemeindex[pos-1] = 44;
            goto pos41788;
        }

// RULES FOR PHONEMES BEFORE R
//        <VOWEL> R -> <VOWEL> RX
// Example: ART


// If vowel flag is set change R to RX
        A = flags[A] & 128;
        if (A != 0) phonemeindex[pos] = 18;  // 'RX'

// continue to next phoneme
        pos++;
        goto cont_s07;

pos41611:

// RULE:
//       <VOWEL> L -> <VOWEL> LX
// Example: ALL

// Is phoneme L?
        if (A == 24)    // 'L'
        {
// If prior phoneme does not have VOWEL flag set, move to next phoneme
            if ((flags[phonemeindex[pos-1]] & 128) == 0) {pos++; goto cont_s07;}
// Prior phoneme has VOWEL flag set, so change L to LX and move to next phoneme
            phonemeindex[X] = 19;     // 'LX'
            pos++;
            goto cont_s07;
        }

// RULE:
//       G S -> G Z
//
// Can't get to fire -
//       1. The G -> GX rule intervenes
//       2. Reciter already replaces GS -> GZ

// Is current phoneme S?
        if (A == 32)    // 'S'
        {
// If prior phoneme is not G, move to next phoneme
            if (phonemeindex[pos-1] != 60) {pos++; goto cont_s07;}
// Replace S with Z and move on
            phonemeindex[pos] = 38;    // 'Z'
            pos++;
            goto cont_s07;
        }

// RULE:
//             K <VOWEL OR DIPHTONG NOT ENDING WITH IY> -> KX <VOWEL OR DIPHTONG NOT ENDING WITH IY>
// Example: COW

// Is current phoneme K?
        if (A == 72)    // 'K'
        {
// Get next phoneme
            Y = phonemeindex[pos+1];
// If at end, replace current phoneme with KX
            if (Y == 255) phonemeindex[pos] = 75; // ML : prevents an index out of bounds problem
            else
            {
// VOWELS AND DIPHTONGS ENDING WITH IY SOUND flag set?
                A = flags[Y] & 32;
// Replace with KX
                if (A == 0) phonemeindex[pos] = 75;  // 'KX'
            }
        }
        else

// RULE:
//             G <VOWEL OR DIPHTONG NOT ENDING WITH IY> -> GX <VOWEL OR DIPHTONG NOT ENDING WITH IY>
// Example: GO


// Is character a G?
        if (A == 60)   // 'G'
        {
// Get the following character
            U8 index = phonemeindex[pos+1];

// At end of speech_buffer?
            if (index == 255) //prevent speech_buffer overflow
            {
                pos++; goto cont_s07;
            }
            else
// If diphtong ending with YX, move continue processing next phoneme
            if ((flags[index] & 32) != 0) {pos++; goto cont_s07;}
// replace G with GX and continue processing next phoneme
            phonemeindex[pos] = 63; // 'GX'
            pos++;
            goto cont_s07;
        }

// RULE:
//      S P -> S B
//      S T -> S D
//      S K -> S G
//      S KX -> S GX
// Examples: SPY, STY, SKY, SCOWL

        Y = phonemeindex[pos];
        //pos41719:
// Replace with softer version?
        A = flags[Y] & 1;
        if (A == 0) goto pos41749;
        A = phonemeindex[pos-1];
        if (A != 32)    // 'S'
        {
            A = Y;
            goto pos41812;
        }
        // Replace with softer version
        phonemeindex[pos] = Y-12;
        pos++;
        goto cont_s07;


pos41749:

// RULE:
//      <ALVEOLAR> UW -> <ALVEOLAR> UX
//
// Example: NEW, DEW, SUE, ZOO, THOO, TOO

//       UW -> UX

        A = phonemeindex[X];
        if (A == 53)    // 'UW'
        {
// ALVEOLAR flag set?
            Y = phonemeindex[X-1];
            A = flags2[Y] & 4;
// If not set, continue processing next phoneme
            if (A == 0) {pos++; goto cont_s07;}
            phonemeindex[X] = 16;
            pos++;
            goto cont_s07;
        }
pos41779:

// RULE:
//       CH -> CH CH' (CH requires two phonemes to represent it)
// Example: CHEW

        if (A == 42)    // 'CH'
        {
            //        pos41783:
            Insert(X+1, A+1, mem59, stress[X]);
            pos++;
            goto cont_s07;
        }

pos41788:

// RULE:
//       J -> J J' (J requires two phonemes to represent it)
// Example: JAY


        if (A == 44) // 'J'
        {
            Insert(X+1, A+1, mem59, stress[X]);
            pos++;
            goto cont_s07;
        }

// Jump here to continue
pos41812:

// RULE: Soften T following vowel
// NOTE: This rule fails for cases such as "ODD"
//       <UNSTRESSED VOWEL> T <PAUSE> -> <UNSTRESSED VOWEL> DX <PAUSE>
//       <UNSTRESSED VOWEL> D <PAUSE>  -> <UNSTRESSED VOWEL> DX <PAUSE>
// Example: PARTY, TARDY


// Past this point, only process if phoneme is T or D

        if (A != 69)    // 'T'
        if (A != 57) {pos++; goto cont_s07;}       // 'D'
        //pos41825:


// If prior phoneme is not a vowel, continue processing phonemes
        if ((flags[phonemeindex[X-1]] & 128) == 0) {pos++; goto cont_s07;}

// Get next phoneme
        X++;
        A = phonemeindex[X];
        //pos41841
// Is the next phoneme a pause?
        if (A != 0)
        {
// If next phoneme is not a pause, continue processing phonemes
            if ((flags[A] & 128) == 0) {pos++; goto cont_s07;}
// If next phoneme is stressed, continue processing phonemes
// FIXME: How does a pause get stressed?
            if (stress[X] != 0) {pos++; goto cont_s07;}
//pos41856:
// Set phonemes to DX
        phonemeindex[pos] = 30;       // 'DX'
        } else
        {
            A = phonemeindex[X+1];
            if (A == 255) //prevent speech_buffer overflow
                A = 65 & 128;
            else
// Is next phoneme a vowel or ER?
                A = flags[A] & 128;
            if (A != 0) phonemeindex[pos] = 30;  // 'DX'
        }

        pos++;

cont_s07:
    } // while
}


// Applies various rules that adjust the lengths of phonemes
//
//         Lengthen <FRICATIVE> or <VOICED> between <VOWEL> and <PUNCTUATION> by 1.5
//         <VOWEL> <RX | LX> <CONSONANT> - decrease <VOWEL> length by 1
//         <VOWEL> <UNVOICED PLOSIVE> - decrease vowel by 1/8th
//         <VOWEL> <UNVOICED CONSONANT> - increase vowel by 1/2 + 1
//         <NASAL> <STOP CONSONANT> - set nasal = 5, consonant = 6
//         <VOICED STOP CONSONANT> {optional silence} <STOP CONSONANT> - shorten both to 1/2 + 1
//         <LIQUID CONSONANT> <DIPHTONG> - decrease by 2


//U0 Code48619()
U0 AdjustLengths()
{

    // LENGTHEN VOWELS PRECEDING PUNCTUATION
    //
    // Search for punctuation. If found, back up to the first vowel, then
    // process all phonemes between there and up to (but not including) the punctuation.
    // If any phoneme is found that is a either a fricative or voiced, the duration is
    // increased by (length * 1.5) + 1

    // loop index
    X = 0;
    U8 index;

    // iterate through the phoneme list
    U8 loopIndex=0;
    while(1)
    {
        // get a phoneme
        index = phonemeindex[X];

        // exit loop if end on speech_buffer token
        if (index == 255) break;

        // not punctuation?
        if((flags2[index] & 1) == 0)
        {
            // skip
            X++;
            goto cont_s08;
        }

        // hold index
        loopIndex = X;

        // Loop backwards from this point
pos48644:

        // back up one phoneme
        X--;

        // stop once the beginning is reached
        if(X == 0) break;

        // get the preceding phoneme
        index = phonemeindex[X];

        if (index != 255) //inserted to prevent access overrun
        if((flags[index] & 128) == 0) goto pos48644; // if not a vowel, continue looping

        //pos48657:
        do
        {
            // test for vowel
            index = phonemeindex[X];

            if (index != 255)//inserted to prevent access overrun
            // test for fricative/unvoiced or not voiced
            if(((flags2[index] & 32) == 0) || ((flags[index] & 4) != 0))     //nochmal �berpr�fen
            {
                //A = flags[Y] & 4;
                //if(A == 0) goto pos48688;

                // get the phoneme length
                A = phonemeLength[X];

                // change phoneme length to (length * 1.5) + 1
                A = (A >> 1) + A + 1;

                phonemeLength[X] = A;


            }
            // keep moving forward
            X++;
        } while (X != loopIndex);
        //  if (X != loopIndex) goto pos48657;
        X++;
cont_s08:        
    }  // while

    // Similar to the above routine, but shorten vowels under some circumstances

    // Loop throught all phonemes
    loopIndex = 0;
    //pos48697

    while(1)
    {
        // get a phoneme
        X = loopIndex;
        index = phonemeindex[X];

        // exit routine at end token
        if (index == 255) return;

        // vowel?
        A = flags[index] & 128;
        if (A != 0)
        {
            // get next phoneme
            X++;
            index = phonemeindex[X];

            // get flags
            if (index == 255)
            mem56 = 65; // use if end marker
            else
            mem56 = flags[index];

            // not a consonant
            if ((flags[index] & 64) == 0)
            {
                // RX or LX?
                if ((index == 18) || (index == 19))  // 'RX' & 'LX'
                {
                    // get the next phoneme
                    X++;
                    index = phonemeindex[X];

                    // next phoneme a consonant?
                    if ((flags[index] & 64) != 0) {
                        // RULE: <VOWEL> RX | LX <CONSONANT>



                        // decrease length of vowel by 1 frame
                        phonemeLength[loopIndex]--;


                    }
                    // move ahead
                    loopIndex++;
                    goto cont_s09;
                }
                // move ahead
                loopIndex++;
                goto cont_s09;
            }


            // Got here if not <VOWEL>

            // not voiced
            if ((mem56 & 4) == 0)
            {

                 // Unvoiced
                 // *, .*, ?*, ,*, -*, DX, S*, SH, F*, TH, /H, /X, CH, P*, T*, K*, KX

                // not an unvoiced plosive?
                if((mem56 & 1) == 0) {
                    // move ahead
                    loopIndex++;
                    goto cont_s09;
                }

                // P*, T*, K*, KX


                // RULE: <VOWEL> <UNVOICED PLOSIVE>
                // <VOWEL> <P*, T*, K*, KX>

                // move back
                X--;


                // decrease length by 1/8th
                mem56 = phonemeLength[X] >> 3;
                phonemeLength[X] -= mem56;


                // move ahead
                loopIndex++;
                goto cont_s09;
            }

            // RULE: <VOWEL> <VOICED CONSONANT>
            // <VOWEL> <WH, R*, L*, W*, Y*, M*, N*, NX, DX, Q*, Z*, ZH, V*, DH, J*, B*, D*, G*, GX>


            // decrease length
            A = phonemeLength[X-1];
            phonemeLength[X-1] = (A >> 2) + A + 1;     // 5/4*A + 1


            // move ahead
            loopIndex++;
            goto cont_s09;

        }


        // WH, R*, L*, W*, Y*, M*, N*, NX, Q*, Z*, ZH, V*, DH, J*, B*, D*, G*, GX

//pos48821:

        // RULE: <NASAL> <STOP CONSONANT>
        //       Set punctuation length to 6
        //       Set stop consonant length to 5

        // nasal?
        if((flags2[index] & 8) != 0)
        {

            // M*, N*, NX,

            // get the next phoneme
            X++;
            index = phonemeindex[X];

            // end of speech_buffer?
            if (index == 255)
               A = 65&2;  //prevent speech_buffer overflow
            else
                A = flags[index] & 2; // check for stop consonant


            // is next phoneme a stop consonant?
            if (A != 0)

               // B*, D*, G*, GX, P*, T*, K*, KX

            {

                // set stop consonant length to 6
                phonemeLength[X] = 6;

                // set nasal length to 5
                phonemeLength[X-1] = 5;


            }
            // move to next phoneme
            loopIndex++;
            goto cont_s09;
        }


        // WH, R*, L*, W*, Y*, Q*, Z*, ZH, V*, DH, J*, B*, D*, G*, GX

        // RULE: <VOICED STOP CONSONANT> {optional silence} <STOP CONSONANT>
        //       Shorten both to (length/2 + 1)

        // (voiced) stop consonant?
        if((flags[index] & 2) != 0)
        {
            // B*, D*, G*, GX

            // move past silence
            do
            {
                // move ahead
                X++;
                index = phonemeindex[X];
            } while(index == 0);


            // check for end of speech_buffer
            if (index == 255) //speech_buffer overflow
            {
                // ignore, overflow code
                if ((65 & 2) == 0) {loopIndex++; goto cont_s09;}
            } else if ((flags[index] & 2) == 0) {
                // if another stop consonant, move ahead
                loopIndex++;
                goto cont_s09;
            }

            // RULE: <UNVOICED STOP CONSONANT> {optional silence} <STOP CONSONANT>
// X gets overwritten, so hold prior X value for debug statement
I64 debugX = X;
            // shorten the prior phoneme length to (length/2 + 1)
            phonemeLength[X] = (phonemeLength[X] >> 1) + 1;
            X = loopIndex;

            // also shorten this phoneme length to (length/2 +1)
            phonemeLength[loopIndex] = (phonemeLength[loopIndex] >> 1) + 1;



            // move ahead
            loopIndex++;
            goto cont_s09;
        }


        // WH, R*, L*, W*, Y*, Q*, Z*, ZH, V*, DH, J*, **,

        // RULE: <VOICED NON-VOWEL> <DIPHTONG>
        //       Decrease <DIPHTONG> by 2

        // liquic consonant?
        if ((flags2[index] & 16) != 0)
        {
            // R*, L*, W*, Y*

            // get the prior phoneme
            index = phonemeindex[X-1];

            // prior phoneme a stop consonant>
            if((flags[index] & 2) != 0) {
                             // Rule: <LIQUID CONSONANT> <DIPHTONG>


             // decrease the phoneme length by 2 frames (20 ms)
             phonemeLength[X] -= 2;


        }
         }

         // move to next phoneme
         loopIndex++;
         goto cont_s09;
cont_s09:         
    }
//            goto pos48701;
}

// -------------------------------------------------------------------------
// ML : Code47503 is division with remainder, and mem50 gets the sign
U0 Code47503(U8 mem52)
{

    Y = 0;
    if ((mem53 & 128) != 0)
    {
        mem53 = -mem53;
        Y = 128;
    }
    mem50 = Y;
    A = 0;
    for(X=8; X > 0; X--)
    {
        I64 temp = mem53;
        mem53 = mem53 << 1;
        A = A << 1;
        if (temp >= 128) A++;
        if (A >= mem52)
        {
            A = A - mem52;
            mem53++;
        }
    }

    mem51 = A;
    if ((mem50 & 128) != 0) mem53 = -mem53;

}
