# NOTE: This is not my script.
# Credits goes to Shrikant at virtuallyvtrue.com
# Link: https://virtuallyvtrue.com/2021/12/29/script-to-obtain-the-placement-of-the-physical-disk-by-naa-on-esxi-hosts/
# Script to obtain the placement of the physical disk by naa on ESXi hosts
# Do not change anything below this line
# --------------------------------------

echo "=============Physical disks placement=============="
echo ""
	
esxcli storage core device list | grep "naa" | awk '{print $1}' | grep "naa" | while read in; do

echo "$in"
esxcli storage core device physical get -d "$in"
sleep 1

echo "===================================================="

done