## gentoo-deploy
A deploy script to install Gentoo Linux on a new machine or VirtualMachine<br>
*<b>IT WILL WIPE YOUR DRIVE</b><br>
Anything goes wrong, its your fault! :)<br>

1. Boot a new machine or VM with the [Gentoo Live ISO](https://www.gentoo.org/downloads/)
2. Verify internet access : `ping www.gentoo.org`
3. Check what disk to use : `lsblk`
4. Check what network interface to use : `ip address`
5. Grab and run setup script <br>
   $ `curl https://raw.githubusercontent.com/smurfd/gentoo-deploy/main/setup.sh -o setup.sh`
6. $ `sh ./setup.sh 192.168.0.2 monkey island ghost enp2s0 /dev/sda /dev/sda blowfish blowfishpwd` <br>
          (`sh ./setup.sh IP DNS NIS Host IF HD HDD usr pwd` : pwd needs to be have both Aa1! kind of letters)
7. $ `touch isolomlyswearimuptono.good`
8. $ `sh ./deploy.sh`
<br>
# Deploy my shell configs
`curl -sSf https://raw.githubusercontent.com/smurfd/gentoo-deploy/main/deploy-shell.sh | sh`
<br>
Made it for me, You find it useful? Use at own risk<br>
<br>
Please, give it a shot in a VirtualMachine first<br>
(anything happens after you download the script... ITS YOUR FAULT!)<br>
<br>
<br>
<br>
... did i mention, anything goes wrong, its <b>your fault</b>.
