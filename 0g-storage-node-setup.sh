#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "root is required."
    echo "Please use sudo -i switch to root account and rerun the script"
    exit 1
fi

# Function to install environment
function install_environment() {
    # 1. System updates, installation of required environments
    sudo apt-get update
    sudo apt-get install clang cmake build-essential
    sudo apt-get install git
    sudo apt-get install npm

    # 2. Install go (If it is the same node as the validator node, you can PASS)
    wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    
    # 3. Install pm2
    npm install -g pm2
    
    # 4. Install rustup (When the selection for 1, 2, or 3 appears, just press Enter.)
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    
    # 5. Git clone
    git clone -b v0.2.0 https://github.com/0glabs/0g-storage-node.git

    # 6. Build
    cd $HOME/0g-storage-node
    git submodule update --init
    sudo apt install cargo
    cargo build --release
    
    # 7. Setup variables
    echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
    echo 'export ZGS_LOG_CONFIG_FILE="$HOME/0g-storage-node/run/log_config"' >> ~/.bash_profile
    echo 'export LOG_CONTRACT_ADDRESS="0x2b8bC93071A6f8740867A7544Ad6653AdEB7D919"' >> ~/.bash_profile
    echo 'export MINE_CONTRACT="0x228aCfB30B839b269557214216eA4162db24445d"' >> ~/.bash_profile
    source ~/.bash_profile
    echo -e "ZGS_LOG_DIR: $ZGS_LOG_DIR\nZGS_LOG_CONFIG_FILE: $ZGS_LOG_CONFIG_FILE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT"
    
    # 8. Type and store your private key
    read -p "Enter your private key: " PRIVATE_KEY && echo
    sed -i 's|miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|' $HOME/0g-storage-node/run/config.toml
    
    # 9. Update your config.toml
    sed -i 's|# log_config_file = "log_config"|log_config_file = "'"$ZGS_LOG_CONFIG_FILE"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# log_directory = "log"|log_directory = "'"$ZGS_LOG_DIR"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|mine_contract_address = ".*"|mine_contract_address = "'"$MINE_CONTRACT"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|log_contract_address = ".*"|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|blockchain_rpc_endpoint = "https://rpc-testnet.0g.ai"|blockchain_rpc_endpoint = "https://0g-evm.rpc.nodebrand.xyz"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# network_dir = "network"|network_dir = "network"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# network_libp2p_port = 1234|network_libp2p_port = 1234|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmPxGNWu9eVAQPJww79J32pTJLKGcpjRMb4Qb8xxKkyuG1","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAm93Hd5azfhkGBbkx1zero3nYHvfjQYM2NtiW4R3r5bE2g"\]|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS"\]|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# db_dir = "db"|db_dir = "db"|' $HOME/0g-storage-node/run/config.toml
}

# Function to install 0g storage node
function install-0g-storage-node() {
    install_environment
}

# Function to start 0g storage node
function start-storage-node() {
    # Start pm2
    cd
    cd 0g-storage-node/run/
    pm2 start ../target/release/zgs_node -- --config config.toml
}

# Function to stop 0g storage node
function stop-storage-node() {
    # Stop pm2
    pm2 delete zgs_node 
}

# Function to show logs of 0g storage node
function show-log-storage-node(){
    # Show logs
    pm2 logs
}

# Function to remove 0g storage node
function remove-storage-node(){
    cd
    rm -r -f 0g-start-storage-node
}

# Main menu function
function menu() {
    while true; do
        echo "########Twitter: @jleeinitianode########"
        echo "1. Install 0g storage node"
        echo "2. Start pm2 / 0g storage node"
        echo "3. Stop pm2 / 0g storage node"
        echo "4. Show log pm2 / 0g storage node"
        echo "5. Remove 0g storage node"
        echo "6. Exit"
        echo "#############################################################"
        read -p "Select function: " choice
        case $choice in
        1)
            install-0g-storage-node
            ;;
        2)
            start-storage-node
            ;;      
        3)
            stop-storage-node
            ;;      
        4)
            show-log-storage-node
            ;;      
        5)
            remove-storage-node
            ;;      
        6)
            break
            ;;
        *)
            echo "Choice function again"
            ;;
        esac
    done
}

# Call the menu function
menu
