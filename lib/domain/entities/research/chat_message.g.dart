// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  role: json['role'] as String,
  content: json['content'] as String,
  citations:
      (json['citations'] as List<dynamic>?)
          ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  model: json['model'] as String?,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'citations': instance.citations,
      'model': instance.model,
    };
