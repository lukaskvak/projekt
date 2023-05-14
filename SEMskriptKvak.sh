#!/bin/bash
#instalacia a nastavenie BLACKARCH repositaru
echo "##########################################"
echo "overujem internetove pripojenie"
echo "##########################################" 
 ping -c 1 google.com > /dev/null
  if [ $? -eq 0 ]; then
    echo "Pripojenie na internet je k dispozicii."
  else
    echo "##########################################"
    echo "Nie je k dispozicii pripojenie na internet."
    echo "##########################################"
    exit 1
  fi
echo "##########################################"  
echo "Kontrola ci ste ROOT"
echo "##########################################"
if [ $EUID -ne 0 ]; then
  echo "##########################################"
  echo "Niesi root"
  echo "##########################################"
  echo "##########################################"
  read -p "zadaj heslo pre roota: " heslo
  echo "##########################################"
   echo $heslo | sudo su root
fi
echo "##########################################"
echo "stahujem blackarch plugin a programy"
echo "##########################################"
curl -O https://blackarch.org/strap.sh
if [ $? -eq 0 ]; then
echo "##########################################"
    echo "stahovanie priebehlo uspesne"
echo "##########################################"
else
echo "##########################################"
    echo "pri stahovani doslo ku chybe.."
echo "##########################################"
echo "##########################################"
    echo "skuste restartovat skript"
echo "##########################################"    
fi
#Kontrolny sucet SHA1
echo "Prebiaha kontrola SHA1 blackarch klucu"
echo 5ea40d49ecd14c2e024deecf90605426db97ea0c strap.sh | sha1sum -c
if [ $? -eq 0 ]; then
echo "##########################################"
echo "Kontrola prebehla uspesne"
echo "##########################################"
echo "Instalujem BlackArch"
echo "##########################################"
    chmod +x strap.sh
#spustanie skriptu pre instalaciu Blackarch repositara a jeho pluginov
     ./strap.sh
    else
       echo "###########################################################"
        echo "niekde nastala chyba skuste znova spustit skript ako root"
       echo "###########################################################"
fi
echo "##########################################"
echo "pridavam BlackArch repositar do pacman manazera.."
echo "##########################################"
#echo "[blackarch]" |  tee -a /etc/pacman.conf > /dev/null
#echo "SigLevel = Optional TrustedOnly" |  tee -a /etc/pacman.conf > /dev/null
#echo "Server = https://ftp.icm.edu.pl/pub/Linux/dist/blackarch/\$repo/os/\$arch|ICMuniversity" |  tee -a /etc/pacman.conf > /dev/null
 pacman -Syy #synchronizacia repositarov
#instalacia novych nastrojov pre pentesting a zabezpecenie
skenery=("nmap" "masscan" "openvas" "zenmap" "nikto" "wireshark")
exploitacia=("metasploit" "exploitdb" "msfpc" "sqlmap" "wpscan" "armitage")
reverzne_inzinierstvo=("radare2" "ghidra" "hopper" "binwalk")
lamace_sifier=("hydra" "john" "hashcat" "cewl" "crowbar")
word_listy=("wordlists" "gemu" )
bezdrotove_zariadenia=("aircrack-ng" "reaver" "mdk3" "bully" "fluxion" "bettercap")
webove_apky=("burpsuite" "gobuster" "sqlmap" "dirb" "sqlninja")
ochrana=("terminator" "snort" "ossec" "tripwire" "fail2ban" "logwatch" "ufw")
echo "spustam instalaciu..."
 echo "##########################################"
        echo "yay nemsie bezat ako root preto zadajte meno bezneho uzivatela"
        echo "zadajte meno pouzivatela, ktoreo pouzijeme pre yay: "
        read tmpuzi
for program in "${skenery[@]}" "${exploitacia[@]}" "${lamace_sifier[@]}" "${bezdrotove_zariadenia[@]}" "${webove_apky[@]}" "${ochrana[@]}" "${reverzne_inzinierstvo[@]}"
do
echo "instalujem $program...."
 pacman -S --noconfirm "$program"
    if [ $? -eq 0 ]; then
        echo "##########################################"
        echo "program $program bol uspesne nainstalovany"
        echo "##########################################"
    else
        echo "##########################################"
        echo "program $program nebol uspesne nainstalovany"
        echo "##########################################"
        echo "skusim pouzit yay"
       
        sudo -u $tmpuzi yay -S --noconfirm "$program"
        if [ $? -eq 0 ]; then
        echo "##########################################"
        echo "program $program bol uspesne nainstalovany"
        echo "##########################################"
        else
        echo "##########################################"
        echo "program $program nebol uspesne nainstalovany"
        echo "##########################################"
        fi

    fi
done


echo "##########################################"
echo "spustam firewall"
echo "##########################################"
systemctl enable ufw
if [ $? -eq 0 ]; then
echo "##########################################"
 echo "firewall je uspesne zapnuty"
 echo "##########################################"
else
echo "##########################################"
 echo "chyba pri zapnuti firewallu"
 echo "##########################################"
 fi
 echo "###################################################################################"
read -p "chcete povolit nejake vase spojenia, ktore firewall nebude blokovat ? Y/n: " pov
echo "####################################################################################"
if [ "$pov" == "Y" ] || [ "$pov" == y ]; then
while true; do
echo "##############################################################################"
read -p "zadajte prosim IP adresu zariadenia,pre ktore chcete povolit spojenie: " IP
echo "##############################################################################"
read -p "zadajte port, ktory chcete pouzit: " port
echo "##############################################################################"
     ufw allow from $IP to any port $port
     if [ $? -eq 0 ]; then
 echo "##########################################"    
 echo "nove spojenie bolo uspesne pridane"
 echo "##########################################"
     else
 echo "##########################################"    
 echo "chyba pri pridani spojenia"
 echo "##########################################"
     fi
     echo "###############################################"
    read -p "chcete pridat dalsie spojenie ? Y/n: " repeat
     echo "###############################################"
    if [ "$repeat" == "n" ] || [ "$repeat" == "N" ]; then
    break
    fi
done
fi
#vytvorenie pouzivatelov a nastavenie zdielaneho adresara
echo "#########################################################"
read -p "Chcete vytvorit zdielany priecinok ? Y/n: " priecinok
echo "#########################################################"
if [ "$priecinok" == "y" ] || [ "$priecinok" == "Y"  ]; then
echo "#########################################################"
  read -p "Prosim zadajte meno pre zdielany priecinok: " adresar
echo "#########################################################"
  echo "Vytvaram priecinok $adresar..."
echo "##########################################"
   mkdir /home/$adresar #vytvorenie adresaru
echo "##########################################"
  echo "nastavujem pristup a permissions"
echo "##########################################"
chown root:users /home/$adresar #nastavenie ownershipu iba pre root a users group
chmod 770 /home/$adresar #permissions wrx pre root a users group
echo "zdielany priecinok bol uspesne vytvoreny.."
 elif [ "$priecinok" == "n" ] || [  "$priecinok" == "N" ]; then
echo "##########################################"
echo "Preskakujem tvorbu zdielaneho priecinku..."
echo "##########################################"
 else
echo "##########################################"
echo "Neplatny vstup. Prosim zadaj y alebo n."
echo "##########################################"
fi
echo "################################################################"
read -p "Prosim zadajte pocet pouzivatelov, ktorych chcete vytvorit" uzivatelia
echo "################################################################"
for ((i=0;i<=$uzivatelia;i++)); do # vytvorenie uzivatelov
echo "##########################################"
read -p "Zadajte meno pre uzivatela $i: " meno
echo "##########################################"
read -p "Zadajte heslo pre uzivatela $i: " heslo
echo "##########################################"
useradd -m -s /bin/bash $meno && echo "$heslo" |  passwd $meno #vytvori noveho pouzivatela
echo "######################################################"
echo "Vytvaram osobitny priecinok s pravami pre pouzivatela $meno.."
echo "######################################################"
    read -p "zadajte nazov pre vas osobitny adresar: " adresar2
echo "######################################################"
     mkdir/home/$meno/$adresar2
     chown $meno:$meno /home/$meno/$adresar2
     chmod 700 /home/$meno/$adresar2
    if [ $? -eq 0 ]; then
    echo "##########################################################"
        echo "vytvorenie vaseho adresara: $adresar2 bolo uspesne"
    echo "##########################################################"    
        echo "###################################################################################"
        echo "pre adresar ma vsetky povolenia iba pouzivatel pre, ktoreho je adresar urceny.."
        echo "###################################################################################"
    else
    echo "###################################################"
        echo "vytvorenie adresara: $adresar2 bolo neuspesne"
    echo "###################################################"    
    #moznost pristupu do zdielaneho priecinku
    echo "chcete mat pristup do zdielaneho priecinku ? Y/n: "
    read ch
            case $ch in
                    y | Y)
                        echo "##########################################"
                        echo "Umoznujem pristup pre $meno"
                        echo "##########################################"
                         usermod -aG users $meno
                            if [ $? -eq 0 ]; then
                        echo "#################################################"    
                        echo "Pouzivatel $meno ma pristup do /home/$adresar..."
                        echo "#################################################"
                            else
                        echo "##########################################"    
                        echo "Nastala chyba"
                        echo "##########################################"

                            fi
                        ;;
                    n | N)
                        echo "##########################################"                   
                        echo "Neumoznujem pristup do /home/$adresar..."
                        echo "##########################################"
                        ;;
                        *)
                        echo "##########################################"
                        echo "Niekde nastala chyba skuste skript spustit znovu ako root"
                        echo "##########################################"
                        esac

      fi
done
echo "##########################################"
echo "koniec instalacie"
echo "##########################################"
