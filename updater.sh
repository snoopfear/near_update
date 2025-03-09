cd $HOME/nearcore && NEWTAG=$(curl -s https://api.github.com/repos/near/nearcore/releases/latest | grep 'tag_name' | cut -d '"' -f 4) && git fetch && git checkout "$NEWTAG"

cd $HOME/nearcore && make release

cd $HOME && sudo systemctl stop neard && rm /usr/local/bin/neard && cp "$HOME/nearcore/target/release/neard" /usr/local/bin/neard && sudo systemctl restart neard && echo "Текущая версия NEAR:" && neard --version && journalctl -n 100 -f -u neard | ccze -A | grep INFO
