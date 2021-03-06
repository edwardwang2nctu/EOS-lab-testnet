#!/bin/bash

echo "     ----------       --------        ---            "
echo "    |          |    /          |     |   |           "
echo "     ---    ---     |   ------       |   |           "
echo "        |  |        |  |             |   |           "
echo "        |  |        |   ------       |   |           "
echo "        |  |         \         \     |   |           "
echo "        |  |           -----   |     |   |           "
echo "        |  |                |  |     |   \           "
echo "     ---    ---      -------   |     |    --------   "
echo "    |          |    |          /     \            |  "
echo "     ----------      ---------        ------------   "
echo



echo "Do you want to cerate 'Genesis eos node' or 'Ordinary eos node'?"
select yn in "Genesis eos node" "Producer eos node" "Ordinary eos node"; do
    case $yn in
        "Genesis eos node" ) nodetype='genesis'; break;;
        "Producer eos node" ) nodetype='producer'; break;;
        "Ordinary eos node" ) nodetype='ordinary'; break;;
    esac
done

echo

ask_keypair(){
    if [ "$1" == "bp" ]
    then
        echo "Do you want to use default key-pair for block producer account ?"
    else
        echo "Do you want to use default key-pair for system account ?"
    fi
    #echo "Do you want to use default key-pair for system account ?"
    echo "Default private key : 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
    select yn in "default" "custom" "none"; do
        case $yn in
            "default" ) eosio_prikey=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 && eosio_pubkey=EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV; break;;
            "custom" ) read -p "Enter new private key: "  eosio_prikey && read -p "Enter new public key: "  eosio_pubkey; break;;
        esac
    done
}


ask_fix_block(){
    echo
}

ask_create_key(){
    echo
}

ask_producer_name(){
    echo "Enter producer name:"
    echo "Default pd name : producer"
    select yn in "default" "custom"; do
        case $yn in
            "default" ) pd_name=producer; break;;
            "custom" ) read -p "Enter new pd name : " pd_name; break;;
        esac
    done
}

ask_genesis_pubkey(){
    echo "Do you want to use default \"genesis public key\" for block producer start document ?"
    echo "Default public key : EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV"
    select yn in "default" "custom" "none"; do
        case $yn in
            "default" ) gene_pubkey=EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV; break;;
            "custom" ) read -p "Enter new genesis pub key: "  gene_pubkey; break;;
        esac
    done
}

set_host_ip(){
    ip=$(hostname -I)
    ip=${ip% }:9876
}

set_auto_production_flase(){
    sed -i "s/enable-stale-production = true/#enable-stale-production = true/" node/config.ini
}

set_bash(){
    if [ "$1" == "key" ]
    then
        #echo
        echo "export eosio_prikey=$eosio_prikey" >> ~/.bashrc
        echo "export eosio_pubkey=$eosio_pubkey" >> ~/.bashrc
        echo "export eos_endpoint=172.17.0.2:8888" >> ~/.bashrc
    else
        echo "export eos_endpoint=172.17.0.2:8888" >> ~/.bashrc
    fi
    
}

set_config(){
    if [ "$1" == "bp" ]
    then
        sed -i "s/producer-name = eosio/producer-name = $pd_name/" node/config.ini
        sed -i "s/\"initial_key\": \"EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV\",/\"initial_key\": \"$gene_pubkey\",/" node/genesis.json
    else
        sed -i "s/\"initial_key\": \"EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV\",/\"initial_key\": \"$eosio_pubkey\",/" node/genesis.json
    fi
    sed -i "s/p2p-peer-address = $ip/#p2p-peer-address = $ip/" node/config.ini
    sed -i "s/signature-provider = EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3/signature-provider = $eosio_pubkey=KEY:$eosio_prikey/" node/config.ini
    
}

set_init_wallet(){
    cleos -u http://$eos_endpoint wallet create --file wallet_pass.txt
    cleos -u http://$eos_endpoint wallet import --private-key $eosio_prikey
}

run_node(){
    bash EOS-lab-testnet/start_node.sh start >> nodeos.log 2>&1 &

    echo " ==================="
    echo "|Node is running... |"
    echo " ==================="
    echo "Log : $PWD/nodeos.log"

    echo -e "System account key :\n$eosio_prikey\n$eosio_pubkey" >> node.info
    echo "Node info save at : $PWD/node.info"
}
#######################################################
#######################################################
if [ $nodetype == "genesis" ]
then
    echo "Prepare..."
    sleep 0.5
    bash EOS-lab-testnet/start_node.sh init_gene >> /dev/null 2>&1

    ask_keypair
    set_bash key
    set_host_ip
    set_config
    echo "Initial wallet..."
    set_init_wallet
    echo
    read -p "Press [Enter] to run node..."
    run_node
elif [ $nodetype == "producer" ]
then
    echo "Prepare..."
    sleep 0.5
    #bash EOS-lab-testnet/wallet.sh init
    bash EOS-lab-testnet/start_node.sh init_ord >> /dev/null 2>&1
    echo
    ask_keypair bp
    echo
    ask_genesis_pubkey
    echo
    ask_producer_name
    echo
    set_bash key
    set_host_ip
    set_auto_production_flase
    set_config bp

    echo "Initial wallet..."
    set_init_wallet
    echo
    read -p "Press [Enter] to run node..."
    run_node

fi
#######################################################
#######################################################

# echo "Do you want to use default 'p2p-peer-address'  ?"
# echo -e "default address \n172.17.0.3:9876\n172.17.0.4:9876\n172.17.0.5:9876"
# select yn in "default" "custom"; do
#     case $yn in
#         "default" ) p2p_address='genesis'; break;;
#         "custom" ) nodetype='ordinary'; break;;
#     esac
# done







