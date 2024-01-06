# Axiom Quickstart

## Introduction

This starter repo is a guide to get you started making your first [Axiom](https://axiom.xyz) query as quickly as possible using the [Axiom Client](https://github.com/axiom-crypto/axiom-client). To learn more about Axiom, check out the developer docs at [docs.axiom.xyz](https://docs.axiom.xyz) or join our developer [Telegram](https://t.me/axiom_discuss).

A guide on how to use this repository is available in the [Axiom Docs: Quickstart](https://docs.axiom.xyz/introduction/quickstart).

## Setup

Install `npm` or `yarn` or `pnpm`:

```bash
# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.bashrc
# Install latest LTS node
nvm install --lts
# Install pnpm
npm install -g pnpm
pnpm setup
source ~/.bashrc
```

To install this project's Typescript dependencies, run

```bash
pnpm install
```

Copy `.env.example` to `.env` and fill in with your provider URL (and optionally Goerli private key).
You can export your Goerli private key in Metamask by going to "Account Details" and then "Export Private Key".

> ⚠️ **WARNING**: Never use your mainnet private key on a testnet! You should never use a private key for an account you have on both mainnet and a testnet.

Install [Foundry](https://book.getfoundry.sh/getting-started/installation). The recommended way to do this is using Foundryup:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

To install this project's smart contract dependencies, run

```bash
foundry install
```

## Test

To run Foundry tests that simulate the Axiom integration flow, run

```bash
forge test -vvvv
```

## CLI Cheatsheet

```bash
# compile
npx axiom compile axiom/circuit.ts --function nonceIncrementor --inputs data/inputs/defaultInput.json --provider $PROVIDER_URI_GOERLI
# run
npx axiom run axiom/circuit.ts --function nonceIncrementor --inputs data/inputs/input.json --provider $PROVIDER_URI_GOERLI
# get sendQuery calldata
npx axiom sendQueryArgs <callback contract address> --calldata --sourceChainId 5 --refundAddress <your Goerli wallet address> --provider $PROVIDER_URI_GOERLI
```

## AxiomV1

If you are looking for the AxiomV1 Quickstart, it is now on the [v1 branch](https://github.com/axiom-crypto/axiom-quickstart/tree/v1).

## Axiom クエリについて

Axiom クエリは、過去のイーサリアムデータを使用し、そのデータに対して計算を実行する特別な Axiom クライアント回路を記述することで指定されます。これは@axiom-crypto/clientパッケージを使用してTypescriptで行うことができます。
このクイックスタートでは、axiom/circuit.ts の回路例を使用します。回路コードは nonceIncrementor という関数で定義されている。この回路は入力として変数 blockNumber とアドレスを受け取り、与えられた blockNumber のアドレスの nonce を検証する要求を Axiom に行い、回路内で nonce を 1 だけインクリメントします。コールバック契約に転送される回路の出力は、bytes32[]配列として[blockNumber, address, nonce + 1]です。

## スマートコントラクトの統合

AxiomV2Query コントラクトが、Axiom が上記で指定したクエリを実行した後に呼び出すスマート・コントラクトを提供する必要があります。このコントラクトは、上で書いた回路の出力を受け取るものです。
src/AxiomNonceIncrementor.sol にスマートコントラクト AxiomNonceIncrementor の例があります。このコントラクトは、Axiom コールバックを受信するコントラクトをセットアップするための一般的な足場を実装する抽象コントラクト AxiomV2Client を継承します。オーバーライドする関数は _validateAxiomV2Call と _axiomV2Callback です。
この例では、_axiomV2Callback でコールバックから [blockNumber, address, nonceInc] を受け取り、マッピング blockToAddrToNonceInc[blockNumber][address] = nonceInc に nonceInc を格納し、イベントを発行します。
サンプルのコントラクトをデプロイし、クエリを送信し、Axiom フルフィルメントにいたずらし、コールバックを実行する Foundry テストを test/AxiomNonceIncrementor.t.sol に用意しました。次のようにして実行できます。

```bash
forge test --mt testAxiomFulfillQuery -vvvv
```

テストの冗長出力には、コールバックの詳細と、コールバック関数の終了時に AxiomNonceIncrementor コントラクタが発するイベントが表示されます。

### デプロイした記録

```bash
Deployer: 0x51908F598A5e0d8F1A3bAbFa6DF76F9704daD072
Deployed to: 0x56715247586de9E5f0FdBb88845bd6e437aC7424
Transaction hash: 0x7fd4364f5b8e6aafc448a9cf52dddfd43d5282f25e690e150fe6d2460aeb9cb0
Starting contract verification...
Waiting for etherscan to detect contract deployment...
Start verifying contract `0x56715247586de9e5f0fdbb88845bd6e437ac7424` deployed on goerli
```

クエリを生成する方法

```bash
npx axiom compile axiom/circuit.ts --function nonceIncrementor --inputs data/inputs/defaultInput.json --provider $PROVIDER_URI_GOERLI
npx axiom run axiom/circuit.ts --function nonceIncrementor --inputs data/inputs/input.json --provider $PROVIDER_URI_GOERLI
npx axiom sendQueryArgs 0x56715247586de9E5f0FdBb88845bd6e437aC7424 --calldata --sourceChainId 5 --refundAddress 0x51908F598A5e0d8F1A3bAbFa6DF76F9704daD072 --provider $PROVIDER_URI_GOERLI 
```

クエリを送信する方法

```bash
cast send --rpc-url $PROVIDER_URI_GOERLI --private-key $PRIVATE_KEY_GOERLI --value "20500000000000000" 0xf15cc7B983749686Cd1eCca656C3D3E46407DC1f "0xba1d7f190000000000000000000000000000000000000000000000000000000000000005ce9e4724a6f35ee6169d09e3f4f3d5cfecd2782e0b6ad3200c988f380def18f400000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000c20068dbc5fde4a7eda9d2ea35c1a36ab9ff8213fa9e1f1effd7c93c86e4a5c1eb800000000000000000000000000000000000000000000000000000005d21dba000000000000000000000000000000000000000000000000000000000000030d4000000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad0720000000000000000000000000000000000000000000000000000000000000c80000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000000ed73cd98a611b12b4d2b4939bf1c8533bc4f2d8465908bbbbcc80d10418aedb12c04b25057d0bddf35d4542077516abb76445b8e745a457e3ccc1bf9aac2ba406b9f00e05c46f8095a4b94d63d2abc6f95ac26460ea9c9db9179b77f4c936216318d2e8b16df8cb7ab3125198923271247a8bc329e3a6fe1adbf61a08fb9d692a000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000080efbec779e12698cae35514362b340e608042af2fb615c92ddfafa204d334610c0ca5f25e1da10e70a70ba99b9a90f73cdda963d83a6df8b480bcd4cf7f1bbc0d22e4c62aacfc240ed0553bfad00122ba8c7627c870c739f3f818584e066a8b1f841485e0a9f109688bdc4f5ff851d9e2e44833ae573456742c1237322e93854279a62f1cc2f1440cc9fdcd534b612a49da4b6139bbed8cf53a26f4568ac3f567720d0b23c2b64b09b9c41cd9495ef317a609d1746bb942fc326cfc0d0a82d30c61029072f461cff9095a0daa8619775c00372e8dc519945081c49c464d337227000000000000000000000000000000000000000000000000000000000000088000000000000000000000000000000000000000000000000000000000009a34530000000000000000000000008018fe32fcfd3d166e8b4c4e37105318a84ba11b0000000000000000000000000000000000000000000000000000000000002f12b7542c743fd6e57f638934bc780123c004dd781db1ba0847dad75e95d653db60dbd09e5fb3f60bf8dd11ffc5974efb104cbe8eea9960548a1de397b85d02dc0658ed52d569b672a5ddc55a4107cf249013e3851d6a78cdab9bda2b8947bf276baf9298d57ca819624e145f6b465e24d3283b67fb6e3f50893cb72165aae92c644792d082940843fd8d79fa677886c2ded2c701f32e945f7a9ac4fb630a5ece07c1ba1de623a5e264ccd413f3ee53301ab27ad44b55681d43be0c9606baa4fe468baf7de28ef1cfae3e4ef985bb9d0d2c71c48e32d5169c31e04c7e0d2c4d5b5952cdb37e3a48fd3db461c9e4f9026206205db0ebca75499ef0855bdee989ab4fe1f3bc9b02156e3f51fd9d2c07da24b301c1f3efe316160e27512d314ae9101c1742c7ff4bab39520eccd93acba6eecf0e252b212c1ce20590cbec0f49d016565749d9fb854ace51f7ef09a9e4d38dc0ea616652c29ea750a3cfb8897557e75692fc18a930970d7d9ea3e0ab31937230a61699297745379a057bd02d497e112955ba35aef8e6219996b4f4158fb08a5fd645f3e99a73199ab6fa36319d95a8226282496e9a489906123a47f61ec2e4c7c7fff7f814712953368d63dfb6c64b4d97ab2d9589c62df705e246aa76c2927d4b6ed7537c04bf2e5a9868d036fae251485f3bbfea12eeff58fffa2258bb6811bb8acac4205083b1c7f14094ecd18f2240f465ec05c0adec700b41e1683d02f7e6cd53c312be78b24db67d954f328112ab01c136227263e3fc1c833334b66738f5da0da1cde25c333b26b1c586cd7f0bed96715e75d67f5c84829c8d10a5627365941780c5440761b0964ae5c86fe31d168d644c2f227794265d013922403ddc825c71e778d317404093f42b462b482854cfe49b0c051db1e9a18a79f0d9de14095f8b037692cfe5c11992f77d6a770dd4fa26f4dcaf3c4393cf627d7af8a8564a6a2cd06ef7c230a2ac5f5bc11fd9107eb21eb7fc85586ef4f62093636a039790ac0d8b053796562fa0602a24eead225742512b582155ea451d0064a0bcc237a5822f03f4e8d5cba2d109e51ec31f10df533ce744f82cd0756d1223d7932aecdaac1dd58b1c01d4e3fe1dd5240438121f8b45919a716091d5ac134363cf9c800c86757d911b776f5968e7ba0cf425220f4b1a490152a7aeffe6d832eb9b75fcc4024661a206f5ed1d2cbcf30c2c3e2ff84d871ef0795d62e696f7002f5713cce256b8bc048d5fda89e1c7d496cff42946a4e24d6277f291ae87f7168d3a3eab8db9d4e04e585c230d3a2b9f247cf81aa5a6542cb272077002594d2f91dd11c64fb6d0463d0522e93dda3ea8d7aa2b19b726b74f2a349b6da6022efd21ca9d28c9a401bb605c971ce74c042e7105a31cb409c2b82c981d22e6c79a13b74563a99bd020a9e2edbdbe15e659899280ab1bcdd273279052903cc0f95928574c892a7af67107bd86eeb2b271d4574b5b05285522a314999d56e074fe3ed7fdf63ffe215ae6a3445171fe09a5005e6a87c5038168e2d6184fb6554100538d2d63b42ed917958b58013461c57028ba3a9ce8276c7cd901ef3ed3724d56205988620fe47667a119620954058f6a5c5029b10d1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000013cd23a2f32ff858bc8f9144dc83eebcd1cd92e70b61128f497b8fd8bea4ac2d3a0b075e59db364b4b83e4f1860c9ce1cec04676a2dc054abfd7bf261d1bc51936e46b488c7303f73da96bf3700d878c7fb2da034f9acd7caf7c3c01559b2202f691f4248e838179fa4b0169c73cd56144a63023c852eb31b8be667b43f37f25c74b48199667de9601adc4af37ca78d2d383bca273da066c6e7b153987a4901e24b87122c5691acd0f1510755ebd616d974633424ef8aa29bf7d6e870e4dac099593b214e6344a79cdd7ab4b73c7e6589998d4aa29387fc403a27ec419c3e21a548ffb42d28c0ac8982fb3cb34533e874148172a3b3836424b04553e0dae1f03d0534b9db50f4cb273d1ee36a7565ab736e636ed64dd5b7af47463be2d06f71dced1901e93a9483970d6b4df80f5b257107368997e193241b339e9052b3e9e1900a54f7e77f0285fcca1140066455acc313d6f79deb7c388e97c2fa06c2b8d2a27d013e05bdb9a613ae874189782067b909a11da72c2d39143d48e174a608a25012b7b4054c6233ceb24a7889473db3f0cb95c19d46761790d6260e3cd2c2303b93d2c3924409ed8f6c19eccaf26f28e2f9e6f9fa042defab05845e89190fe10b802030512049f54f61058f92d0970f377a1105d7251d784daca19610f53d10100f4bc68f352045530c2fab6fe709d08792a52f36070f791f212536523e2bc16bf637a8aeda185798c6dcebcd1f40489d374c10aeaea18b7d94ae5a47f9c64217bd15172ca903ff211f93f75c791239ddbe6e6588c55a829c8c3a4bb66b1b021c5cd790751fd3a4a6ba5f1f5e7d5112f59b01c960881b5370502cc2f816ea22b2a786b0903a5ad71a7141fe1a94b2180a6f210bad087d5009b1300808509882d58878c7c8f9bd3f8916dd0617a2a7bab873becff59ff9ff2aa5d65959bf67512bf51324134793c1264c791690fe316c359a54434642825e6112bd391553b3812ad5abdec4276df9946dcf7eb4beb738b3a8e6439e28c41f43fb671b44471d41ac4776537e793809614c992aae335c1d2a7699bb812cf423af430aae4e52a711f3794699cd302d682703355f30673e12326944e1f8262ce9fa507434598f39a672b740389b34f079a8df8a3798c5fa357b674ad3ace89a5bd1614a39ede898e62000000000000000000000000ea7813e6b0a3ab051ce07bf17d19aba8f1f8b3ac000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028000000000000000500010002009a34538018fe32fcfd3d166e8b4c4e37105318a84ba11b00000000000000000000000000000000000000000000000000000000"
```

実行結果

```bash
blockHash               0x506fae0c578565285d793a3537d10c20f76e0d767ea270a8353ace5ea0e3eaf2
blockNumber             10308429
contractAddress         
cumulativeGasUsed       799470
effectiveGasPrice       3000000010
gasUsed                 156505
logs                    [{"address":"0xf15cc7b983749686cd1ecca656c3d3e46407dc1f","topics":["0xe1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c","0x00000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad072"],"data":"0x0000000000000000000000000000000000000000000000000048d4a431e54000","blockHash":"0x506fae0c578565285d793a3537d10c20f76e0d767ea270a8353ace5ea0e3eaf2","blockNumber":"0x9d4b4d","transactionHash":"0xf0927a71721b4e8e942670a709670b311960f0a30e3a6250dc7e9604d0a663da","transactionIndex":"0x1","logIndex":"0x9","removed":false},{"address":"0xf15cc7b983749686cd1ecca656c3d3e46407dc1f","topics":["0xae95b2503575f3fe1b46b9e02c8ea724f2aa9340a4b06018ce7945d365eec811","0xce33572eefe5258c952fb4352744358912424caf45f8f9aa2558e537509965e9","0x00000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad072"],"data":"0x00000000000000000000000000000000000000000000000000000000009d676d00000000000000000000000000000000000000000000000000000005d21dba000000000000000000000000000000000000000000000000000000000000030d400000000000000000000000000000000000000000000000000048d4a431e54000","blockHash":"0x506fae0c578565285d793a3537d10c20f76e0d767ea270a8353ace5ea0e3eaf2","blockNumber":"0x9d4b4d","transactionHash":"0xf0927a71721b4e8e942670a709670b311960f0a30e3a6250dc7e9604d0a663da","transactionIndex":"0x1","logIndex":"0xa","removed":false},{"address":"0xf15cc7b983749686cd1ecca656c3d3e46407dc1f","topics":["0xb72b05c090ac4ae9ec18b7e708d597093716f98567026726f6f5d9f172316178","0x00000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad072","0x5b806b9bd023b511d72e44c9e0b7b300a6b532989ee62bb7b6fde7238000afcc","0xce33572eefe5258c952fb4352744358912424caf45f8f9aa2558e537509965e9"],"data":"0x068dbc5fde4a7eda9d2ea35c1a36ab9ff8213fa9e1f1effd7c93c86e4a5c1eb800000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad072000000000000000000000000ea7813e6b0a3ab051ce07bf17d19aba8f1f8b3ac00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000","blockHash":"0x506fae0c578565285d793a3537d10c20f76e0d767ea270a8353ace5ea0e3eaf2","blockNumber":"0x9d4b4d","transactionHash":"0xf0927a71721b4e8e942670a709670b311960f0a30e3a6250dc7e9604d0a663da","transactionIndex":"0x1","logIndex":"0xb","removed":false}]
logsBloom               0x00000000000000000000080000000000000000000000000000000000102000000000001000000200000000000004000000000000000000000000000000000000000000000000000040000000000000000000000000000080000000008000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000001000000000000000000000000000000000004000000000000000000000004000000000000000000000000000000000000000800002000000000000000000000000000000000000000000000000000000003000000000000000000002000000004000000400000000000200000
root                    
status                  1
transactionHash         0xf0927a71721b4e8e942670a709670b311960f0a30e3a6250dc7e9604d0a663da
transactionIndex        1
type                    2
```

[EtherScan - 0xf0927a71721b4e8e942670a709670b311960f0a30e3a6250dc7e9604d0a663da](https://goerli.etherscan.io/tx/0xf0927a71721b4e8e942670a709670b311960f0a30e3a6250dc7e9604d0a663da)

[Axiom Explorer - 93267157725810194257544188252405213718531135484736144400773100082455186597353](https://explorer.axiom.xyz/v2/goerli/mock/query/93267157725810194257544188252405213718531135484736144400773100082455186597353)

## 以下、 ERC20の所有を確認するサーキットを試した時の記録 (Link Token)

クエリを生成する方法

```bash
source .env
npx axiom compile axiom/sample-circuit.ts --function proveHoldToken --inputs data/inputs/sample1/defaultInput.json --provider $PROVIDER_URI_GOERLI
npx axiom run axiom/sample-circuit.ts --function proveHoldToken --inputs data/inputs/sample1/input.json --provider $PROVIDER_URI_GOERLI
npx axiom sendQueryArgs 0xa053855198b6b136bd97a77001438fceb4a98ae0 --calldata --sourceChainId 5 --refundAddress 0x51908F598A5e0d8F1A3bAbFa6DF76F9704daD072 --provider $PROVIDER_URI_GOERLI 
```

コンパイルした結果

```bash
Slot 0xad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5 has empty MPT proof in account 0x0000000000000000000000000000000000000000 at block 0
Witness generation: 1.500s
Witness generation: 2.378ms
VK generation: 4.649s
PK generation: 949.854ms
Saved build.json to /Users/harukikondo/git/axiom-quickstart/data/build.json
```

実行した結果

```bash
Witness generation: 1.409s
PK generation: 970.18ms
SNARK proof generation: 9.430s
Saved output.json to /Users/harukikondo/git/axiom-quickstart/data/output.json
```

サンプル用のNFTをデプロイした記録

```bash
sh script/deploy_sampleNFT_goerli.sh
```
実行結果例

```bash
[⠆] Compiling...
No files changed, compilation skipped
Deployer: 0x51908F598A5e0d8F1A3bAbFa6DF76F9704daD072
Deployed to: 0xA053855198B6b136bD97A77001438fCEb4a98ae0
Transaction hash: 0xdbb87a9c934ec453cfcb64f781be4385f769c3e7392b3e3d229eb87832b91977
Starting contract verification...
Waiting for etherscan to detect contract deployment...
Start verifying contract `0xa053855198b6b136bd97a77001438fceb4a98ae0` deployed on goerli
```

[SampleNFT - 0xA053855198B6b136bD97A77001438fCEb4a98ae0](https://goerli.etherscan.io/address/0xA053855198B6b136bD97A77001438fCEb4a98ae0)

検証する時のコマンド

```bash
forge verify-contract --watch --chain-id 5 0xBA03210a6E732b24c9bB9C56e7874aD84A84d277 AxiomSampleNFT
```

クエリを送信した結果

`data/inputs/sendQuery`にデータが格納されている。

クエリを送信してNFTをミントしてみる

```bash
cast send --rpc-url $PROVIDER_URI_GOERLI --private-key $PRIVATE_KEY_GOERLI --value "20500000000000000" 0xf15cc7B983749686Cd1eCca656C3D3E46407DC1f "0xba1d7f190000000000000000000000000000000000000000000000000000000000000005471473b83a27c58a55d341689a9f5c3e17167531e138178ab8789e3323502ec300000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000c40b57999db16997657ae18339b20708f35044670b8c40413a6c21b54c032170f8900000000000000000000000000000000000000000000000000000005d21dba000000000000000000000000000000000000000000000000000000000000030d4000000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad0720000000000000000000000000000000000000000000000000000000000000ca0000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000000ec138183e1c2247333edbde76988bba9303f2cd896b32421669146a0c20b2d316c04b25057d0bddf35d4542077516abb76445b8e745a457e3ccc1bf9aac2ba406c2e83051a7a744137b59d8027c8cfe1de214ed790e85cb36843154893c228a030ada5793aea5e0ad661e54887d4d5e6602ef7b4aa098e78a93dae25237c11f000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000804dab82f4773b031c57eeecd24a7cf72b3049b4b022d1426c188a2b8a18a4a513e7c80275b75862b99e1fa30b6430966affa7b0c49cac51eee115840fcf50966c22e4c62aacfc240ed0553bfad00122ba8c7627c870c739f3f818584e066a8b1f841485e0a9f109688bdc4f5ff851d9e2e44833ae573456742c1237322e93854279a62f1cc2f1440cc9fdcd534b612a49da4b6139bbed8cf53a26f4568ac3f567527b5372bc169e804a72d5ee7e3bb7b3ae94ce4bd62d6d6fd5bd892618a37c0caf4fd90f1a00f1ea6ffd052bf4f6554151ebe1283ad285694c817d89680cc70a00000000000000000000000000000000000000000000000000000000000008a000000000000000000000000000000000000000000000000000000000009da18a000000000000000000000000326c977e6efc84e512bb9c30f76e30c160ed06fb00000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad0720000000000000000000000000000000000000000000000056bc75e2d6310000056549e340cbc1e122ebe77a3d6d3f92da31464118778e099e0cf8ae827f19a5dcbdc74ac17698c59f10e8555b49f90c77bb32f0626a7b5bb0e783b1461ab404936e7961ce7baeae2db46ab388780431a52425c1dab0a0ff459eb9bc8f9bfde04717d86abff4beeae4c9ab52d4dc6354367ae18284667a7e04b78423d7c8af94368bfdcaff12312c4eeed7bdde22ec235cc9972f8cfa2c682ee0579585a6644466a6561122483db4efbab12e20374b2406175f0a0b505198d40c5ff64dfce390b885221ba45912286b34df97777eb54af1da9a062f95b8a52177a0569a51ea24dae175bbc9073f45f2547b7fcdf2c1e01cb809b6ce07d0be050c090129068d4176ba5167feeebd1f2741e3d40506f1e8025e2ab9045c556f64e02a033e207d5032eeb6c951f3733d4dc6a76be81541abf5534f581b6def64607d9173c94ceae4825d44ffaf60cb42e7ad85ce25ba62573c6f130eb16e934628127d7e52ae22b0bfd468670742b0abc41600a48808a1df4b36026df5a0add1ac55a852165ec500f04072a1cbc26f1d4c7e0baa6c95dd1ba1269dc2e4ddbed09ec863413c2b8d425507acf98b6e930f559ac702feee10f8795acf2cf1f20f2792c13e0a0061da0479ebe53fe5f2367328736e2a1fcd0309b253a4107967250bd845680231000ac28fed27c5071b399917af16cd94788ccec65750a7ee9e2b223e5b1b271bc8ae70f0288fe16aeb5a61ece88e33c497eb429240973d73a926f4c69fd794070d0671a0929962fdcb4b96c6f3e1763b5a1d358de5c841ca75f61f164472857b23a8c280246d1af581e449bd203713782cc885f1b2abe3753cf83ce12f9aa8309328d0ced26c322fef976581c84d0b03f7922f130f860b21ce8f335ee4f25e5b8f70c04a7d41a0b802f05061103a23fa614723339bd494220fd9accabb90599e307ba1ee2eb5293c70dde2bf822b0fed1e383de3e6e8510b62f8d79f8de797e696b9e2de3de9b2820b8367af1ea647aed1ff59935583c77c76ae17edb3542e93ad2270db5315c6c827fe88d98ed008778dab3473cfbaca6ad75c2587a26ab334c30d60d33a51458b6010c757484f8fbfc239bc74a5b50587543a5d5cf32695e5df3671ecab9cf07c40bc6d85ecbdfff5bd9a871391d0e7448ddfc63a43655f0241f231a9ad172b3696509ba49bfb757063d88240342c099da2d8af30810608f304fbe0dd0d97af23f4e26c060beaea01aad9665706c0503e30ccb8fd2d81944a05d200aaa83dc26843889f4cfdc71884e5bb8623c2bcf253b3f7a95398b888c5af6f20ebe90740aad823814869b40fcaacc9b06189121b87fec2fc9889663d673139d03f6fe1de189f86a33d097300b3c1230df1f00666a21497a8a74c0c57efea43c22aef7c5468f907a11a223839d019295bfec22516d687f35397521548fbcbc5f2e54e947cfa2c50b504bd4469d7de5ec5eecd751fb8006df1365e595e6e9ec921f02c3b1c989a9c5950c7a540b68e4ea2e1b1447465570660b31227f78e7deb22a145441dc24dafffaf00d6a5495d1f20200041ef6ffaf766920c3edceac32b72ebfb1e9c2ad802a4d30807c809e21f74069229d4670c5e80b85462f8ee31af4170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005bef5dcf2350b2f717289c839bf170259b935de21011ccc92ce195e0fdf51827f1b8b1ab7e2463220a14cddc753950213f9d006ffca9abcf3c77e89c219103105296c25acea24528d2318029670cf9c51d2844106556558d7c244f172ff1ba088103aa371386902c746b80ea193f2cb02e3e007cb2b86ee62a045c9017a6d909e2af2cf341995e0cf7d6e0daa0b0a144165690d486e6dbeaae3c7a3f4d43e627b743eefb1096e138b42b99b0deee858b3fa13c5f8bf1e28e938280d1f7d34a1838124fad050248eedad5f524d3841f86009d8fb661ed6dec330c049cbf634602a7c822264f785b9fb245cd685b3d6d6ae0ede0e13f497574c6ff84bce21f7019e4b9efd11837f5b2ff04ce4964c1601e5182756614ff8ea500387c7ea490bb039521c707cfff35b07b71234975129b158872eda2492a0f1e05a8099451e98b1cd28fca9595acfc1017e97b140ed52d91c0efdf96232e3067f35e7278c9a2e90cc565db2c186b62f833da9e86e8f645ee3319ae41343d048863308e6425e7822688c942b9cb318fbca287570fd3d599e731a4e048ea96494bd1982fcc44041c1328e3f8c5eb8d13c30192b2de3436ff5c0b11580b8b09b7d8086b6be40d2cb501f637d7132f38a41b4b8d16692dedf88ab0aa69ac698edd6226c98609b9db5a10efed8e0ed0db25a7ac48d9558dab3c4f1a182d0dd51896cb7a7eae6ff65f3d26a91441b2e1234d8449ec91b3d88ee8f57d444402563d38bb83a4d7cc4aa23701b063b54ef3b5a2000b54f088c04c75b61831f76c90fdc278498346b9d112d629d746d385de080f651d180aa7b0591a5591e2cab80f6a2a86cddbf57467a36111c93ff90fbe4e983608701e01f21a458b7b43802fb5e16b77d418cac71a52b00bf4818844cf3f25037b099431de7e855ae65c2cc348d1ab3afff8f6ddaa23ce2649a84eb53ef3ad2f4298d1b73ea5e2cb03b3c0a7e5cf7a5970adee9d56c4bd1f69c6be3e97125e407359082c7376985c7cf8265ba1fe9d42abf8dfc590211e16454d3b049a064f56352f4815e10e11a66e758fdde6ebe17f073ffd2b73a46f167fa2c8c8ae7d2aff8fec3f3ead4c0810c95c5c3e4cfc08fe7a9333afa89424460a8d3ce80ceac31bb2094f095e13f0a59a74f1eb82cbf1d3b9973b36a479d851000000000000000000000000a053855198b6b136bd97a77001438fceb4a98ae0000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065000000000000000500010006009da18a326c977e6efc84e512bb9c30f76e30c160ed06fb00000000000000000000000000000000000000000000000000000000000000010100000000000000000000000051908f598a5e0d8f1a3babfa6df76f9704dad072000000000000000000000000000000000000000000000000000000"
```

実行結果

LINK Tokenを保有していれば NFTがミントできる

[NFTをミントした時のトランザクション](https://goerli.etherscan.io/tx/0x34eae8a9727582d34abcb87e216724ecc9168fc54c24f24fd27b0f6dfd70cd52)

