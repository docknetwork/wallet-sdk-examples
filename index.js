import { NetworkManager } from "@docknetwork/wallet-sdk-core/lib/modules/network-manager";
import { Wallet } from "@docknetwork/wallet-sdk-core/lib/modules/Wallet";
import { Transactions } from "@docknetwork/wallet-sdk-transactions/lib/transactions";

NetworkManager.getInstance().setNetworkId("testnet");

async function main() {
  const wallet = await Wallet.create();

  console.log("Wallet crated");

  const account1 = await wallet.accounts.getOrCreate({
    name: "Account 1",
    mnemonic:
      "opera creek math job debate rib royal immense report sick used earth",
  });

  const account2 = await wallet.accounts.getOrCreate({
    name: "Account 2",
    mnemonic:
      "autumn sentence spot genuine tribe frequent photo draft leg proof aunt knock",
  });

  console.log("Account1 address: ", account1.address);
  console.log("Account1 balance: ", await account1.getBalance());

  const accountTx = Transactions.with(account1);

  const fee = await accountTx.getFee({
    toAddress: account2.address,
    amount: 1,
  });

  console.log(`Fee ${fee}`);
}

main();
