#include <string.h>
#include <math.h>
#include <stdio.h>
#include <iostream>
#include <queue>
#include <map>
#include <cstdlib>

#include <pthread.h>
//#include <android/log.h>
//#define LOGI(...)  __android_log_print(ANDROID_LOG_INFO,"JNI LOG",__VA_ARGS__)

using namespace std;

//#define RUN_BASE_POW_GENERATOR 1

#define MAX_LEN 100
#define BASE_POW_MAX_LEN  (30)

#define NUMBER_LEN 128

#ifdef RUN_BASE_POW_GENERATOR
void basePowGenerator();
#endif

//extern "C" {
	int max(int a, int b) {
		return a > b ? a : b;
	}

	//char* insert_realloc (char *str, char c, int pos){
	//	int i;
	//	int len = strlen(str);
	//
	//	str = realloc(str, len + 2);
	//	for (i = len + 1 ; i > pos ; --i)
	//	str[i] = str[i - 1];
	//	str[i] = c;
	//	return str;
	//}

	void split(char **arr, char *str, const char *del){
		char *s = strtok(str, del);
		while(s != NULL){
			*arr++ = s;
			s = strtok(NULL, del);
		}
	}

	char * replace(char const * const original, char const * const pattern, char const * const replacement) {
	  size_t const replen = strlen(replacement);
	  size_t const patlen = strlen(pattern);
	  size_t const orilen = strlen(original);

	  size_t patcnt = 0;
	  const char * oriptr;
	  const char * patloc;

	  // find how many times the pattern occurs in the original string
	  for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen)
	  {
		patcnt++;
	  }

	  {
		// allocate memory for the new string
		size_t const retlen = orilen + patcnt * (replen - patlen);
		char * const returned = (char *) malloc( sizeof(char) * (retlen + 1) );

		if (returned != NULL)
		{
		  // copy the original string,
		  // replacing all the instances of the pattern
		  char * retptr = returned;
		  for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen)
		  {
			size_t const skplen = patloc - oriptr;
			// copy the section until the occurence of the pattern
			strncpy(retptr, oriptr, skplen);
			retptr += skplen;
			// copy the replacement
			strncpy(retptr, replacement, replen);
			retptr += replen;
		  }
		  // copy the rest of the string.
		  strcpy(retptr, oriptr);
		}
		return returned;
	  }
	}


	// 0 ~ BASE_POW_MAX_LEN
	const char *BasePowList [BASE_POW_MAX_LEN+1] = {
			"1",
			"87",
			"7569",
			"658503",
			"57289761",
			"4984209207",
			"433626201009",
			"37725479487783",
			"3282116715437121",
			"285544154243029527",
			"24842341419143568849",
			"2161283703465490489863",
			"188031682201497672618081",
			"16358756351530297517773047",
			"1423211802583135884046255089",
			"123819426824732821912024192743",
			"10772290133751755506346104768641",
			"937189241636402729052111114871767",
			"81535464022367037427533666993843729",
			"7093585369945932256195429028464404423",
			"617141927185296106289002325476403184801",
			"53691347665120761247143202316447077077687",
			"4671147246865506228501458601530895705758769",
			"406389810477299041879626898333187926401012903",
			"35355913511525016643527540154987349596888122561",
			"3075964475502676447986895993483899414929266662807",
			"267608909368732850974859951433099249098846199664209",
			"23281975115079758034812815774679634671599619370786183",
			"2025531835011938949028714972397128216429166885258397921",
			"176221269646038688565498202598550154829337519017480619127",
			"15331250459205365905198343626073863470152364154520813864049",
	};

	//ascii 32~126
	static const char BaseChar [] = {
		//' ',
		'!',
		//'"',
		'#', '$', '%', '&', 0x27, '(', ')', '*', '+',   //12

		//',',

		'-', '.', '/',  // 3

		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',  // 10

		':', ';', '<', '=', '>', '?', '@',  //7

		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',  // 26

		//'[',

		'\\',

		//']',

		'^', '_', 0x60,

		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',  // 26

		//'{', '|',	'}',

		'~',
	};

	static const char BaseIndex [] = {
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,1,2,3,4,5,6,7,8,9,0,10,11,12,
		13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,
		29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,
		45,46,47,48,49,50,51,52,53,54,55,0,56,0,57,58,
		59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,
		75,76,77,78,79,80,81,82,83,84,85,0,0,0,86,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	};

	static int BASE = sizeof(BaseChar);
	static int mCacheSize = 5000;


	class Cache {
		private:
			queue<string> keyQueue;
			map<string, string> keyValueMap;
			map<string, string>::iterator it;

			pthread_mutex_t m_mutex;
			pthread_cond_t  m_condv;
		public:
			Cache(){
				pthread_mutex_init(&m_mutex, NULL);
				pthread_cond_init(&m_condv, NULL);
			}
			~Cache(){
				pthread_mutex_destroy(&m_mutex);
				pthread_cond_destroy(&m_condv);
			}
			
			char *get(char *key){
				
				pthread_mutex_lock(&m_mutex);

				string keyStr(key);
				char * ret;
				it = keyValueMap.find(keyStr);
				if(it == keyValueMap.end()){ //not found
					ret = NULL;
				}else{
					ret = (char *)it->second.c_str();
				}

				pthread_cond_signal(&m_condv);
				pthread_mutex_unlock(&m_mutex);
				return ret;
			}

			void put(char *key, char *value){
				
				pthread_mutex_lock(&m_mutex);

				string keyStr(key);
				string valueStr(value);

				if(!keyQueue.empty() && keyQueue.size() >= mCacheSize){
					keyValueMap.erase(keyQueue.front());
					keyQueue.pop();	
				}
				
				keyQueue.push(keyStr);
				keyValueMap[keyStr] = valueStr;

				pthread_cond_signal(&m_condv);
				pthread_mutex_unlock(&m_mutex);

				//LOGI("keyQueue=  %d\n", keyQueue.size());
				//for (it=keyValueMap.begin(); it!=keyValueMap.end(); ++it){
				//	LOGI("==> put map=  %s, %s\n", it->first.c_str(), it->second.c_str());
				//}
				
			}
	};

	static Cache mEncodeCache, mDecodeCache;

	void Reverse(char* a){
		int len1=strlen(a)-1;
		int len2=(len1+1)/2;
		char temp;
		int i;
		for (i=0;i<len2;i++){
			temp=a[i];
			a[i]=a[len1-i];
			a[len1-i]=temp;
		}
		return;
	}

	static char* Add(char* a,char* b){
		int maxlen = max(strlen(a),strlen(b));
		char* p = (char*) malloc(maxlen+2);
		char* pA=a+strlen(a)-1;
		char* pB=b+strlen(b)-1;
		int m=0;
		int n=0;
		int c=0;
		int i=0;

		memset(p, 0,maxlen+2);
		for (i=0;i<maxlen;i++){
			m = n = 0;
			if ((pA+1) != a){
				m = *pA - 48;
				pA--;
			}

			if ((pB+1) != b){
				n = *pB - 48;
				pB--;
			}

			*(p+i) = (m+n+c) % 10 + 48;
			c = (m+n+c) / 10;
		}
		if (c>0){
			*(p+i) = 48 + c;
			*(p+i+1) = '\0';
		}
		else{
			*(p+i) = '\0';
		}
		Reverse(p);
		return p;
	}
	
	static char* Mult(char* a,char* b){
		int lenA =strlen(a);
		int lenB =strlen(b);

		char* p = (char*) malloc(lenA+lenB+1);
		memset(p, 0, lenA+lenB+1);
		
		char* pA=a+lenA-1;
		char* pB=b+lenB-1;
		int m=0;
		int n=0;
		int c=0;

		int s=0;
		int i=0;
		int j=0;
		for (i=0;i<lenA;i++){
				m = *(pA-i) - 48;
			c=0;
			for (j=0;j<lenB;j++)	{
				n = *(pB-j) - 48;
				if((*(p+i+j)>='0')&&(*(p+i+j)<='9')){
					s = *(p+i+j) - 48;
				}
				else{
					s = 0;
				}
				*(p+i+j) = (m*n+c+s) % 10 + 48;
				c = (m*n+c+s) / 10;
			}
			*(p+i+j) = 48 + c;
		}
		if (c>0){
			*(p+i+j) = '\0';
		}
		else{
			*(p+i+j-1) = '\0';
		}
		Reverse(p);
	return p;
	}
		
	static void addDecValue (int * pArray, int n, int carry){
		int tmp = 0;
		int i;

		for (i = (n-1); (i >= 0); i--){
			tmp = (pArray[i] * 10) + carry;
			pArray[i] = tmp % BASE;
			carry = tmp / BASE;
		}
	}

	static int *initBaseArray(char *decStr, int lenDecStr){
		int * pArray = NULL;
		int i;

		pArray = (int *) calloc (lenDecStr,  sizeof (int));

		for (i = 0; i < lenDecStr; i++){
			addDecValue (pArray, lenDecStr, decStr[i] - '0');
		}
		return (pArray);
	}

	#if 0
	static char *getBaseIndexCharFormBaseChar(char s){
		char i;
		char *ret;
		for(i=0; i < BASE; ++i){
			if(s == BaseChar[i]){
				asprintf(&ret,"%d", i);
				return ret;
			}
		}

		asprintf(&ret,"0");
		return ret;
	}
	#else 
	static char *getBaseIndexCharFormBaseChar(char s){
		char *ret;
		asprintf(&ret,"%d", BaseIndex[s]);
		return ret;
	}
	#endif

	#if 0
	char *getBaseEncode(char *str){

		int decStrLen = strlen (str);
		if(decStrLen == 0){return NULL;}

		int i,j,start=0;
		int * pArray = NULL;
		//char *baseArray;
		static char baseArray[NUMBER_LEN];

		pArray = initBaseArray (str, decStrLen);
		while ((pArray[start] == 0) && (start < (decStrLen-1))){
			start++;
		}

		int len = decStrLen-start;
		//baseArray = (char *)malloc(len + 1);
		//baseArray[len] = 0;
		memset(baseArray, 0, NUMBER_LEN);
		

		for (i = start,j=0; i < decStrLen; ++i,++j){
			baseArray[j] = BaseChar[pArray[i]];
		}

		if (pArray != NULL){
			free (pArray);
		}

		return baseArray;
	}
	#else
		char *getBaseEncode(char *str){

		int decStrLen = strlen (str);
		if(decStrLen == 0){return NULL;}

		int i,j,start=0;
		int * pArray = NULL;
		char *baseArray;
		//char baseArray[NUMBER_LEN];

		pArray = initBaseArray (str, decStrLen);
		while ((pArray[start] == 0) && (start < (decStrLen-1))){
			start++;
		}

		int len = decStrLen-start;
		baseArray = (char *)malloc(len + 1);
		baseArray[len] = 0;
		//memset(baseArray, 0, NUMBER_LEN);
		

		for (i = start,j=0; i < decStrLen; ++i,++j){
			baseArray[j] = BaseChar[pArray[i]];
		}

		if (pArray != NULL){
			free (pArray);
		}

		return baseArray;
	}

	#endif
	char *getBaseDecode(char *str){
		int baseStrLen = strlen (str);

		if(baseStrLen < 1 || baseStrLen > BASE_POW_MAX_LEN){return NULL;}

		int i,j;
		//char baseArray[NUMBER_LEN];
		char *baseArray = (char *)malloc(NUMBER_LEN);
		memset(baseArray, 0, NUMBER_LEN);
		//char *baseArray = (char *)"";

		char *dat;
		char *pow;
		char *m;
		char *add;
		for(i = 0 ; i < baseStrLen; ++i){
			dat = getBaseIndexCharFormBaseChar(str[i]);
			if(dat == "0"){continue;}

			pow = (char*)BasePowList[baseStrLen -1 -i];
			m = Mult(dat, pow);

			add = Add(baseArray, m);			

			memcpy(baseArray, add, strlen(add));			
			if(dat != NULL){free(dat);}
			if(m != NULL){free(m);}
			if(add != NULL){free(add);}
		}
		
		return baseArray;
	}


	void setCacheSize(int cacheSize){
		mCacheSize = cacheSize;
		
	}
	
	char *getBaseEncodeByCache(char *str, bool *isRealseRet){
		char *cache = mEncodeCache.get(str);
		if(cache == NULL){
			char *value = getBaseEncode(str); 
			if(value!=NULL){
				*isRealseRet = 1;
				mEncodeCache.put(str, value);
			}
			return value;
		}

		return cache;
	}

	char *getBaseDecodeByCache(char *str ,bool *isRealseRet){
		char *cache = mDecodeCache.get(str);
		if(cache == NULL){
			char *value = getBaseDecode(str);
			if(value!=NULL){
				*isRealseRet = 1;
				mDecodeCache.put(str, value);
			}
			return value;
		}

		return cache;
	}

	#ifdef RUN_BASE_POW_GENERATOR
	void basePowGenerator(){
		char* strBASE;
		asprintf(&strBASE,"%d", BASE);

		char *multResult = strBASE;
		int i;
		for(i = 0; i <= BASE_POW_MAX_LEN; ++i){
			if(i==0){
				multResult = "1";
			}else if(i==1){
				multResult = strBASE;
			}else{
				multResult = Mult(multResult, strBASE);
			}
			LOGI("\"%s\",\n", multResult);
		}
	}
	#endif

	#if 0
		if(t==0){
			t=1;
			int i;

			printf("static const char BaseIndex [] = {");

			char b[256];	
			memset(b, 0, 256);
			
			for(i=0;i<sizeof(BaseChar);++i){
				b[BaseChar [i]]=i;
			}
			
			for(i=0;i<256;++i){
				//printf("%c",BaseChar [i]);
				if(i%16==0){
					printf("\n	");
				}
				printf("%d,", b[i]);


			}
			
			printf("\n};\n");
			
		}
#endif
//}
