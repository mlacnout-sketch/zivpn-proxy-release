#!/system/bin/sh
# Credit by LeXX
# ZIVPN Core Service Script

MODDIR=${0%/*}
BIN=$MODDIR/system/bin
export LD_LIBRARY_PATH=$BIN
LOG=$MODDIR/proxy.log

# -- KONFIGURASI AKUN --
SERVER_IP="ISI_IP_DISINI"
PASS="ISI_PASSWORD_DISINI"
OBFS='hu``hqb`c'
# ----------------------

echo "[$(date)] Starting ZIVPN Core (Self-Contained)..." > $LOG

# 1. BERSIHKAN PROSES LAMA
pkill -f libuz
pkill -f libload

# 2. START HYSTERIA (4 Core)
echo "Starting 4 Hysteria cores..." >> $LOG
for PORT in 1080 1081 1082 1083; do
  # Buat config JSON on-the-fly
  CONFIG="{\"server\":\"$SERVER_IP:6000-19999\",\"obfs\":\"$OBFS\",\"auth\":\"$PASS\",\"socks5\":{\"listen\":\"127.0.0.1:$PORT\"},\"insecure\":true,\"recvwindowconn\":131072,\"recvwindow\":327680}"
  
  $BIN/libuz -s "$OBFS" --config "$CONFIG" >> $LOG 2>&1 &
done

sleep 2

# 3. START LOAD BALANCER (Port 7777)
echo "Starting Load Balancer on 7777..." >> $LOG
$BIN/libload -lport 7777 -tunnel 127.0.0.1:1080 127.0.0.1:1081 127.0.0.1:1082 127.0.0.1:1083 >> $LOG 2>&1 &

sleep 1

# 4. CEK STATUS
if pgrep -f libload > /dev/null; then
  echo "SUCCESS: Proxy jalan di 127.0.0.1:7777"
else
  echo "FAILED: Gagal start. Cek $LOG"
fi