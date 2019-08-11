/**
 * JUnzip library by Joonas Pihlajamaa (firstname.lastname@iki.fi).
 * Released into public domain. https://github.com/jokkebk/JUnzip
 */

#define Z_OK 0
#define Z_ERRNO -1

I64 JZHOUR(I64 t) { return ((t)>>11); };
I64 JZMINUTE(I64 t) { return (((t)>>5) & 63); };
I64 JZSECOND(I64 t) { return (((t) & 31) * 2); };
I64 JZTIME(I64 h, I64 m, I64 s) { return (((h)<<11) + ((m)<<5) + (s)/2); };

I64 JZYEAR(I64 t) { return (((t)>>9) + 1980); };
I64 JZMONTH(I64 t) { return (((t)>>5) & 15); };
I64 JZDAY(I64 t) { return ((t) & 31); };
I64 JZDATE(I64 y, I64 m, I64 d) { return ((((y)-1980)<<9) + ((m)<<5) + (d)); };

class JZFile
{
    I64 (*read)(JZFile *file, U8 *buf, I64 size);
    I64 (*tell)(JZFile *file);
    I64 (*seek)(JZFile *file, I64 offset, I64 whence);
    I64 (*error)(JZFile *file);
    U0 (*close)(JZFile *file);
    U64 addr;
};

class JZLocalFileHeader
{
    U32 signature; // 0x04034B50
    U16 versionNeededToExtract; // unsupported
    U16 generalPurposeBitFlag; // unsupported
    U16 compressionMethod;
    U16 lastModFileTime;
    U16 lastModFileDate;
    U32 crc32;
    U32 compressedSize;
    U32 uncompressedSize;
    U16 fileNameLength;
    U16 extraFieldLength; // unsupported
};

class JZGlobalFileHeader
{
    U32 signature; // 0x02014B50
    U16 versionMadeBy; // unsupported
    U16 versionNeededToExtract; // unsupported
    U16 generalPurposeBitFlag; // unsupported
    U16 compressionMethod;
    U16 lastModFileTime;
    U16 lastModFileDate;
    U32 crc32;
    U32 compressedSize;
    U32 uncompressedSize;
    U16 fileNameLength;
    U16 extraFieldLength; // unsupported
    U16 fileCommentLength; // unsupported
    U16 diskNumberStart; // unsupported
    U16 internalFileAttributes; // unsupported
    U32 externalFileAttributes; // unsupported
    U32 relativeOffsetOflocalHeader;
};

class JZFileHeader
{
    U16 compressionMethod;
    U16 lastModFileTime;
    U16 lastModFileDate;
    U32 crc32;
    U32 compressedSize;
    U32 uncompressedSize;
    U32 offset;
};

class JZEndRecord
{
    U32 signature; // 0x06054b50
    U16 diskNumber; // unsupported
    U16 centralDirectoryDiskNumber; // unsupported
    U16 numEntriesThisDisk; // unsupported
    U16 numEntries;
    U32 centralDirectorySize;
    U32 centralDirectoryOffset;
    U16 zipCommentLength;
    // Followed by .ZIP file comment (variable size)
};

#define JZ_BUFFER_SIZE 65536

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

// JUnzip library by Joonas Pihlajamaa. See junzip.h for license and details.

U8 jzBuffer[JZ_BUFFER_SIZE]; // limits maximum zip descriptor size

// Read ZIP file end record. Will move within file.
I64 jzReadEndRecord(JZFile *zip, JZEndRecord *endRecord) {
    I64 fileSize, readBytes, i;
    JZEndRecord *er;
    zip->seek(zip, 0, SEEK_END);
    if((fileSize = zip->tell(zip)) <= sizeof(JZEndRecord)) {
        // Too small file to be a zip!
        return Z_ERRNO;
    }
    readBytes = cond((fileSize < sizeof(jzBuffer)), fileSize, sizeof(jzBuffer));
    zip->seek(zip, fileSize - readBytes, SEEK_SET);
    if(zip->read(zip, jzBuffer, readBytes) < readBytes) {
        // Couldn't read end of zip file!
        return Z_ERRNO;
    }
    // Naively assume signature can only be found in one place...
    for(i = readBytes - sizeof(JZEndRecord); i >= 0; i--) {
        er = (jzBuffer + i);
        if(er->signature == 0x06054B50)
            break;
    }
    if(i < 0) {
        // End record signature not found in zip!
        return Z_ERRNO;
    }
    MemCpy(endRecord, er, sizeof(JZEndRecord));
    if(endRecord->diskNumber || endRecord->centralDirectoryDiskNumber ||
            endRecord->numEntries != endRecord->numEntriesThisDisk) {
        // Multifile zips not supported!
        return Z_ERRNO;
    }
    return Z_OK;
}

extern I64 JZRecordCallback(EConsole *con, JZFile *zip, I64 idx, JZFileHeader *header, U8 *filename, U8 *user_data);

// Read ZIP file global directory. Will move within file.
I64 jzReadCentralDirectory(EConsole *con, JZFile *zip, JZEndRecord *endRecord, U8 *user_data) {
    JZGlobalFileHeader fileHeader;
    JZFileHeader header;
    I64 i;
    zip->seek(zip, endRecord->centralDirectoryOffset, SEEK_SET);
    for(i=0; i<endRecord->numEntries; i++) {
        if(zip->read(zip, &fileHeader, sizeof(JZGlobalFileHeader)) <
                sizeof(JZGlobalFileHeader)) {
            ConPrint(con, "Couldn't read file header %d!\n", i);
            return Z_ERRNO;
        }
        if(fileHeader.signature != 0x02014B50) {
            ConPrint(con, "Invalid file header signature %d!\n", i);
            return Z_ERRNO;
        }
        if(fileHeader.fileNameLength + 1 >= JZ_BUFFER_SIZE) {
            ConPrint(con, "Too long file name %d!\n", i);
            return Z_ERRNO;
        }
        if(zip->read(zip, jzBuffer, fileHeader.fileNameLength) <
                fileHeader.fileNameLength) {
            ConPrint(con, "Couldn't read filename %d!\n", i);
            return Z_ERRNO;
        }
        jzBuffer[fileHeader.fileNameLength] = '\0'; // NULL terminate
        zip->seek(zip, fileHeader.extraFieldLength, SEEK_CUR);
        zip->seek(zip, fileHeader.fileCommentLength, SEEK_CUR);
        // Construct JZFileHeader from global file header
        MemCpy(&header, &fileHeader.compressionMethod, sizeof(header));
        header.offset = fileHeader.relativeOffsetOflocalHeader;
        if(!JZRecordCallback(con, zip, i, &header, jzBuffer, user_data))
            break; // end if callback returns zero
    }
    return Z_OK;
}

// Read local ZIP file header. Silent on errors so optimistic reading possible.
I64 jzReadLocalFileHeaderRaw(JZFile *zip, JZLocalFileHeader *header, U8 *filename, I64 len) {
    if(zip->read(zip, header, sizeof(JZLocalFileHeader)) <
            sizeof(JZLocalFileHeader))
        return Z_ERRNO;
    if(header->signature != 0x04034B50)
        return Z_ERRNO;
    if(len) { // read filename
        if(header->fileNameLength >= len)
            return Z_ERRNO; // filename cannot fit
        if(zip->read(zip, filename, header->fileNameLength) <
                header->fileNameLength)
            return Z_ERRNO; // read fail
        filename[header->fileNameLength] = '\0'; // NULL terminate
    } else { // skip filename
        if(zip->seek(zip, header->fileNameLength, SEEK_CUR))
            return Z_ERRNO;
    }
    if(header->extraFieldLength) {
        zip->seek(zip, header->extraFieldLength, SEEK_CUR);
    }
    // For now, silently ignore bit flags and hope ZLIB can uncompress
    // if(header->generalPurposeBitFlag)
    //     return Z_ERRNO; // Flags not supported
    if(header->compressionMethod == 0 &&
            (header->compressedSize != header->uncompressedSize))
        return Z_ERRNO; // Method is "store" but sizes indicate otherwise, abort
    return Z_OK;
}

I64 jzReadLocalFileHeader(JZFile *zip, JZFileHeader *header,
        U8 *filename, I64 len) {
    JZLocalFileHeader localHeader;
    if(jzReadLocalFileHeaderRaw(zip, &localHeader, filename, len) != Z_OK)
        return Z_ERRNO;
    MemCpy(header, &localHeader.compressionMethod, sizeof(JZFileHeader));
    header->offset = 0; // not used in local context
    return Z_OK;
}

// Read data from file stream, described by header, to preallocated buffer
I64 jzReadData(JZFile *zip, JZFileHeader *header, U8 *buffer) {
    if(header->compressionMethod == 0) { // Store - just read it
        if(zip->read(zip, buffer, header->uncompressedSize) <
                header->uncompressedSize || zip->error(zip))
            return Z_ERRNO;
    } else if(header->compressionMethod == 8) { // Deflate - using puff()
        U32 destlen = header->uncompressedSize,
                      sourcelen = header->compressedSize;
        U8 *comp = MAlloc(sourcelen);
        if(comp == NULL) return Z_ERRNO; // couldn't allocate
        U64 read = zip->read(zip, comp, sourcelen);
        if(read != sourcelen) return Z_ERRNO; // TODO: more robust read loop
        upng_t *dummy = CAlloc(sizeof(upng_t));
        I64 ret = uz_inflate_data(dummy, buffer, &destlen, comp, &sourcelen, NULL);
        Free(dummy);
        Free(comp);
        if (ret) return Z_ERRNO; // something went wrong
    } else {
        return Z_ERRNO;
    }
    return Z_OK;
}

class StdioJZFile
{
    JZFile handle;
    U8 *buf;
    I64 size;
    I64 pos;
};

U64
stdio_read_file_handle_read(JZFile *file, U8 *buf, I64 size)
{
    StdioJZFile *handle = file;
    MemCpy(buf, handle->buf+handle->pos, size);
    handle->pos+=size;
    return size;
}

I64
stdio_read_file_handle_tell(JZFile *file)
{
    StdioJZFile *handle = file;
    return handle->pos;
}

I64
stdio_read_file_handle_seek(JZFile *file, I64 offset, I64 whence)
{
    StdioJZFile *handle = file;
    switch (whence)
    {
        case SEEK_SET:
            handle->pos = offset;
            break;
        case SEEK_CUR:
            handle->pos += offset;
            break;
        case SEEK_END:
            handle->pos = handle->size + offset;
            break;
        default:
            break;
    }
}

I64
stdio_read_file_handle_error(JZFile *file)
{
    StdioJZFile *handle = file;
    return 0;
}

JZFile *
jzfile_from_file(U8 *file)
{
    if (!FileFind(file))
    {
        return NULL;
    }
    StdioJZFile *handle = CAlloc(sizeof(StdioJZFile));
    handle->handle.read = &stdio_read_file_handle_read;
    handle->handle.tell = &stdio_read_file_handle_tell;
    handle->handle.seek = &stdio_read_file_handle_seek;
    handle->handle.error = &stdio_read_file_handle_error;
    handle->handle.addr = handle;
    handle->buf = FileRead(file, &handle->size);
    return &(handle->handle);
}

I64 JZProcessFile(EConsole *con, JZFile *zip)
{
    JZFileHeader header;
    U8 filename[1024];
    U8 *data;
    if(jzReadLocalFileHeader(zip, &header, filename, sizeof(filename))) {
        ConPrint(con, "Couldn't read local file header!\n");
        return -1;
    }
    if((data = MAlloc(header.uncompressedSize)) == NULL) {
        ConPrint(con, "Couldn't allocate memory!\n");
        return -1;
    }
    ConPrint(con, "  inflating: %s\n", &filename);
    //ConPrint(con, "%s, %d / %d bytes at offset %08X\n", filename,
            //header.compressedSize, header.uncompressedSize, header.offset);
    if(jzReadData(zip, &header, data) != Z_OK) {
        ConPrint(con, "Couldn't read file data!\n");
        Free(data);
        return -1;
    }
    FileWrite(filename, data, header.uncompressedSize);
    Free(data);
    return 0;
}

I64 JZRecordCallback(EConsole *con, JZFile *zip, I64 idx, JZFileHeader *header, U8 *filename, U8 *user_data)
{
    I64 offset;
    offset = zip->tell(zip); // store current position
    zip->seek(zip, header->offset, SEEK_SET);
    JZProcessFile(con, zip); // alters file offset
    zip->seek(zip, offset, SEEK_SET); // return to position
    return 1; // continue
}