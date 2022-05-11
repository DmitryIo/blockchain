// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract SimpleStorage {
    // this will be get initializet to 0
    uint256 favouriteNumber;
    bool favouriteBool;

    struct People {
        uint256 favouriteNumber;
        string name;
    }
    // dynamic array
    People[] public people;

    mapping(string => uint256) public nameToFavouriteNumber;

    function store(uint256 _favouriteNumber) public returns (uint256) {
        favouriteNumber = _favouriteNumber;
        return _favouriteNumber;
    }

    // view просто для просмотра состояния блокчейна
    // pure для какой-то математики
    function viewNumber() public view returns (uint256) {
        return favouriteNumber;
    }

    function doubleNumber(uint256 _favouriteNumber)
        public
        view
        returns (uint256)
    {
        return favouriteNumber + _favouriteNumber;
    }

    // storage означает хранить переменную после execution
    // memory означает хранить переменную только на время обработки

    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        //people.push(People({favouriteNumber : _favouriteNumber, name: _name}));
        people.push(People(_favouriteNumber, _name));
        nameToFavouriteNumber[_name] = _favouriteNumber;
    }
}
