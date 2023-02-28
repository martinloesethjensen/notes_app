import 'package:isar/isar.dart';

part 'search.g.dart';

@Collection(accessor: 'searches')
class Search {
  Id id = Isar.autoIncrement;

  late String query;

  DateTime dateTime = DateTime.now().toUtc();
}
