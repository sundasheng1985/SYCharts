//
//  _MApiSignalInfo.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/4.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#ifndef MApi_CrashReport_SignalInfo_h
#define MApi_CrashReport_SignalInfo_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include <mach/mach.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
#include <sys/_structs.h>
#include <stdlib.h>
    
const char* mapisig_signalName(int signal);
const char* mapisig_signalCodeName(int signal, int code);
const int* mapisig_fatalSignals(void);
int mapisig_numFatalSignals(void);
int mapisig_signalForMachException(int exception, mach_exception_code_t code);
int mapisig_machExceptionForSignal(int signal);


#ifdef __arm64__
#include <sys/_types/_ucontext64.h>
#define MAPI_SIG_UC_MCONTEXT uc_mcontext64
    typedef ucontext64_t SignalUserContext;
#else
#define MAPI_SIG_UC_MCONTEXT uc_mcontext
    typedef ucontext_t SignalUserContext;
#endif

#ifdef __LP64__
#define MAPI_SIG_STRUCT_NLIST struct nlist_64
#else
#define MAPI_SIG_STRUCT_NLIST struct nlist
#endif
    
#ifdef __arm64__
#define MAPI_SIG_STRUCT_MCONTEXT_L _STRUCT_MCONTEXT64
#else
#define MAPI_SIG_STRUCT_MCONTEXT_L _STRUCT_MCONTEXT
#endif

    uintptr_t* mapicrw_i_getBacktrace(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext,
                                      uintptr_t* const backtraceBuffer,
                                      int* const backtraceLength,
                                      int* const skippedEntries);
    void mapicrw_i_logBacktrace(const uintptr_t* const backtrace,
                                const int backtraceLength,
                                const int skippedEntries, char *log);

    
#ifdef __cplusplus
}
#endif

#endif // MApi_CrashReport_SignalInfo_h
