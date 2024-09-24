rm -rf ./node_modules/.cache

# rm -rf ./node_modules/@docknetwork/wallet-sdk-wasm/src
# cp -rf ./node_modules/@docknetwork/wallet-sdk-wasm/lib ./node_modules/@docknetwork/wallet-sdk-wasm/src

rm -rf ./node_modules/@docknetwork/wallet-sdk-wasm
cp -rf ../../wallet-sdk/packages/wasm  ./node_modules/@docknetwork/wallet-sdk-wasm
rm -rf ./node_modules/@docknetwork/wallet-sdk-wasm/src
cp -rf ./node_modules/@docknetwork/wallet-sdk-wasm/lib ./node_modules/@docknetwork/wallet-sdk-wasm/src

rm -rf ./node_modules/@docknetwork/wallet-sdk-core
cp -rf ../../wallet-sdk/packages/core  ./node_modules/@docknetwork/wallet-sdk-core
rm -rf ./node_modules/@docknetwork/wallet-sdk-core/src
cp -rf ./node_modules/@docknetwork/wallet-sdk-core/lib ./node_modules/@docknetwork/wallet-sdk-core/src

rm -rf ./node_modules/@docknetwork/wallet-sdk-data-store
cp -rf ../../wallet-sdk/packages/data-store  ./node_modules/@docknetwork/wallet-sdk-data-store
rm -rf ./node_modules/@docknetwork/wallet-sdk-data-store/src
cp -rf ./node_modules/@docknetwork/wallet-sdk-data-store/lib ./node_modules/@docknetwork/wallet-sdk-data-store/src

rm -rf ./node_modules/@docknetwork/wallet-sdk-data-store-web
cp -rf ../../wallet-sdk/packages/data-store-web  ./node_modules/@docknetwork/wallet-sdk-data-store-web
rm -rf ./node_modules/@docknetwork/wallet-sdk-data-store-web/src
cp -rf ./node_modules/@docknetwork/wallet-sdk-data-store-web/lib ./node_modules/@docknetwork/wallet-sdk-data-store-web/src
