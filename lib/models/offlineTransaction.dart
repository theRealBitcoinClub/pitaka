class OfflineTransaction {
    int _id;
    String _timestamp;
    String _mode;
    String _transactionJson;
    double _amount;
    String _txnID;
    String _time;
    String _qrCode;

    OfflineTransaction(
        this._timestamp,
        this._mode,
        this._transactionJson,
        this._amount,
        this._txnID,
        this._time
        this._qrCode
    );

    OfflineTransaction.withId(
        this._id,
        this._timestamp,
        this._mode,
        this._transactionJson,
        this._amount,
        this._txnID,
        this._time
        this._qrCode
    );


    // (Getters) This can be customized depending on your needs
    int get id => _id;
    String get timestamp => _timestamp;
    String get mode => _mode;
    String get transactionJson => _transactionJson;
    double get amount => _amount; 
    String get txnID => _txnID;
    String get time => _time;
    String get qrcode => _qrCode;

    // (Setters) This can be customized depending on your needs
    set timestamp(String value) => this._timestamp = value;
    set mode(String value) => this._mode = value;
    set transactionJson(String value) => this._transactionJson = value;
    set amount(double value) => this._amount = value;
    set txnID(String value) => this._txnID = value;
    set time(String value) => this._time = value;
    set qrcode(String value) => this._qrCode = value;
}