#include <stdio.h>
#include <string.h>
#include <stdbool.h> 

#include "string_utils.h"

char* left_trim(char *str)
{
	if(str==NULL)
        return;
	while(*str == ' ' || *str == '\t' || *str == '\r' || *str == '\n')
		str++;
	return str;
}


bool startsWith(const char *base, const char *str)
{
    size_t blen = strlen(base);
	size_t slen = strlen(str);
    return (blen < slen) ? false : (strncmp(str, base, slen) == 0);
}

bool endsWith(const char *base, const char *str) 
{
    size_t blen = strlen(base);
    size_t slen = strlen(str);
    return (blen >= slen) && (0 == strcmp(base + blen - slen, str));
}

/** 
getting the first index of str in base
 */
int indexOf(char* base, char* str) {
    return indexOf_offset(base, str, 0);
}

int indexOf_offset(char* base, char* str, int offset) {
    int result;
    int baselen = strlen(base);
    // str should not longer than base
    if (strlen(str) > baselen || offset > baselen) {
        result = -1;
    } else {
        if (offset < 0 ) {
            offset = 0;
        }
        char* pos = strstr(base+offset, str);
        if (pos == NULL) {
            result = -1;
        } else {
            result = pos - base;
        }
    }
    return result;
}

/** use two index to search in two part to prevent the worst case
 * (assume search 'aaa' in 'aaaaaaaa', you cannot skip three char each time)
 */ 
int lastIndexOf (char* base, char* str) {
    int result;
    // str should not longer than base
    if (strlen(str) > strlen(base)) {
        result = -1;
    } else {
        int start = 0;
        int endinit = strlen(base) - strlen(str);
        int end = endinit;
        int endtmp = endinit;
        while(start != end) {
            start = indexOf_offset(base, str, start);
            end = indexOf_offset(base, str, end);

            // not found from start
            if (start == -1) {
                end = -1; // then break;
            } else if (end == -1) {
                // found from start
                // but not found from end
                // move end to middle
                if (endtmp == (start+1)) {
                    end = start; // then break;
                } else {
                    end = endtmp - (endtmp - start) / 2;
                    if (end <= start) {
                        end = start+1;
                    }
                    endtmp = end;
                }
            } else {
                // found from both start and end
                // move start to end and
                // move end to base - strlen(str)
                start = end;
                end = endinit;
            }
        }
        result = start;
    }
    return result;
}