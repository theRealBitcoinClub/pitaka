class OfflineTransaction {
    int id;
    String timestamp;
    String transactionType;

    OfflineTransaction({
        this.id,
        this.timestamp,
        this.transactionType
    });

    factory OfflineTransaction.fromJson(Map<String, dynamic> data) => new OfflineTransaction(
        id: data["id"],
        timestamp: data["timestamp"],
        transactionType: data["transactionType"],

    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "timestamp": timestamp,
        "signature": transactionType
    };
}