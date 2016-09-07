# Redis cluster doesn't play well with NAT'd environments (e.g. docker-machine) -
# have to explicitly advertise externally routable IP if NAT'd. After
# https://github.com/antirez/redis/issues/2527, announce ip/port can be used
IP=$REDIS_CLUSTER_ADVERTISED_IP

if [ -z "$IP" ]; then
  echo "REDIS_CLUSTER_ADVERTISED_IP not provided. Exiting."
  exit 1
fi

echo "Using cluster bind IP $IP"

# Check if bind address has been added yet, only add on initial container start to
# avoid duplicates on container restarts
bind_line=`grep bind /redis-conf/7000/redis.conf`
if [ -z "$bind_line" ]; then
  for PORT in `seq 7000 7005`; do
    CONFIG="/redis-conf/$PORT/redis.conf"
    TMPFILE="/tmp/${PORT}_redis.conf"
    # Prepend bind address to beginning of config file using a temp file
    echo "bind $IP" | cat - "$CONFIG" > "$TMPFILE" && mv "$TMPFILE" "$CONFIG"
  done
fi

supervisord
sleep 3

echo "yes" | ruby /redis/src/redis-trib.rb create --replicas 1 ${IP}:7000 ${IP}:7001 ${IP}:7002 ${IP}:7003 ${IP}:7004 ${IP}:7005
tail -f /var/log/supervisor/redis-1.log
