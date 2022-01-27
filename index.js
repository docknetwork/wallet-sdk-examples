import { Wallet } from "@docknetwork/wallet-sdk-core/lib/modules/Wallet";
import { waitFor } from "@docknetwork/wallet-sdk-core/lib/test-utils";

async function main() {
  const wallet = await Wallet.create();

  console.log("Wallet crated");

  const account = await wallet.accounts.create({ name: "test2" });

  console.log("Account: ", account.address);
}

main();
