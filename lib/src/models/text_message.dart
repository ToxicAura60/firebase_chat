import 'partial_text.dart';
import 'message.dart';

class TextMessage extends Message {
  const TextMessage({
    required super.id,
    required super.authorId,
    required this.text,
    required super.status,
    super.repliedMessage,
    super.createdAt,
    super.updatedAt,
  }) : super(type: MessageType.text);

  final String text;

  @override
  Message copyWith({
    String? id,
    String? authorId,
    String? text,
    MessageStatus? status,
    Message? repliedMessage,
    int? createdAt,
    int? updatedAt,
  }) {
    return TextMessage(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      status: status ?? this.status,
      repliedMessage: repliedMessage ?? this.repliedMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['authorId'] = authorId;
    map['text'] = text;
    map['type'] = type.name;
    map['status'] = status.name;
    map['repliedMessage'] = repliedMessage?.toMap();
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    return map;
  }

  factory TextMessage.fromMap(
    Map<dynamic, dynamic> map,
  ) {
    return TextMessage(
      id: map['id'],
      authorId: map['authorId'],
      text: map['text'],
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      repliedMessage: map['repliedMessage'] == null
          ? null
          : Message.fromMap(map['repliedMessage']),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory TextMessage.fromPartial(PartialText partialText) {
    return TextMessage(
      id: '',
      status: MessageStatus.initial,
      authorId: partialText.authorId,
      text: partialText.text,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        authorId,
        text,
        status,
        repliedMessage,
      ];
}
