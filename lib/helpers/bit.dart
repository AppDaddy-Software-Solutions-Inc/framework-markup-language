// TODO
import 'dart:math';

int _setBit({required int bit, int? value, required bool on})
{
  int myValue = pow(2, bit - 1) as int;
  return on ? (value! | myValue) : (value! - (value & myValue));
}

// TODO
bool isBitSet({int? bit, int? value})
{
  if (bit == null) return false;
  if (value == null) return false;

  int myValue = pow(2, bit - 1) as int;
  return ((value & myValue) == myValue);
}

// TODO
int setBit({required int bit, int? value}) => _setBit(bit: bit, value: value, on: true);

// TODO
int clearBit({required int bit, int? value}) => _setBit(bit: bit, value: value, on: false);
