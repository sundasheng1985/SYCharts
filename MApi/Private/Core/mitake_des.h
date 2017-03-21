#ifndef _MITAKE_DES_H
#define _MITAKE_DES_H

#ifndef uint8
#define uint8  unsigned char
#endif

#ifndef uint32
#define uint32 unsigned long int
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
    uint32 esk[32];     /* DES encryption subkeys */
    uint32 dsk[32];     /* DES decryption subkeys */
}
mitake_des_context;

typedef struct
{
    uint32 esk[96];     /* Triple-DES encryption subkeys */
    uint32 dsk[96];     /* Triple-DES decryption subkeys */
}
mitake_des3_context;

int  mitake_des_set_key( mitake_des_context *ctx, uint8 key[8] );
void mitake_des_encrypt( mitake_des_context *ctx, uint8 input[8], uint8 output[8] );
void mitake_des_decrypt( mitake_des_context *ctx, uint8 input[8], uint8 output[8] );

int  mitake_des3_set_2keys( mitake_des3_context *ctx, uint8 key1[8], uint8 key2[8] );
int  mitake_des3_set_3keys( mitake_des3_context *ctx, uint8 key1[8], uint8 key2[8],
                    uint8 key3[8] );

void mitake_des3_encrypt( mitake_des3_context *ctx, uint8 input[8], uint8 output[8] );
void mitake_des3_decrypt( mitake_des3_context *ctx, uint8 input[8], uint8 output[8] );

#ifdef __cplusplus
}
#endif

#endif /* des.h */