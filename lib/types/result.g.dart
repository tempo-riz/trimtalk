// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResultAdapter extends TypeAdapter<Result> {
  @override
  final int typeId = 1;

  @override
  Result read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Result(
      date: fields[0] as String,
      duration: fields[1] as String,
      path: fields[2] as String,
      filename: fields[3] as String,
      transcript: fields[4] as String?,
      summary: fields[5] as String?,
      loadingTranscript: fields[6] as bool,
      loadingSummary: fields[7] as bool,
      sender: fields[8] as String?,
      groupId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Result obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.filename)
      ..writeByte(4)
      ..write(obj.transcript)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.loadingTranscript)
      ..writeByte(7)
      ..write(obj.loadingSummary)
      ..writeByte(8)
      ..write(obj.sender)
      ..writeByte(9)
      ..write(obj.groupId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
