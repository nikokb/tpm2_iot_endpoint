tpm2_evictcontrol -C o -c 0x81010002
tpm2_createprimary -C o -g sha256 -G rsa -c primary.ctx
tpm2_import -C primary.ctx -G rsa -i private.pem -u key.pub -r key.prv
rm private.pem
tpm2_load -C primary.ctx -u key.pub -r key.prv -c key.ctx
tpm2_evictcontrol -C o -c key.ctx 0x81010002