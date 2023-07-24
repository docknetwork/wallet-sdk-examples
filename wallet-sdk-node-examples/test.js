
const {createWallet} = require('@docknetwork/wallet-sdk-core/lib/wallet');

async function main() {
    const wallet = await createWallet({
        defaultNetwork: 'testnet',
    });

    console.log('wallet created');

    const document = await wallet.getDocumentById('test');

    console.log(document);    
}

main();