from platform import win32_edition
from solcx import compile_standard
import json
from web3 import Web3
from dotenv import load_dotenv
import os

load_dotenv()

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()

compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.6.0",
)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)


# get bytecode

bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi

abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

w3 = Web3(
    Web3.HTTPProvider("https://rinkeby.infura.io/v3/a0eb40ca6c0245e298442678967d2083")
)
chainid = 4
my_address = "0x410c71C23c0E2cA0513f2311a067b815d18a8756"
private_key = os.getenv("PRIVATE_KEY", "0")
# private_key = "0x6e9b762ae28fe8899206f184ce477b4950bc80e0bf4eebbcdbca6cf31d9da3b"

# Create contract in python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# print(SimpleStorage) web3._utils.datatypes.Contract
nonce = w3.eth.getTransactionCount(my_address)
# nonce - сколько транзакций было сделано с этого адреса
transaction = SimpleStorage.constructor().buildTransaction(
    {
        "chainId": chainid,
        "from": my_address,
        "nonce": nonce,
        "gasPrice": w3.eth.gas_price,
    }
)

signed_transaction = w3.eth.account.sign_transaction(
    transaction, private_key=private_key
)

# Send this signed transaction

print("Deploying contract...")
tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print("Deployed contract!")
# Working with contract
# Contract Address
# Contract ABI

simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

# Calling View function from contract
# Call -> Simulate the call and getting a return value (dont make change to blockchain)
# Transact -> Actually make a state change
print(simple_storage.functions.viewNumber().call())
# print(simple_storage.functions.store(15).call())
# print(simple_storage.functions.viewNumber().call())

print("Updating contact...")
store_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "chainId": chainid,
        "from": my_address,
        "nonce": nonce + 1,
        "gasPrice": w3.eth.gas_price,
    }
)
signed_store_transaction = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)

tx_store_hash = w3.eth.send_raw_transaction(signed_store_transaction.rawTransaction)
tx_store_receipt = w3.eth.wait_for_transaction_receipt(tx_store_hash)
print("Updated contract!")

print(simple_storage.functions.viewNumber().call())
