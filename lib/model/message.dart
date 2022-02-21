class Message {
  late String address;
  late String name;
  late String message;
  DateTime createdTime = DateTime.now();
  int clapCount = 0;
  String? recipient;

  Message({
    required this.address,
    required this.name,
    required this.message,
    required this.createdTime,
  });
}
