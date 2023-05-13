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
if [ $EUID -ne 0 ]; then
  echo "Niesi root"
  read -p "zadaj heslo pre roota: " heslo
   sudo su -
fi
echo "stahujem blackarch plugin a programy"
curl -O https://blackarch.org/strap.sh
if [ $? -eq 0 ]; then
    echo "stahovanie priebehlo uspesne"
else
    echo "pri stahovani doslo ku chybe.."
    echo "skuste restartovat skript"
fi
#Kontrolny sucet SHA1
echo 5ea40d49ecd14c2e024deecf90605426db97ea0c strap.sh | sha1sum -c
if [ $? -eq 0 ]; then
    chmod +x strap.sh
#spustanie skriptu pre instalaciu Blackarch repositara a jeho pluginov
     ./strap.sh
    else
        echo "niekde nastala chyba skuste znova spustit skript ako root"
fi
echo "pridavam BlackArch repositar do pacman manazera.."
echo "[blackarch]" |  tee -a /etc/pacman.conf > /dev/null
echo "SigLevel = Optional TrustedOnly" |  tee -a /etc/pacman.conf > /dev/null
echo "Server = https://ftp.icm.edu.pl/pub/Linux/dist/blackarch/\$repo/os/\$arch|ICMuniversity" |  tee -a /etc/pacman.conf > /dev/null
 pacman -Syy #synchronizacia repositarov
#instalacia novych nastrojov pre pentesting a zabezpecenie
skenery=("nmap" "masscan" "openvas" "zenmap" "nikto" "wireshark")
exploitacia=("metasploit" "exploitdb" "msfpc" "sqlmap" "wpscan" "armitage")
reverzne_inzinierstvo=("radare2" "ghidra" "hopper" "binwalk")
lamace_sifier=("hydra" "john" "hashcat" "cewl" "crowbar")
word_listy=("wordlists")
bezdrotove_zariadenia=("aircrack-ng" "reaver" "mdk3" "bully" "fluxion" "bettercap")
webove_apky=("burpsuite" "owasp-zap" "sqliv" "dirb" "sqlninja")
ochrana=("terminator" "snort" "ossec" "tripwire" "fail2ban" "logwatch" "ufw")
echo "spustam instalaciu..."
for program in "${skenery[@]}" "${exploitacia[@]}" "${lamace_sifier[@]}" "${bezdrotove_zariadenia[@]}" "${webove_apky[@]}" "${ochrana[@]}" "${reverzne_inzinierstvo[@]}"
do
echo "instalujem $program...."
 pacman -S --noconfirm "$program"
    if [ $? -eq 0 ]; then
        echo "program $program bol uspesne nainstalovany"
    else
        echo "program $program nebol uspesne nainstalovany"
        echo "skusim pouzit yay"
         yay -S --noconfirm "$program"
        if [ $? -eq 0 ]; then
        echo "program $program bol uspesne nainstalovany"
        else
        echo "program $program nebol uspesne nainstalovany"
        fi

    fi
done
echo "spustam firewall"
systemctl enable ufw
read -p "chcete povolit nejake vase spojenia, ktore firewall nebude blokovat ? Y/n: " pov
if [ "$pov" == "Y" ] || [ "$pov" == y ]; then
while true; do
read -p "zadajte prosim IP adresu zariadenia,pre ktore chcete povolit spojenie: " IP
read -p "zadajte port, ktory chcete pouzit: " port
     ufw allow from $IP to any port $port
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
   mkdir /home/$adresar #vytvorenie adresaru
  echo "nastavujem pristup a permissions"
   chown root:users /home/$adresar #nastavenie ownershipu iba pre root a users group
   chmod 770 /home/$adresar #permissions wrx pre root a users group
  echo "zdielany priecinok bol uspesne vytvoreny.."
  elif [ "$priecinok" == "n" ] || [  "$priecinok" == "N" ]; then
  echo "..."
else
  echo "Neplatny vstup. Prosim zadaj y alebo n."
fi
read -p "Prosim zadajte pocet pouzivatelov, ktorych chcete vytvorit" uzivatelia
for ((i=1;i<=$uzivatelia;i++)); do # vytvorenie uzivatelov
    read -p "Zadajte meno pre uzivatela $i: " meno
    read -p "Zadajte heslo pre uzivatela $i: " heslo
     useradd -m -s /bin/bash $meno && echo "$heslo" |  passwd $meno #vytvori noveho pouzivatela
    echo "Vytvaram osobitny priecinok s pravami pre pouzivatela $meno.."
    read -p "zadajte nazov pre vas osobitny adresar: " adresar2
     mkdir/home/$meno/$adresar2
     chown
     chown $meno:$meno /home/$meno/$adresar2
     chmod 700 /home/$meno/$adresar2
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
                         usermod -aG users $meno
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

echo "koniec instalacie"

