I64 cond(Bool bool, I64 true_val, I64 false_val)
{ // Conditional operator pseudo-polyfill.
	if (bool)
	{
		return true_val;
	}
	else
	{
		return false_val;
	}
}

/**
 * hex2int
 * take a hex string and convert it to a 32bit number (max 8 hex digits)
 */
U32 hex2int(U8 *hex) {
    U32 val = 0;
    while (*hex) {
        // get current character then increment
        U8 byte = *hex++; 
        // transform hex character to the 4bit equivalent number, using the ascii table indexes
        if (byte >= '0' && byte <= '9') byte = byte - '0';
        else if (byte >= 'a' && byte <='f') byte = byte - 'a' + 10;
        else if (byte >= 'A' && byte <='F') byte = byte - 'A' + 10;
        else return U32_MAX;    
        // shift 4 to make space for new digit, and add the 4 bits of the new digit 
        val = (val << 4) | (byte & 0xF);
    }
    return val;
}

U0 StrAppend(U8 *dst, U8 *fmt,...)
{ // Append to pre-alloced string. COMPLETELY unsafe.
	U8 *buf;
	if (argc)
	{
		buf=StrPrintJoin(NULL, fmt, argc, argv);
	}
	else
	{
		buf=StrNew(fmt);
	}
	U8 *src=buf;
    StrPrint(dst+StrLen(dst), src);
    Free(buf);
}

U8 *StrReplace(U8 *s, U8 *oldW, 
                                 U8 *newW) 
{ 
	if (!StrFind(oldW, s))
	{
		return StrNew(s);
	}
    U8 *result; 
    I64 i, cnt = 0; 
    I64 newWlen = StrLen(newW); 
    I64 oldWlen = StrLen(oldW); 
  
    // Counting the number of times old word 
    // occur in the string 
    for (i = 0; s[i] != '\0'; i++) 
    { 
        if (StrFind(oldW, &s[i]) == &s[i]) 
        { 
            cnt++; 
  
            // Jumping to index after the old word. 
            i += oldWlen - 1; 
        } 
    } 
  
    // Making new string of enough length 
    result = MAlloc(i + cnt * (newWlen - oldWlen) + 1); 
  
    i = 0; 
    while (*s) 
    { 
        // compare the substring with the result 
        if (StrFind(oldW, s) == s) 
        { 
            StrCpy(&result[i], newW); 
            i += newWlen; 
            s += oldWlen; 
        } 
        else
            result[i++] = *s++; 
    } 
  
    result[i] = '\0'; 
    return result; 
} 


CDoc *trace_log = DocNew;
DocMax(trace_log);

U0 TraceLog()
{
	DocDump(trace_log);
}