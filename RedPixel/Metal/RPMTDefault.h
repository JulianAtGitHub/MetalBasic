#ifndef _RP_MT_DEFAULT_H_
#define _RP_MT_DEFAULT_H_

@protocol MTLDevice;
id<MTLDevice> DefaultMTLDevice(void);

@protocol MTLLibrary;
id<MTLLibrary> DefaultMTLLibrary(void);

#endif /* _RP_MT_DEFAULT_H_ */