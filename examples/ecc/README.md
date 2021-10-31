Follow this guide.

```bash
# key generation
./generate.rb secp384r1 > keypair.json

# signing and verifying
cat ~/image.png | shasum -a 384 -b | cut -d " " -f1 | ./sign.rb secp384r1 $(cat keypair.json | jq -Mr '.private_key') > signature.json
cat ~/image.png | shasum -a 384 -b | cut -d " " -f1 | ./verify.rb secp384r1 $(cat keypair.json | jq -Mr '.public_key') $(cat signature.json | jq -Mr '.signature')

# encrypting and decrypting
echo -n 'Some text to encrypt' | ./encrypt.rb secp384r1 $(cat keypair.json | jq -Mr '.public_key') > encrypted.json
cat encrypted.json | jq -Mr '.ciphertext' | ./decrypt.rb secp384r1 $(cat keypair.json | jq -Mr '.private_key') > decrypted.json
```