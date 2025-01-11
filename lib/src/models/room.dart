import 'partial_room.dart';
import 'package:equatable/equatable.dart';
import 'message.dart';

class Room extends Equatable {
  const Room({
    required this.id,
    required this.name,
    this.imageURL,
    this.lastMessage,
    required this.userIds,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? imageURL;
  final List<dynamic> userIds;
  final Message? lastMessage;
  final int? createdAt;
  final int? updatedAt;

  factory Room.fromMap(Map<dynamic, dynamic> map) {
    return Room(
      id: map['id'],
      name: map['name'],
      imageURL: map['imageURL'],
      lastMessage: map['lastMessage'] == null
          ? null
          : Message.fromMap(map['lastMessage']),
      userIds: map['userIds'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory Room.fromPartial(PartialRoom partialRoom) {
    return Room(
      id: '',
      name: partialRoom.name,
      userIds: partialRoom.userIds,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['imageURL'] = imageURL;
    map['lastMessage'] = lastMessage?.toMap();
    map['userIds'] = userIds;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageURL,
        lastMessage,
        userIds,
        createdAt,
        updatedAt,
      ];
}
