import 'message.dart';
import 'partial_message.dart';

class PartialText extends PartialMessage {
  const PartialText({
    required super.authorId,
    required this.text,
  }) : super(type: MessageType.text);

  final String text;

  @override
  Map<String, Object?> toMap() {
    final map = <String, dynamic>{};
    map['authorId'] = authorId;
    map['text'] = text;
    map['type'] = type.name;
    return map;
  }

  @override
  List<Object?> get props => [
        authorId,
        text,
        type,
      ];
}
