import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexuschat_app/features/profile/domain/models/user_profile.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String id,
    required UserProfile user,
    required DateTime addedAt,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}
