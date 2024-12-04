
cleanup() {
    # Delete existing namespaces
    for ns in $(ip netns list | awk '{print $1}'); do
        ip netns del "$ns"
    done
    # Delete any existing veth interfaces
    for iface in $(ip -o link show | awk -F': ' '/veth/ {print $2}'); do
        ip link delete "$iface" 2>/dev/null
    done
}

cleanup

ip netns add node1
ip netns add node2
ip netns add node3

ip link add veth1 type veth peer name veth2
ip link add veth3 type veth peer name veth4

ip link set veth1 netns node1
ip link set veth2 netns node2
ip link set veth3 netns node2
ip link set veth4 netns node3


ip netns exec node1 ip link set lo up
ip netns exec node1 ip link set veth1 up
ip netns exec node1 batctl if add veth1
ip netns exec node1 ip link set bat0 up

ip netns exec node2 ip link set lo up
ip netns exec node2 ip link set veth2 up
ip netns exec node2 batctl if add veth2
ip netns exec node2 ip link set veth3 up
ip netns exec node2 batctl if add veth3
ip netns exec node2 ip link set bat0 up


ip netns exec node3 ip link set lo up
ip netns exec node3 ip link set veth4 up
ip netns exec node3 batctl if add veth4
ip netns exec node3 ip link set bat0 up


ip netns exec node1 ip addr add 192.168.1.1/24 dev bat0
ip netns exec node2 ip addr add 192.168.1.2/24 dev bat0
ip netns exec node3 ip addr add 192.168.1.3/24 dev bat0

pinger(){
ip netns exec node1 ping -c 4 192.168.1.2
ip netns exec node2 ping -c 4 192.168.1.3
ip netns exec node3 ping -c 4 192.168.1.1
}

bato(){
ip netns exec node1 batctl o
ip netns exec node1 batctl cl
ip netns exec node1 batctl n
ip netns exec node2 batctl o
ip netns exec node1 batctl cl
ip netns exec node1 batctl n
ip netns exec node3 batctl o
ip netns exec node1 batctl cl
ip netns exec node1 batctl n

}
sleep 30
pinger
bato
cleanup