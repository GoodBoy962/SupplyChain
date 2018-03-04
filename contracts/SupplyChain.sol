pragma solidity ^0.4.20;

contract SupplyChain {

    mapping (bytes => ProviderRecord) providerRecords;
    mapping (bytes => DistributorIncomingRecord) distributorIncomingRecords;
    mapping (bytes => DistributorShipRecord) distributorShipRecords;
    mapping (bytes => TransporterRecord) transporterRecords;
    mapping (bytes => CustomerIncomingRecord) customerIncomingRecords;
    mapping (bytes => QualityCheckRecord) qualityCheckRecords;

    modifier isUniqueId(bytes _id) {
        require(providerRecords[_id].provider == address(0));
        _;
    }

    modifier isDistributor(bytes _id, address _distributor) {
        require(providerRecords[_id].distributor == _distributor);
        _;
    }

    modifier isWarehousing(bytes _id) {
        require(bytes(distributorIncomingRecords[_id].nomenclature).length != 0);
        _;
    }

    modifier isTransporter(bytes _id, address _transporter) {
        require(distributorShipRecords[_id].transporter == _transporter);
        _;
    }

    modifier isCustomer(bytes _id, address _customer) {
        require(distributorShipRecords[_id].customer == msg.sender);
        _;
    }

    modifier isTransportered(bytes _id) {
        require(bytes(transporterRecords[_id].batch).length != 0);
        _;
    }

    modifier isReceived(bytes _id) {
        require(bytes(customerIncomingRecords[_id].nomenclature).length != 0);
        _;
    }

    //TODO structures non-address data can ve transformer to simple string with serialized data
    struct ProviderRecord {
        address provider;
        uint date;
        string nomenclature;
        uint amount;
        string batch;
        string characteristics;
        address distributor;
    }

    struct DistributorIncomingRecord {
        uint date;
        string nomenclature;
        uint amount;
        string batch;
        string characteristics;
    }

    struct DistributorShipRecord {
        uint date;
        string nomenclature;
        uint amount;
        string batch;
        string characteristics;
        address transporter;
        address customer;
    }

    struct TransporterRecord {
        string batch;
        string route;
        string driver;
        string conditions;
    }

    struct CustomerIncomingRecord {
        uint date;
        string nomenclature;
        uint amount;
        string batch;
    }

    struct QualityCheckRecord {
        uint date;
        string nomenclature;
        uint amount;
        string batch;
        string characteristics;
    }

    function createOrder(
        bytes _id,
        string _nomenclature,
        uint _amount,
        string _batch,
        string _characteristics,
        address _distributor
    ) public isUniqueId(_id){
        providerRecords[_id] = ProviderRecord({
            provider: msg.sender,
            date: now,
            nomenclature: _nomenclature,
            amount: _amount,
            batch: _batch,
            characteristics: _characteristics,
            distributor: _distributor
        });
    }

    function warehouseByDistributor(
        bytes _id,
        string _nomenclature,
        uint _amount,
        string _batch,
        string _characteristics
    ) public isDistributor(_id, msg.sender) {
        distributorIncomingRecords[_id] = DistributorIncomingRecord({
           date: now,
           nomenclature: _nomenclature,
           amount: _amount,
           batch: _batch,
           characteristics: _characteristics
        });
    }

    function shipByDistributor(
        bytes _id,
        string _nomenclature,
        uint _amount,
        string _batch,
        string _characteristics,
        address _transporter,
        address _customer
    ) public isDistributor(_id, msg.sender) isWarehousing(_id) {
        distributorShipRecords[_id] = DistributorShipRecord({
           date: now,
           nomenclature: _nomenclature,
           amount: _amount,
           batch: _batch,
           characteristics: _characteristics,
           transporter: _transporter,
           customer: _customer
        });
    }

    function transport(
        bytes _id,
        string _batch,
        string _route,
        string _driver,
        string _conditions
    ) public isTransporter(_id, msg.sender) {
        transporterRecords[_id] = TransporterRecord({
           batch: _batch,
           route: _route,
           driver: _driver,
           conditions: _conditions
        });
    }

    function warehouseByCustomer(
        bytes _id,
        string _nomenclature,
        uint _amount,
        string _batch
    ) public isCustomer(_id, msg.sender) isTransportered(_id) {
        customerIncomingRecords[_id] = CustomerIncomingRecord({
            date: now,
            nomenclature: _nomenclature,
            amount: _amount,
            batch: _batch
        });
    }

    function checkQuality(
        bytes _id,
        string _nomenclature,
        uint _amount,
        string _batch,
        string _characteristics
    ) public isCustomer(_id, msg.sender) isReceived(_id) {
        qualityCheckRecords[_id] = QualityCheckRecord({
            date: now,
            nomenclature: _nomenclature,
            amount: _amount,
            batch: _batch,
            characteristics: _characteristics
        });
        //TODO if ok => pay
    }

    function getProviderRecord(
        bytes _id
    ) public constant returns(address, uint, string, uint, string, string, address) {
        ProviderRecord memory r = providerRecords[_id];
        return (r.provider, r.date, r.nomenclature, r.amount, r.batch, r.characteristics, r.distributor);
    }

    function getDistributorIncomingRecord(
        bytes _id
    ) public constant returns(uint, string, uint, string, string) {
        DistributorIncomingRecord memory r = distributorIncomingRecords[_id];
        return (r.date, r.nomenclature, r.amount, r.batch, r.characteristics);
    }

    function getDistributorShipRecord(
        bytes _id
    ) public constant returns(uint, string, uint, string, string, address, address) {
        DistributorShipRecord memory r = distributorShipRecords[_id];
        return (r.date, r.nomenclature, r.amount, r.batch, r.characteristics, r.transporter, r.customer);
    }

    function getTransporterRecord(
        bytes _id
    ) public constant returns(string, string, string, string) {
        TransporterRecord memory r = transporterRecords[_id];
        return (r.batch, r.route, r.driver, r.conditions);
    }

    function getCustomerIncomingRecord(
        bytes _id
    ) public constant returns(uint, string, uint, string) {
       CustomerIncomingRecord memory r = customerIncomingRecords[_id];
        return (r.date, r.nomenclature, r.amount, r.batch);
    }

    function getQualityCheckRecord(
        bytes _id
    ) public constant returns(uint, string, uint, string, string) {
        QualityCheckRecord memory r = qualityCheckRecords[_id];
        return (r.date, r.nomenclature, r.amount, r.batch, r.characteristics);
    }

}
