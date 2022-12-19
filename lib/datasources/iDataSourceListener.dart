// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../data/data.dart';
import 'iDataSource.dart';

abstract class IDataSourceListener
{
  Future<bool> onDataSourceSuccess(IDataSource source, Data? map);
  onDataSourceException(IDataSource source, Exception exception);
  onDataSourceBusy(IDataSource source, bool busy);
}