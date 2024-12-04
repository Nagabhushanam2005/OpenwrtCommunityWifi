## BATMAN-ADV with namespaces

To check how the batman-adv routing works, we can create a simple network with namespaces.

## Requirements

- batman-adv module installed.
- ip-full package installed.
- veth module installed.

## Setting up the network with static IP addresses

1. Make sure no existing namespaces are present.

    ```bash
    ip netns list
    ```

    If there are any namespaces present, delete them using the following command:

    ```bash
    ip netns del <namespace>
    ```
    or run the following script:

    ```bash
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
    ```



2. Create three namespaces: `node1`, `node2`, and `node3`.

    ```bash
    ip netns add node1
    ip netns add node2
    ip netns add node3
    ```
3. Create veth pairs and assign them to the namespaces.

    ```bash
    ip link add veth1 type veth peer name veth2
    ip link add veth3 type veth peer name veth4
    ```

4. Assign the veth interfaces to the namespaces.

    ```bash
    ip link set veth1 netns node1
    ip link set veth2 netns node2
    ip link set veth3 netns node2
    ip link set veth4 netns node3
    ```

5. Set up the interfaces in the namespaces.

    ```bash
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
    ```

6. Set up the IP addresses in the namespaces.

    ```bash
    ip netns exec node1 ip addr add 192.168.1.1/24 dev bat0
    ip netns exec node2 ip addr add 192.168.1.2/24 dev bat0
    ip netns exec node3 ip addr add 192.168.1.3/24 dev bat0
    ```

7. Wait for the batman-adv protocol to converge.

    ```bash
    sleep 20
    ```


8. Check the originators table in `node1`, `node2`, and `node3`.

    ```bash
    ip netns exec node1 batctl o
    ip netns exec node2 batctl o
    ip netns exec node3 batctl o
    ```
9. Ping the other nodes from `node1`.

    ```bash
    ip netns exec node1 ping -c 4 192.168.1.2
    ip netns exec node1 ping -c 4 192.168.1.3
    ```

10. Run cleanup again to delete the namespaces and veth interfaces.

    ```bash
    cleanup
    ```

## Output

The output of the `batctl o` command will show the originators table of the nodes. The output of the `ping` command will show the connectivity between the nodes.

The script should output something similar to the following:

```bash
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=64 time=1024 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=64 time=0.028 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=64 time=0.107 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=64 time=0.117 ms

--- 192.168.1.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3072ms
rtt min/avg/max/mdev = 0.028/256.001/1023.755/443.262 ms
PING 192.168.1.3 (192.168.1.3) 56(84) bytes of data.
64 bytes from 192.168.1.3: icmp_seq=1 ttl=64 time=0.168 ms
64 bytes from 192.168.1.3: icmp_seq=2 ttl=64 time=0.135 ms
64 bytes from 192.168.1.3: icmp_seq=3 ttl=64 time=0.126 ms
64 bytes from 192.168.1.3: icmp_seq=4 ttl=64 time=0.138 ms

--- 192.168.1.3 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3066ms
rtt min/avg/max/mdev = 0.126/0.141/0.168/0.015 ms
PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.111 ms
64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.140 ms
64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.101 ms
64 bytes from 192.168.1.1: icmp_seq=4 ttl=64 time=0.136 ms

--- 192.168.1.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3065ms
rtt min/avg/max/mdev = 0.101/0.122/0.140/0.016 ms
```

And the output of the `batctl o` commands will show the originators table of the nodes:

```bash
[B.A.T.M.A.N. adv 2024.0, MainIF/MAC: veth1/7a:12:b1:2e:b3:77 (bat0/4a:09:fb:20:0b:d5 BATMAN_IV)]
   Originator        last-seen (#/255) Nexthop           [outgoingIF]
 * 0a:cd:4b:0d:3a:80    0.327s   (231) 0a:cd:4b:0d:3a:80 [     veth1]
 * f6:bd:4c:6f:5d:ce    0.215s   (180) 0a:cd:4b:0d:3a:80 [     veth1]

[B.A.T.M.A.N. adv 2024.0, MainIF/MAC: veth2/0a:cd:4b:0d:3a:80 (bat0/92:d3:f9:e2:a7:8a BATMAN_IV)]
   Originator        last-seen (#/255) Nexthop           [outgoingIF]
 * 7a:12:b1:2e:b3:77    0.335s   (231) 7a:12:b1:2e:b3:77 [     veth2]
 * f6:bd:4c:6f:5d:ce    0.335s   (231) f6:bd:4c:6f:5d:ce [     veth3]

[B.A.T.M.A.N. adv 2024.0, MainIF/MAC: veth4/f6:bd:4c:6f:5d:ce (bat0/aa:c0:86:76:33:74 BATMAN_IV)]
   Originator        last-seen (#/255) Nexthop           [outgoingIF]
 * 0a:cd:4b:0d:3a:80    0.345s   (230) 82:36:e4:78:4c:ec [     veth4]
 * 7a:12:b1:2e:b3:77    0.241s   (180) 82:36:e4:78:4c:ec [     veth4]
 * 82:36:e4:78:4c:ec    0.345s   (231) 82:36:e4:78:4c:ec [     veth4]
```

## Script

This [script](/AdHoc/batman_netns.sh) demonstrates how to set up a simple network using batman-adv and namespaces. It creates three nodes with static IP addresses and shows the connectivity between them using the `ping` command. The `batctl o` command displays the originators table of the nodes, showing the routing information in the network. This setup can be used to experiment with batman-adv and understand how it works in a controlled environment.
