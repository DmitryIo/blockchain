from lib2to3.pgen2.literals import simple_escapes
from brownie import SimpleStorage, accounts, config


def read_contract():
    simple_storage = SimpleStorage[-1]
    # ABI
    # Address
    print(simple_storage.viewNumber())


def main():
    read_contract()
