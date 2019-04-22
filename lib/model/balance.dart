class Balance {
    int id;
    String account;
    String balance;
    String timestamp;
    String signature;
    DateTime datecreated;

    Balance({
        this.id,
        this.account,
        this.balance,
        this.timestamp,
        this.signature,
        this.datecreated
    });

    factory Balance.fromJson(Map<String, dynamic> data) => new Balance(
        id: data["id"],
        account: data["account"],
        timestamp: data["timestamp"],
        signature: data["signature"],
        datecreated: data['datecreated']

    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "account": account,
        "balance": balance,
        "timestamp": timestamp,
        "signature": signature,
        "datecreated": datecreated
    };
}