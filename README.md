# gentoo-deploy
A deploy script to install Gentoo Linux on a new machine or VirtualMachine<br>
Warning !!! [IT WILL WIPE YOUR DRIVE] !!!<br>
Anything goes wrong, its your fault! :)<br>

1. Boot a new machine or virtual machine with the Gentoo Live ISO <br>
2. Verify internet access <br>
<br>
Grab and run setup script <br>
3. $ curl https://raw.githubusercontent.com/smurfd/gentoo-deploy/main/setup.sh -o setup.sh
4. $ sh ./setup.sh IP DNS NIS Host IF HD HDD usr pwd <br>
   example : <br>
   $ sh ./setup.sh 192.168.0.2 monkey island ghost enp2s0 /dev/sda /dev/nvme0n1 blowfish blowfishpwd <br>
<br>
<br>
Made it for me, You find it useful? Use at own risk<br>
<br>
Please, give it a shot in a VirtualMachine first<br>
(anything happens after you download the script... ITS YOUR FAULT!)<br>
<br>
<br>
<br>
... did i mention, anything goes wrong, its your fault.
