// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_pane.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReaderPane _$ReaderPaneFromJson(Map<String, dynamic> json) => _ReaderPane(
  paneId: json['paneId'] as String,
  layerId: json['layerId'] as String,
  isVisible: json['isVisible'] as bool? ?? true,
);

Map<String, dynamic> _$ReaderPaneToJson(_ReaderPane instance) =>
    <String, dynamic>{
      'paneId': instance.paneId,
      'layerId': instance.layerId,
      'isVisible': instance.isVisible,
    };
