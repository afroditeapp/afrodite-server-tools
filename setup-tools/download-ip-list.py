import requests
import ipaddress
import argparse
import os

supported_country = "fi"

parser = argparse.ArgumentParser(description="Fetch IP address list for country and save it")
parser.add_argument("-f", "--file", required=True, type=str, help="Save list of IP address ranges here")
parser.add_argument("-c", "--country", required=True,  type=str, help="Specify country code")

args = parser.parse_args()

if args.country != supported_country:
    print(f"unsupported country {args.country}")

# https://stat.ripe.net/docs/02.data-api/country-resource-list.html
response = requests.get(f"https://stat.ripe.net/data/country-resource-list/data.json?resource={args.country}")
ip_list = response.json()["data"]["resources"]["ipv4"]

for ip in ip_list:
    startEnd = ip.split("-")

    try:
        if len(startEnd) == 2:
            ipaddress.IPv4Network(startEnd[0])
            ipaddress.IPv4Network(startEnd[1])
        else:
            ipaddress.IPv4Network(ip)
    except ipaddress.AddressValueError:
        print(f"Error: invalid IP address")
        exit(-1)

if os.path.isfile(args.file):
    print("Error: file already exists")
    exit(-1)

with open(args.file, "w") as file:
    file.writelines(ip + "\n" for ip in ip_list)
