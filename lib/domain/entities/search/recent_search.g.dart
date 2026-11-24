// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecentSearch _$RecentSearchFromJson(Map<String, dynamic> json) =>
    _RecentSearch(
      queryText: json['queryText'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$RecentSearchToJson(_RecentSearch instance) =>
    <String, dynamic>{
      'queryText': instance.queryText,
      'timestamp': instance.timestamp.toIso8601String(),
    };
