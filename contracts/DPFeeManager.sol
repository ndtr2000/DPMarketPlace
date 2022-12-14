// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./libraries/PriceConverter.sol";
import "./DPNFT.sol";
import "./interface/IDPFeeManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract DPFeeManager is Ownable, IDPFeeManager {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _paymentMethods;
    mapping(address => address) private aggregatorV3Address;

    uint256 private _listingPrice = 0.00001 ether;
    uint256 private _listingPriceSecondary = 0.0001 ether;

    address private _charity;
    address private _web3re;

    constructor(address charity_, address web3re_) {
        _charity = charity_;
        _web3re = web3re_;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function updateListingPriceSecondary(
        uint256 listingPriceSecondary
    ) public payable onlyOwner {
        _listingPriceSecondary = listingPriceSecondary;
    }

    function setPaymentMethod(
        address _token,
        address _aggregatorV3Address
    ) external onlyOwner {
        require(
            !_paymentMethods.contains(_token),
            "Payment method already set"
        );
        _paymentMethods.add(_token);
        aggregatorV3Address[_token] = _aggregatorV3Address;
    }

    function removePaymentMethod(address _token) external onlyOwner {
        require(_paymentMethods.contains(_token), "Payment method not set");
        _paymentMethods.remove(_token);
        aggregatorV3Address[_token] = address(0);
    }

    function changeAggregatorAddress(
        address _token,
        address _aggregatorV3Address
    ) external onlyOwner {
        require(_paymentMethods.contains(_token), "Payment method not set");
        aggregatorV3Address[_token] = _aggregatorV3Address;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getFeeInformation(
        address paymentMethod
    ) external view override returns (FeeInformation memory) {
        return
            FeeInformation(
                _charity,
                _web3re,
                aggregatorV3Address[paymentMethod],
                _listingPrice,
                _listingPriceSecondary
            );
    }

    function getCharityAddress() external view override returns (address) {
        return _charity;
    }

    function getWeb3reAddress() external view override returns (address) {
        return _web3re;
    }

    function getPaymentMethods()
        external
        view
        override
        returns (address[] memory)
    {
        return _paymentMethods.values();
    }

    function getPaymentMethodDetail(
        address _token
    ) external view override returns (bool, address) {
        bool isSupported = _paymentMethods.contains(_token);
        return (isSupported, aggregatorV3Address[_token]);
    }

    function getListingPrice() external view override returns (uint256) {
        return _listingPrice;
    }

    function getListingPriceSecondary()
        external
        view
        override
        returns (uint256)
    {
        return _listingPriceSecondary;
    }
}
