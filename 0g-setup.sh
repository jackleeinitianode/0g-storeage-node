#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "root is required."
    echo "Please use sudo -i switch to root account and rerun the script"
    exit 1
fi

# Function to install required environment
function install_environment() {
    # 1. System updates, installation of required environments
    sudo apt-get update
    sudo apt-get install clang cmake build-essential
    sudo apt install git
    
    # 2. Install go
    wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    
    # 3. Install pm2
    npm install -g pm2
    
    # 4. Install rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    
    # 5. Git clone
    git clone https://github.com/0glabs/0g-storage-node.git
    
    # 6. Build
    cd $HOME/0g-storage-node
    git submodule update --init
    sudo apt install cargo
    cargo build --release
    
    # 7. Setup environment variables
    echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
    echo 'export ZGS_LOG_CONFIG_FILE="$HOME/0g-storage-node/run/log_config"' >> ~/.bash_profile
    echo 'export LOG_CONTRACT_ADDRESS="0x2b8bC93071A6f8740867A7544Ad6653AdEB7D919"' >> ~/.bash_profile
    echo 'export MINE_CONTRACT="0x228aCfB30B839b269557214216eA4162db24445d"' >> ~/.bash_profile
    source ~/.bash_profile
    echo -e "ZGS_LOG_DIR: $ZGS_LOG_DIR\nZGS_LOG_CONFIG_FILE: $ZGS_LOG_CONFIG_FILE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT"
    
    # 8. Extract and store private_key
    # Type and store your private key
    read -sp "Enter your private key: " PRIVATE_KEY && echo
    sed -i 's|miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|' $HOME/0g-storage-node/run/config.toml
    
    # 9. Update config.toml
    sed -i 's|# log_config_file = "log_config"|log_config_file = "'"$ZGS_LOG_CONFIG_FILE"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# log_directory = "log"|log_directory = "'"$ZGS_LOG_DIR"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|mine_contract_address = ".*"|mine_contract_address = "'"$MINE_CONTRACT"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|log_contract_address = ".*"|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|blockchain_rpc_endpoint = "https://rpc-testnet.0g.ai"|blockchain_rpc_endpoint = "https://0g-evm.rpc.nodebrand.xyz"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# network_dir = "network"|network_dir = "network"|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# network_libp2p_port = 1234|network_libp2p_port = 1234|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmPxGNWu9eVAQPJww79J32pTJLKGcpjRMb4Qb8xxKkyuG1","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAm93Hd5azfhkGBbkx1zero3nYHvfjQYM2NtiW4R3r5bE2g"\]|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS"\]|' $HOME/0g-storage-node/run/config.toml
    sed -i 's|# db_dir = "db"|db_dir = "db"|' $HOME/0g-storage-node/run/config.toml
    
    # 10. Start pm2
    pm2 start ../target/release/zgs_node -- --config config.toml
}

# Function to install initial node
function install_initia() {
    install_environment
}

# Function for menu
function menu() {
    while true; do
        echo "######## Twitter: @jleeinitianode ########"
        echo "1. Install initia Node"
        echo "2. Exit"
        echo "#############################################################"
        read -p "Select function: " choice
        case $choice in
            1)
                install_initia
                ;;
            2)
                break
                ;;
            *)
                echo "Please choose a valid option."
                ;;
        esac
        read -p "Press any key to continue..."
    done
}

# Call the menu function
menu
