// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResearchAnswer _$ResearchAnswerFromJson(Map<String, dynamic> json) =>
    _ResearchAnswer(
      answer: json['answer'] as String,
      lang: json['lang'] as String,
      citations:
          (json['citations'] as List<dynamic>?)
              ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      model: json['model'] as String?,
    );

Map<String, dynamic> _$ResearchAnswerToJson(_ResearchAnswer instance) =>
    <String, dynamic>{
      'answer': instance.answer,
      'lang': instance.lang,
      'citations': instance.citations,
      'model': instance.model,
    };
