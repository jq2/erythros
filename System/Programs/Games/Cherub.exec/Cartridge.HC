U0 initCart() {
    I64 cartridgeType=ROM[0x147];
    switch (cartridgeType) {
        case 0x00:
            //ROM w/o bank switching
            if (overrideMBC1) {
                break;
            };
            // no break
        case 0x01:
            cMBC1 = TRUE;
            break;
        case 0x02:
            cMBC1 = TRUE;
            cSRAM = TRUE;
            break;
        case 0x03:
            cMBC1 = TRUE;
            cSRAM = TRUE;
            cBATT = TRUE;
            break;
        case 0x05:
            cMBC2 = TRUE;
            break;
        case 0x06:
            cMBC2 = TRUE;
            cBATT = TRUE;
            break;
        case 0x08:
            cSRAM = TRUE;
            break;
        case 0x09:
            cSRAM = TRUE;
            cBATT = TRUE;
            break;
        case 0x0B:
            cMMMO1 = TRUE;
            break;
        case 0x0C:
            cMMMO1 = TRUE;
            cSRAM = TRUE;
            break;
        case 0x0D:
            cMMMO1 = TRUE;
            cSRAM = TRUE;
            cBATT = TRUE;
            break;
        case 0x0F:
            cMBC3 = TRUE;
            cTIMER = TRUE;
            cBATT = TRUE;
            break;
        case 0x10:
            cMBC3 = TRUE;
            cTIMER = TRUE;
            cBATT = TRUE;
            cSRAM = TRUE;
            break;
        case 0x11:
            cMBC3 = TRUE;
            break;
        case 0x12:
            cMBC3 = TRUE;
            cSRAM = TRUE;
            break;
        case 0x13:
            cMBC3 = TRUE;
            cSRAM = TRUE;
            cBATT = TRUE;
            break;
        case 0x19:
            cMBC5 = TRUE;
            break;
        case 0x1A:
            cMBC5 = TRUE;
            cSRAM = TRUE;
            break;
        case 0x1B:
            cMBC5 = TRUE;
            cSRAM = TRUE;
            cBATT = TRUE;
            break;
        case 0x1C:
            cRUMBLE = TRUE;
            break;
        case 0x1D:
            cRUMBLE = TRUE;
            cSRAM = TRUE;
            break;
        case 0x1E:
            cRUMBLE = TRUE;
            cSRAM = TRUE;
            cBATT = TRUE;
            break;
        case 0x1F:
            cCamera = TRUE;
            break;
        case 0xFD:
            cTAMA5 = TRUE;
            break;
        case 0xFE:
            cHuC3 = TRUE;
            break;
        case 0xFF:
            cHuC1 = TRUE;
            break;
        default:
            "Cartridge type is unknown.\n";
            PressAKey;
            break;
    };
}