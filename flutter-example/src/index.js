import './shim';
import { createWallet } from "@docknetwork/wallet-sdk-core/lib/wallet";

let wallet;

async function main() {
  wallet = await createWallet({
    databasePath: "data-store",
    dbType: "sqljs",
    typeORMConfigs: {
      location: "data-store",
      sqlJsConfig: {
        locateFile: (file) => `https://sql.js.org/dist/${file}`,
      },
    },
  });

  window.wallet = wallet;
}

main();

async function handleMessage(parentMessage) {
  // handle parent message here

  if (parentMessage.type === "addCredential") {
    await wallet.addDocument(parentMessage.credential);
    return;
  }

  if (parentMessage.type === "getDocuments") {
    const documents = await wallet.getAllDocuments();
    postMessage({
      type: "documents",
      documents,
    });
  }
}

