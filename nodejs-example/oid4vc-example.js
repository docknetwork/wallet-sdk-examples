import { createWallet } from "@docknetwork/wallet-sdk-core/lib/wallet";
import {
  createDataStore,
} from "@docknetwork/wallet-sdk-data-store-typeorm/lib";
import {
  createCredentialProvider,
} from "@docknetwork/wallet-sdk-core/lib/credential-provider";
import {
  createDIDProvider,
} from "@docknetwork/wallet-sdk-core/lib/did-provider";
import {WalletEvents} from '@docknetwork/wallet-sdk-wasm/lib/modules/wallet'

async function main() {
  const dataStore = await createDataStore({
    databasePath: "dock-wallet",
    defaultNetwork: "testnet",
  });

  const wallet = await createWallet({
    dataStore,
  });

  // Wait for the wallet to connect to the network
  await wallet.waitForEvent(WalletEvents.networkConnected);

  const didProvider = createDIDProvider({
    wallet,
  });

  const defaultDID = await didProvider.getDefaultDID();

  console.log(`Wallet DID: ${defaultDID}`)

  const credentialProvider = createCredentialProvider({
    wallet,
  });

  console.log('Fetching the credential from the OID4VC issuer');

  // OID4VC Url
  // This URL can be rendered as a QR Code
  const credentialUrl = 'openid-credential-offer://?credential_offer=%7B%22credential_issuer%22%3A%22https%3A%2F%2Fapi-staging.dock.io%2Fopenid%2Fissuers%2F2baff124-6681-428b-b5a1-449f211d9624%22%2C%22credentials%22%3A%5B%22ldp_vc%3AMyCredential%22%5D%2C%22grants%22%3A%7B%22urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Apre-authorized_code%22%3A%7B%22pre-authorized_code%22%3A%22bN3fNhSP0TnVoGgYzn0lOsVq-hQCmelt3AvDa-TA3n0%22%2C%22user_pin_required%22%3Afalse%7D%7D%7D';
  await credentialProvider.importCredentialFromURI({
    uri: credentialUrl,
    didProvider,
  });

  console.log('Credential added to the wallet!')

  const credentials = await credentialProvider.getCredentials();

  console.log('List of all credentials:');

  for (let i = 0; i < credentials.length; i++) {
    const credential = credentials[i];
    console.log(`Credential ${credential.id}`);
  }
}

main();
