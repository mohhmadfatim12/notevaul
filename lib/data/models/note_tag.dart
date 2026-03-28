/// Model representing many-to-many relationship between Note and Tag.
class NoteTagModel {
  final String noteId;
  final String tagId;

  const NoteTagModel({
    required this.noteId,
    required this.tagId,
  });

  factory NoteTagModel.fromMap(Map<String, dynamic> map) {
    return NoteTagModel(
      noteId: map['note_id'] as String,
      tagId: map['tag_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note_id': noteId,
      'tag_id': tagId,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory NoteTagModel.fromJson(Map<String, dynamic> json) =>
      NoteTagModel.fromMap(json);
}
