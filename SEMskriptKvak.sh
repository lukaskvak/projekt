#!/bin/bash
#instalacia a nastavenie BLACKARCH repositaru

#stiahnutie skriptu
curl -O https://blackarch.org/strap.sh
#overenie SHA1 klucu
echo 5ea40d49ecd14c2e024deecf90605426db97ea0c strap.sh | sha1sum -c
if [ $? -eq 0 ]; then
    chmod +x strap.sh
#spustanie skriptu pre instalaciu Blackarch repositara a jeho pluginov
    sudo ./strap.sh
    else
        echo "niekde nastala chyba skuste znova spustit skript ako root"
fi
echo "pridavam BlackArch repositar do pacman manazera.."
echo "[blackarch]" | sudo tee -a /etc/pacman.conf > /dev/null
echo "SigLevel = Optional TrustedOnly" | sudo tee -a /etc/pacman.conf > /dev/null
echo "Server = https://ftp.icm.edu.pl/pub/Linux/dist/blackarch/\$repo/os/\$arch|ICMuniversity" | sudo tee -a /etc/pacman.conf > /dev/null
#vytvorenie pouzivatelov a nastavenie zdielaneho adresara
read -p "Chcete vytvorit zdielany priecinok ? Y/n: " priecinok
if [ "$priecinok" == "y" ] || [ "$priecinok" == "Y"  ]; then
  read -p "Prosim zadajte meno pre zdielany priecinok: " adresar
  echo "Vytvaram priecinok $adresar..."
  sudo mkdir /home/$adresar #vytvorenie adresaru
  echo "nastavujem pristup a permissions"
  sudo chown root:users /home/$adresar #nastavenie ownershipu iba pre root a users group
  sudo chmod 770 /home/$adresar #permissions wrx pre root a users group
elif [ "$priecinok" == "n" ] || [  "$priecinok" == "N" ]; then
  echo "..."
else
  echo "Neplatny vstup. Prosim zadaj y alebo n."
fi
read -p "Prosim zadajte pocet pouzivatelov, ktorych chcete vytvorit" uzivatelia
for((i=1;i<=$uzivatelia;i++)); do # vytvorenie uzivatelov
    read -p "Zadajte meno pre uzivatela $i: " meno
    read -p "Zadajte heslo pre uzivatela $i: " heslo
    sudo useradd -m -s /bin/bash $meno && echo "$heslo" | sudo passwd $meno #vytvori noveho pouzivatela
    #moznost pristupu do zdielaneho priecinku
    echo "chcete mat pristup do zdielaneho priecinku ? Y/n: "
    read ch
            case $ch in
                    y | Y)
                        echo "Umoznujem pristup pre $meno"
                        sudo usermod -aG users $meno
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


done
sudo pacman -Syyu #synchronizacia repositarov
#instalacia novych nastrojov pre pentesting a zabezpecenie
skenery=("nmap" "masscan" "openvas" "zenmap" "nikto")
exploitacia=("metasploit" "msfpc" "sqlmap" "wpscan" "armitage")
lamace_sifier=("hydra" "john" "hashcat" "cewl" "crowbar")
bezdrotove_zariadenia=("aircrack-ng" "reaver" "mdk3" "bully" "fluxion")
webove_apky=("burpsuite" "owasp-zap" "sqliv" "dirb" "sqlninja")
ochrana=("snort" "ossec" "tripwire" "fail2ban" "logwatch")
echo "spustam instalaciu..."
for program in "${skenery[@]}" "${exploitacia[@]}" "${lamace_sifier[@]}" "${bezdrotove_zariadenia[@]}" "${webove_apky}[@]}" "${ochrana[@]}"
do
echo "instalujem $program...."
sudo pacman -S --noconfirm "$program"
    if [ $? -eq 0 ]; do
        echo "program $program bol uspesne nainstalovany"
    else
        echo "program $program nebol uspesne nainstalovany"
    fi
done
echo "koniec instalacie"

