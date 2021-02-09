Get the install file onto your server:

# $ wget https://github.com/Carbon-Reduction-Initiative/mn-install/blob/master/cari-install.sh

# $ bash cari-install.sh

bash <( curl https://raw.githubusercontent.com/smuhter/mn-install/master/CARI_install_2MN.sh )

wait at step masternode private key

On CARI Wallet
Goto Masternode
click on Create Masternode Controller
Click next and enter a MN Address label e.g. CRI-MN1
click next and enter the IP of the VPS 
click next and then you will see the entry in the wallet window.
click on the 3 dots next to the MN name and click on info
click on "export data to run the masternode on a remote server"

Paste this in notepad so that you can copy the masternode private key

go back to VPS and enter the masternode private key you pasted above
hit enter

wait for 15 confirmations on the CRI-MN1 address and then start the MN from the wallet
