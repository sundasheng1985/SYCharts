//
//  _MApiSignalInfo.c
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/4.
//  Copyright © 2016年 Mitake. All rights reserved.
//


#include "_MApiSignalInfo.h"

#include <signal.h>
#include <sys/_structs.h>
#include <limits.h>
#include <stdio.h>

typedef struct
{
    const int code;
    const char* const name;
} MApiSignalCodeInfo;

typedef struct
{
    const int sigNum;
    const char* const name;
    const MApiSignalCodeInfo* const codes;
    const int numCodes;
} MApiSignalInfo;

#define ENUM_NAME_MAPPING(A) {A, #A}

static const MApiSignalCodeInfo g_sigIllCodes[] =
{
    ENUM_NAME_MAPPING(ILL_NOOP),
    ENUM_NAME_MAPPING(EXC_CRASH),
    ENUM_NAME_MAPPING(ILL_ILLTRP),
    ENUM_NAME_MAPPING(ILL_PRVOPC),
    ENUM_NAME_MAPPING(ILL_ILLOPN),
    ENUM_NAME_MAPPING(ILL_ILLADR),
    ENUM_NAME_MAPPING(ILL_PRVREG),
    ENUM_NAME_MAPPING(ILL_COPROC),
    ENUM_NAME_MAPPING(ILL_BADSTK),
};

static const MApiSignalCodeInfo g_sigTrapCodes[] =
{
    ENUM_NAME_MAPPING(0),
    ENUM_NAME_MAPPING(TRAP_BRKPT),
    ENUM_NAME_MAPPING(TRAP_TRACE),
};

static const MApiSignalCodeInfo g_sigFPECodes[] =
{
    ENUM_NAME_MAPPING(FPE_NOOP),
    ENUM_NAME_MAPPING(FPE_FLTDIV),
    ENUM_NAME_MAPPING(FPE_FLTOVF),
    ENUM_NAME_MAPPING(FPE_FLTUND),
    ENUM_NAME_MAPPING(FPE_FLTRES),
    ENUM_NAME_MAPPING(FPE_FLTINV),
    ENUM_NAME_MAPPING(FPE_FLTSUB),
    ENUM_NAME_MAPPING(FPE_INTDIV),
    ENUM_NAME_MAPPING(FPE_INTOVF),
};

static const MApiSignalCodeInfo g_sigBusCodes[] =
{
    ENUM_NAME_MAPPING(BUS_NOOP),
    ENUM_NAME_MAPPING(BUS_ADRALN),
    ENUM_NAME_MAPPING(BUS_ADRERR),
    ENUM_NAME_MAPPING(BUS_OBJERR),
};

static const MApiSignalCodeInfo g_sigSegVCodes[] =
{
    ENUM_NAME_MAPPING(SEGV_NOOP),
    ENUM_NAME_MAPPING(SEGV_MAPERR),
    ENUM_NAME_MAPPING(SEGV_ACCERR),
};

#define SIGNAL_INFO(SIGNAL, CODES) {SIGNAL, #SIGNAL, CODES, sizeof(CODES) / sizeof(*CODES)}
#define SIGNAL_INFO_NOCODES(SIGNAL) {SIGNAL, #SIGNAL, 0, 0}

static const MApiSignalInfo g_fatalSignalData[] =
{
    SIGNAL_INFO_NOCODES(SIGABRT),
    SIGNAL_INFO(SIGBUS, g_sigBusCodes),
    SIGNAL_INFO(SIGFPE, g_sigFPECodes),
    SIGNAL_INFO(SIGILL, g_sigIllCodes),
    SIGNAL_INFO_NOCODES(SIGPIPE),
    SIGNAL_INFO(SIGSEGV, g_sigSegVCodes),
    SIGNAL_INFO_NOCODES(SIGSYS),
    SIGNAL_INFO(SIGTERM, g_sigTrapCodes),
};
static const int g_fatalSignalsCount = sizeof(g_fatalSignalData) / sizeof(*g_fatalSignalData);

// Note: Dereferencing a NULL pointer causes SIGILL, ILL_ILLOPC on i386
//       but causes SIGTRAP, 0 on arm.
static const int g_fatalSignals[] =
{
    SIGABRT,
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGPIPE,
    SIGSEGV,
    SIGSYS,
    SIGTRAP,
};

const char* mapisig_signalName(const int sigNum)
{
    for(int i = 0; i < g_fatalSignalsCount; i++)
    {
        if(g_fatalSignalData[i].sigNum == sigNum)
        {
            return g_fatalSignalData[i].name;
        }
    }
    return NULL;
}

const char* mapisig_signalCodeName(const int sigNum, const int code)
{
    for(int si = 0; si < g_fatalSignalsCount; si++)
    {
        if(g_fatalSignalData[si].sigNum == sigNum)
        {
            for(int ci = 0; ci < g_fatalSignalData[si].numCodes; ci++)
            {
                if(g_fatalSignalData[si].codes[ci].code == code)
                {
                    return g_fatalSignalData[si].codes[ci].name;
                }
            }
        }
    }
    return NULL;
}

const int* mapisig_fatalSignals(void)
{
    return g_fatalSignals;
}

int mapisig_numFatalSignals(void)
{
    return g_fatalSignalsCount;
}

#define EXC_UNIX_BAD_SYSCALL 0x10000 /* SIGSYS */
#define EXC_UNIX_BAD_PIPE    0x10001 /* SIGPIPE */
#define EXC_UNIX_ABORT       0x10002 /* SIGABRT */

int mapisig_machExceptionForSignal(const int sigNum)
{
    switch(sigNum)
    {
        case SIGFPE:
            return EXC_ARITHMETIC;
        case SIGSEGV:
            return EXC_BAD_ACCESS;
        case SIGBUS:
            return EXC_BAD_ACCESS;
        case SIGILL:
            return EXC_BAD_INSTRUCTION;
        case SIGTRAP:
            return EXC_BREAKPOINT;
        case SIGEMT:
            return EXC_EMULATION;
        case SIGSYS:
            return EXC_UNIX_BAD_SYSCALL;
        case SIGPIPE:
            return EXC_UNIX_BAD_PIPE;
        case SIGABRT:
            // The Apple reporter uses EXC_CRASH instead of EXC_UNIX_ABORT
            return EXC_CRASH;
        case SIGKILL:
            return EXC_SOFT_SIGNAL;
    }
    return 0;
}

int mapisig_signalForMachException(const int exception,
                                    const mach_exception_code_t code)
{
    switch(exception)
    {
        case EXC_ARITHMETIC:
            return SIGFPE;
        case EXC_BAD_ACCESS:
            return code == KERN_INVALID_ADDRESS ? SIGSEGV : SIGBUS;
        case EXC_BAD_INSTRUCTION:
            return SIGILL;
        case EXC_BREAKPOINT:
            return SIGTRAP;
        case EXC_EMULATION:
            return SIGEMT;
        case EXC_SOFTWARE:
        {
            switch (code)
            {
                case EXC_UNIX_BAD_SYSCALL:
                    return SIGSYS;
                case EXC_UNIX_BAD_PIPE:
                    return SIGPIPE;
                case EXC_UNIX_ABORT:
                    return SIGABRT;
                case EXC_SOFT_SIGNAL:
                    return SIGKILL;
            }
            break;
        }
    }
    return 0;
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#define unlikely_if(x) if(__builtin_expect(x,0))
#define KSLOGGER_CBufferSize 1024

#define kStackOverflowThreshold 200
#define kBacktraceGiveUpPoint 10000000

typedef struct _MCrashFrameEntry
{
    const struct _MCrashFrameEntry* const previous;
    const uintptr_t return_address;
} _MCrashFrameEntry;


#if defined (__arm__)
uintptr_t mapimach_instructionAddress(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__pc;
}
uintptr_t mapimach_framePointer(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__r[7];
}

uintptr_t mapimach_linkRegister(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__lr;
}
#endif

#if defined (__arm64__)

uintptr_t mapimach_instructionAddress(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__pc;
}
uintptr_t mapimach_framePointer(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__fp;
}

uintptr_t mapimach_linkRegister(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__lr;
}
#endif

#if defined (__i386__)

uintptr_t mapimach_instructionAddress(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__eip;
}
uintptr_t mapimach_framePointer(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__ebp;
}
uintptr_t mapimach_linkRegister(__unused const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return 0;
}
#endif

#if defined (__x86_64__)

uintptr_t mapimach_instructionAddress(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__rip;
}

uintptr_t mapimach_framePointer(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__rbp;
}

uintptr_t mapimach_linkRegister(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext __attribute__ ((unused)))
{
    return 0;
}

#endif

kern_return_t mapimach_copyMem(const void* const src,
                               void* const dst,
                               const size_t numBytes)
{
    vm_size_t bytesCopied = 0;
    return vm_read_overwrite(mach_task_self(),
                             (vm_address_t)src,
                             (vm_size_t)numBytes,
                             (vm_address_t)dst,
                             &bytesCopied);
}

int mapibt_backtraceLength(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext)
{
    const uintptr_t instructionAddress = mapimach_instructionAddress(machineContext);
    
    if(instructionAddress == 0)
    {
        return 0;
    }
    
    _MCrashFrameEntry frame = {0};
    const uintptr_t framePtr = mapimach_framePointer(machineContext);
    if(framePtr == 0 ||
       mapimach_copyMem((void*)framePtr, &frame, sizeof(frame)) != KERN_SUCCESS)
    {
        return 1;
    }
    for(int i = 1; i < kBacktraceGiveUpPoint; i++)
    {
        if(frame.previous == 0 ||
           mapimach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS)
        {
            return i;
        }
    }
    
    return kBacktraceGiveUpPoint;
}


int mapibt_backtraceThreadState(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext,
                              uintptr_t*const backtraceBuffer,
                              const int skipEntries,
                              const int maxEntries)
{
    if(maxEntries == 0)
    {
        return 0;
    }
    
    int i = 0;
    
    if(skipEntries == 0)
    {
        const uintptr_t instructionAddress = mapimach_instructionAddress(machineContext);
        backtraceBuffer[i] = instructionAddress;
        i++;
        
        if(i == maxEntries)
        {
            return i;
        }
    }
    
    if(skipEntries <= 1)
    {
        uintptr_t linkRegister = mapimach_linkRegister(machineContext);
        
        if(linkRegister)
        {
            backtraceBuffer[i] = linkRegister;
            i++;
            
            if (i == maxEntries)
            {
                return i;
            }
        }
    }
    
    _MCrashFrameEntry frame = {0};
    
    const uintptr_t framePtr = mapimach_framePointer(machineContext);
    if(framePtr == 0 ||
       mapimach_copyMem((void*)framePtr, &frame, sizeof(frame)) != KERN_SUCCESS)
    {
        return 0;
    }
    for(int j = 1; j < skipEntries; j++)
    {
        if(frame.previous == 0 ||
           mapimach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS)
        {
            return 0;
        }
    }
    
    for(; i < maxEntries; i++)
    {
        backtraceBuffer[i] = frame.return_address;
        if(backtraceBuffer[i] == 0 ||
           frame.previous == 0 ||
           mapimach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS)
        {
            break;
        }
    }
    return i;
}


uintptr_t* mapicrw_i_getBacktrace(const MAPI_SIG_STRUCT_MCONTEXT_L* const machineContext,
                                uintptr_t* const backtraceBuffer,
                                int* const backtraceLength,
                                int* const skippedEntries)
{
    
    if(machineContext == NULL)
    {
        return NULL;
    }
    
    int actualSkippedEntries = 0;
    int actualLength = mapibt_backtraceLength(machineContext);
    if(actualLength >= kStackOverflowThreshold)
    {
        actualSkippedEntries = actualLength - *backtraceLength;
    }
    
    *backtraceLength = mapibt_backtraceThreadState(machineContext,
                                                 backtraceBuffer,
                                                 actualSkippedEntries,
                                                 *backtraceLength);
    if(skippedEntries != NULL)
    {
        *skippedEntries = actualSkippedEntries;
    }
    return backtraceBuffer;
}


uintptr_t mapidl_firstCmdAfterHeader(const struct mach_header* const header)
{
    switch(header->magic)
    {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            // Header is corrupt
            return 0;
    }
}

uint32_t mapidl_imageIndexContainingAddress(const uintptr_t address)
{
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* header = 0;
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++)
    {
        header = _dyld_get_image_header(iImg);
        if(header != NULL)
        {
            // Look for a segment command with this address within its range.
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPtr = mapidl_firstCmdAfterHeader(header);
            if(cmdPtr == 0)
            {
                continue;
            }
            for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++)
            {
                const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                if(loadCmd->cmd == LC_SEGMENT)
                {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize)
                    {
                        return iImg;
                    }
                }
                else if(loadCmd->cmd == LC_SEGMENT_64)
                {
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize)
                    {
                        return iImg;
                    }
                }
                cmdPtr += loadCmd->cmdsize;
            }
        }
    }
    return UINT_MAX;
}

uintptr_t mapidl_segmentBaseOfImageIndex(const uint32_t idx)
{
    const struct mach_header* header = _dyld_get_image_header(idx);
    
    // Look for a segment command and return the file image address.
    uintptr_t cmdPtr = mapidl_firstCmdAfterHeader(header);
    if(cmdPtr == 0)
    {
        return 0;
    }
    for(uint32_t i = 0;i < header->ncmds; i++)
    {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SEGMENT)
        {
            const struct segment_command* segmentCmd = (struct segment_command*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0)
            {
                return segmentCmd->vmaddr - segmentCmd->fileoff;
            }
        }
        else if(loadCmd->cmd == LC_SEGMENT_64)
        {
            const struct segment_command_64* segmentCmd = (struct segment_command_64*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0)
            {
                return (uintptr_t)(segmentCmd->vmaddr - segmentCmd->fileoff);
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    
    return 0;
}

bool mapidl_dladdr(const uintptr_t address, Dl_info* const info)
{
    info->dli_fname = NULL;
    info->dli_fbase = NULL;
    info->dli_sname = NULL;
    info->dli_saddr = NULL;
    
    const uint32_t idx = mapidl_imageIndexContainingAddress(address);
    if(idx == UINT_MAX)
    {
        return false;
    }
    const struct mach_header* header = _dyld_get_image_header(idx);
    const uintptr_t imageVMAddrSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
    const uintptr_t addressWithSlide = address - imageVMAddrSlide;
    const uintptr_t segmentBase = mapidl_segmentBaseOfImageIndex(idx) + imageVMAddrSlide;
    if(segmentBase == 0)
    {
        return false;
    }
    
    info->dli_fname = _dyld_get_image_name(idx);
    info->dli_fbase = (void*)header;
    
    // Find symbol tables and get whichever symbol is closest to the address.
    const MAPI_SIG_STRUCT_NLIST* bestMatch = NULL;
    uintptr_t bestDistance = ULONG_MAX;
    uintptr_t cmdPtr = mapidl_firstCmdAfterHeader(header);
    if(cmdPtr == 0)
    {
        return false;
    }
    for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++)
    {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SYMTAB)
        {
            const struct symtab_command* symtabCmd = (struct symtab_command*)cmdPtr;
            const MAPI_SIG_STRUCT_NLIST* symbolTable = (MAPI_SIG_STRUCT_NLIST*)(segmentBase + symtabCmd->symoff);
            const uintptr_t stringTable = segmentBase + symtabCmd->stroff;
            
            for(uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++)
            {
                // If n_value is 0, the symbol refers to an external object.
                if(symbolTable[iSym].n_value != 0)
                {
                    uintptr_t symbolBase = symbolTable[iSym].n_value;
                    uintptr_t currentDistance = addressWithSlide - symbolBase;
                    if((addressWithSlide >= symbolBase) &&
                       (currentDistance <= bestDistance))
                    {
                        bestMatch = symbolTable + iSym;
                        bestDistance = currentDistance;
                    }
                }
            }
            if(bestMatch != NULL)
            {
                info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddrSlide);
                info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
                if(*info->dli_sname == '_')
                {
                    info->dli_sname++;
                }
                // This happens if all symbols have been stripped.
                if(info->dli_saddr == info->dli_fbase && bestMatch->n_type == 3)
                {
                    info->dli_sname = NULL;
                }
                break;
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    
    return true;
}

#if defined(__arm__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(1UL))
#elif defined(__arm64__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(3UL))
#else
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#endif

#define CALL_INSTRUCTION_FROM_RETURN_ADDRESS(A) (DETAG_INSTRUCTION_ADDRESS((A)) - 1)

void mapibt_symbolicate(const uintptr_t* const backtraceBuffer,
                      Dl_info* const symbolsBuffer,
                      const int numEntries,
                      const int skippedEntries)
{
    int i = 0;
    
    if(!skippedEntries && i < numEntries)
    {
        mapidl_dladdr(backtraceBuffer[i], &symbolsBuffer[i]);
        i++;
    }
    
    for(; i < numEntries; i++)
    {
        mapidl_dladdr(CALL_INSTRUCTION_FROM_RETURN_ADDRESS(backtraceBuffer[i]), &symbolsBuffer[i]);
    }
}

const char* mapifu_lastPathEntry(const char* const path)
{
    if(path == NULL)
    {
        return NULL;
    }
    
    char* lastFile = strrchr(path, '/');
    return lastFile == NULL ? path : lastFile + 1;
}

#if defined(__LP64__)
#define TRACE_FMT         "%-4d%-31s 0x%016lx %s + %lu\n"
#define POINTER_FMT       "0x%016lx"
#define POINTER_SHORT_FMT "0x%lx"
#else
#define TRACE_FMT         "%-4d%-31s 0x%08lx %s + %lu\n"
#define POINTER_FMT       "0x%08lx"
#define POINTER_SHORT_FMT "0x%lx"
#endif

void mapicrw_i_logBacktraceEntry(const int entryNum,
                               const uintptr_t address,
                               const Dl_info* const dlInfo, char *log)
{
    char faddrBuff[20];
    char saddrBuff[20];
    
    const char* fname = mapifu_lastPathEntry(dlInfo->dli_fname);
    if(fname == NULL)
    {
        sprintf(faddrBuff, POINTER_FMT, (uintptr_t)dlInfo->dli_fbase);
        fname = faddrBuff;
    }
    
    uintptr_t offset = address - (uintptr_t)dlInfo->dli_saddr;
    const char* sname = dlInfo->dli_sname;
    if(sname == NULL)
    {
        sprintf(saddrBuff, POINTER_SHORT_FMT, (uintptr_t)dlInfo->dli_fbase);
        sname = saddrBuff;
        offset = address - (uintptr_t)dlInfo->dli_fbase;
    }
    
    sprintf(log + strlen(log), TRACE_FMT, entryNum, fname, address, sname, offset);
}

void mapicrw_i_logBacktrace(const uintptr_t* const backtrace,
                          const int backtraceLength,
                          const int skippedEntries, char *log)
{
    if(backtraceLength > 0)
    {
        sprintf(log, "\n");
        Dl_info symbolicated[backtraceLength];
        mapibt_symbolicate(backtrace, symbolicated, backtraceLength, skippedEntries);
        
        for(int i = 0; i < backtraceLength; i++)
        {
            mapicrw_i_logBacktraceEntry(i, backtrace[i], &symbolicated[i], log);
        }
    }
}
