// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Citation _$CitationFromJson(Map<String, dynamic> json) => _Citation(
  uid: json['uid'] as String,
  ref: json['ref'] as String,
  title: json['title'] as String?,
  kind: json['kind'] as String? ?? 'canon',
  snippet: json['snippet'] as String?,
);

Map<String, dynamic> _$CitationToJson(_Citation instance) => <String, dynamic>{
  'uid': instance.uid,
  'ref': instance.ref,
  'title': instance.title,
  'kind': instance.kind,
  'snippet': instance.snippet,
};
