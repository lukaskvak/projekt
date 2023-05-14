#!/bin/bash
#instalacia a nastavenie BLACKARCH repositaru
echo "overujem internetove pripojenie"
 ping -c 1 google.com > /dev/null
  if [ $? -eq 0 ]; then
    echo "Pripojenie na internet je k dispozicii."
  else
    echo "Nie je k dispozicii pripojenie na internet."
    exit 1
  fi
echo "Kontrola ci ste ROOT"
if [ $(id-u) -eq 0 ]; then
  echo "Niesi root"
  echo "zadaj 2x heslo pre roota: "
 sudo -s
fi
echo "stahujem blackarch"
curl -O https://blackarch.org/strap.sh
#Kontrolny sucet SHA1
echo "5ea40d49ecd14c2e024deecf90605426db97ea0c strap.sh" | sha1sum -c
if [ $? -eq 0 ]; then
    chmod +x strap.sh
#spustanie skriptu pre instalaciu Blackarch repositara a jeho pluginov
    echo "pridavam BlackArch repositar do pacman manazera.."
    sudo ./strap.sh
    else
        echo "niekde nastala chyba skuste znova spustit skript ako root"
fi
#echo "[blackarch]" | sudo tee -a /etc/pacman.conf > /dev/null
#echo "SigLevel = Optional TrustedOnly" | sudo tee -a /etc/pacman.conf > /dev/null
#echo "Server = https://ftp.icm.edu.pl/pub/Linux/dist/blackarch/\$repo/os/\$arch|ICMuniversity" | sudo tee -a /etc/pacman.conf > /dev/null
sudo pacman -Syyu #synchronizacia repositarov
#instalacia novych nastrojov pre pentesting a zabezpecenie
skenery=("nmap" "masscan" "openvas" "zenmap" "nikto" "wireshark")
exploitacia=("metasploit" "exploitdb" "msfpc" "sqlmap" "wpscan" "armitage")
reverzne_inzinierstvo=("radare2" "ghidra" "hopper" "binwalk")
lamace_sifier=("hydra" "john" "hashcat" "cewl" "crowbar")
bezdrotove_zariadenia=("aircrack-ng" "reaver" "mdk3" "bully" "fluxion" "bettercap")
webove_apky=("burpsuite" "gobuster" "sqlib" "dirb" "sqlninja")
ochrana=("terminator" "snort" "empire" "tripwire" "fail2ban" "logwatch" "ufw")
misc=("wordlists" "libvirt" "qemu")
echo "spustam instalaciu..."
echo "POZOR PRE NIEKTORE PROGRAMY POTREBUJES YAY"
echo "ROOT NEMOZE POUZIVAT YAY"
echo "ZADAJ PROSIM MENO BEZNEHO UZIVATELA KTOREHO POUZIJEME: "
read tmpusr
 if [ $? -eq 0 ]; then

for program in "${skenery[@]}" "${exploitacia[@]}" "${lamace_sifier[@]}" "${bezdrotove_zariadenia[@]}" "${webove_apky[@]}" "${ochrana[@]}" "${reverzne_inzinierstvo[@]}"
do
echo "instalujem $program...."
sudo pacman -S --noconfirm "$program"
    if [ $? -eq 0 ]; then
        echo "program $program bol uspesne nainstalovany"
    else
        echo "program $program nebol uspesne nainstalovany"
        echo "skusim pouzit yay"
        sudo -u $tmpusr yay -S --noconfirm "$program"
        if [ $? -eq 0 ]; then
        echo "program $program bol uspesne nainstalovany"
        else
        echo "program $program nebol uspesne nainstalovany"
        fi

    fi
done
fi
echo "spustam firewall"
systemctl enable ufw
read -p "chcete povolit nejake vase spojenia, ktore firewall nebude blokovat ? Y/n: " pov
if [ "$pov" == "Y" ] || [ "$pov" == "y" ]; then
while true; do
read -p "zadajte prosim IP adresu zariadenia,pre ktore chcete vypnut firewall: " IP
read -p "zadajte port, ktory planujete pouzivat: " port
    sudo ufw allow from $IP to any port $port
    echo "spojenie bolo uspesne pridane"
    read -p "chcete pridat dalsie spojenie ? Y/n: " repeat
    if [ "$repeat" == "n" ] || [ "$repeat" == "N" ]; then
    break
    fi
done
fi
#vytvorenie pouzivatelov a nastavenie zdielaneho adresara
read -p "Chcete vytvorit zdielany priecinok ? Y/n: " priecinok
if [ "$priecinok" == "y" ] || [ "$priecinok" == "Y"  ]; then
  read -p "Prosim zadajte meno pre zdielany priecinok: " adresar
  echo "Vytvaram priecinok $adresar..."
  sudo mkdir /home/$adresar #vytvorenie adresaru
  echo "nastavujem pristup a permissions"
  sudo groupadd SPECIAL
  sudo chown root:SPECIAL /home/$adresar #nastavenie ownershipu iba pre root a users group
  sudo chmod 770 /home/$adresar #permissions wrx pre root a users group
  echo "zdielany priecinok bol uspesne vytvoreny.."
  elif [ "$priecinok" == "n" ] || [  "$priecinok" == "N" ]; then
  echo "..."
else
  echo "Neplatny vstup. Prosim zadaj y alebo n."
fi
read -p "Prosim zadajte pocet pouzivatelov, ktorych chcete vytvorit" uzivatelia
for((i=1;i<=$uzivatelia;i++)); do # vytvorenie uzivatelov
    read -p "Zadajte meno pre uzivatela $i: " meno
    sudo useradd -m -s /bin/bash $meno
    echo "Zadajte 2x heslo pre uzivatela $i: "
    sudo passwd $meno #zahesluje noveho pouzivatela
    echo "Vytvaram osobitny priecinok s pravami pre pouzivatela $meno.."
    read -p "zadajte nazov pre vas osobitny adresar: " adresar2
    sudo mkdir/home/$meno/$adresar2
    sudo chown $meno:$meno /home/$meno/$adresar2
    sudo chmod 700 /home/$meno/$adresar2
    if [ $? -eq 0 ]; then
        echo "vytvorenie vaseho adresara: $adresar2 bolo uspesne"
        echo "pre adresar ma vsetky povolenia iba pouzivatel pre, ktoreho je adresar urceny.."
    else
        echo "vytvorenie adresara: $adresar2 bolo neuspesne"
    #moznost pristupu do zdielaneho priecinku
    echo "chcete mat pristup do zdielaneho priecinku ? Y/n: "
    read ch
            case $ch in
                    y | Y)
                        echo "Umoznujem pristup pre $meno"
                        sudo usermod -aG SPECIAL $meno
                            if [ $? -eq 0 ]; then
                        echo "Pouzivatel $meno ma pristup do /home/$adresar..."
                            else
                        echo "Nastala chyba"

                            fi
                        ;;
                    n | N)
                        echo "Neumoznujem pristup do /home/$adresar..."
                        ;;
                        *)
                        echo "Niekde nastala chyba skuste skript spustit znovu ako root"
                        esac

    fi
    echo "chcete si prednastavit virtualny stroj,ktory budete mat na testovanie ? Y/n: "
    read choice
            case $choice in
                    y | Y)
                        echo "vytvaram virtualny stroj  pre $meno"
                        sudo usermod -aG libvirt $meno
                        sudo usermod -aG libvirt-qemu $meno
                        systemctl enable libvirt.service
                        systemctl start libvirt.service 
                        mkdir /home/$meno/virtualnystroj
                        cd /home/$meno/virtualnystroj
                        echo "zadajte ISO disk image pre vas virtualny stroj: "
                        read vimISO
                        echo "zadajte Pamat RAM pre vas virtualny stroj: "
                        read vimRAM
                        echo "zadajte velkost pre ulozny priestor vaseho virtualneho stroja :  G"
                        read vimDISK
                        echo "overujem ci vasa CPU podporuje virtualizaciu.."
                           if grep -o 'vmx\|svm' /proc/cpuinfo > /dev/null; then
                        echo "Vase zariadenie podporuje virtualizaciu"
                        echo "Vytvaram novy virtualny stroj"
                            qemu-img create -f qcow2 mydisk.qcow2 "${vimDISK}G"
                            qemu-system-x86_64 -enable-kvm -m "$vimRAM" -cdrom "$vimISO" -drive file=mydisk.qcow2,if=virtio -netdev user,id=user0 -device virtio-net-pci,netdev=user0
                            echo "vytvaram skript launch_vm.sh, ktorym budete moct spustat virtualny stroj"
                            echo "#!/bin/bash" > launch_vm.sh
                             echo "qemu-system-x86_64 -enable-kvm -m $vimRAM -drive file=mydisk.qcow2,if=virtio -netdev user,id=user0 -device virtio-net-pci,netdev=user0" >> launch_vm.sh
                            chmod +x launch_vm.sh
                             if [ $? -eq 0 ]; then
                             echo "skript launch_vm.sh bol uspesne vytvoreny.."
                             echo "najdete ho v $(pwd)/launch_vm.sh"
                             fi
                           else
                            echo "Vasa CPU nepodporuje virtualizaciu."
                            echo "Prosim zmente nastavenia uefi alebo biosu a restartuje."
                           fi
                        ;;
                    n | N)
                        echo "Neumoznujem pristup do /home/$adresar..."
                        ;;
                        *)
                        echo "Niekde nastala chyba skuste skript spustit znovu ako root"
                        esac

    fi

    done

echo "koniec instalacie"

