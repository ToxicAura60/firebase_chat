import 'package:equatable/equatable.dart';

class PartialRoom extends Equatable {
  const PartialRoom({
    required this.name,
    this.imageURL,
    required this.userIds,
  });

  final String name;
  final String? imageURL;
  final List<String> userIds;

  @override
  List<Object?> get props => [
        name,
        imageURL,
        userIds,
      ];
}
