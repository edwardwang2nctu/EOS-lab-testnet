# EOS-lab-testnet

## Quick start guide

[guide](https://github.com/Intelligent-Systems-Lab/EOS-lab-testnet/blob/master/quick_start.md)

## Use docker 

```shell=
# node1 v4  
docker run -d -it -p 8881:8080/tcp -p 8891:8888/tcp --name eos1 tony92151/eos_lab:v4

# node2 v4
docker run -d -it -p 8882:8080/tcp -p 8892:8888/tcp --name eos2 tony92151/eos_lab:v4

# remove node1
docker container rm -f eos1
```
or use script
```shell=
# start node1 for v4
bash run_docker.sh run 1 v4

# remove node1
bash run_docker.sh rm 1
```

then go to browser

http://localhost:8881 for eos1

http://localhost:8882 for eos2

etc.

## Get start

### Clone repo
```sheel=
git clone https://github.com/Intelligent-Systems-Lab/EOS-lab-testnet.git
```
Init env
```sheel=
# default endpoint(172.17.0.2)
bash EOS-lab-testnet/init_env.sh default
source ~/.bashrc
```
### set up system contract
```sheel=
bash EOS-lab-testnet/init_bios.sh
```

### Start genesis node
```sheel=
bash EOS-lab-testnet/start_node.sh init
bash EOS-lab-testnet/start_node.sh start
```
### Init wallet
```sheel=
bash EOS-lab-testnet/wallet.sh init
```
and you will get a public-key

<img src="https://raw.githubusercontent.com/Intelligent-Systems-Lab/EOS-lab-testnet/master/images/image1.png" width="600"/>

then also see private-key by
```sheel=
bash EOS-lab-testnet/wallet.sh key_info
```
<img src="https://raw.githubusercontent.com/Intelligent-Systems-Lab/EOS-lab-testnet/master/images/image2.png" width="600"/>

### Activate `WTMSIG_BLOCK_SIGNATURES` conscious

more [detial](https://www.bcskill.com/index.php/archives/884.html)
```sheel=
bash EOS-lab-testnet/fix_block.sh
```
`Init wallet before Activate the conscious`

### set bios contract
```sheel=
bash EOS-lab-testnet/fix_bios.sh
```

### Create account
create account 
```sheel=
cleos -u http://$eos_endpoint create account eosio john {public key} -p eosio@active
```
create account and stack some money from `eosio`account
```sheel=
bash EOS-lab-testnet/create_account.sh john {public key}
```

### Start node

change `name` and `key pair` to yours.

```shell=
export node_name=john
export noden_key=EOS56s...
export noden_pkey=5Kgp1...
```
```shell=
# Node1(for 172.17.0.3)
nodeos \
--agent-name "EOS Agent - Node 1" 
--producer-name $node_name \
--plugin eosio::chain_api_plugin \
--plugin eosio::net_api_plugin \
--p2p-server-address 172.17.0.3:9876 \
--p2p-peer-address 172.17.0.2:9876 \
--p2p-peer-address 172.17.0.4:9876 \
--private-key [\"$noden_key\",\"$noden_pkey\"]

# Node2(for 172.17.0.4)
nodeos \
--agent-name "EOS Agent - Node 2" 
--producer-name $node_name \
--plugin eosio::chain_api_plugin \
--plugin eosio::net_api_plugin \
--p2p-server-address 172.17.0.4:9876 \
--p2p-peer-address 172.17.0.2:9876 \
--p2p-peer-address 172.17.0.3:9876 \
--private-key [\"$noden_key\",\"$noden_pkey\"]
```

### Register as block producer

```sheel=
cleos -u http://$eos_endpoint push action eosio setprods "testnetprods.json" -p eosio@active
```
In contract `setprods`, it need the format like below.

`testnetprods.json`
```json=
{
    "schedule": [
        {
            "producer_name": "eosio",
            "authority": [
                "block_signing_authority_v0",
                {
                    "threshold": 1,
                    "keys": [
                        {
                            "key": "EOS8xxxx",
                            "weight": 1
                        }
                    ]
                }
            ]
        }
    ]
}
```

### Stack for vote

```sheel=
cleos -u http://$eos_endpoint create account eosio john {public key} -p eosio@active
```


## FLOW

**genesis node** : `Clone repo`>`Start genesis node`

**node1** : `Clone repo`>`Init wallet`>`Create account`>`Start node`>`Register as block producer`

**node2** : `Clone repo`>`Init wallet`>`Create account`>`Start node`>`Register as block producer`

etc.





