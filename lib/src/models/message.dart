import 'partial_message.dart';
import 'partial_text.dart';

import 'text_message.dart';
import 'package:equatable/equatable.dart';

enum MessageType {
  text,
}

enum MessageStatus {
  initial,
  delivered,
  error,
  seen,
}

extension MessageTypeX on MessageType {
  bool get isText => this == MessageType.text;
}

extension MessageStatusX on MessageStatus {
  bool get isDelivered => this == MessageStatus.delivered;
  bool get isError => this == MessageStatus.error;
  bool get isSeen => this == MessageStatus.seen;
}

abstract class Message extends Equatable {
  const Message({
    required this.id,
    required this.authorId,
    required this.type,
    required this.status,
    this.repliedMessage,
    this.createdAt,
    this.updatedAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    final type = MessageType.values.firstWhere(
      (e) => e.name == map['type'],
    );

    switch (type) {
      case MessageType.text:
        return TextMessage.fromMap(map);
    }
  }

  factory Message.fromPartial(PartialMessage partialMessage) {
    final type = partialMessage.type;

    switch (type) {
      case MessageType.text:
        return TextMessage.fromPartial(partialMessage as PartialText);
    }
  }

  final String id;
  final String authorId;
  final MessageType type;
  final MessageStatus status;
  final Message? repliedMessage;
  final int? createdAt;
  final int? updatedAt;

  Message copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    String? authorId,
    MessageStatus? status,
    Message? repliedMessage,
  });

  Map<String, Object?> toMap();
}
