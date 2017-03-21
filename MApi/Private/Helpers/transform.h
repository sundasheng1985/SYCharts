char *getBaseEncode(char *str);
char *getBaseDecode(char *str);

void setCacheSize(int cacheSize);
char *getBaseEncodeByCache(char *str, bool *isRealseRet);
char *getBaseDecodeByCache(char *str, bool *isRealseRet);
