class OfflineTransaction {
    int _id;
    String _timestamp;
    String _transactionType;
    String _transactionJson;
    double _amount;

    OfflineTransaction(
        this._timestamp,
        this._transactionType,
        this._transactionJson,
        this._amount
    );

    OfflineTransaction.withId(
        this._id,
        this._timestamp,
        this._transactionType,
        this._transactionJson,
        this._amount
    );


    // (Getters) This can be customized depending on your needs
    int get id => _id;
    String get timestamp => _timestamp;
    String get transactionType => _transactionType;
    String get transactionJson => _transactionJson;
    double get amount => _amount; 

    // (Setters) This can be customized depending on your needs
    set timestamp(String value) => this._timestamp = value;
    set transactionType(String value) => this._transactionType = value;
    set transactionJson(String value) => this._transactionJson = value;
    set amount(double value) => this._amount = value;
}