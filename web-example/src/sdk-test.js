import { createWallet } from "@docknetwork/wallet-sdk-core/lib/wallet";
import { createAccountProvider } from "@docknetwork/wallet-sdk-core/lib/account-provider";


async function main() {
    const wallet = await createWallet({
        databasePath: "data-store",
        dbType: "sqljs",
        typeORMConfigs: {
            location: "data-store",
            sqlJsConfig: {
                locateFile: file => `https://sql.js.org/dist/${file}`
            },
        }
    });

    window.wallet = wallet;

    const accountsProvider = createAccountProvider({
        wallet,
    });

    const account = await accountsProvider.create({
        name: 'test',
    });

    // manage DIDs
    const documents = await wallet.getAllDocuments();

    console.log(documents);
}


main();