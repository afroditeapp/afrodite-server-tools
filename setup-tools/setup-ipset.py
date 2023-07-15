import subprocess
import argparse

supported_ipset_names = ["country_fi", "app_manager_access", "ssh_access"]

parser = argparse.ArgumentParser(description="Make ipset from IP list")
parser.add_argument('-f', '--file', required=True, type=str, help='Load IP list from this file')
parser.add_argument('-n', '--name', required=True,  type=str, help='Create ipset with name')

args = parser.parse_args()

if args.name not in supported_ipset_names:
    print(f"unsupported name {args.name}")
    exit(1)

try:
    with open(args.file, 'r') as file:
        # Create the set before running this script
        # subprocess.run(["ipset", "create", args.name, "hash:net"])

        for line in file:
            ipLine = line.strip()
            if len(ipLine) != 0:
                subprocess.run(["ipset", "add", args.name, ipLine])
except FileNotFoundError:
    print("File not found:", args.name)
    exit(1)
