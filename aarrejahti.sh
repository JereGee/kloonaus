#!/usr/bin/env bash
# aarrejahti.sh – Linuxin perustaitojen aarteenetsintä
# Luo kotihakemistoon kansion ~/aarrejahti, jossa on vihjeiden ketju.
# Aja tavallisena käyttäjänä (EI sudolla):  bash aarrejahti.sh
# Uudelleenajo poistaa vanhan aarrejahdin ja luo uuden.

set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "Älä aja tätä sudolla tai root-käyttäjänä. Aja: bash aarrejahti.sh"
  exit 1
fi

AJ="$HOME/aarrejahti"

# Poista mahdollinen vanha aarrejahti (palauta ensin oikeudet, jotta poisto onnistuu)
if [ -d "$AJ" ]; then
  chmod -R u+rwX "$AJ" 2>/dev/null || true
  rm -rf "$AJ"
fi

mkdir -p "$AJ"
cd "$AJ"

# ---------- Vaihe 0: aloitus ----------
cat > LUEMINUT.txt <<'EOF'
Tervetuloa aarrejahtiin!

Aarre on piilotettu tähän hakemistoon vihjeiden taakse.
Jokainen vihje kertoo, mistä seuraava löytyy.

Ensimmäinen vihje on tässä samassa hakemistossa – mutta se on piilossa.
Linuxissa piilotiedoston nimi alkaa pisteellä.

Vinkki: komento ls näyttää tiedostot. Miten saat sen näyttämään myös piilotetut?
(Apua: ls --help tai man ls)
EOF

# ---------- Vaihe 1: piilotiedosto ----------
cat > .vihje1.txt <<'EOF'
VIHJE 1 löytyi!

Seuraava vihje on hakemistorakenteen syvyyksissä:
  arkisto/2026/marraskuu/

Siirry sinne komennolla cd ja katso, mitä siellä on.
Vinkki: Tab-näppäin täydentää hakemistojen nimet.
EOF

# ---------- Vaihe 2: hakemistorakenne ----------
for v in 2024 2025 2026; do
  for kk in syyskuu lokakuu marraskuu joulukuu; do
    mkdir -p "arkisto/$v/$kk"
    echo "Tässä ei ole mitään kiinnostavaa. Kokeile toista kansiota." > "arkisto/$v/$kk/muistio.txt"
  done
done
rm "arkisto/2026/marraskuu/muistio.txt"
cat > arkisto/2026/marraskuu/vihje2.txt <<'EOF'
VIHJE 2 löytyi!

Palvelimen lokitiedostossa on tuhansia rivejä:
  ~/aarrejahti/lokit/palvelin.log

Yksi riveistä sisältää sanan AVAIN. Se kertoo, missä seuraava vihje on.
Älä lue koko tiedostoa – etsi.

Vinkki: grep etsii tekstiä tiedostosta.
EOF

# ---------- Vaihe 3: lokitiedosto ja grep ----------
mkdir -p lokit
palvelut=(sshd cron kernel systemd nginx apt NetworkManager)
viestit=(
  "yhteys avattu"
  "yhteys suljettu"
  "ajastettu tehtävä suoritettu"
  "levytila tarkistettu"
  "palvelu käynnistetty uudelleen"
  "päivitykset haettu"
  "käyttäjä kirjautui"
  "verkkoliitäntä päivitetty"
)
{
  for i in $(seq 1 5000); do
    if   (( i % 137 == 0 )); then taso="ERROR"
    elif (( i % 11 == 0 ));  then taso="WARN "
    else                          taso="INFO "
    fi
    p=${palvelut[$(( i % ${#palvelut[@]} ))]}
    m=${viestit[$(( (i * 7) % ${#viestit[@]} ))]}
    tunti=$(( 8 + i / 625 ))
    min=$(( (i / 10) % 60 ))
    sek=$(( i % 60 ))
    if (( i == 3141 )); then
      printf "2026-11-02 %02d:%02d:%02d INFO  [aarre] AVAIN: seuraava vihje on tiedostossa ~/aarrejahti/salaisuus.txt\n" "$tunti" "$min" "$sek"
    else
      printf "2026-11-02 %02d:%02d:%02d %s [%s] %s (tapahtuma %d)\n" "$tunti" "$min" "$sek" "$taso" "$p" "$m" "$i"
    fi
  done
} > lokit/palvelin.log

# ---------- Vaihe 4: käyttöoikeudet ----------
cat > salaisuus.txt <<'EOF'
VIHJE 3 löytyi – sait lukuoikeuden kuntoon!

Komento ls -l näyttää oikeudet. Tämä tiedosto oli muotoa ---------- eli
kenelläkään ei ollut lukuoikeutta, ei edes omistajalla.

Seuraava vaihe: hakemistossa on skripti avaa.sh, joka avaa aarrearkun.
Se ei kuitenkaan suostu käynnistymään komennolla ./avaa.sh

Selvitä miksi ja korjaa asia. (Katso oikeudet komennolla ls -l)
EOF
chmod 000 salaisuus.txt

# ---------- Vaihe 5: suoritusoikeus ja ohjelman asennus ----------
cat > avaa.sh <<'EOF'
#!/usr/bin/env bash
# Aarrearkun avausskripti

echo "Aarrearkku narisee..."

if command -v cowsay >/dev/null 2>&1; then
  COW="cowsay"
elif [ -x /usr/games/cowsay ]; then
  COW="/usr/games/cowsay"
else
  echo
  echo "VIHJE 4: Arkku on lukossa. Avaimena toimii ohjelma nimeltä cowsay,"
  echo "jota ei ole vielä asennettu tähän koneeseen."
  echo
  echo "Asenna se paketinhallinnalla (tarvitset sudo-oikeudet) ja aja minut uudelleen:"
  echo "  ./avaa.sh"
  exit 1
fi

LIPPU="LIPPU{$(echo "$USER-$(hostname)" | sha256sum | cut -c1-8)}"
"$COW" "Onneksi olkoon $USER! Löysit aarteen. Koodisi: $LIPPU"
echo
echo "Kerro koodisi opettajalle."
echo "Ehditkö vielä? Lue tiedosto ~/aarrejahti/bonus.txt"
EOF
# avaa.sh jätetään tarkoituksella ilman suoritusoikeutta
chmod 644 avaa.sh

# ---------- Bonustehtävät ----------
cat > bonus.txt <<'EOF'
BONUSTEHTÄVÄT nopeimmille

B1. Montako ERROR-tasoista riviä tiedostossa lokit/palvelin.log on?
    (Vinkki: grep osaa myös laskea. Katso grep --help)

B2. Arkistoon on piilotettu tiedosto, jonka pääte on .bonus.
    Etsi se kirjoittamatta jokaista kansiota auki käsin.
    (Vinkki: find)

B3. Tee itsellesi alias, jolla komento  ll  näyttää  ls -la  -tulosteen.
    Lisää se tiedoston ~/.bashrc loppuun, jotta se säilyy.

B4. Asenna ohjelma tree ja tulosta koko aarrejahdin rakenne.
EOF
mkdir -p arkisto/2025/lokakuu/.vanhat
echo "B2 ratkaistu! Löysit piilotetun tiedoston komennolla find. Koodi: BONUS-FIND" > arkisto/2025/lokakuu/.vanhat/kadonnut.bonus

echo
echo "Aarrejahti on valmis!"
echo "Aloita näin:"
echo "  cd ~/aarrejahti"
echo "  cat LUEMINUT.txt"
