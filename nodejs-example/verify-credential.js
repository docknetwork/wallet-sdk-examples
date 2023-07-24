const {createWallet} = require('@docknetwork/wallet-sdk-core/lib/wallet');
const {
  credentialServiceRPC,
} = require('@docknetwork/wallet-sdk-wasm/lib/services/credential');
const {dockService} = require('@docknetwork/wallet-sdk-wasm/lib/services/dock');

const exampleCredential = require('./example-credential.json');

async function main() {
  const wallet = await createWallet({
    defaultNetwork: 'testnet',
  });

  console.log('Connecting to dock network');

  await dockService.ensureDockReady();

  // Fetching and adding credential to the wallet
  let credential = await wallet.getDocumentById(exampleCredential.id);

  if (!credential) {
    console.log('Adding credential to the wallet');
    credential = await wallet.addDocument(exampleCredential);
  }

  console.log('Credential loaded in the wallet');
  console.log('Verifying the credential...');

  // check if credential is valid
  const isValid = await credentialServiceRPC.verifyCredential({
    credential,
  });

  console.log('Credential is valid:', isValid);
}

main();
