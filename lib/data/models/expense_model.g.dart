// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      userId: fields[1] as String,
      amount: fields[2] as double,
      category: fields[3] as String,
      description: fields[4] as String,
      date: fields[5] as DateTime,
      isTaxDeductible: fields[6] as bool,
      receiptPath: fields[7] as String?,
      receiptUrl: fields[8] as String?,
      merchantName: fields[9] as String?,
      taxYear: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      isRecurring: fields[13] as bool,
      recurringFrequency: fields[14] as String?,
      paymentMethod: fields[15] as String?,
      vatAmount: fields[16] as double?,
      panNumber: fields[17] as String?,
      billNumber: fields[18] as String?,
      notes: fields[19] as String?,
      tags: (fields[20] as List?)?.cast<String>(),
      isVerified: fields[21] as bool,
      isReimbursable: fields[22] as bool,
      isReimbursed: fields[23] as bool,
      metadata: (fields[24] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.isTaxDeductible)
      ..writeByte(7)
      ..write(obj.receiptPath)
      ..writeByte(8)
      ..write(obj.receiptUrl)
      ..writeByte(9)
      ..write(obj.merchantName)
      ..writeByte(10)
      ..write(obj.taxYear)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.isRecurring)
      ..writeByte(14)
      ..write(obj.recurringFrequency)
      ..writeByte(15)
      ..write(obj.paymentMethod)
      ..writeByte(16)
      ..write(obj.vatAmount)
      ..writeByte(17)
      ..write(obj.panNumber)
      ..writeByte(18)
      ..write(obj.billNumber)
      ..writeByte(19)
      ..write(obj.notes)
      ..writeByte(20)
      ..write(obj.tags)
      ..writeByte(21)
      ..write(obj.isVerified)
      ..writeByte(22)
      ..write(obj.isReimbursable)
      ..writeByte(23)
      ..write(obj.isReimbursed)
      ..writeByte(24)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
