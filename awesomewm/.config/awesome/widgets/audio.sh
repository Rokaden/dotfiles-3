#!/bin/sh

audio_card=""
volume=""
alsa=""
pulse=""
log_file="/tmp/audio.log"
log=false # true or false
time=$(date)

log() {
  if [ $log ] ; then
    echo "$time - $1" >> $log_file
  fi
}

die() {
  log "[DIE]: $1"
  exit 1
}

detect_bin() {
  alsa=$(which amixer 2>/dev/null 2>&1)
  pulse=$(which pactl 2>/dev/null 2>&1)
  log "detect_bin - alsa : $alsa , pulse : $pulse"
  if [[ ! -x $alsa ]] && [[ ! -x $pulse ]] ; then
	  die "detect_bin - fail to detect amixer or pulse"
  fi
}

check_audio_card() {
  local card
  if card=$(cat /proc/asound/card*/id | grep -i "^$1$") ; then
    audio_card=$1
  fi
}

for_pulse() {
  local sink
  log "Attemp with pulse $pulse"
  sink=$($pulse list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,')
  volume=$($pulse list sinks | grep '^[[:space:]]Volume:' | head -n $(( $sink + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
  if [[ ! -z $sink ]] && [[ ! -z $volume ]] ; then
    echo "pactlPulse$1: $volume%"
    return 0
  fi
  die "Card no found with pulse s:$sink - n:$now -a:$1"
}

for_alsa() {
  local p a
  log "Attemp with alsa $alsa"
  p=$($alsa -c $1 -M -D pulse sget Master 2>/dev/null | grep -o -E "[[:digit:]]+%" | head -n 1)
  a=$($alsa -c $1 -M get Master 2>/dev/null | grep -o -E "[[:digit:]]+%" | head -n 1)

  if [ ! -z $p ] ; then
    echo "amixerPulse$1: $p"
    return 0
  elif [ ! -z $a ] ; then
    echo "amixerAlsa$1: $a"
    return 0
  fi
  die "ALSA - No found with $alsa and $1 , p:<<  $p >>, a:<< $a >>"
}

alsa_or_pulse() {
  if [[ -x $pulse ]] ; then
    for_pulse
  elif [[ -x $alsa ]] ; then
    for_alsa $1
  else
	  die "No found $alsa or $pulse"
  fi
}

# Check first a card given as argument else try card n2 or n1
show_volume() {
	detect_bin
  if [ ! -z $audio_card ] ; then
    alsa_or_pulse $audio_card
  elif alsa_or_pulse 2 ; then
    echo
  elif alsa_or_pulse 1 ; then
    echo
  elif alsa_or_pulse 0 ; then
    echo
  else
    die "volume no found with amixer"
  fi
}

music_state() {
  local music_info
  [ -z $MPC ] && die "mpc no found"
  if music_info=$($MPC | grep "\[" | awk '{print $3,$4}' | tr -d '()') ; then
    echo "$music_info"
  fi
}

case $1 in
  volume) 
    check_audio_card $2
    show_volume $2
    shift
    shift
    ;;
  music)
    music_state
    shift
    ;;
  *)
    die "arg: $1 not recognized"
esac

exit 0
