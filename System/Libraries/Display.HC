class EDisplay
{
    I64 width;
    I64 height;
    I64 bpp;
};

EDisplay display;

U0 DisplayInit()
{
    display.width = 1280;
    display.height = 720;
    display.bpp = 24;
}

DisplayInit;
