class NodeInfo {
  final int ID;
  final int TotalBlocks;
  final int TotalTransactoins;
  final int Headers;
  final int Blocks;
  final int Transactions;
  final int Size;
  final int TotalQuery; // the number of query including local storage
  final int QueryFrom; // the number of received query
  final int QueryTo; // the number of send query
  final String Timestamp;

  NodeInfo({
    this.ID = 0,
    this.TotalBlocks = 0,
    this.TotalTransactoins = 0,
    this.Headers = 0,
    this.Blocks = 0,
    this.Transactions = 0,
    this.Size = 0,
    this.TotalQuery = 0,
    this.QueryFrom = 0,
    this.QueryTo = 0,
    this.Timestamp = "",
  });

  factory NodeInfo.fromJson(Map<String, dynamic> json) {
    return NodeInfo(
      ID: json['ID'] as int,
      TotalBlocks: json['TotalBlocks'] as int,
      TotalTransactoins: json['TotalTransactoins'] as int,
      Headers: json['Headers'] as int,
      Blocks: json['Blocks'] as int,
      Transactions: json['Transactions'] as int,
      Size: json['Size'] as int,
      TotalQuery: json['TotalQuery'] as int,
      QueryFrom: json['QueryFrom'] as int,
      QueryTo: json['QueryTo'] as int,
      Timestamp: json['Timestamp'] as String,
    );
  }
}
