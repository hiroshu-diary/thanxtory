
class Post {
  late String serverId;
  late String receiverId;
  late String content;
  late DateTime createdAt;
  late int clapCount;

  Post({
    required this.serverId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.clapCount,
  });
}
