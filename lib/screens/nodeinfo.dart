class NodeInfo {
  final int id;
  final int totalBlocks;
  final int totalTransactoins;
  final int headers;
  final int blocks;
  final int transactions;
  final int size;
  final int totalQuery; // the number of query including local storage
  final int queryFrom; // the number of received query
  final int queryTo; // the number of send query
  final String timestamp;

  NodeInfo({
    this.id = 0,
    this.totalBlocks = 0,
    this.totalTransactoins = 0,
    this.headers = 0,
    this.blocks = 0,
    this.transactions = 0,
    this.size = 0,
    this.totalQuery = 0,
    this.queryFrom = 0,
    this.queryTo = 0,
    this.timestamp = "",
  });

  factory NodeInfo.fromJson(Map<String, dynamic> json) {
    return NodeInfo(
      id: json['ID'] as int,
      totalBlocks: json['TotalBlocks'] as int,
      totalTransactoins: json['TotalTransactoins'] as int,
      headers: json['Headers'] as int,
      blocks: json['Blocks'] as int,
      transactions: json['Transactions'] as int,
      size: json['Size'] as int,
      totalQuery: json['TotalQuery'] as int,
      queryFrom: json['QueryFrom'] as int,
      queryTo: json['QueryTo'] as int,
      timestamp: json['Timestamp'] as String,
    );
  }
}
