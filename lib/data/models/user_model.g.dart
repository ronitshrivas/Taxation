// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      phoneNumber: fields[3] as String?,
      panNumber: fields[4] as String?,
      profileImageUrl: fields[5] as String?,
      isMarried: fields[6] as bool,
      address: fields[7] as String?,
      city: fields[8] as String?,
      occupation: fields[9] as String?,
      employerName: fields[10] as String?,
      dateOfBirth: fields[11] as DateTime?,
      currentFiscalYear: fields[12] as String,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      biometricEnabled: fields[15] as bool,
      preferredLanguage: fields[16] as String?,
      preferredDateFormat: fields[17] as String?,
      notificationsEnabled: fields[18] as bool,
      darkModeEnabled: fields[19] as bool,
      remoteAreaCategory: fields[20] as String?,
      basicSalary: fields[21] as double?,
      taxSettings: (fields[22] as Map?)?.cast<String, dynamic>(),
      preferences: (fields[23] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.panNumber)
      ..writeByte(5)
      ..write(obj.profileImageUrl)
      ..writeByte(6)
      ..write(obj.isMarried)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.city)
      ..writeByte(9)
      ..write(obj.occupation)
      ..writeByte(10)
      ..write(obj.employerName)
      ..writeByte(11)
      ..write(obj.dateOfBirth)
      ..writeByte(12)
      ..write(obj.currentFiscalYear)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.biometricEnabled)
      ..writeByte(16)
      ..write(obj.preferredLanguage)
      ..writeByte(17)
      ..write(obj.preferredDateFormat)
      ..writeByte(18)
      ..write(obj.notificationsEnabled)
      ..writeByte(19)
      ..write(obj.darkModeEnabled)
      ..writeByte(20)
      ..write(obj.remoteAreaCategory)
      ..writeByte(21)
      ..write(obj.basicSalary)
      ..writeByte(22)
      ..write(obj.taxSettings)
      ..writeByte(23)
      ..write(obj.preferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
