import 'message.dart';
import 'package:equatable/equatable.dart';

abstract class PartialMessage extends Equatable {
  const PartialMessage({
    required this.authorId,
    required this.type,
  });

  final String authorId;
  final MessageType type;

  Map<String, Object?> toMap();
}
