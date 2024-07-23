import subprocess
import argparse

# The country_fi_new is for the update-country-ipset.sh script
supported_ipset_names = ["country_fi", "country_fi_new", "app_manager_access", "ssh_access"]

parser = argparse.ArgumentParser(description="Make ipset from IP list")
parser.add_argument('-f', '--file', required=True, type=str, help='Load IP list from this file')
parser.add_argument('-n', '--name', required=True,  type=str, help='Create ipset with name')

args = parser.parse_args()

if args.name not in supported_ipset_names:
    print(f"unsupported name {args.name}")
    exit(1)

try:
    with open(args.file, 'r') as file:
        result1 = subprocess.run(["ipset", "-exist", "create", args.name, "hash:net"])
        if result1.returncode != 0:
            print("Creating IP set failed")
            exit(1)

        for line in file:
            ipLine = line.strip()
            if len(ipLine) != 0:
                result2 = subprocess.run(["ipset", "-exist", "add", args.name, ipLine])
                if result2.returncode != 0:
                    print("Adding IP to IP set failed")
                    exit(1)
except FileNotFoundError:
    print("File not found:", args.name)
    exit(1)
