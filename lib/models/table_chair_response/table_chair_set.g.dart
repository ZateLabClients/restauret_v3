// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_chair_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableChairSet _$TableChairSetFromJson(Map<String, dynamic> json) =>
    TableChairSet(
      tableId: json['table_id'] as int?,
      tableShape: json['tableShape'] as int?,
      room_id: json['room_id'] as int?,
      roomName: json['roomName'] as String?,
      leftChairCount: json['leftChairCount'] as int?,
      rightChairCount: json['rightChairCount'] as int?,
      topChairCount: json['topChairCount'] as int?,
      bottomChairCount: json['bottomChairCount'] as int?,
      createdAt: json['createdAt'] as String?,
    )..tableNumber = json['tableNumber'] as int?;

Map<String, dynamic> _$TableChairSetToJson(TableChairSet instance) =>
    <String, dynamic>{
      'table_id': instance.tableId,
      'tableShape': instance.tableShape,
      'room_id': instance.room_id,
      'roomName': instance.roomName,
      'tableNumber': instance.tableNumber,
      'leftChairCount': instance.leftChairCount,
      'rightChairCount': instance.rightChairCount,
      'topChairCount': instance.topChairCount,
      'bottomChairCount': instance.bottomChairCount,
      'createdAt': instance.createdAt,
    };
