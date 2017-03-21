//
//  _MCrashReporter.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/4.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "_MCrashReporter.h"
#import "_MApiSignalInfo.h"
#import "_MApiLogger.h"

static NSUncaughtExceptionHandler *g_previousUncaughtExceptionHandler;
static struct sigaction* g_previousSignalHandlers = NULL;

static NSString * const kReportDirectory = @"crash";

#define kMaxStackTracePrintLines 40

@interface _MCrashReporter ()
- (void)handleCrashString:(NSString *)str;
- (void)uninstallHandler;
@end

void mapi_crashreport_handleException(NSException* exception)
{
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"%@\r\n", exception.name];
    [str appendFormat:@"%@\r\n", exception.reason];
    [str appendFormat:@"%@\r\n", exception.callStackSymbols];
    
    _MCrashReporter *cp = [_MCrashReporter sharedInstance];
    [cp performSelectorOnMainThread:@selector(handleCrashString:) withObject:str waitUntilDone:YES];
    
    if (g_previousUncaughtExceptionHandler != NULL) {
        g_previousUncaughtExceptionHandler(exception);
    }
    
    [cp uninstallHandler];
}

void mapi_crashreport_handleSignal(int sig,
                                    siginfo_t* signalInfo,
                                    void* userContext)
{
    /// TODO: call stack trace....
    int sigNum = (int)signalInfo->si_signo;
    int sigCode = (int)signalInfo->si_code;
    const char* sigName = mapisig_signalName(sigNum);
    const char* sigCodeName = mapisig_signalCodeName(sigNum, sigCode);
    
    NSMutableString *str = [NSMutableString string];
#if defined(__LP64__)
    [str appendFormat:@"App crashed due to signal: [%s, %s] at %016lx\n",
#else
    [str appendFormat:@"App crashed due to signal: [%s, %s] at %08lx\n",
#endif
     sigName, sigCodeName, (uintptr_t)signalInfo->si_addr];
    


    uintptr_t concreteBacktrace[kMaxStackTracePrintLines];
    int backtraceLength = sizeof(concreteBacktrace) / sizeof(*concreteBacktrace);
    MAPI_SIG_STRUCT_MCONTEXT_L* machineContext=((SignalUserContext*)userContext)->MAPI_SIG_UC_MCONTEXT;

    int skippedEntries = 0;
    
    uintptr_t* backtrace = mapicrw_i_getBacktrace(machineContext,
                                                  concreteBacktrace,
                                                  &backtraceLength,
                                                  &skippedEntries);
    
    if(backtrace != NULL)
    {
        char log[sizeof(char)*2048*backtraceLength];
        mapicrw_i_logBacktrace(backtrace, backtraceLength, skippedEntries, log);
        [str appendFormat:@"%s", log];
    }
    _MCrashReporter *cp = [_MCrashReporter sharedInstance];
    [cp performSelectorOnMainThread:@selector(handleCrashString:) withObject:str waitUntilDone:YES];
    [cp uninstallHandler];
    raise(sigNum);
}



@implementation _MCrashReporter

#pragma mark init

- (id)init {
    if ((self = [super init])) {
        [self install_signal_handler];
        [self install_NSException_handler];        
    }
    return self;
}

#pragma mark public

+ (instancetype)sharedInstance {
    static _MCrashReporter *cp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cp = [[_MCrashReporter alloc] init];
    });
    return cp;
}

- (void)sendCrashReport {
    [_MApiLogger sendReportInDirectory:kReportDirectory];
}

- (void)handleTryCatchException:(NSException *)exp {
    NSUncaughtExceptionHandler *tmp_previousUncaughtExceptionHandler = g_previousUncaughtExceptionHandler;
    g_previousUncaughtExceptionHandler = NULL;
    mapi_crashreport_handleException(exp);
    g_previousUncaughtExceptionHandler = tmp_previousUncaughtExceptionHandler;
}

#pragma mark private
- (void)handleCrashString:(NSString *)str {
    [_MApiLogger writeContent:str inDirectory:kReportDirectory];
}


#pragma mark installer
- (void)uninstallHandler {
    [self uninstall_NSException_handler];
    [self uninstall_signal_handler];
}

- (bool)install_NSException_handler {
    g_previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&mapi_crashreport_handleException);
    return true;
}

- (void)uninstall_NSException_handler {
    if (g_previousUncaughtExceptionHandler) {
        NSSetUncaughtExceptionHandler(g_previousUncaughtExceptionHandler);
    }
}

- (void)uninstall_signal_handler {
    
    const int* fatalSignals = mapisig_fatalSignals();
    int fatalSignalsCount = mapisig_numFatalSignals();
    
    for(int i = 0; i < fatalSignalsCount; i++)
    {
        sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
    }
    
}
- (bool)install_signal_handler {

    const int* fatalSignals = mapisig_fatalSignals();
    int fatalSignalsCount = mapisig_numFatalSignals();
    
    if(g_previousSignalHandlers == NULL)
    {
        g_previousSignalHandlers = malloc(sizeof(*g_previousSignalHandlers)
                                          * (unsigned)fatalSignalsCount);
    }
    
    struct sigaction action = {{0}};
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
#ifdef __LP64__
    action.sa_flags |= SA_64REGSET;
#endif
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = &mapi_crashreport_handleSignal;
    
    for(int i = 0; i < fatalSignalsCount; i++)
    {
        if(sigaction(fatalSignals[i], &action, &g_previousSignalHandlers[i]) != 0)
        {
            char sigNameBuff[30];
            const char* sigName = mapisig_signalName(fatalSignals[i]);
            if(sigName == NULL)
            {
                snprintf(sigNameBuff, sizeof(sigNameBuff), "%d", fatalSignals[i]);
                sigName = sigNameBuff;
            }
            // Try to reverse the damage
            for(i--;i >= 0; i--)
            {
                sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
            }
            goto failed;
        }
    }
    return true;
    
failed:
    return false;

}

@end
