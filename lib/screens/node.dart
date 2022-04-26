class Node {
  final String mode;
  final int sc;
  final String ip;
  final int port;
  final String hash;
  final bool isSC;
  final List<Node> childNodes;

  Node({
    this.mode = "",
    this.sc = 0,
    this.ip = "",
    this.port = 0,
    this.hash = "",
    this.isSC = false,
    this.childNodes = const <Node>[],
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      mode: json['mode'] as String,
      sc: json['storage_class'] as int,
      ip: json['ip'] as String,
      port: json['port'] as int,
      hash: json['hash'] as String,
    );
  }

  @override
  String toString() {
    return '{mode: $mode, SC: $sc, IP:$ip, Port:$port, Hash:$hash}';
  }
}
